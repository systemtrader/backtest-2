select symbol, avg(returns) as avgret 
    from minireturn 
    where date <= '20141231' and date >= '20141201'
    group by symbol
    order by avgret desc limit 20;
