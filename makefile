main: main.c portfolio.c 
	cc main.c portfolio.c -o main
portfolio: porfolio.c porfolio.h
	cc portfolio.c porfolio.h
