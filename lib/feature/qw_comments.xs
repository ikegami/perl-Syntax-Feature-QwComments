#define PERL_NO_GET_CONTEXT
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"


#define MY_CXT_KEY  "feature::qw_comments::"
#define MY_HINT_KEY "feature::qw_comments::"

typedef struct {
   // Empty
   int dummy;
} my_cxt_t;

START_MY_CXT


// PL_keyword_plugin is truly global (i.e. not per-interpreter or per-thread), so this can be truly global too.
static int (*next_keyword_plugin)(pTHX_ char*, STRLEN, OP**);

// For global hint hash.
static SV* hintkey_sv;


STATIC void croak_missing_terminator(pTHX_ I32 edelim) {
#define croak_missing_terminator(a) croak_missing_terminator(aTHX_ a)
   char* s;
   char q;

   if (edelim == -1)
      Perl_croak(aTHX_ "qw not terminated anywhere before EOF");

   if (isCNTRL_A(edelim)) {
       s = ""; // ~~~ ^ plus toCTRL(edelim)
   }
   else {
      s = ""; // ~~~
   }

   q = strchr(s, '"') ? '\'' : '"';
   Perl_croak(aTHX_ "Can't find qw terminator %c%s%c anywhere before EOF", q, s, q);
}


// sv is assumed to contain a string (and nothing else).
// sv is assumed to have no magic.
STATIC void append_char_to_word(pTHX_ SV* word_sv, UV c) {
#define append_char_to_word(a,b) append_char_to_word(aTHX_ a,b)
   char buf[UTF8_MAXBYTES+1];  // I wonder why the "+ 1".
   STRLEN len;
   if (SvUTF8(word_sv) || c > 255) {
      len = (char*)uvuni_to_utf8((U8*)buf, c) - buf;
      sv_utf8_upgrade_flags_grow(word_sv, 0, len+1);
   } else {
      len = 1;
      buf[0] = (char)c;
   }

   sv_catpvn_nomg(word_sv, buf, len);
}


// sv is assumed to contain a string (and nothing else).
// sv is assumed to have no magic.
// The sv's length is reduced to zero length and the UTF8 flag is turned off.
STATIC void append_word_to_list(pTHX_ OP** list_op_ptr, SV* word_sv) {
#define append_word_to_list(a,b) append_word_to_list(aTHX_ a,b)
   STRLEN len = SvCUR(word_sv);
   if (len) {
      SV* sv_copy = newSV(len);
      sv_copypv(sv_copy, word_sv);
      *list_op_ptr = op_append_elem(OP_LIST, *list_op_ptr, newSVOP(OP_CONST, 0, sv_copy));

      SvCUR_set(word_sv, 0);
      SvUTF8_off(word_sv);
   }
}


// XXX ~~~ croak_missing_terminator causes list_op and word_sv to leak.
STATIC OP * parse_qw(pTHX) {
#define parse_qw() parse_qw(aTHX)
   I32 sdelim;
   I32 edelim;
   IV depth;
   OP* list_op = newLISTOP(OP_LIST, 0, NULL, NULL);
   SV* word_sv = newSVpvn("", 0);
   int warned_comma = !ckWARN(WARN_QW);

   lex_read_space(0);

   sdelim = lex_read_unichar(0);
   if (sdelim == -1)
      croak_missing_terminator(-1);

   { // Find corresponding closing delimiter
      char* p;
      if (sdelim && (p = strchr("([{< )]}> )]}>", sdelim)))
         edelim = *(p + 5);
      else
         edelim = sdelim;
   }

   depth = 1;
   for (;;) {
      I32 c = lex_peek_unichar(0);
      if (c == -1)
         croak_missing_terminator(edelim);
      if (c == edelim) {
         append_word_to_list(&list_op, word_sv);
         lex_read_unichar(0);
         if (!--depth)
            break;
         append_char_to_word(word_sv, c);
      }
      else if (c == sdelim) {
         lex_read_unichar(0);
         ++depth;
         append_char_to_word(word_sv, c);
      }
      else if (c == '\\') {
         lex_read_unichar(0);
         c = lex_peek_unichar(0);
         if (c == -1)
             croak_missing_terminator(edelim);
         if (c != sdelim && c != edelim && c != '\\')
            append_char_to_word(word_sv, '\\');
         lex_read_unichar(0);
         append_char_to_word(word_sv, c);
      }
      else if (c == '#' || isSPACE(c)) {
         append_word_to_list(&list_op, word_sv);
         lex_read_space(0);
      }
      else {
         if (c == ',' && !warned_comma) {
            Perl_warner(aTHX_ packWARN(WARN_QW), "Possible attempt to separate words with commas");
            ++warned_comma;
         }
         lex_read_unichar(0);
         append_char_to_word(word_sv, c);
      }
   }

   SvREFCNT_dec(word_sv);

   list_op->op_flags |= OPf_PARENS;
   return list_op;
}


