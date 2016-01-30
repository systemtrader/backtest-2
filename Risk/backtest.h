#ifndef BACKTEST_H
#define BACKTEST_H

#include "strategy.h"

void backtest (const struct macrostrategy *, const Portfolio *,
        const char *, const char *);
#endif  /*BACKTEST_H*/
