#include "portfolio.h"

double valueportfolio (struct portfolio *port){
    float res = 0;
    size_t i;
    for (i = 0; i < port->portsize ; i++)
        res +=  port->records[i].asset.price * 
            port->records[i].shares; 
    return res ;
}

/*int main (int argc, char *argv[]) {
    double value, timespent;
    clock_t begin, end;
    Security *psec;
    Security seca = {.symbol = "APPL", .price =34.8};
    Security secb = {.symbol = "GOOG", .price =4.5};
    
    Record reca = {.asset = &seca, .share = 1};
    Record recb = {.asset = &secb, .share = 10};

    Portfolio port = {.records[0] = reca, .records[1] = recb, .portsize = 2};
    
    begin = clock();
    value = valueportfolio(&port);
    end = clock();
    timespent = (double)(end -begin)/CLOCKS_PER_SEC;
    printf("%f time %f\n", value, timespent);
    puts("Hello world");
    return 0;
}*/

