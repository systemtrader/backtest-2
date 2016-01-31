#include "backtest.h"
void backtest (const struct macrostrategy *strat, const Portfolio *port,
        const char *startdate, const char *enddate){
    char curdate[DAYMAX] = {0};
    Action *action = (Action *) malloc (sizeof(Action) * 
            (strat->portsize + port->portsize));
    time_t starttime = daytotime(startdate, DAYFORMAT), 
        endtime = daytotime(enddate, DAYFORMAT), curtime = starttime; 
    Portfolio curport = *port;
    Portfolio nextport = {0};
    strcpy(curdate, startdate);

    while (curtime < endtime ){
        puts(curdate);
        runstrategy(&curport, &nextport, strat, action, curdate);  
        printf("%lf\n", valueportfolio(&nextport));
        curport = nextport;
        memset(&nextport, 0, sizeof(nextport));
        curtime += DAYTOSEC(strat->period); 
        timetoday(curtime, curdate, DAYFORMAT, DAYMAX);
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
    strat.period = 2;
    strat.portsize = 2;
    strat.direction = HIGHEST;
    backtest(&strat, &port, firstdate, lastdate);
    return 0;
}

