create table turnover as
    select symbol, sum(size) as turnover from prices 
        where symbol not in ('ZWZZT', 'ZVV', 'ZZZZ', 'ZXZZT', 'ZVZZT')
        group by symbol order by turnover desc; 
