module SqlInterface where
import Data.Time
import Database.HDBC 

dbName :: String
dbName = "/home/wale/Documents/backtest/Risk/stocks.db"

dailyTable :: String
dailyTable = "minireturn"

type Formula = String
type Symbol = String

sqlStr::String
sqlStr = "select symbol, date, price, sum(returns) as avgret from (select * \
        \ from " ++ dailyTable ++ " where date >= ? and date <= ? and price > 10 \ 
        \ ) where date = ? \
        \ group by symbol order by avgret desc  limit ? ;"
 
getDateSqlStr :: String
getDateSqlStr = "select distinct date from " ++ dailyTable ++ " where date != 'DATE';"

lastDateSqlStr :: String
lastDateSqlStr = "select date from " ++ dailyTable ++ " order by date desc limit 1;"

sqlToDates :: [SqlValue] -> Day
sqlToDates  xs = case xs of 
    [SqlByteString x] -> parseTimeOrError True defaultTimeLocale "\"%Y%m%d\"" (show x) :: Day
    _                 -> error "sqlToDates: error"

    
sqlToSymbol :: [SqlValue] -> String
sqlToSymbol  xs = case xs of 
    [SqlByteString x] -> show x :: String 
    _                 -> error "sqlToSymbol: error" 

sqlToPrice :: [SqlValue] -> Double
sqlToPrice xs = case xs of     
    [SqlByteString x] -> (read . show)  x :: Double
    _                 -> error "sqlToPrice error" 

checkStr :: String
checkStr = "select symbol from " ++ dailyTable ++ " where symbol = ? and date >= ?;" 
