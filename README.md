bison -d calc.y; flex calc.l; gcc -o calc calc.tab.c lex.yy.c -lfl; ./calc <FILENAME>
or make; ./calc <FILENAME>
