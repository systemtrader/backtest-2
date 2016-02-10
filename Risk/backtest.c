#include "backtest.h"

static void first_last_date (char * first_day, char *last_day){
    sqlite3 *db;
    sqlite3_stmt *stmt;
    const char *sql = "select distinct date from minireturn where \
                       date = (select date from minireturn order \
                               by date desc limit 1) or \
                       date = (select date from minireturn order \
                               by date asc limit 1) order by date desc;";

    unsigned int rc;
    rc = sqlite3_open_v2(DBNAME, &db, SQLITE_OPEN_READONLY, NULL);
    if (rc != SQLITE_OK)
        pexit("first_last_day: open error");
    rc = sqlite3_prepare_v2(db, sql,
            strlen(sql) + 1, &stmt, NULL);
    if (rc != SQLITE_OK)
        pexit("first_last_day: prepare error");

    rc = sqlite3_step(stmt);
    strcpy(last_day, (char *)sqlite3_column_text(stmt, 0));
    rc = sqlite3_step(stmt);
    strcpy(first_day, (char *)sqlite3_column_text(stmt, 0));
    
    sqlite3_finalize(stmt);
    sqlite3_close(db);

}
static void printout (char (*dates)[DAYMAX], double *pval, size_t n){
    size_t i;
    puts("");
    printf("%8s \t %12s\n", "Dates", "Values");
    printf("%8s \t %12s\n", "--------", "-------");
    for (i = 0; i < n; i++ )
        printf("%-8s \t %12.3e\n", dates[i], pval[i]);
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

void backtest (const struct macrostrategy *strat, const Portfolio *port){
    char trading_date[DAYMAX] = {0}, (*dates)[DAYMAX];
    double *portvalues = NULL;
    size_t datecount = 0, i;
    char  last_data_date[DAYMAX], first_data_date[DAYMAX],
          first_trading_date[DAYMAX];

    Action *action = (Action *) malloc (sizeof(Action) * 
            (2 * strat->portsize  + 1));
    Portfolio old_port = *port;
    Portfolio new_port = {0};
    
    //Get the first and last backtesting dates imposed by the database
    first_last_date(first_data_date, last_data_date);

    //Get the first trading day by assuming initial
    //investment occured on the first day in the data set
    strcpy(first_trading_date, first_data_date);
    inc_day(first_trading_date, strat->period);

    //There is an innitial portfolio value at the start of the 
    //trading date not the data date and count_days handles it
    datecount = count_days(first_trading_date, last_data_date, strat->period);
    portvalues = malloc(datecount * sizeof(double));
    dates = malloc(datecount * sizeof(char[DAYMAX]));

    //Initialize the old portfolio
    strcpy(trading_date, first_trading_date );
    build_initial_portfolio(strat, &old_port, trading_date, valueportfolio(&old_port)); 
    portvalues[0] = valueportfolio(&old_port);
    strcpy(dates[0], trading_date);
    inc_day(trading_date, strat->period);
    for (i = 0; i < datecount - 1; i++ ){
        memset(&new_port, 0, sizeof(new_port));
        runstrategy(&old_port, &new_port, strat, action, trading_date);  
        portvalues[i + 1 ] = valueportfolio(&old_port);
        strcpy(dates[i + 1], trading_date); 
        old_port = new_port;
        inc_day(trading_date, strat->period);
    }
    printout(dates, portvalues, datecount);
    free(action);
    free(dates);
    free(portvalues);
}

int main (int argc, char *argv[]) {
    struct macrostrategy strat; 
    //struct security oibr = {.symbol = "OIBR", .price = 3.25};
    struct security cash = {.symbol = "USD", .price =1, .type = CASH};
    Record rec = {.asset = cash, .shares = 10000};
    //Record recoi = {.asset = oibr, .shares = 50};
    struct portfolio initial_portfolio = {.records[0] = rec, .portsize = 1};
    memset(&strat, 0 , sizeof strat);
    if(argc != 3){
        puts("2 args are required: trading interval and porfolio size");
        exit(EXIT_FAILURE);
    }
    sscanf(argv[1], "%d", &strat.period);
    sscanf(argv[2], "%d", &strat.portsize);
    strat.direction = HIGHEST;
    backtest(&strat, &initial_portfolio);
    return 0;
}

