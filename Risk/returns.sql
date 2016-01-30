drop table minireturn;

create table tmpminiprice as
    select * from miniprice;

create table minireturn as
    select a.symbol, a.date, a.price, zlog(a.price) - zlog(b.price)  as returns 
        from miniprice a, tmpminiprice b
        where a.symbol = b.symbol and a.rowid - 1 = b.rowid;

drop table tmpminiprice;

