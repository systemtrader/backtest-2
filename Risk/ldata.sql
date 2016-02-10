create  table trades (symbol text, 
    date text, time text, price real, size integer, 
    G127 integer, corr integer, cond blob, ex text);
.separator ","
.import ../dailytrades.csv trades
