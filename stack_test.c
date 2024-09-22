#include <stdio.h>
#include <stdlib.h>

#include "stack.h"

typedef struct symbol_t
{
    struct symbol_t *prev;
    struct symbol_t *next;
    int id;
} symbol_t;

void print_elem(void *ptr)
{
    symbol_t *elem = ptr;

    if (!elem)
        return;

    elem->prev ? printf("%d", elem->prev->id) : printf("*");
    printf(" < %d > ", elem->id);
    elem->next ? printf("%d\n", elem->next->id) : printf("*\n");
}

void init_symbol(symbol_t *symbol, int id)
{
    symbol->id = id;
    symbol->prev = NULL;
    symbol->next = NULL;
}

int main()
{
    stack_t *symbol_table = malloc(sizeof(stack_t));
    symbol_t symbols[10];

    printf("STACK SIZE: %d\n", stack_size(symbol_table));

    init_symbol(&symbols[0], 12);
    stack_push(&symbol_table, (stack_elem_t *)&symbols[0]);

    init_symbol(&symbols[1], 10);
    stack_push(&symbol_table, (stack_elem_t *)&symbols[1]);

    init_symbol(&symbols[2], 8);
    stack_push(&symbol_table, (stack_elem_t *)&symbols[2]);

    init_symbol(&symbols[3], 6);
    stack_push(&symbol_table, (stack_elem_t *)&symbols[3]);

    printf("STACK SIZE: %d\n", stack_size(symbol_table));

    stack_print("Table of Symbols\n", symbol_table, print_elem);

    stack_pop(&symbol_table);

    printf("STACK SIZE: %d\n", stack_size(symbol_table));

    stack_print("Table of Symbols\n", symbol_table, print_elem);

    free(symbol_table);
    return 0;
}