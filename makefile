all: aula5.l aula5.y
	flex aula5.l
	bison -d aula5.y
	gcc aula5.tab.c -o analisador -lm -lfl
	./analisador

clean:
	rm -f analisador lex.yy.c aula5.tab.c aula5.tab.h