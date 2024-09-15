
// Testar se funciona corretamente o empilhamento de par�metros
// passados por valor ou por refer�ncia.


%{
#include <stdio.h>
#include <ctype.h>
#include <stdlib.h>
#include <string.h>
#include "compiler.h"

int num_vars;

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

programa    :{
             generateCode (NULL, "INPP");
             }
             PROGRAM IDENTIFIER
             OPEN_PARENTHESIS lista_idents CLOSE_PARENTHESIS SEMICOLON
             bloco DOT {
               generateCode (NULL, "PARA");
             }
;

bloco       :
              parte_declara_vars
              {
              }

              comando_composto
              ;




parte_declara_vars:  var
;


var         : { } VAR declara_vars
            |
;

declara_vars: declara_vars declara_var
            | declara_var
;

declara_var : { }
              lista_id_var COLON
              tipo
              { /* AMEM */
              }
              SEMICOLON
;

tipo        : IDENTIFIER
;

lista_id_var: lista_id_var COMMA IDENTIFIER
              { /* insere �ltima vars na tabela de s�mbolos */ }
            | IDENTIFIER { /* insere vars na tabela de s�mbolos */}
;

lista_idents: lista_idents COMMA IDENTIFIER
            | IDENTIFIER
;


comando_composto: T_BEGIN comandos T_END

comandos:
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