STATIC int is_pragma_active(pTHX_ SV* hintkey_sv) {
#define is_pragma_active(a) is_pragma_active(aTHX_ a)
   HE* he;
   if (!GvHV(PL_hintgv))
      return 0;

   he = hv_fetch_ent(GvHV(PL_hintgv), hintkey_sv, 0, SvSHARED_HASH(hintkey_sv));
   return he && SvTRUE(HeVAL(he));
}


STATIC void enable_pragma(pTHX_ SV* hintkey_sv) {
#define enable_pragma(a) enable_pragma(aTHX_ a)
   SV* val_sv = newSViv(1);
   HE* he;
   PL_hints |= HINT_LOCALIZE_HH;
   gv_HVadd(PL_hintgv);
   he = hv_store_ent(GvHV(PL_hintgv), hintkey_sv, val_sv, SvSHARED_HASH(hintkey_sv));
   if (he) {
      SV* val = HeVAL(he);
      SvSETMAGIC(val);
   } else {
      SvREFCNT_dec(val_sv);
   }
}


STATIC void disable_pragma(pTHX_ SV* hintkey_sv) {
#define disable_pragma(a) disable_pragma(aTHX_ a)
   if (GvHV(PL_hintgv)) {
      PL_hints |= HINT_LOCALIZE_HH;
      hv_delete_ent(GvHV(PL_hintgv), hintkey_sv, G_DISCARD, SvSHARED_HASH(hintkey_sv));
   }
}


STATIC int my_keyword_plugin(pTHX_ char* keyword_ptr, STRLEN keyword_len, OP** op_ptr) {
   dMY_CXT;

   if (keyword_len == 2 && keyword_ptr[0] == 'q' && keyword_ptr[1] == 'w' && is_pragma_active(hintkey_sv)) {
      *op_ptr = parse_qw();
      return KEYWORD_PLUGIN_EXPR;
   }

   return next_keyword_plugin(aTHX_ keyword_ptr, keyword_len, op_ptr);
}


STATIC void my_cxt_init(pTHX_ pMY_CXT) {
#define my_cxt_init(a) my_cxt_init(aTHX_ a)
   // Empty
}


// ========================================

MODULE = feature::qw_comments   PACKAGE = feature::qw_comments

BOOT:
   {
      MY_CXT_INIT;
      my_cxt_init(aMY_CXT);

      hintkey_sv = newSVpvs_share(MY_HINT_KEY);

      next_keyword_plugin = PL_keyword_plugin;
      PL_keyword_plugin = my_keyword_plugin;
   }

void
CLONE(...)
   CODE:
      MY_CXT_CLONE;
      my_cxt_init(aMY_CXT);

void
import(...)
   PPCODE:
      enable_pragma(hintkey_sv);

void
unimport(...)
   PPCODE:
      disable_pragma(hintkey_sv);
