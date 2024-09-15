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

FILE *fp = NULL;
void generateCode(char *rot, char *comando)
{

  if (fp == NULL)
  {
    fp = fopen("MEPA", "w");
  }

  if (rot == NULL)
  {
    fprintf(fp, "     %s\n", comando);
    fflush(fp);
  }
  else
  {
    fprintf(fp, "%s: %s \n", rot, comando);
    fflush(fp);
  }
}

int printError(char *erro)
{
  fprintf(stderr, "Error on line %d - %s\n", num_lines, erro);
  exit(-1);
}

void yyerror(const char *s)
{
  fprintf(stderr, "Error: %s\n", s);
}
