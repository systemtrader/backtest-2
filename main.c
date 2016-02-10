#include <stdio.h>
#include "portfolio.h"

int main (){
    Security google = {.symbol = "GOOGL", .price=12.3, 
        .shares=34, .action=nothing};
    Security apple = {.symbol = "APPL", .price=104.3, 
        .shares=12, .action=nothing};
    Security cur [] = {google, apple};

    Portfolio curport = {.size=2,.securities=cur};
    printf("value of portfolio %f\n", marketvalue(&curport));
}
