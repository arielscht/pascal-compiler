// GRR20203949 Ariel Evaldt Schmitt

#include <stdio.h>
#include <stdlib.h>

#include "stack.h"

stack_t *stack_init()
{
    stack_t *stack;

    stack = malloc(sizeof(stack_t));
    if (stack != NULL)
    {
        stack->top = NULL;
        stack->size = 0;
    }

    return stack;
}

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

    if (name != NULL)
    {
        printf("%s", name);
    }
    do
    {
        print_elem(cur_element);
        cur_element = cur_element->prev;
    } while (cur_element != NULL);
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

stack_elem_t *stack_pop(stack_t **stack)
{
    stack_elem_t *top;

    if (stack == NULL)
    {
        fprintf(stderr, "The stack does not exist.\n");
        return NULL;
    }
    if ((*stack)->top == NULL)
    {
        fprintf(stderr, "The stack is empty.\n");
        return NULL;
    }

    top = (*stack)->top;
    (*stack)->top = (*stack)->top->prev;
    (*stack)->size -= 1;

    return top;
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

int stack_remove(stack_t **stack, int check_elem(void *))
{
    int removed_qty = 0;
    stack_elem_t *cur_element, *elem_to_delete;
    cur_element = (*stack)->top;

    if (stack == NULL)
    {
        fprintf(stderr, "The stack does not exist.\n");
        return 1;
    }

    while (cur_element != NULL)
    {
        elem_to_delete = cur_element;
        cur_element = cur_element->prev;
        if (check_elem(elem_to_delete))
        {
            if (elem_to_delete->prev)
                elem_to_delete->prev->next = elem_to_delete->next;

            if (elem_to_delete->next)
                elem_to_delete->next->prev = elem_to_delete->prev;

            if (elem_to_delete == (*stack)->top)
            {
                (*stack)->top = elem_to_delete->prev;
            }

            free(elem_to_delete);

            removed_qty++;
        }
    };

    (*stack)->size -= removed_qty;

    return 0;
}

int clear_item(void *ptr)
{
    return 1;
}

int stack_clear(stack_t **stack)
{
    stack_remove(stack, clear_item);
}