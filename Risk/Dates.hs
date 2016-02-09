module Dates where
import Data.Time
import Database.HDBC 
import Database.HDBC.Sqlite3
import SqlInterface


data TimeUnit = Day Integer 
    |Month Integer
    |Year Integer
    deriving (Show, Eq, Read)

previousDate :: TimeUnit -> Day -> Day
previousDate (Day n) dt = addDays (-n) dt
previousDate (Month n) dt = addGregorianMonthsClip (-n) dt
previousDate (Year n) dt = addGregorianYearsClip (-n) dt

getBalancingDates :: TimeUnit -> [Day] -> [Day]
getBalancingDates _ [] = []
getBalancingDates n (x:xs) = x : getBalancingDates n ys where
    ys = filter (<= previousDate n x) xs
    
lastDate :: IO Day
lastDate = connectSqlite3 dbName
    --dbName is defined in SqlInterface
    >>= \connection -> quickQuery' connection lastDateSqlStr [] 
    >>= \sqlDate -> disconnect connection 
    >>  (return . head . (map sqlToDates))  sqlDate 
