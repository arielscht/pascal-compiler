%{
#include <stdio.h>
#include <ctype.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

#include "compiler.h"
#include "stack.h"
#include "output_helpers.h"

#define BUFFER_SIZE 200

char buffer[BUFFER_SIZE];
stack_t *symbol_table;
stack_t *exp_stack;
stack_t *block_stack;
stack_t *label_stack;
stack_t *subroutine_call_stack;

void add_var(char *identifier);
symbol_entry *add_subroutine(char *identifier, char *label, symbol_category subroutine_type);
void add_param(char *identifier, passing_type p_type);
int set_symbol_types(char* type);
int set_params_offset();
int (*get_symbol_checker(char *symbol))(void *);
int check_symbol(void *ptr);
int check_symbol_to_remove(void *ptr);
symbol_entry *search_var(char *identifier);
symbol_entry *search_var_or_param(char *identifier) ;
symbol_entry *search_subroutine(char *identifier);
void check_if_procedure();
void check_exp_det_type(var_type type);
void check_exp_types();
void add_exp_entry(var_type type, exp_category category);
void add_block_entry();
void add_labels(int quantity);
void remove_labels(int quantity);
void handle_subroutine_call();
void add_subroutine_call();
void handle_procedure_arg();

int num_labels;
char *symbol_to_find;
char identifier_to_find[TOKEN_SIZE];
passing_type pass_type;
symbol_entry *cur_proc;

%}

%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE

%token PROGRAM OPEN_PARENTHESIS CLOSE_PARENTHESIS
%token OPEN_BRACKETS CLOSE_BRACKETS
%token COMMA SEMICOLON COLON DOT
%token T_BEGIN T_END VAR IDENTIFIER ASSIGNMENT NUMBER
%token LABEL TYPE ARRAY OF PROCEDURE FUNCTION
%token GOTO 
%token IF THEN ELSE NOT OR AND WHILE DO
%token INTDIV PLUS MINUS MULTIPLY DIVIDE
%token EQUAL NOT_EQUAL LESS LESS_EQUAL GREATER_EQUAL GREATER

%%

program:
                     {
                        generate_code(NULL, "INPP");
                     }
                     PROGRAM IDENTIFIER
                     OPEN_PARENTHESIS program_identifiers_list CLOSE_PARENTHESIS SEMICOLON
                     block DOT 
                     {
                        generate_code(NULL, "PARA");
                     }
;

program_identifiers_list:
                     program_identifiers_list COMMA IDENTIFIER
                     | IDENTIFIER
;

block:
                     {
                        add_block_entry();
                        lexical_level += 1;
                     }
                     vars_declaration
                     subroutines_declaration
                     {
                        block_entry *entry = (block_entry *)block_stack->top;
                        label_entry *label = (label_entry *)label_stack->top;

                        if(entry->skip_subroutines == 0) {
                           generate_code(label->label, "NADA");

                           remove_labels(1);
                        }
                     }
                     compound_command
                     {
                        block_entry * entry = (block_entry *)stack_pop(&block_stack);

                        if(entry->num_vars > 0) {
                           sprintf(buffer, "DMEM %d", entry->num_vars);
                           generate_code(NULL, buffer);
                        }

                        free(entry);
                        stack_remove(&symbol_table, check_symbol_to_remove);

                        lexical_level -= 1;
                     }
;

vars_declaration: 
                     VAR declare_vars
                     {
                        block_entry *entry = (block_entry*)block_stack->top;
                        sprintf(buffer, "AMEM %d", entry->num_vars);
                        generate_code(NULL, buffer);
                     }
                     | /* empty */
;

declare_vars: 
                     declare_vars declare_var
                     | declare_var
;

declare_var: 
                     var_list COLON type SEMICOLON
;

type: 
                     IDENTIFIER
                     {
                        set_symbol_types(token);
                     }
;

var_list: 
                     var_list COMMA var_ident
                     | var_ident
                     
;

var_ident:              
                     IDENTIFIER 
                     {
                        add_var(token);
                        block_entry *entry = (block_entry*)block_stack->top;
                        entry->num_vars += 1;
                        entry->offset += 1;
                     }
;

