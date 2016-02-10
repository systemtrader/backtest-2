#include "portfolio.h"

double marketvalue (struct portfolio * port){
    double value;
    int i;
    for(i=0, value = 0.0; i < port->size; i++)
        value  +=  (port->securities[i].price)*(port->securities[i].shares); 
    return value;
}

void adjustportfolio (Portfolio * newport,
        Portfolio * oldport){
    double psalloc;
    int i;
    psalloc = marketvalue(oldport)/newport->size;
    for (i = 0; i < newport->size; i++){
        newport->securities[i].shares = psalloc/newport->securities[i].price;
        newport->securities[i].action = nothing;
    };
}




        
