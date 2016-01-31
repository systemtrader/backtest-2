#include "backtest.h"
void backtest (const struct macrostrategy *strat, const Portfolio *port,
        const char *startdate, const char *enddate){
    char curdate[DAYMAX] = {0} ;
    Action *action = (Action *) malloc (sizeof(Action) * 
            (strat->portsize + port->portsize + 1));
    Portfolio curport = *port;
    Portfolio nextport = {0};
    strcpy(curdate, startdate);

    while (strcmp(curdate, enddate) < 0 ){
        runstrategy(&curport, &nextport, strat, action, curdate);  
        curport = nextport;
        memset(&nextport, 0, sizeof(nextport));
        inc_day(curdate, strat->period);
    }
    free(action);
}
int main () {
    struct macrostrategy strat; 
    struct security oibr = {.symbol = "OIBR", .price = 3.25};
    struct security cash = {.symbol = "USD", .price =1};
    Record rec = {.asset = cash, .shares = 1000};
    Record recoi = {.asset = oibr, .shares = 50};
    struct portfolio port = {.records[0] = rec, 
        .records[1] = recoi, .portsize = 2};
    const char *lastdate = "20141231";
    const char *firstdate = "20141203";
    memset(&strat, 0 , sizeof strat);
    strat.period = 5;
    strat.portsize = 2;
    strat.direction = HIGHEST;
    backtest(&strat, &port, firstdate, lastdate);
    return 0;
}

