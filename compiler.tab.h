/* A Bison parser, made by GNU Bison 3.8.2.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015, 2018-2021 Free Software Foundation,
   Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <https://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

/* DO NOT RELY ON FEATURES THAT ARE NOT DOCUMENTED in the manual,
   especially those whose name start with YY_ or yy_.  They are
   private implementation details that can be changed or removed.  */

#ifndef YY_YY_COMPILER_TAB_H_INCLUDED
# define YY_YY_COMPILER_TAB_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Token kinds.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    YYEMPTY = -2,
    YYEOF = 0,                     /* "end of file"  */
    YYerror = 256,                 /* error  */
    YYUNDEF = 257,                 /* "invalid token"  */
    PROGRAM = 258,                 /* PROGRAM  */
    OPEN_PARENTHESIS = 259,        /* OPEN_PARENTHESIS  */
    CLOSE_PARENTHESIS = 260,       /* CLOSE_PARENTHESIS  */
    OPEN_BRACKETS = 261,           /* OPEN_BRACKETS  */
    CLOSE_BRACKETS = 262,          /* CLOSE_BRACKETS  */
    COMMA = 263,                   /* COMMA  */
    SEMICOLON = 264,               /* SEMICOLON  */
    COLON = 265,                   /* COLON  */
    DOT = 266,                     /* DOT  */
    T_BEGIN = 267,                 /* T_BEGIN  */
    T_END = 268,                   /* T_END  */
    VAR = 269,                     /* VAR  */
    IDENTIFIER = 270,              /* IDENTIFIER  */
    ASSIGNMENT = 271,              /* ASSIGNMENT  */
    NUMBER = 272,                  /* NUMBER  */
    LABEL = 273,                   /* LABEL  */
    TYPE = 274,                    /* TYPE  */
    ARRAY = 275,                   /* ARRAY  */
    OF = 276,                      /* OF  */
    PROCEDURE = 277,               /* PROCEDURE  */
    FUNCTION = 278,                /* FUNCTION  */
    GOTO = 279,                    /* GOTO  */
    IF = 280,                      /* IF  */
    THEN = 281,                    /* THEN  */
    ELSE = 282,                    /* ELSE  */
    NOT = 283,                     /* NOT  */
    OR = 284,                      /* OR  */
    AND = 285,                     /* AND  */
    WHILE = 286,                   /* WHILE  */
    DO = 287,                      /* DO  */
    INTDIV = 288,                  /* INTDIV  */
    PLUS = 289,                    /* PLUS  */
    MINUS = 290,                   /* MINUS  */
    MULTIPLY = 291,                /* MULTIPLY  */
    DIVIDE = 292                   /* DIVIDE  */
  };
  typedef enum yytokentype yytoken_kind_t;
#endif

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef int YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;


int yyparse (void);


#endif /* !YY_YY_COMPILER_TAB_H_INCLUDED  */
