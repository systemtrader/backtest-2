#include "strategy.h"
static void allocatewealth (const   struct macrostrategy *strat, 
        Portfolio *new_port, const double portvalue);
static void optimal_ports (const struct macrostrategy *strat, const char *trading_date,
        Portfolio *indicative_portfolio);

void build_initial_portfolio (const struct macrostrategy *strat, Portfolio *initial_portfolio,
    const char *first_date, double initial_wealth){
    optimal_ports(strat,first_date,initial_portfolio);
    allocatewealth(strat, initial_portfolio, initial_wealth);
}

static void optimal_ports (const struct macrostrategy *strat, const char *trading_date,
        Portfolio *indicative_portfolio){
    sqlite3 *db;
    sqlite3_stmt *stmt;
    char order[sizeof("desc")] = {0}, previous_trading_date[DAYMAX] = {0};
    char sql[SQLMAX] = {0};
    const char *headsql = 
        "select symbol, price, avg(returns) as avgret \
        from minireturn \
        where date <= ?100 and date >= ?101\
        group by symbol\
        order by avgret "; 
    const char *tailsql = " limit ?103;";
    unsigned int rc, i;

     //Prepare and bind sql statement 
    if(strat->direction == HIGHEST)
        strcpy(order,"desc");
    else
        strcpy(order,"asc");
    strcpy(sql, headsql);
    strcat(sql, order);
    strcat(sql, tailsql);

    //Open database and prepare sql stement
    rc = sqlite3_open_v2(DBNAME, &db, SQLITE_OPEN_READONLY, NULL);
    if (rc != SQLITE_OK){
        pexit("optimal_ports: open error");
    }
    rc = sqlite3_prepare_v2(db, sql,
            strlen(sql) + 1, &stmt, NULL);
    if (rc != SQLITE_OK){
        sqlite3_close(db);
        pexit("optimal_ports: prepare error");
    }

    //Define previous trading date. A downward increment...
    strcpy(previous_trading_date, trading_date);
    inc_day(previous_trading_date, - strat->period);

    //Bind the appropriate dates and porfolio sizes
    rc = sqlite3_bind_text(stmt, 100, trading_date, DAYMAX,
            SQLITE_TRANSIENT);
    rc += sqlite3_bind_text(stmt, 101, previous_trading_date, DAYMAX,
            SQLITE_TRANSIENT);
    rc += sqlite3_bind_int(stmt, 103, strat->portsize);

    if (rc != SQLITE_OK){
        sqlite3_finalize(stmt);
        sqlite3_close(db);
        pexit("optimal_ports: bind error");
    }

    //Prepare the indicative portfolio
    rc = sqlite3_step(stmt);
    i = 0;
    while (rc == SQLITE_ROW){
        strcpy(indicative_portfolio->records[i].asset.symbol, 
                (char *)sqlite3_column_text(stmt, 0));
        indicative_portfolio->records[i].asset.price  
            = sqlite3_column_double(stmt, 1);
        indicative_portfolio->records[i].asset.target 
            = sqlite3_column_double(stmt, 2);
        rc = sqlite3_step(stmt);
        i++;
    }
    indicative_portfolio->portsize = strat->portsize;
    //Clean up.
    sqlite3_finalize(stmt);
    sqlite3_close(db);
}

