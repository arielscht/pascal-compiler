
// Testar se funciona corretamente o empilhamento de par�metros
// passados por valor ou por refer�ncia.


%{
#include <stdio.h>
#include <ctype.h>
#include <stdlib.h>
#include <string.h>

#include "compiler.h"
#include "stack.h"

#define BUFFER_SIZE 10

int num_vars = 0;
char buffer[BUFFER_SIZE];

%}

%token PROGRAM OPEN_PARENTHESIS CLOSE_PARENTHESIS
%token OPEN_BRACKETS CLOSE_BRACKETS
%token COMMA SEMICOLON COLON DOT
%token T_BEGIN T_END VAR IDENTIFIER ASSIGNMENT
%token LABEL TYPE ARRAY OF PROCEDURE FUNCTION
%token GOTO 
%token IF THEN ELSE NOT OR AND WHILE DO
%token INTDIV PLUS MINUS MULTIPLY DIVIDE

%%

program:
                     {
                        generate_code(NULL, "INPP");
                     }
                     PROGRAM IDENTIFIER
                     OPEN_PARENTHESIS identifiers_list CLOSE_PARENTHESIS SEMICOLON
                     block DOT 
                     {
                        generate_code(NULL, "PARA");
                     }
;

block:
                     vars_declaration
                     {
                     }
                     compound_command
;

vars_declaration: 
                     VAR declare_vars
                     | /* empty */
;

declare_vars: 
                     declare_vars declare_var
                     | declare_var
;

declare_var: 
                     { }
                     var_list COLON
                     type
                     {
                        sprintf(buffer, "AMEM %d", num_vars);
                        generate_code(NULL, buffer);
                        num_vars = 0;
                     }
                     SEMICOLON
;

type: 
                     IDENTIFIER
;

var_list: 
                     var_list COMMA IDENTIFIER
                     { /* insere �ltima vars na tabela de s�mbolos */
                        num_vars += 1;
                     }
                     | IDENTIFIER 
                     { /* insere vars na tabela de s�mbolos */
                        num_vars += 1;
                     }
;

identifiers_list: 
                     identifiers_list COMMA IDENTIFIER
                     | IDENTIFIER
;

compound_command: 
                     T_BEGIN commands T_END

commands:
;

%%

int main (int argc, char** argv) {
   FILE* fp;
   extern FILE* yyin;

   if (argc<2 || argc>2) {
         printf("compiler usage <arq>a %d\n", argc);
         return(-1);
      }

   fp=fopen (argv[1], "r");
   if (fp == NULL) {
      printf("compiler usage <arq>b\n");
      return(-1);
   }


/* -------------------------------------------------------------------
 *  Start symbols table
 * ------------------------------------------------------------------- */

   yyin=fp;
   yyparse();

   return 0;
}
