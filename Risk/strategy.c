#include "strategy.h"

static size_t getaction(const Portfolio *, struct portfolio *, const struct macrostrategy *,
        struct action *);
static void allocatewealth (const struct macrostrategy *, Portfolio *,
        const double);

void printaction(const Action *todo, size_t ntodo){
    #define PRTTRANS(X) ((X) == BUY ? "BUY" : "SELL") 
    size_t i = 0;
    //puts("\nThe following orders will be executed.");
    
    printf("\n%-8s \t %-8s \t %6s\n","Symbol","Todo","Shares");
    printf("%-8s \t %-8s \t %6s\n","------","----","------");
    for ( ; i < ntodo ; i++){
        printf("%-8s \t %-8s \t %6d\n",
                todo[i].symbol, PRTTRANS(todo[i].action),
                todo[i].shares);
    }
    puts("");
    #undef PRTTRANS
}

void printportfolio(const Portfolio *port){
    size_t i;
 //   puts("\nSymbol \t\t Price \t\t Target \t\t Shares\n"
//           "---------------------------"
  //         "------------------------------------");
  //         "------ \t\t ----- \t\t ------ \t\t ------");
    printf("\n%-8s \t %6s \t %6s \t %6s\n",
            "Symbol", "Price", "Target", "Shares");
    printf("%-8s \t %6s \t %6s \t %6s\n",
            "------", "-----", "------", "------");
    for (i = 0; i < port->portsize; i++)
        printf("%-8s \t %6.2f \t %6.2f%% \t %6d\n",
                port->records[i].asset.symbol, 
                port->records[i].asset.price, 
                100*port->records[i].asset.target,
                port->records[i].shares);
    puts("");
}

static void allocatewealth (const struct macrostrategy *strat, 
        Portfolio *newport, const double portvalue){
    double persharealloc;
    size_t i;
    Record cashrec ;
    Security cash = {.symbol = "USD", .target = 9.99, .price = 1};
    if (strat->allocation == EQ_WEALTH){
        persharealloc = portvalue / (float) newport->portsize;
        for (i = 0; i < newport->portsize; i++)
            newport->records[i].shares = floor(persharealloc / newport->records[i].asset.price);
    }
    cashrec.shares = floor(portvalue - valueportfolio(newport));
    cashrec.asset = cash;
    newport->records[newport->portsize] = cashrec;
    ++(newport->portsize);
}

static size_t getaction (const Portfolio *cuport, Portfolio *newport, 
        const struct macrostrategy *strat, struct action *todo){
   size_t i, j, k;
   double portval;
   bool exists;

   portval = valueportfolio(cuport);
   allocatewealth (strat, newport, portval);
   for (i = 0; i < cuport->portsize; i++){
       strcpy(todo[i].symbol, cuport->records[i].asset.symbol); 
       todo[i].action = SELL;
       todo[i].shares = cuport->records[i].shares;
   }
   for (k = 0, i = 0; i < newport->portsize; i++){
       exists = false;
       for (j = 0; j < cuport->portsize; j++)
           if (strcmp (newport->records[i].asset.symbol, cuport->records[j].asset.symbol) == 0){
               exists = true;
               if (todo[j].shares > newport->records[i].shares)
                   todo[j].shares -= newport->records[i].shares;
               else {
                   todo[j].shares = newport->records[i].shares - todo[j].shares;
                   todo[j].action = BUY;
               }
               break;
           }
       if (exists == false){
           strcpy(todo[k + cuport->portsize].symbol, newport->records[i].asset.symbol);
           todo[k + cuport->portsize].action = BUY;
           todo[k + cuport->portsize].shares = newport->records[i].shares;
           k++;
       }
   }
   return (k + cuport->portsize);
}

void runstrategy (const Portfolio *cuport,  Portfolio *newport, 
        const struct macrostrategy *strat, struct action *todo,
        const char *lastdate){
    sqlite3 * db = 0;
    sqlite3_stmt *stmt;
    int rc; 
    size_t i, ntodo;
    char sql[SQLMAX];
    char  begindate[DAYMAX],
         order[32];
    time_t lasttime, begintime;
    struct tm lasttm = {0}, begintm ={0};
    const char *headsql = "select symbol, price, avg(returns) as avgret \
        from minireturn \
        where date <= ?100 and date >= ?101\
        group by symbol\
        order by avgret "; 
    const char *tailsql = " limit ?103;";
   
    //Get most recent data date
    rc = sqlite3_open_v2(DBNAME, &db, SQLITE_OPEN_READONLY, NULL);

    //Obtain the start date from the strategy
    //and the last data dates
    strptime(lastdate, DAYFORMAT, &lasttm);
    lasttime = mktime(&lasttm);
    begintime = lasttime - DAYTOSEC(strat->period);
    begintm = *(localtime( &begintime));
    strftime(begindate, DAYMAX, 
            DAYFORMAT, &begintm);

    //Prepare and bind sql statement 
    if(strat->direction == HIGHEST)
        strcpy(order,"desc");
    else
        strcpy(order,"asc");
    strcpy(sql, headsql);
    strcat(sql, order);
    strcat(sql, tailsql);

    rc = sqlite3_prepare_v2(db, sql,
            strlen(sql)+1, &stmt, NULL);

    sqlite3_bind_text(stmt, 100, lastdate, DAYMAX,
            SQLITE_TRANSIENT);
    sqlite3_bind_text(stmt, 101, begindate, DAYMAX,
            SQLITE_TRANSIENT);
    sqlite3_bind_int(stmt, 103, strat->portsize);

    //Prepare the result struct
    rc = sqlite3_step(stmt);
    i = 0;
    while (rc == SQLITE_ROW){
        strcpy(newport->records[i].asset.symbol, (char *)sqlite3_column_text(stmt, 0));
        newport->records[i].asset.price  = sqlite3_column_double(stmt, 1);
        newport->records[i].asset.target = sqlite3_column_double(stmt, 2);
        rc = sqlite3_step(stmt);
        i++;
    }
    newport->portsize = strat->portsize;
    ntodo = getaction (cuport,newport, strat, todo);
    printaction(todo, ntodo);
    printportfolio(newport);
    sqlite3_finalize(stmt);
    sqlite3_close(db);
}
/*
int main (int argc, char *argv[]) {
    struct macrostrategy strat = {{0}};
    struct action *result;
    struct security oibr = {.symbol = "OIBR", .price = 3.25};
    struct security cash = {.symbol = "USD", .price =1};
    Record rec = {.asset = cash, .shares = 1000};
    Record recoi = {.asset = oibr, .shares = 50};
    struct portfolio port = {.records[0] = rec, .records[1] = recoi, .portsize = 2};
    Portfolio newport = port;
    const char *lastdate = "20141231";
    strat.period = 7;
    strat.portsize = 2;
    strat.direction = HIGHEST;
    result = (Action *) malloc (sizeof(Action) * (strat.portsize + port.portsize));
    runstrategy(&port, &newport, &strat, result, lastdate);
    free(result);
    return 0;
}
*/
