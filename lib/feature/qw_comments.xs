#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"


STATIC int (*next_keyword_plugin)(pTHX_ char*, STRLEN, OP**);


STATIC void croak_missing_terminator(pTHX_ I32 edelim) {
#define croak_missing_terminator(a) croak_missing_terminator(aTHX_ a)
   char* s;
   char q;

   if (edelim == -1)
      croak("qw not terminated anywhere before EOF");

   if (isCNTRL(edelim)) {
      s = ""; // ~~~ ^ plus toCTRL(PL_multi_close)
   }
   else {
      s = ""; // ~~~
   }

   q = strchr(s, '"') ? '\'' : '"';
   croak("Can't find qw terminator %c%s%c anywhere before EOF", q, s, q);
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
      buf[0] = c;
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
   OP * list_op = newLISTOP(OP_LIST, 0, NULL, NULL);
   SV * word_sv = newSVpvn("", 0);
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
            warner(packWARN(WARN_QW), "Possible attempt to separate words with commas");
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


STATIC int my_keyword_plugin(pTHX_ char* keyword_ptr, STRLEN keyword_len, OP** op_ptr) {
   if (keyword_len == 2 && keyword_ptr[0] == 'q' && keyword_ptr[1] == 'w') {
      *op_ptr = parse_qw();
      return KEYWORD_PLUGIN_EXPR;
   }

   return next_keyword_plugin(aTHX_ keyword_ptr, keyword_len, op_ptr);
}


// ========================================

MODULE = feature::qw_comments

BOOT:
   next_keyword_plugin = PL_keyword_plugin;
   PL_keyword_plugin = my_keyword_plugin;
