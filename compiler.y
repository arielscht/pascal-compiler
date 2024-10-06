
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
stack_t *exp_stack;

void print_symbol(void *ptr);
void print_exp_entry(void *ptr);
void add_symbol(symbol_category category, var_type type, char *identifier);
int set_var_types(var_type type);
int (*get_symbol_checker(char *symbol))(void *);
int check_symbol(void *ptr);
symbol_entry *search_var(char *identifier);
int check_exp_type(var_type type);
void add_exp_entry(var_type type);

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
                        stack_print("Table of symbols\n", symbol_table, print_symbol);
                        printf("identifier: %s\n", token);
                        if(strcmp(token, "integer") == 0) {
                           set_var_types(INTEGER);
                           stack_print("Table of symbols\n", symbol_table, print_symbol);
                        } else if(strcmp(token, "boolean") == 0) {
                           set_var_types(BOOLEAN);
                           stack_print("Table of symbols\n", symbol_table, print_symbol);
                        } else {
                           sprintf(buffer, "Unknown type %s", token);
                           print_error(buffer);
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
                        symbol = search_var(token);
                        var_to_assign = symbol;
                     }
                     ASSIGNMENT expression 
                     {
                        sprintf(buffer, "AMRZ %d,%d", var_to_assign->lexical_level, var_to_assign->offset);
                        generate_code(NULL, buffer);
                        exp_entry *entry;
                        entry = (exp_entry *)stack_pop(&exp_stack);
                        if(entry->type != var_to_assign->type) {
                           free(entry);
                           print_error("Type mismatch.");
                        }
                        free(entry);
                     }
;

expression:
                     simple_expression
;

simple_expression:
                     simple_expression PLUS term
                     {
                        check_exp_type(INTEGER);
                        add_exp_entry(INTEGER);
                        generate_code(NULL, "SOMA");
                     }
                     | simple_expression MINUS term
                     {
                        check_exp_type(INTEGER);
                        add_exp_entry(INTEGER);
                        generate_code(NULL, "SUBT");
                     }
                     | term
;

term: 
                     term MULTIPLY factor
                     {
                        check_exp_type(INTEGER);
                        add_exp_entry(INTEGER);
                        generate_code(NULL, "MULT");
                     }
                     | term DIVIDE factor
                     {
                        check_exp_type(INTEGER);
                        add_exp_entry(INTEGER);
                        generate_code(NULL, "DIVI");
                     }
                     | factor
;

factor:
                     NUMBER
                     {
                        add_exp_entry(INTEGER);
                        sprintf(buffer, "CRCT %s", token);
                        generate_code(NULL, buffer);
                     }
                     | IDENTIFIER
                     {
                        symbol_entry *symbol;
                        symbol = search_var(token);
                        add_exp_entry(symbol->type);
                        sprintf(buffer, "CRVL %d,%d", symbol->lexical_level, symbol->offset);
                        generate_code(NULL, buffer);
                     }
;

%%

int check_exp_type(var_type type) {
   exp_entry *left_exp, *right_exp;

   left_exp = (exp_entry *)stack_pop(&exp_stack);
   right_exp = (exp_entry *)stack_pop(&exp_stack);

   if(left_exp->type != type 
      || right_exp->type != type
      || (left_exp->type != right_exp->type)) {
      free(left_exp);
      free(right_exp);
      print_error("Type mysmatch.");
   }

   free(left_exp);
   free(right_exp);
}

symbol_entry *search_symbol(char *identifier) {
   symbol_entry *symbol;
   symbol_to_find = token;
   symbol = (symbol_entry *)stack_search(symbol_table, check_symbol);

   if(symbol == NULL) {
      sprintf(buffer, "%s is not defined.", token);
      print_error(buffer);
   }

   return symbol;
}

symbol_entry *search_var(char *identifier) {
   symbol_entry *symbol;
   symbol = search_symbol(identifier);

   if(symbol && symbol->category != SIMPLE_VAR) {
      sprintf(buffer, "%s is not a simple var.", token);
      print_error(buffer);
   };

   return symbol;
}

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

void add_exp_entry(var_type type) 
{
   exp_entry *entry = malloc(sizeof(exp_entry));
   entry->prev = NULL;
   entry->next = NULL;
   entry->type = type;
   stack_push(&exp_stack, (stack_elem_t *)entry);
}

void add_symbol(symbol_category category, var_type type, char *identifier) {
   symbol_entry *symbol = malloc(sizeof(symbol_entry));
   symbol->prev = NULL;
   symbol->next = NULL;
   symbol->category = category;
   strncpy(symbol->identifier, token, TOKEN_SIZE);
   symbol->offset = offset;
   symbol->lexical_level = lexical_level;
   symbol->type = type;
   stack_push(&symbol_table, (stack_elem_t *)symbol);
}

void print_symbol(void *ptr)
{
    symbol_entry *elem = ptr;

    if (!elem)
        return;

   printf("id: %s, c: %d, t: %d, ll: %d, o: %d\n", elem->identifier, elem->category, elem->type, elem->lexical_level, elem->offset);
}

void print_exp_entry(void *ptr) 
{
   exp_entry *elem = ptr;

   if(!elem) {
      return;
   }

   printf("type: %d\n", elem->type);
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
   exp_stack = malloc(sizeof(stack_t));
   lexical_level = 0;
   offset = 0;


   yyin=fp;
   yyparse();

   free(symbol_table);
   free(exp_stack);

   return 0;
}
