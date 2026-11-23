
all: syntrix.exe

syntrix.exe: main.c parser.y lexer.l symbol_table.c symbol_table.h
	bison -d parser.y
	flex lexer.l
	gcc main.c parser.tab.c lex.yy.c symbol_table.c -o syntrix.exe

run: syntrix.exe
	./syntrix.exe

clean:
	rm -f parser.tab.c parser.tab.h lex.yy.c syntrix.exe
