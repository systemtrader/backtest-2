<<<<<<< HEAD
drop table miniprice;
=======
>>>>>>> e2bb0da6eef2215aa4f58b8e8b04e0f74a2b18d4
create table miniprice as 
    select symbol, date, time, price from prices
        where date between '20141201' and '20141231' ;
