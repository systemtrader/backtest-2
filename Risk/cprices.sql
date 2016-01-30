create table prices as
    select symbol, date, time, avg(price) as price, 
        sum(size) as size from trades
        group by symbol, date, time;
commit;
