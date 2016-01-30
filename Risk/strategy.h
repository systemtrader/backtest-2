#ifndef STRATEGY_H
#define STRATEGY_H

#define __USE_XOPEN
#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sqlite3.h>
#include "action.h"
#include "database.h"
#include "lib.h"
#include "portfolio.h"
#include <time.h>
#include <math.h>
#define STRATNAMEMAX 32

typedef enum direction {
    HIGHEST,
    LOWEST
} Direction;

typedef enum allocationtype{
    EQ_WEALTH,
    EQ_SHARES
} Allocation;

typedef struct macrostrategy {
    char name[STRATNAMEMAX];
    int period;
    double initwealth;
    size_t portsize;
    double (*statistic) (double *);
    Direction direction;
    Allocation allocation;
} MacroStrategy;

void runstrategy (struct portfolio *, Portfolio *,
        struct macrostrategy *, struct action *,
        const char *);

void printportfolio(const Portfolio *);
void printaction(const Action *, size_t );
#endif  /*STRATEGY_H*/
