<<<<<<< HEAD
drop table prices;

create table prices as 
    select symbol, date, time, avg(price) as price, 
        sum(size) as size from trades
        where symbol in (select symbol from turnover order by turnover desc limit 10500)
        group by symbol, date, time;
=======
create table prices as
    select symbol, date, time, avg(price) as price, 
        sum(size) as size from trades
        group by symbol, date, time;
commit;
>>>>>>> e2bb0da6eef2215aa4f58b8e8b04e0f74a2b18d4
