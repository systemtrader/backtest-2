Relect f.symbol, f.date,f.price, b.price,((f.price/b.price) - 1) as ret  from prices f, 
    (select symbol, date, price from prices 
        where date = '20120130')  b 
    where b.symbol = f.symbol and
        f.date = '20120524' 
    order by ret desc limit 20;

    
