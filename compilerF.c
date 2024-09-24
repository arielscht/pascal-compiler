/* -------------------------------------------------------------------
 *
 * Compiler auxiliary functions
 *
 * ------------------------------------------------------------------- */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "compiler.h"

/* -------------------------------------------------------------------
 *  global variables
 * ------------------------------------------------------------------- */

symbols symbol, relation;
char token[TOKEN_SIZE];
int lexical_level;
int offset;
int num_lines;

FILE *fp = NULL;
void generate_code(char *label, char *command)
{

  if (fp == NULL)
  {
    fp = fopen("MEPA", "w");
  }

  if (label == NULL)
  {
    fprintf(fp, "     %s\n", command);
    fflush(fp);
  }
  else
  {
    fprintf(fp, "%s: %s \n", label, command);
    fflush(fp);
  }
}

int print_error(char *error)
{
  fprintf(stderr, "Error on line %d - %s\n", num_lines, error);
  exit(-1);
}

void yyerror(char *s)
{
  fprintf(stderr, "Error: %s\n", s);
}
