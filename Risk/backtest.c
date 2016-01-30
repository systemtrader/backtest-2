#include "backtest.h"

int main () {
    struct macrostrategy strat; 
    struct action *result;
    struct security oibr = {.symbol = "OIBR", .price = 3.25};
    struct security cash = {.symbol = "USD", .price =1};
    Record rec = {.asset = cash, .shares = 1000};
    Record recoi = {.asset = oibr, .shares = 50};
    struct portfolio port = {.records[0] = rec, .records[1] = recoi, .portsize = 2};
    Portfolio newport = port;
    const char *lastdate = "20141231";
    memset(&strat, 0 , sizeof strat);
    strat.period = 7;
    strat.portsize = 2;
    strat.direction = HIGHEST;
    result = (Action *) malloc (sizeof(Action) * (strat.portsize + port.portsize));
    runstrategy(&port, &newport, &strat, result, lastdate);
    free(result);
    return 0;
}

