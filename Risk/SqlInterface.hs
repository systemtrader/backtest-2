module SqlInterface where
import Data.Time
import Database.HDBC 
import Database.HDBC.Sqlite3

dbName :: String
dbName = "/home/wale/Documents/backtest/Risk/stocks.db"

dailyTable :: String
dailyTable = "minireturn"

type Formula = String
type Symbol = String

returnFormula :: Formula
returnFormula = "((f.price/b.price) - 1)"

sqlStr::String
sqlStr = "select symbol, date, price, avg(returns) as avgret\
        \ from minireturn\
        \ where date >= ? and date <= ?\
        \ group by symbol\
        \ order by avgret desc limit ?;"
 
getDateSqlStr :: String
getDateSqlStr = "select distinct date from miniprice where date != 'DATE';"

lastDateSqlStr :: String
lastDateSqlStr = "select date from " ++ dailyTable ++ " order by date desc limit 1;"

activeSymbolSqlStr :: String
activeSymbolSqlStr = "select symbol from "++dailyTable++" where date = ? \
    \intersect select symbol from "++dailyTable++" where date = ?;" 

sqlToDates :: [SqlValue] -> Day
sqlToDates [SqlByteString x] =  
    parseTimeOrError True defaultTimeLocale "\"%Y%m%d\"" (show x) :: Day

sqlToSymbol :: [SqlValue] -> String
sqlToSymbol [SqlByteString x] = show x :: String 

sqlToPrice :: [SqlValue] -> Double
sqlToPrice [SqlByteString x] = (read . show)  x :: Double
