module SqlInterface where
import Data.Time
import Database.HDBC 
import Database.HDBC.Sqlite3

databaseName :: String
databaseName = "stocks.db"

dailyTable :: String
dailyTable = "miniprice"

type Formula = String
type Symbol = String

returnFormula :: Formula
returnFormula = "((f.price/b.price) - 1)"

sqlStr::String
sqlStr = "select f.symbol, f.date,f.price, ((f.price/b.price) - 1) as target  \
    \ from " ++ dailyTable ++ " f, (select symbol, date, price from prices where date = ?)  b \
    \ where b.symbol = f.symbol and f.date = ? order by target desc limit ?;"

getDateSqlStr :: String
getDateSqlStr = "select distinct date from miniprice where date != 'DATE';"

lastDateSqlStr :: String
lastDateSqlStr = "select date from " ++ dailyTable ++ " order by date desc limit 1;"

activeSymbolSqlStr :: String
activeSymbolSqlStr = "select symbol from "++dailyTable++" where date = ? \
    \intersect select symbol from "++dailyTable++" where date = ?;" 

pricesBtwSqlStr :: String
pricesBtwSqlStr = "select price from "++dailyTable++" where symbol = ? and date >= ? and date <= ?;"

sqlToDates :: [SqlValue] -> Day
sqlToDates [SqlByteString x] =  
    parseTimeOrError True defaultTimeLocale "\"%Y%m%d\"" (show x) :: Day

sqlToSymbol :: [SqlValue] -> String
sqlToSymbol [SqlByteString x] = show x :: String 

sqlToPrice :: [SqlValue] -> Double
sqlToPrice [SqlByteString x] = (read . show)  x :: Double