subroutines_declaration:
                     subroutines_declaration subroutine_declaration SEMICOLON
                     | 
                     {
                        block_entry *entry = (block_entry *)block_stack->top;
                        label_entry *label;

                        if(entry->skip_subroutines == 1) {
                           add_labels(1);

                           label = (label_entry *)label_stack->top;

                           sprintf(buffer, "DSVS %s", label->label);
                           generate_code(NULL, buffer);

                           entry->skip_subroutines = 0;
                        }
                     }
                     subroutine_declaration SEMICOLON
                     | /* empty */
;

subroutine_declaration:
                     procedure_declaration
                     | function_declaration
;

procedure_declaration: 
                     PROCEDURE IDENTIFIER
                     {
                        label_entry *entry;

                        add_labels(1);

                        entry = (label_entry *)label_stack->top;
                        cur_proc = add_subroutine(token, entry->label, PROC);

                        sprintf(buffer, "ENPR %d", lexical_level + 1);
                        generate_code(entry->label, buffer);

                        remove_labels(1);
                     }
                     subroutine_parameters SEMICOLON block
                     {
                        symbol_entry *entry = (symbol_entry *)symbol_table->top;

                        sprintf(buffer, "RTPR %d,%d", lexical_level + 1, entry->num_params);
                        generate_code(NULL, buffer);
                     }
;

function_declaration:
                     FUNCTION IDENTIFIER {
                        label_entry *entry;

                        add_labels(1);

                        entry = (label_entry *)label_stack->top;
                        cur_proc = add_subroutine(token, entry->label, FUNC);

                        sprintf(buffer, "ENPR %d", lexical_level + 1);
                        generate_code(entry->label, buffer);

                        remove_labels(1);
                     }
                     subroutine_parameters COLON IDENTIFIER {
                        set_symbol_types(token);
                     } 
                     SEMICOLON block
                     {
                        symbol_entry *entry = (symbol_entry *)symbol_table->top;

                        sprintf(buffer, "RTPR %d,%d", lexical_level + 1, entry->num_params);
                        generate_code(NULL, buffer);
                     }
;

subroutine_parameters:
                     formal_parameters
                     | /* empty */
;

formal_parameters:
                     OPEN_PARENTHESIS formal_parameters_list 
                     {
                        set_params_offset();
                     }
                     CLOSE_PARENTHESIS
;

formal_parameters_list:
                     formal_parameters_list SEMICOLON formal_parameters_section
                     | formal_parameters_section
;

formal_parameters_section:
                     VAR 
                     { 
                        pass_type = REFERENCE;
                     } 
                     param_identifiers_list COLON type
                     | FUNCTION param_identifiers_list COLON type
                     | PROCEDURE param_identifiers_list
                     | 
                     {
                        pass_type = VALUE;
                     }
                     param_identifiers_list COLON type
;

param_identifiers_list: 
                     param_identifiers_list COMMA param_ident
                     | param_ident
;

param_ident:         
                     IDENTIFIER
                     {
                        add_param(token, pass_type);
                     }
;

compound_command: 
                     T_BEGIN commands T_END
;

commands:
                     commands SEMICOLON command
                     | command
;

command:
                     NUMBER SEMICOLON no_label_command
                     | no_label_command
;

no_label_command:             
                     assignment
                     | procedure_call
                     | compound_command 
                     | conditional
                     | loop
                     | /* empty */
;

left_identifier: 
                     IDENTIFIER 
                     {
                        strncpy(identifier_to_find, token, TOKEN_SIZE);
                     }
;  

assignment:
                     left_identifier ASSIGNMENT expression 
                     {
                        symbol_entry *symbol;
                        exp_entry *entry;
                        entry = (exp_entry *)stack_pop(&exp_stack);
                        symbol = search_var_or_param(identifier_to_find);

                        if(entry->type != symbol->type) {
                           print_error("Type mismatch.");
                        }

                        if(symbol->pass_type == REFERENCE) {
                           sprintf(buffer, "ARMI %d,%d", symbol->lexical_level, symbol->offset);
                        } else {
                           sprintf(buffer, "ARMZ %d,%d", symbol->lexical_level, symbol->offset);
                        }

                        generate_code(NULL, buffer);
                        free(entry);
                     }
;

expression:
                     simple_expression
                     | simple_expression relation
;

