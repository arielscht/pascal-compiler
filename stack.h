#ifndef __STACK__
#define __STACK__

#ifndef NULL
#define NULL ((void *)0)
#endif

typedef struct stack_elem_t
{
    struct stack_elem_t *prev;
    struct stack_elem_t *next;
} stack_elem_t;

typedef struct stack_t
{
    struct stack_elem_t *top;
    int size;
} stack_t;

int stack_size(stack_t *stack);

void stack_print(char *name, stack_t *stack, void print_elem(void *));

int stack_push(stack_t **stack, stack_elem_t *elem);

int stack_pop(stack_t **stack);

#endif
