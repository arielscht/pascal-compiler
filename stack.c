// GRR20203949 Ariel Evaldt Schmitt

#include <stdio.h>
#include <stdlib.h>

#include "stack.h"

int stack_size(stack_t *stack)
{
    return stack->size;
}

void stack_print(char *name, stack_t *stack, void print_elem(void *))
{
    stack_elem_t *cur_element;

    cur_element = stack->top;

    if (stack->top == NULL)
    {
        return;
    }

    printf("%s", name);
    do
    {
        print_elem(cur_element);
        printf(" ");
        cur_element = cur_element->prev;
    } while (cur_element != NULL);

    printf("\n");
}

int stack_push(stack_t **stack, stack_elem_t *elem)
{
    if (stack == NULL)
    {
        fprintf(stderr, "The stack does not exist.\n");
        return -1;
    }
    if (elem == NULL)
    {
        fprintf(stderr, "The element does not exist.\n");
        return -2;
    }
    if (elem->prev != NULL || elem->next != NULL)
    {
        fprintf(stderr, "The element already is in a stack.\n");
        return -3;
    }

    if ((*stack)->top == NULL)
    {
        (*stack)->top = elem;
        (*stack)->size = 1;
    }
    else
    {
        elem->prev = (*stack)->top;
        (*stack)->top->next = elem;
        (*stack)->top = elem;
        (*stack)->size += 1;
    }

    return 0;
}

int stack_pop(stack_t **stack)
{
    if (stack == NULL)
    {
        fprintf(stderr, "The stack does not exist.\n");
        return -1;
    }
    if ((*stack)->top == NULL)
    {
        fprintf(stderr, "The stack is empty.\n");
        return -2;
    }

    (*stack)->top = (*stack)->top->prev;
    (*stack)->size -= 1;

    return 0;
}

stack_elem_t *stack_search(stack_t *stack, int check_elem(void *))
{
    stack_elem_t *cur_element;

    cur_element = stack->top;

    while (cur_element != NULL)
    {
        if (check_elem(cur_element) == 1)
        {
            return cur_element;
        }
        cur_element = cur_element->prev;
    };

    return NULL;
}

int stack_update(stack_t **stack, int check_elem(void *), void update_elem(void *))
{
    stack_elem_t *element_to_update;

    element_to_update = stack_search(*stack, check_elem);

    if (element_to_update == NULL)
    {
        return 1;
    }

    update_elem(element_to_update);

    return 0;
}