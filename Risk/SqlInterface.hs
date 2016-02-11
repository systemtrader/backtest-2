module SqlInterface where
import Data.Time
import Database.HDBC 
import Database.HDBC.Sqlite3

dbName :: String
<<<<<<< HEAD
dbName = "stocks.db"

dailyTable :: String
dailyTable = "return"
=======
dbName = "/home/wale/Documents/backtest/Risk/stocks.db"

dailyTable :: String
dailyTable = "minireturn"
>>>>>>> e2bb0da6eef2215aa4f58b8e8b04e0f74a2b18d4

type Formula = String
type Symbol = String

returnFormula :: Formula
returnFormula = "((f.price/b.price) - 1)"

sqlStr::String
sqlStr = "select symbol, date, price, avg(returns) as avgret\
<<<<<<< HEAD
        \ from " ++ dailyTable ++ " where date >= ? and date <= ? and price > 15 and price < 5000\
=======
        \ from minireturn\
        \ where date >= ? and date <= ?\
>>>>>>> e2bb0da6eef2215aa4f58b8e8b04e0f74a2b18d4
        \ group by symbol\
        \ order by avgret desc limit ?;"
 
getDateSqlStr :: String
<<<<<<< HEAD
getDateSqlStr = "select distinct date from prices where date != 'DATE';"
=======
getDateSqlStr = "select distinct date from miniprice where date != 'DATE';"
>>>>>>> e2bb0da6eef2215aa4f58b8e8b04e0f74a2b18d4

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
