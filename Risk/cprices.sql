drop table prices;

create table prices as 
    select symbol, date, time, avg(price) as price, 
        sum(size) as size from trades
        where symbol in (select symbol from turnover order by turnover desc limit 10500)
        group by symbol, date, time;
