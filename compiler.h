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
  div_symbol
} symbols;

typedef enum symbol_category
{
  SIMPLE_VAR,
} symbol_category;

typedef enum var_type
{
  INTEGER,
  BOOLEAN,
} var_type;

typedef struct symbol_entry
{
  symbol_category category;
  char *identifier;
  int lexical_level;
  int offset;
  var_type type;
} symbol_entry;

/* -------------------------------------------------------------------
 * global variables
 * ------------------------------------------------------------------- */

extern symbols symbol, relation;
extern char token[TOKEN_SIZE];
extern int lexical_level;
extern int offset;
extern int num_lines;

/* -------------------------------------------------------------------
 * global prototypes
 * ------------------------------------------------------------------- */

void generate_code(char *, char *);
int yylex();
void yyerror(char *s);
