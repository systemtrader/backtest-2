backtest: backtest.c strategy.o portfolio.c strategy.h
	gcc  -g backtest.c strategy.o portfolio.c -lm -lsqlite3 -o backtest -Wall   
strategy.o: strategy.c 
	gcc -c strategy.c -lm -lsqlite3 -o strategy.o
