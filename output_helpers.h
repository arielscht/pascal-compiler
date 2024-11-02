#ifndef __OUTPUT_HELPERS__
#define __OUTPUT_HELPERS__

#include "compiler.h"

char *parse_symbol_category(symbol_category category);

char *parse_passing_type(passing_type type);

char *parse_var_type(var_type type);

void print_param(void *ptr);

void print_symbol(void *ptr);

void print_exp_entry(void *ptr);

void print_label_entry(void *ptr);

#endif
