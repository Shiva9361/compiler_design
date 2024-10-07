parser: y.tab.c lex.yy.c y.tab.h
	gcc -w y.tab.c lex.yy.c -ll -o parser
lex.yy.c: $(fname).l
	lex $(fname).l
y.tab.c: $(fname).y
	yacc --debug --verbose -v -d -t $(fname).y
clean:
	rm -f myexec y.tab.c lex.yy.c y.tab.h y.output
