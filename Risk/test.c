#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include "lib.h"

int main (int argc, char *argv[]) {

    struct tm t ={0};
    char * date = "20141124";
    char dt[9] = {0};
    datetotm (date, &t);
    puts("");
    strcpy(dt, date);
    add_days(date, 367, dt);
    puts(date);
    puts(dt);
    exit(0);
}