relation:
                     EQUAL simple_expression
                     {
                        check_exp_types();
                        add_exp_entry(BOOLEAN, EXP);
                        generate_code(NULL, "CMIG");
                     }
                     | NOT_EQUAL simple_expression
                     {
                        check_exp_types();
                        add_exp_entry(BOOLEAN, EXP);
                        generate_code(NULL, "CMDG");
                     }
                     | LESS simple_expression
                     {
                        check_exp_det_type(INTEGER);
                        add_exp_entry(BOOLEAN, EXP);
                        generate_code(NULL, "CMME");
                     }
                     | LESS_EQUAL simple_expression
                     {
                        check_exp_det_type(INTEGER);
                        add_exp_entry(BOOLEAN, EXP);
                        generate_code(NULL, "CMEG");
                     }
                     | GREATER_EQUAL simple_expression
                     {
                        check_exp_det_type(INTEGER);
                        add_exp_entry(BOOLEAN, EXP);
                        generate_code(NULL, "CMAG");
                     }
                     | GREATER simple_expression
                     {
                        check_exp_det_type(INTEGER);
                        add_exp_entry(BOOLEAN, EXP);
                        generate_code(NULL, "CMMA");
                     }
;

simple_expression:
                     simple_expression PLUS term
                     {
                        check_exp_det_type(INTEGER);
                        add_exp_entry(INTEGER, EXP);
                        generate_code(NULL, "SOMA");
                     }
                     | simple_expression MINUS term
                     {
                        check_exp_det_type(INTEGER);
                        add_exp_entry(INTEGER, EXP);
                        generate_code(NULL, "SUBT");
                     }
                     | term
;

term: 
                     term MULTIPLY factor
                     {
                        check_exp_det_type(INTEGER);
                        add_exp_entry(INTEGER, EXP);
                        generate_code(NULL, "MULT");
                     }
                     | term DIVIDE factor
                     {
                        check_exp_det_type(INTEGER);
                        add_exp_entry(INTEGER, EXP);
                        generate_code(NULL, "DIVI");
                     }
                     | factor
;

factor:
                     NUMBER
                     {
                        add_exp_entry(INTEGER, CONST_EXP);
                        sprintf(buffer, "CRCT %s", token);
                        generate_code(NULL, buffer);
                     }
                     | IDENTIFIER
                     {  
                        subroutine_call_entry *proc_entry;
                        symbol_entry *symbol;
                        symbol = search_var_or_param(token);
                        add_exp_entry(symbol->type, symbol->category == SIMPLE_VAR ? VAR_EXP : PARAM_EXP);

                        proc_entry = (subroutine_call_entry *)subroutine_call_stack->top;
                        if(proc_entry != NULL){ // The expression is in a procedure/function call
                           if(proc_entry->subroutine->params[proc_entry->cur_arg].pass_type == VALUE) {
                              if(symbol->category == SIMPLE_VAR || symbol->pass_type == VALUE) {
                                 sprintf(buffer, "CRVL %d,%d", symbol->lexical_level, symbol->offset);
                              } else {
                                 sprintf(buffer, "CRVI %d,%d", symbol->lexical_level, symbol->offset);
                              }
                           } else {
                              if(symbol->category == SIMPLE_VAR || symbol->pass_type == VALUE) {
                                 sprintf(buffer, "CREN %d,%d", symbol->lexical_level, symbol->offset);
                              } else {
                                 sprintf(buffer, "CRVL %d,%d", symbol->lexical_level, symbol->offset);
                              }
                           }
                        } else {
                           if(symbol->pass_type == REFERENCE) {
                              sprintf(buffer, "CRVI %d,%d", symbol->lexical_level, symbol->offset);
                           } else {
                              sprintf(buffer, "CRVL %d,%d", symbol->lexical_level, symbol->offset);
                           }
                        }
                        
                        generate_code(NULL, buffer);
                     }
                     | OPEN_PARENTHESIS expression CLOSE_PARENTHESIS
;

subroutine_call:
                     subroutine_ident OPEN_PARENTHESIS expressions_list CLOSE_PARENTHESIS
;

subroutine_ident: 
                     left_identifier
                     {
                        add_subroutine_call();
                     }
;

procedure_call:
                     subroutine_call
                     {
                        check_if_procedure();
                        handle_subroutine_call();
                     }
                     | subroutine_ident
                     {
                        check_if_procedure();
                        handle_subroutine_call();
                     }
;

