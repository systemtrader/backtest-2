#ifndef ACTIONS_H
#define ACTIONS_H

#include "lib.h"
typedef enum transaction {
    BUY,
    SELL,
    NOTHING
} Transaction;

typedef struct action {
    char  symbol[SYMBOLMAX];
    Transaction action;
    unsigned int shares;
    double price;
    double cost;
    char date[DAYMAX];
} Action;

#endif  /*ACTIONS_H*/
