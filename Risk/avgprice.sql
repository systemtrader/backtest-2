create table averageprice as
    select symbol, avg(price) as avgprice from trades 
        where symbol not in ('ZWZZT', 'ZVV', 'ZZZZ', 'ZXZZT', 'ZVZZT')
        group by symbol order by avgprice desc; 
