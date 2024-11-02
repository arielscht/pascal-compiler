#include <stdio.h>
#include "output_helpers.h"

char *parse_symbol_category(symbol_category category)
{
    switch (category)
    {
    case SIMPLE_VAR:
        return "sv";
    case PROC:
        return "proc";
    case FUNC:
        return "func";
    case FORMAL_PARAM:
        return "fp";
    default:
        return "unk";
    }
}

char *parse_passing_type(passing_type type)
{
    switch (type)
    {
    case REFERENCE:
        return "ref";
    case VALUE:
        return "val";
    default:
        return "unk";
    }
}

char *parse_var_type(var_type type)
{
    switch (type)
    {
    case BOOLEAN:
        return "bool";
    case INTEGER:
        return "int";
    default:
        return "unk";
    }
}

void print_param(void *ptr)
{
    param_entry *elem = ptr;

    if (!elem)
        return;

    printf("{%s, %s}", parse_var_type(elem->type), parse_passing_type(elem->pass_type));
}

void print_symbol(void *ptr)
{
    symbol_entry *elem = ptr;

    if (!elem)
        return;

    printf("id: %s, cat: %4s, type: %4s, pass_type: %4s, lex_level: %2d, offset: %2d, label: %3s", elem->identifier, parse_symbol_category(elem->category), parse_var_type(elem->type), parse_passing_type(elem->pass_type), elem->lexical_level, elem->offset, elem->label);

    if (elem->params)
    {
        printf(", params: %d[", elem->num_params);
        for (int i = 0; i < elem->num_params; i++)
        {
            print_param(&elem->params[i]);
        }
        printf("]");
    }

    printf("\n");
}

void print_exp_entry(void *ptr)
{
    exp_entry *elem = ptr;

    if (!elem)
    {
        return;
    }

    printf("type: %d\n", elem->type);
}

void print_label_entry(void *ptr)
{
    label_entry *elem = ptr;

    if (!elem)
    {
        return;
    }

    printf("label: %s\n", elem->label);
}