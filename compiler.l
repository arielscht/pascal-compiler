%{
#include<stdio.h>
#include<string.h>

#include "compiler.h"
#include "compiler.tab.h"

#define PRINT(STR) printf("%s    # %s \n", STR, token);

int num_lines = 1;

%}

line_break [\n]

discard [\t ]+

identifier [a-zA-Z][a-zA-Z0-9]*

numero [0-9]+

comment "(*".*"*)"

%%

{line_break} {num_lines++;}

{discard}

{comment}

program { 
          symbol  = program_symbol;
          strncpy (token, yytext, TOKEN_SIZE);
          PRINT("program ");
          return PROGRAM;
        }

var     { 
          symbol = var_symbol;
          strncpy (token, yytext, TOKEN_SIZE);
          PRINT("var  ");
          return VAR;
        }

begin   { 
          symbol = begin_symbol;
          strncpy (token, yytext, TOKEN_SIZE);
          PRINT("begin ");
          return T_BEGIN;
        }

end     { 
          symbol = end_symbol;
          strncpy (token, yytext, TOKEN_SIZE);
          PRINT("end  ");
          return T_END;
        }

label   { 
          symbol = label_symbol;
          strncpy (token, yytext, TOKEN_SIZE);
          PRINT("label  ");
          return LABEL;
        }

type    { 
          symbol = type_symbol;
          strncpy (token, yytext, TOKEN_SIZE);
          PRINT("type  ");
          return TYPE;
        }

array   { 
          symbol = array_symbol;
          strncpy (token, yytext, TOKEN_SIZE);
          PRINT(" array  ");
          return ARRAY;
        }

of      { 
          symbol = of_symbol;
          strncpy (token, yytext, TOKEN_SIZE);
          PRINT(" of  ");
          return OF;
        }

procedure { 
            symbol = procedure_symbol;
            strncpy (token, yytext, TOKEN_SIZE);
            PRINT("procedure  ");
            return PROCEDURE;
          }
        
function  { 
            symbol = function_symbol;
            strncpy (token, yytext, TOKEN_SIZE);
            PRINT("function  ");
            return FUNCTION;
          }

goto    { 
          symbol = goto_symbol;
          strncpy (token, yytext, TOKEN_SIZE);
          PRINT("goto  ");
          return GOTO;
        }

if      { 
          symbol = if_symbol;
          strncpy (token, yytext, TOKEN_SIZE);
          PRINT("if  ");
          return IF;
        }

then    { 
          symbol = then_symbol;
          strncpy (token, yytext, TOKEN_SIZE);
          PRINT("then  ");
          return THEN;
        }

else    { 
          symbol = else_symbol;
          strncpy (token, yytext, TOKEN_SIZE);
          PRINT("else  ");
          return ELSE;
        }

not     { 
          symbol = not_symbol;
          strncpy (token, yytext, TOKEN_SIZE);
          PRINT(" not  ");
          return NOT;
        }

or      { 
          symbol = or_symbol;
          strncpy (token, yytext, TOKEN_SIZE);
          PRINT(" or  ");
          return OR;
        }

and     { 
          symbol = and_symbol;
          strncpy (token, yytext, TOKEN_SIZE);
          PRINT(" and  ");
          return AND;
        }

while   { 
          symbol = while_symbol;
          strncpy (token, yytext, TOKEN_SIZE);
          PRINT(" while  ");
          return WHILE;
        }

do      { 
          symbol = do_symbol;
          strncpy (token, yytext, TOKEN_SIZE);
          PRINT(" do  ");
          return DO;
        }

div  {
          symbol = int_div_symbol;
          strncpy (token, yytext, TOKEN_SIZE);
          PRINT(" intdiv  ");
          return INTDIV;
        }

:=      { 
          symbol = assignment_symbol;
          strncpy (token, yytext, TOKEN_SIZE);
          PRINT(" assignment  ");
          return ASSIGNMENT;
        }

\;      { 
          symbol = semicolon_symbol;
          strncpy (token, yytext, TOKEN_SIZE);
          PRINT(" semicolon  ");
          return SEMICOLON;
        }

\:      { 
          symbol = colon_symbol;
          strncpy (token, yytext, TOKEN_SIZE);
          PRINT(" colon ");
          return COLON;
        }

\,      { 
          symbol = comma_symbol;
          strncpy (token, yytext, TOKEN_SIZE);
          PRINT(" comma  ");
          return COMMA;
        }


\.      { 
          symbol = dot_symbol;
          strncpy (token, yytext, TOKEN_SIZE);
          PRINT(" dot  ");
          return DOT;
        }

\(      { 
          symbol = open_parenthesis_symbol;
          strncpy (token, yytext, TOKEN_SIZE);
          PRINT(" open_parenthesis  ");
          return OPEN_PARENTHESIS;
        }

\)      { 
          symbol = close_parenthesis_symbol;
          strncpy (token, yytext, TOKEN_SIZE);
          PRINT(" close_parenthesis ");
          return CLOSE_PARENTHESIS;
        }

\[      {
          symbol = open_brackets_symbol;
          strncpy (token, yytext, TOKEN_SIZE);
          PRINT(" open_brackets ");
          return OPEN_BRACKETS;
        }

\]      {
          symbol = close_brackets_symbol;
          strncpy (token, yytext, TOKEN_SIZE);
          PRINT(" close_brackets ");
          return CLOSE_BRACKETS;
        }

\+      {
          symbol = plus_symbol;
          strncpy (token, yytext, TOKEN_SIZE);
          PRINT(" plus ");
          return PLUS;
        }

\-      {
          symbol = minus_symbol;
          strncpy (token, yytext, TOKEN_SIZE);
          PRINT(" minus ");
          return MINUS;
        }

\*      {
          symbol = multiply_symbol;
          strncpy (token, yytext, TOKEN_SIZE);
          PRINT(" multiply ");
          return MULTIPLY;
        }

\/      {
          symbol = div_symbol;
          strncpy (token, yytext, TOKEN_SIZE);
          PRINT(" divide ");
          return DIVIDE;
        }

{identifier} { 
              symbol = identifier_symbol;
              strncpy (token, yytext, TOKEN_SIZE);
              PRINT(" identifier  ");
              return IDENTIFIER;
            }

%%
