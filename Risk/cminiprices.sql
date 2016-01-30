create table miniprice as 
    select symbol, date, time, price from prices
        where date between '20141201' and '20141231' ;