function_call:
                     // subroutine_call
                     // | subroutine_ident
                     // {
                     //    handle_subroutine_call();
                     // }
;

expressions_list:
                     expressions_list COMMA expression 
                     {
                        handle_procedure_arg();
                     }
                     | expression
                     {
                        handle_procedure_arg();
                     }
;

conditional:
                        if_then else_condition
                        {
                           label_entry *entry;

                           entry = (label_entry *)label_stack->top;
                           generate_code(entry->label, "NADA");

                           remove_labels(2);
                        }
;

if_then:
                     IF expression
                     {
                        add_labels(2);
                        label_entry *entry;
                        exp_entry *exp;

                        exp = (exp_entry *)stack_pop(&exp_stack);
                        if(exp->type != BOOLEAN) {
                           print_error("The IF expression must be of boolean type.");
                        }

                        entry = (label_entry *)label_stack->top->prev;
                        sprintf(buffer, "DSVF %s", entry->label);
                        generate_code(NULL, buffer);

                        free(exp);
                     } 
                     THEN no_label_command
                     {
                        label_entry *entry;

                        entry = (label_entry *)label_stack->top;
                        sprintf(buffer, "DSVS %s", entry->label);
                        generate_code(NULL, buffer);

                        entry = (label_entry *)label_stack->top->prev;
                        generate_code(entry->label, "NADA");
                     }
;

else_condition:
                     ELSE no_label_command
                     | %prec LOWER_THAN_ELSE
;

loop:
                     WHILE 
                     {
                        label_entry *entry;

                        add_labels(2);
                        entry = (label_entry *)label_stack->top->prev;
                        sprintf(buffer, "NADA");
                        generate_code(entry->label, buffer);
                     }
                     expression 
                     {
                        label_entry *entry;
                        exp_entry *exp;
                        entry = (label_entry *)label_stack->top;

                        exp = (exp_entry *)stack_pop(&exp_stack);
                        if(exp->type != BOOLEAN) {
                           print_error("The WHILE expression must be of boolean type.");
                        }

                        sprintf(buffer, "DSVF %s", entry->label);
                        generate_code(NULL, buffer);
                        free(exp);
                     } 
                     DO no_label_command
                     {
                        label_entry *entry1, *entry2;
                        entry1 = (label_entry *) label_stack->top->prev;
                        entry2 = (label_entry *) label_stack->top;

                        sprintf(buffer, "DSVS %s", entry1->label);
                        generate_code(NULL, buffer);
                        sprintf(buffer, "NADA");
                        generate_code(entry2->label, buffer);
                        remove_labels(2);
                     }
;

%%

void handle_procedure_arg() {
   exp_entry *exp;
   subroutine_call_entry *entry;
   param_entry *cur_param;

   entry = (subroutine_call_entry *)subroutine_call_stack->top;
   cur_param = &entry->subroutine->params[entry->cur_arg];
   exp = (exp_entry*)stack_pop(&exp_stack);

   if(cur_param->pass_type == REFERENCE) {
      if(exp->category != VAR_EXP && exp->category != PARAM_EXP) {
         sprintf(buffer, "Error calling subroutine %s: argument at position %d must be a variable or formal param.", entry->subroutine->identifier, entry->cur_arg);
         print_error(buffer);
      }
   }

   if(cur_param->type != exp->type) {
      sprintf(buffer, "Error calling subroutine %s: argument at position %d expected a %s type but got a %s type.", entry->subroutine->identifier, entry->cur_arg, parse_var_type(cur_param->type), parse_var_type(exp->type));
      print_error(buffer);
   }

   entry->num_args += 1;
   entry->cur_arg += 1;
}

void handle_subroutine_call() {
   subroutine_call_entry *call_entry;
   symbol_entry *symbol;
   int i;
   
   call_entry = (subroutine_call_entry *)stack_pop(&subroutine_call_stack);
   symbol = call_entry->subroutine;

   if(call_entry->num_args != symbol->num_params) {
      sprintf(buffer, "procedure %s requires %d arguments and %d were passed.", symbol->identifier, symbol->num_params, call_entry->num_args);
      print_error(buffer);
   }

   if(symbol->category == FUNC) {
      generate_code(NULL, "AMEM 1");
   }

   sprintf(buffer, "CHPR %s, %d", symbol->label, lexical_level);
   generate_code(NULL, buffer);

   free(call_entry);
}

