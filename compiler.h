#ifndef __COMPILER__
#define __COMPILER__

#include "stack.h"

#define TOKEN_SIZE 16

typedef enum symbols
{
  program_symbol,
  var_symbol,
  begin_symbol,
  end_symbol,
  identifier_symbol,
  number_symbol,
  dot_symbol,
  comma_symbol,
  semicolon_symbol,
  colon_symbol,
  assignment_symbol,
  open_parenthesis_symbol,
  close_parenthesis_symbol,
  open_brackets_symbol,
  close_brackets_symbol,
  label_symbol,
  type_symbol,
  array_symbol,
  of_symbol,
  procedure_symbol,
  function_symbol,
  goto_symbol,
  if_symbol,
  then_symbol,
  else_symbol,
  not_symbol,
  or_symbol,
  and_symbol,
  while_symbol,
  do_symbol,
  int_div_symbol,
  plus_symbol,
  minus_symbol,
  multiply_symbol,
  div_symbol,
  equal_symbol,
  not_equal_symbol,
  less_symbol,
  less_equal_symbol,
  greater_equal_symbol,
  greater_symbol,
  read_symbol,
  write_symbol,
  forward_symbol,
} symbols;

typedef enum symbol_category
{
  SIMPLE_VAR,
  PROC,
  FUNC,
  FORMAL_PARAM,
} symbol_category;

typedef enum var_type
{
  UNKNOWN = -1,
  INTEGER,
  BOOLEAN,
} var_type;

typedef enum exp_category
{
  VAR_EXP,
  PARAM_EXP,
  CONST_EXP,
  EXP,
  FUNC_EXP,
} exp_category;

typedef enum passing_type
{
  VALUE,
  REFERENCE,
} passing_type;

typedef struct param_entry
{
  var_type type;
  passing_type pass_type;
} param_entry;

typedef struct symbol_entry
{
  struct symbol_entry *prev;
  struct symbol_entry *next;
  symbol_category category;
  char identifier[TOKEN_SIZE];
  char label[TOKEN_SIZE];
  int lexical_level;
  int offset;
  int num_params;
  int func_active;
  int return_assigned;
  int implemented;
  int params_read;
  var_type type;
  passing_type pass_type;
  param_entry *params;
} symbol_entry;

typedef struct exp_entry
{
  struct exp_entry *prev;
  struct exp_entry *next;
  var_type type;
  exp_category category;
} exp_entry;

typedef struct block_entry
{
  struct block_entry *prev;
  struct block_entry *next;
  int num_vars;
  int offset;
  int skip_subroutines;
} block_entry;

typedef struct label_entry
{
  struct label_entry *prev;
  struct label_entry *next;
  char *label;
} label_entry;

typedef struct subroutine_call_entry
{
  struct subroutine_call_entry *prev;
  struct subroutine_call_entry *next;
  symbol_entry *subroutine;
  int num_args;
  int cur_arg;
} subroutine_call_entry;

/* -------------------------------------------------------------------
 * global variables
 * ------------------------------------------------------------------- */

extern symbols symbol, relation;
extern char token[TOKEN_SIZE];
extern int lexical_level;
extern int num_lines;

/* -------------------------------------------------------------------
 * global prototypes
 * ------------------------------------------------------------------- */

void generate_code(char *, char *);
int print_error(char *error);
int yylex();
void yyerror(char *s);

#endif