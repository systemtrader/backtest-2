#ifndef LIB_H
#define LIB_H

#ifndef _GNU_XOPEN_
#define _GNU_XOPEN_
#define __USE_XOPEN
#define _GNU_SOURCE
#endif  /*_GNU_XOPEN_*/
#include <time.h>
#include <string.h>
#include <assert.h>
#define DAYFORMAT "%Y%m%d"
#define DAYMAX 9
#define DAYTOSEC(x) (x * 86400)
#define SQLMAX 512
#define SYMBOLMAX 8

typedef enum boolean {true, false} bool; 
static inline void adddaytodate (const char *presentdate, unsigned int days, 
        char * futuredate, const char *dateformat ){
    struct tm presenttm = {0};
    struct tm futuretm ={0};
    time_t presenttime = 0;
    time_t futuretime = 0;
    strptime(presentdate, dateformat, &presenttm);
    presenttime = mktime(&presenttm);
    futuretime = presenttime + DAYTOSEC(days);
    futuretm = *(localtime( &futuretime));
    strftime(futuredate, strlen(presentdate) + 1, 
            dateformat, &futuretm);
}
static inline time_t daytotime (const char *date, const char *dateformat){
    struct tm datetm = {0};
    strptime(date, dateformat, &datetm);
    return (mktime(&datetm));
}

static inline void timetoday (time_t thetime, char *date, 
        const char *dateformat, size_t sizeofdate){
    struct tm datetm = {0};
    datetm = *(localtime( &thetime));
    strftime(date, sizeofdate + 1, 
            dateformat, &datetm);
}
static inline void datetotm (const char *date, struct tm *t){
    unsigned int day, mon, year;
    sscanf(date,"%4d%2d%2d", &year, &mon, &day);
    t->tm_year = year - 1900;
    t->tm_mon = mon - 1;
    t->tm_mday = day;
}
static inline void inc_day( char *source, unsigned int days){
    struct tm t = {0};
    datetotm(source, &t);
    t.tm_mday += days;
    mktime(&t);
    sprintf(source, "%4i%02i%02i", 
            t.tm_year + 1900, t.tm_mon +1,
            t.tm_mday);
}



#endif  /*LIB_H*/