void check_if_procedure() {
   subroutine_call_entry *entry;

   entry = (subroutine_call_entry *)subroutine_call_stack->top;

   if(entry->subroutine->category != PROC) {
      sprintf(buffer, "%s is not a procedure.", entry->subroutine->identifier);
      print_error(buffer);
   }
}

void check_exp_types() {
   exp_entry *left_exp, *right_exp;

   left_exp = (exp_entry *)stack_pop(&exp_stack);
   right_exp = (exp_entry *)stack_pop(&exp_stack);

   if(left_exp->type != right_exp->type) {
      print_error("Type mysmatch.");
   }

   free(left_exp);
   free(right_exp);
}

void check_exp_det_type(var_type type) {
   exp_entry *left_exp, *right_exp;

   left_exp = (exp_entry *)stack_pop(&exp_stack);
   right_exp = (exp_entry *)stack_pop(&exp_stack);

   if(left_exp->type != type 
      || right_exp->type != type
      || (left_exp->type != right_exp->type)) {
      print_error("Type mysmatch.");
   }

   free(left_exp);
   free(right_exp);
}

symbol_entry *search_symbol(char *identifier) {
   symbol_entry *symbol;
   symbol_to_find = identifier;
   symbol = (symbol_entry *)stack_search(symbol_table, check_symbol);

   if(symbol == NULL) {
      sprintf(buffer, "%s is not defined.", identifier);
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

symbol_entry *search_var_or_param(char *identifier) {
   symbol_entry *symbol;
   symbol = search_symbol(identifier);

   if(symbol && symbol->category != SIMPLE_VAR && symbol->category != FORMAL_PARAM) {
      sprintf(buffer, "%s is not a simple var nor a formal param.", token);
      print_error(buffer);
   };

   return symbol;
}

symbol_entry *search_subroutine(char *identifier) {
   symbol_entry *symbol;
   symbol = search_symbol(identifier);

   if(symbol && symbol->category != PROC && symbol->category != FUNC) {
      sprintf(buffer, "%s is not a subroutine.", identifier);
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

   if((elem->category == SIMPLE_VAR || elem->category == FORMAL_PARAM || elem->category == FUNC) && elem->type == UNKNOWN) {
      return 1;
   }

   return 0;
}

int check_symbol_to_remove(void *ptr) {
   symbol_entry *elem = ptr;

   if(!elem) {
      return 0;
   }

   switch(elem->category) {
      case SIMPLE_VAR:
         if(elem->lexical_level == lexical_level) {
            return 1;
         }
         return 0;
      case PROC:
      case FUNC:
         if(elem->lexical_level == lexical_level + 1) {
            if(elem->num_params > 0) {
               free(elem->params);
            }
            return 1;
         }
         return 0;
      case FORMAL_PARAM:
         if(elem->lexical_level == lexical_level) {
            return 1;
         }
         return 0;
      default:
         return 0;
   }
}

int check_no_offset_param(void *ptr) {
    symbol_entry *elem = ptr;

   if(!elem) {
      return 0;
   }

   if(elem->category == FORMAL_PARAM && elem->offset == -1) {
      return 1;
   }

   return 0;
}

int set_symbol_types(char* type) {
   symbol_entry *symbol;
   var_type symbol_type;

   if(strcmp(type, "integer") == 0) {
      symbol_type = INTEGER;
   } else if(strcmp(type, "boolean") == 0) {
      symbol_type = BOOLEAN;
   } else {
      sprintf(buffer, "Unknown type %s", token);
      print_error(buffer);
   }

   symbol = (symbol_entry *)stack_search(symbol_table, check_unknown_type);

   while(symbol != NULL) {
      symbol->type = symbol_type;
      symbol = (symbol_entry *)stack_search(symbol_table, check_unknown_type);
   }

   stack_print("Table of symbols\n", symbol_table, print_symbol);

   return 0;
}

int set_params_offset() {
   symbol_entry *symbol;
   int i;
   int offset = -4;

   if(cur_proc->num_params > 0) {
      cur_proc->params = calloc(cur_proc->num_params, sizeof(param_entry));
      i = cur_proc->num_params - 1;
      
      symbol = (symbol_entry *)stack_search(symbol_table, check_no_offset_param);

      while(symbol != NULL) {
         cur_proc->params[i].type = symbol->type;
         cur_proc->params[i].pass_type = symbol->pass_type;
         symbol->offset = offset;
         offset -= 1;
         i -= 1;
         symbol = (symbol_entry *)stack_search(symbol_table, check_no_offset_param);
      }
   }


   return 0;
}

void add_subroutine_call() {
   subroutine_call_entry *entry;
   symbol_entry *symbol;

   symbol = search_subroutine(identifier_to_find);

   entry = malloc(sizeof(subroutine_call_entry));
   entry->prev = NULL;
   entry->next = NULL;
   entry->num_args = 0;
   entry->cur_arg = 0;
   entry->subroutine = symbol;
   stack_push(&subroutine_call_stack, (stack_elem_t *)entry);
}

void add_exp_entry(var_type type, exp_category category) 
{
   exp_entry *entry = malloc(sizeof(exp_entry));
   entry->prev = NULL;
   entry->next = NULL;
   entry->type = type;
   entry->category = category;
   stack_push(&exp_stack, (stack_elem_t *)entry);
}

void add_block_entry() {
   block_entry *entry = malloc(sizeof(block_entry));
   entry->prev = NULL;
   entry->next = NULL;
   entry->num_vars = 0;
   entry->offset = 0;
   entry->skip_subroutines = 1;
   stack_push(&block_stack, (stack_elem_t*)entry);
}

void add_label() {
   int num_digits = (int)log10(num_labels) + 1;
   int num_chars = num_digits <= 2 ? 3 : 1 + num_digits;

   label_entry *entry = malloc(sizeof(label_entry));
   entry->prev = NULL;
   entry->next = NULL;
   entry->label = calloc(num_chars + 1, sizeof(char *));
   sprintf(entry->label, "R%02d", num_labels);
   stack_push(&label_stack, (stack_elem_t *)entry);

   num_labels++;
}

void add_labels(int quantity) {
   int i;

   for(i = 0; i < quantity; i++) {
      add_label();
   }
}

void remove_labels(int quantity) {
   label_entry *entry;
   int i;

   for(i = 0; i < quantity; i++) {
      entry = (label_entry*)stack_pop(&label_stack);
      if(entry) {
         free(entry->label);
         free(entry);
      } else {
         return;
      }
   }
}

symbol_entry *add_symbol(char *identifier, symbol_category category, var_type type, passing_type p_type, int offset, int lexical_level, char *label) {
   symbol_entry *symbol = malloc(sizeof(symbol_entry));
   symbol->prev = NULL;
   symbol->next = NULL;
   symbol->params = NULL;
   symbol->category = category;
   symbol->offset = offset;
   symbol->lexical_level = lexical_level;
   symbol->type = type;
   symbol->pass_type = p_type;
   symbol->num_params = 0;
   strncpy(symbol->identifier, identifier, TOKEN_SIZE);

   if(label != NULL) {
      strncpy(symbol->label, label, TOKEN_SIZE);
   }

   stack_push(&symbol_table, (stack_elem_t *)symbol);

   return symbol;
}

void add_var(char *identifier) {
   block_entry *entry = (block_entry*)block_stack->top;
   add_symbol(identifier, SIMPLE_VAR, UNKNOWN, -1, entry->offset, lexical_level, NULL);
}

symbol_entry *add_subroutine(char *identifier, char *label, symbol_category subroutine_type) {
   symbol_entry *proc_entry;
   proc_entry = add_symbol(identifier, subroutine_type, UNKNOWN, -1, -1, lexical_level + 1, label);

   return proc_entry;
}

void add_param(char *identifier, passing_type p_type) {
   add_symbol(identifier, FORMAL_PARAM, UNKNOWN, p_type, -1, lexical_level + 1, NULL);
   cur_proc->num_params += 1;
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
   symbol_table = stack_init();
   exp_stack = stack_init();
   block_stack = stack_init();
   label_stack = stack_init();
   subroutine_call_stack = stack_init();

   lexical_level = -1;
   pass_type = -1;
   num_labels = 0;
   cur_proc = NULL;

   yyin=fp;
   yyparse();

   free(symbol_table);
   free(exp_stack);
   free(block_stack);
   free(label_stack);
   free(subroutine_call_stack);

   return 0;
}
