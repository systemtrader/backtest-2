module Dates where
import Data.Time
import Data.Time.Format
import Database.HDBC 
import Database.HDBC.Sqlite3
import Lib
import SqlInterface

data TimeUnit = Day Integer 
    |Month Integer
    |Year Integer
    deriving (Show, Eq, Read)

previousDate :: TimeUnit -> Day -> Day
previousDate (Day n) dt = addDays (-n) dt
previousDate (Month n) dt = addGregorianMonthsClip (-n) dt
previousDate (Year n) dt = addGregorianYearsClip (-n) dt

turnOverDates :: TimeUnit -> [Day] -> [Day]
turnOverDates n [] = []
turnOverDates n (x:xs) = x : turnOverDates n ys where
    ys = filter (<= previousDate n x) xs

    
lastDate :: IO Day
lastDate = connectSqlite3 databaseName 
    >>= \connection -> quickQuery' connection lastDateSqlStr [] 
    >>= \sqlDate -> disconnect connection 
    >>  (return . head . (map sqlToDates))  sqlDate 
    

