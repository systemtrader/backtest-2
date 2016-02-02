#include "backtest.h"
static void printout (char (*dates)[DAYMAX], double *pval, size_t n){
    size_t i;
    puts("");
    printf("%8s \t %8s\n", "Dates", "Values");
    printf("%8s \t %8s\n", "--------", "-------");
    for (i = 0; i < n; i++ )
        printf("%-8s \t %8.2f\n", dates[i], pval[i]);
    puts("");
}

static size_t count_days (const char * const startdate, 
        const char * const enddate, unsigned int period){
    size_t datecount = 0;
    char curdate[DAYMAX] = {0} ;
    strcpy(curdate, startdate);

    if (strcmp(startdate, enddate) > 0){
        puts("exec_days: start date is later than endate");
        exit(EXIT_FAILURE);
    }

    while (strcmp(curdate, enddate) < 0 ){
        inc_day(curdate, period);
        datecount++;
    }
    return (datecount);
}

void backtest (const struct macrostrategy *strat, const Portfolio *port,
        const char *startdate, const char *enddate){
    char curdate[DAYMAX] = {0}, (*dates)[DAYMAX];
    double *portvalues = NULL;
    size_t datecount = 0, i;

    Action *action = (Action *) malloc (sizeof(Action) * 
            (strat->portsize * port->portsize + 1));
    Portfolio curport = *port;
    Portfolio nextport = {0};
    strcpy(curdate, startdate);
    datecount = count_days(startdate, enddate, strat->period);
    portvalues = malloc(datecount * sizeof(double));
    dates = malloc(datecount * sizeof(curdate));

    for (i = 0; i < datecount; i++ ){
        strcpy(dates[i], curdate); 
        portvalues[i] = valueportfolio(&curport);
        runstrategy(&curport, &nextport, strat, action, curdate);  
        curport = nextport;
        inc_day(curdate, strat->period);
    }
    free(action);
    printout(dates, portvalues, datecount);
    free(dates);
    free(portvalues);
}
int main (int argc, char *argv[]) {
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
    if(argc != 3){
        puts("2 args are required");
        exit(EXIT_FAILURE);
    }
    sscanf(argv[1], "%d", &strat.period);
    sscanf(argv[2], "%d", &strat.portsize);
    /*strat.period = 5;
    strat.portsize = 10;*/
    strat.direction = HIGHEST;
    backtest(&strat, &port, firstdate, lastdate);
    return 0;
}