static double port_maket_value (Portfolio *  port, 
        const char *trading_date){
    //The database needs to be queried for the current prices of the old portfolio
    sqlite3 *db;
    sqlite3_stmt *stmt = NULL;
    size_t msize, ssize, i, j = 0 , k,  cashcount;
    unsigned int rc = 0, found;
    char (*syms)[SYMBOLMAX];
    char *marks, sqlstr[SQLMAX] = {0}; 
    char sql [] =
        "select symbol, price from"
        " minireturn where"
        " date = ? and symbol in (";
    //If the porfolio contains just cash then just return it
    if (port->portsize == 1 &&
            port->records[0].asset.type == CASH)
        return port->records[0].shares;

    //Determine the number of cash (could be improved)
    for (cashcount = i = 0; i < port->portsize; i++)
        if (port->records[i].asset.type == CASH)
            cashcount++;

    //Allocate memory for spl parameters
    msize = ssize = port->portsize - cashcount;
    msize = 2 * msize;

    if ((syms = malloc(ssize * sizeof(char[SYMBOLMAX]))) == NULL){
        perror("port_maket_value: calloc failed");
        exit(EXIT_FAILURE);
    }
    if ((marks = calloc(msize, msize * sizeof(char))) == NULL){
        perror("port_maket_value: calloc failed");
        exit(EXIT_FAILURE);
    }

    //Build the parametric side of the sql statement
    for (k  = i = j = 0; j < port->portsize ; i++, j++, k++){
        while (port->records[j].asset.type == CASH)
            j++;
        if (j >= port->portsize)
            break;
        marks[k] = '?';
        marks[++k] = ',';
        strcpy(syms[i], port->records[j].asset.symbol);
    }
    marks[k] = ';';
    marks[--k] = ')';
    strcpy(sqlstr, sql);
    strcat(sqlstr, marks);
    
    //Open database and prepare query
    rc = sqlite3_open_v2(DBNAME, &db, SQLITE_OPEN_READONLY, NULL);
    if (rc != SQLITE_OK)
        pexit("port_maket_value: open error");

    rc = sqlite3_prepare_v2(db, sqlstr,
            sizeof(sqlstr)  , &stmt, NULL);
    if (rc != SQLITE_OK){
        sqlite3_close(db);
        printf("prepare: rc = %d\n", rc);
        exit(EXIT_FAILURE);
    }
    rc = sqlite3_bind_text(stmt,1,trading_date , -1,
      SQLITE_STATIC);

    if (rc != SQLITE_OK){
        sqlite3_finalize(stmt);
        sqlite3_close(db);
        printf("bind: rc = %d\n", rc);
        exit(EXIT_FAILURE);
    }
    
    //Bind symbols to the sql statement
    for (i = 0; i < port->portsize - cashcount; i++){
        rc = sqlite3_bind_text(stmt,2 + i, syms[i] , -1,
            SQLITE_STATIC);
        if (rc != SQLITE_OK){
            printf("inner bind: rc = %d \t item: %d\n ", rc, i);
            exit(EXIT_FAILURE);
        }
    }
    
    //Obtain the new prices for the old portfolio making sures
    //the prices match with the symbols
    rc = sqlite3_step(stmt);
    i = 0;
    while (rc == SQLITE_ROW){
        if (strcmp(port->records[i].asset.symbol, 
                (char *)sqlite3_column_text(stmt, 0)) != 0){
            for (found = j = 0; j < port->portsize ; j ++){
                if (strcmp(port->records[j].asset.symbol, 
                (char *)sqlite3_column_text(stmt, 0)) == 0){
                    port->records[j].asset.price  
                        = sqlite3_column_double(stmt, 1);
                    found = 1;
                    break;
                }
            }
            if (!found){
                perror ("at least one symbol could not be matched");
                exit(EXIT_FAILURE);
            }
        }
        port->records[i].asset.price  
            = sqlite3_column_double(stmt, 1);
        rc = sqlite3_step(stmt);
        i++;
    }
 
    sqlite3_finalize(stmt);
    free(marks);
    free(syms);
    return valueportfolio(port);
}


static void printaction(const Action *todo, size_t ntodo, const char *date){
    #define PRTTRANS(X) ((X) == BUY ? "BUY" : "SELL") 
    double totbought, totsold;
    size_t i = 0;
    //puts("\nThe following orders will be executed.");
    printf("\nTransaction date: %s\n",date);
    puts("--------------------------------------------------------------------------");
    printf("%-8s \t %-8s \t %6s \t %8s \t %8s\n","Symbol","Todo","Shares", "Price", "Total");
    printf("%-8s \t %-8s \t %6s \t %8s \t %8s\n","------","----","------", "-----", "-----");
    for ( ; i < ntodo ; i++){
        printf("%-8s \t %-8s \t %6d \t %8.2f \t %8.2f\n",
                todo[i].symbol, PRTTRANS(todo[i].action),
                todo[i].shares,
                todo[i].price,
                todo[i].cost);
    }

    puts("--------------------------------------------------------------------------");
    for (i = 0, totbought = totsold = 0.0; i < ntodo; i++){
        if (todo[i].action == BUY)
            totbought += todo[i].cost;
        else
            totsold += todo[i].cost;
    }
    printf("Total bought: %f\nTotal sold: %f\nNet Gain: %f\n", 
            totbought, totsold, totsold - totbought);
    puts("--------------------------------------------------------------------------");

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
    printf("Current porfolio value: %.2f\n\n",
            valueportfolio(port));
}

