#ifndef STRATEGY_H
#define STRATEGY_H

#ifndef _GNU_XOPEN_
#define _GNU_XOPEN_
#define __USE_XOPEN
#define _GNU_SOURCE
#endif //_GNU_XOPEN_

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

typedef enum printflag {
    NONE,
    TODO,
    PORT,
    BOTH
} PrintFlag;

typedef struct macrostrategy {
    char name[STRATNAMEMAX];
    int period;
    double initwealth;
    size_t portsize;
    double (*statistic) (double *);
    Direction direction;
    Allocation allocation;
} MacroStrategy;

void runstrategy ( const struct portfolio * const, Portfolio *,
         const struct macrostrategy *, struct action *,
        const char *);

void printportfolio(const Portfolio *);
void printaction(const Action *, size_t );
#endif  /*STRATEGY_H*/
