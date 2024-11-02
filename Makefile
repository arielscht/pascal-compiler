compiler: lex.yy.c compiler.tab.c compiler.o stack.o output_helpers.o compiler.h
	gcc lex.yy.c compiler.tab.c compiler.o stack.o output_helpers.o -o compiler -ll -ly -lc -lm

lex.yy.c: compiler.l compiler.h
	flex compiler.l

compiler.tab.c: compiler.y compiler.h
	bison compiler.y -d -v

compiler.o: compiler.h compilerF.c
	gcc -c compilerF.c -o compiler.o

stack.o: stack.c stack.h 
	gcc -c stack.c -o stack.o

output_helpers.o: output_helpers.c output_helpers.h 
	gcc -c output_helpers.c -o output_helpers.o

clean :
	rm -f compiler.tab.* lex.yy.c compiler.o stack.o output_helpers.o compiler.output compiler