static void printout (const Portfolio *port, 
        const Action *todo, size_t ntodo,  
        const char * date, PrintFlag f){
    if (f == TODO)
        printaction(todo, ntodo, date);
    else if (f == PORT)
        printportfolio(port);
    else if (f == BOTH){
        printaction(todo, ntodo, date);
        printportfolio(port);
    }else if (f == NONE)
        ;
    else
        perror ("printout: invalid print flag");
}

static void allocatewealth (const struct macrostrategy *strat, 
        Portfolio *new_port, const double portvalue){
    double persharealloc;
    size_t i;
    Record cashrec ;
    Security cash = {.symbol = "USD", .target = 9.99, .type = CASH};
    if (strat->allocation == EQ_WEALTH){
        persharealloc = portvalue / (float) new_port->portsize;
        for (i = 0; i < new_port->portsize; i++)
            new_port->records[i].shares = 
                floor(persharealloc / new_port->records[i].asset.price);
    }
    cash.price = portvalue - valueportfolio(new_port);
    cashrec.asset = cash;
    cashrec.shares = 1;
    new_port->records[new_port->portsize] = cashrec;
    ++(new_port->portsize);
}

static size_t getaction (Portfolio * const old_portfolio, 
        Portfolio *new_port, 
        const struct macrostrategy *strat, 
        struct action *todo,
        const char *trading_date){
    //The output show be a list of trades to make in order to 
    //construct the indicative portfolio
    //1. Update the value of the old porfolio by referencing 
    //  current maket price
    //2. Sell the old portfolio, buy the new portfolio

   size_t i, j, k, ntodo;
   double portval;
   bool exists;

   //Current market value of old portfoio is obtained
   portval = port_maket_value(old_portfolio, trading_date);

   //Figure out an allocation scheme for the new portfolio 
   //based on the liguidation value of the old portfolio
   allocatewealth (strat, new_port, portval);

   //Determine the list of trades to execute
   for (i = 0; i < old_portfolio->portsize; i++){
       strcpy(todo[i].symbol, 
               old_portfolio->records[i].asset.symbol); 
       todo[i].action = SELL;
       todo[i].shares = old_portfolio->records[i].shares;
       todo[i].price = old_portfolio->records[i].asset.price;
   }
   for (k = 0, i = 0; i < new_port->portsize; i++){
       exists = false;
       for (j = 0; j < old_portfolio->portsize; j++)
           if (strcmp (new_port->records[i].asset.symbol, 
                       old_portfolio->records[j].asset.symbol) == 0){
               exists = true;
               if (todo[j].shares > new_port->records[i].shares)
                   todo[j].shares -= new_port->records[i].shares;
               else {
                   todo[j].shares = 
                       new_port->records[i].shares - 
                       todo[j].shares;
                   todo[j].action = BUY;
                   todo[j].price = new_port->records[i].asset.price;
               }
               break;
           }
       if (exists == false){
           strcpy(todo[k + old_portfolio->portsize].symbol, 
                   new_port->records[i].asset.symbol);
           todo[k + old_portfolio->portsize].action = BUY;
           todo[k + old_portfolio->portsize].shares = 
               new_port->records[i].shares;
           todo[k + old_portfolio->portsize].price = 
               new_port->records[i].asset.price;
           k++;
       }
   }
   ntodo =  (k + old_portfolio->portsize);
   for (i = 0; i < ntodo; i ++)
       todo[i].cost = todo[i].shares *todo[i].price;
   return ntodo;
}

void runstrategy (Portfolio * const old_portfolio,  
        Portfolio *new_portfolio, 
        const struct macrostrategy *strategy, 
        struct action *todo,
        const char *trading_date){
    //1. Determine optimal new symbol based on the past and by them
    //2. Determine what trades to make 

    unsigned int ntodo = 0;

    //Get optimal portfolios. This step is indicative only. Shares have not
    //been bought or allocated yet
    optimal_ports (strategy, trading_date, new_portfolio);

    //getaction figures out the trades to make
    ntodo = getaction (old_portfolio, new_portfolio, 
            strategy, todo, trading_date);

    //Display the new portfolio and trades to carry out
    printout(new_portfolio, todo, ntodo, trading_date, NONE); 
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
