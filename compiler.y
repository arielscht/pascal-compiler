
// Testar se funciona corretamente o empilhamento de par�metros
// passados por valor ou por refer�ncia.


%{
#include <stdio.h>
#include <ctype.h>
#include <stdlib.h>
#include <string.h>

#include "compiler.h"
#include "stack.h"

#define BUFFER_SIZE 100

int num_vars = 0;
char buffer[BUFFER_SIZE];
stack_t *symbol_table;

void print_elem(void *ptr);
void add_symbol(symbol_category category, var_type type, char *identifier);
int set_var_types(var_type type);
int (*get_symbol_checker(char *symbol))(void *);
int check_symbol(void *ptr);
char *symbol_to_find;
symbol_entry *var_to_assign;

%}

%token PROGRAM OPEN_PARENTHESIS CLOSE_PARENTHESIS
%token OPEN_BRACKETS CLOSE_BRACKETS
%token COMMA SEMICOLON COLON DOT
%token T_BEGIN T_END VAR IDENTIFIER ASSIGNMENT NUMBER
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
                     {
                        stack_print("Table of symbols\n", symbol_table, print_elem);
                        printf("identifier: %s\n", token);
                        if(strcmp(token, "integer") == 0) {
                           set_var_types(INTEGER);
                           stack_print("Table of symbols\n", symbol_table, print_elem);
                        } else if(strcmp(token, "boolean") == 0) {
                           set_var_types(BOOLEAN);
                           stack_print("Table of symbols\n", symbol_table, print_elem);
                        } else {
                           sprintf(buffer, "Unknown type %s", token);
                           yyerror(buffer);
                        }
                     }
;

var_list: 
                     var_list COMMA IDENTIFIER
                     { /* insere �ltima vars na tabela de s�mbolos */
                        add_symbol(SIMPLE_VAR, UNKNOWN, token);
                        num_vars += 1;
                        offset += 1;
                     }
                     | IDENTIFIER 
                     { /* insere vars na tabela de s�mbolos */
                        add_symbol(SIMPLE_VAR, UNKNOWN, token);
                        num_vars += 1;
                        offset += 1;
                     }
;

identifiers_list: 
                     identifiers_list COMMA IDENTIFIER
                     | IDENTIFIER
;

compound_command: 
                     {
                        lexical_level += 1;
                        offset = 0;
                     }
                     T_BEGIN commands T_END
                     {
                        lexical_level -= 1;
                     }
;

commands:
                     commands command SEMICOLON
                     | command SEMICOLON
;

command:             
                     assignment
;

assignment:
                     IDENTIFIER
                     {
                        symbol_entry *symbol;
                        symbol_to_find = token;
                        symbol = (symbol_entry *)stack_search(symbol_table, check_symbol);

                        if(symbol == NULL) {
                           sprintf(buffer, "%s is not defined.", token);
                           yyerror(buffer);
                        } else {
                           if(symbol->category != SIMPLE_VAR) {
                              sprintf(buffer, "%s is not a simple var.", token);
                              yyerror(buffer);
                           } else {
                              var_to_assign = symbol;
                           }
                        }
                     }
                     ASSIGNMENT expression 
                     {
                        sprintf(buffer, "AMRZ %d,%d", var_to_assign->lexical_level, var_to_assign->offset);
                        generate_code(NULL, buffer);
                     }
;

expression:
                     simple_expression
;

simple_expression:
                     simple_expression PLUS term
                     | simple_expression MINUS term
                     | term
;

term: 
                     term MULTIPLY factor
                     | term DIVIDE factor
                     | factor
;

factor:
                     NUMBER
                     {
                        sprintf(buffer, "CRCT %s", token);
                        generate_code(NULL, buffer);
                     }
                     | IDENTIFIER
;

%%

int check_symbol(void *ptr) {
   symbol_entry *elem = ptr;

   if(strcmp(symbol_to_find, elem->identifier) == 0) {
      return 1;
   }

   return 0;
}

int check_unknown_type(void *ptr) {
   symbol_entry *elem = ptr;

   if(!elem) {
      return 0;
   }

   if(elem->type == UNKNOWN) {
      return 1;
   }

   return 0;
}

int update_type(symbol_entry **symbol, var_type type) { 
   (*symbol)->type = type; 
}

int set_var_types(var_type type) {
   symbol_entry *symbol;

   symbol = (symbol_entry *)stack_search(symbol_table, check_unknown_type);

   while(symbol != NULL) {
      update_type(&symbol, type);
      symbol = (symbol_entry *)stack_search(symbol_table, check_unknown_type);
   }

   return 0;
}

void add_symbol(symbol_category category, var_type type, char *identifier) {
   symbol_entry *symbol = malloc(sizeof(symbol_entry));
   symbol->category = category;
   strncpy(symbol->identifier, token, TOKEN_SIZE);
   symbol->offset = offset;
   symbol->lexical_level = lexical_level;
   symbol->type = type;
   stack_push(&symbol_table, (stack_elem_t *)symbol);
}

void print_elem(void *ptr)
{
    symbol_entry *elem = ptr;

    if (!elem)
        return;

   printf("id: %s, c: %d, t: %d, ll: %d, o: %d\n", elem->identifier, elem->category, elem->type, elem->lexical_level, elem->offset);
}

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
   symbol_table = malloc(sizeof(stack_t));
   lexical_level = 0;
   offset = 0;


   yyin=fp;
   yyparse();

   free(symbol_table);

   return 0;
}
