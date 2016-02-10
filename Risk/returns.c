#include "returns.h"

void zlog (sqlite3_context * ctx,
        int nargs, sqlite3_value ** val){
    double res;
    res = log(sqlite3_value_double(val[0]));
    sqlite3_result_double(ctx, res);
}

int main (int argc, char *argv[]) {
    sqlite3 * db;
    int rc, i, j; char * sql; char * zerr;
    int ncols, nrows;
    sql = // " drop table minireturn; 
           "create table tmpprice as\
            select * from prices;\
        create table return as\
            select a.symbol, a.date, a.price,\
                zlog(a.price) - zlog(b.price)  as returns \
                from prices a, tmpprice b\
                where a.symbol = b.symbol and a.rowid - 1 = b.rowid;\
        drop table tmpprice;";

    rc = sqlite3_open("stocks.db", &db);
    if (rc){
        perror("cant open database\n");
        sqlite3_close(db);
        exit(1);
    }
    sqlite3_create_function(
            db, "zlog", 1, SQLITE_UTF8, NULL, 
            zlog, NULL, NULL);

    rc = sqlite3_exec(db, sql,
            NULL, NULL, &zerr);
    if(rc != SQLITE_OK)
        if(zerr != NULL){
            perror(zerr);
            sqlite3_free(zerr);
        }

    sqlite3_close(db);
    exit(0);
}

