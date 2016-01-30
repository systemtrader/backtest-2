import Dates
import Lib
import SqlInterface 
import Portfolio  
import Database.HDBC 
import Database.HDBC.Sqlite3
import Data.Time
import Data.List

data Target = MeanReturn 
    | SharpRatio
    | Volatility 
    deriving (Show, Eq)

targetToFunc :: Target -> ([Double] -> Double)
targetToFunc MeanReturn = \xs -> (sum xs) 
targetToFunc _ = sum

directionToTake :: OrderDirection -> (Int -> [a] -> [a])
directionToTake Asc = take
directionToTake Desc = \n xs -> drop (length xs - n) xs

data OrderDirection = Asc
    | Desc  deriving (Show, Eq)

data Strategy = MicroStrategy { name :: String}
    | MacroStrategy {
        name :: String,
        window :: TimeUnit,
        initialWealth :: Double,
        portfolioSize :: Int,
        target :: Target,
        direction :: OrderDirection}  
    deriving (Show, Eq)

baseMacroStrategy = MacroStrategy {
    name = "",
    window = Day 7,
    initialWealth = 10000,
    portfolioSize = 5,
    target = MeanReturn,
    direction = Desc}

toFormula :: Target -> Formula
toFormula target 
    | target == MeanReturn = returnFormula
    | otherwise = returnFormula 

activeSymbolsBtw :: Day -> Day -> IO [String]
activeSymbolsBtw fDate sDate = connectSqlite3 databaseName 
    >>= \connection -> 
        let dts = map (toSql . filter (/= '-') . showGregorian) [fDate, sDate] 
        in  quickQuery' connection activeSymbolSqlStr dts 
    >>= \sqlSymbs -> disconnect connection 
    >>  (return . (map (filter (/= '\"') . sqlToSymbol)))  sqlSymbs 
 
pricesBtw :: Symbol -> Day -> Day -> IO [Double]
pricesBtw symbol startDate endDate = connectSqlite3 databaseName 
    >>= \connection -> 
        let dts = map (toSql . filter (/= '-') . showGregorian) [startDate, endDate] 
        in  quickQuery' connection pricesBtwSqlStr ([toSql symbol] ++ dts)
    >>= \sqlPrices -> disconnect connection 
    >>  (return . (map sqlToPrice))  sqlPrices

--runStrategy :: Strategy -> IO [Pair Security Action]
runStrategy strategy = lastDate
    >>= \endDate ->
        let startDate = previousDate (window strategy) endDate
        in activeSymbolsBtw startDate endDate
    >>= \symbols ->
        let pricesBtw' fd sd sy = pricesBtw sy fd sd
        in  mapM (pricesBtw' startDate endDate) symbols
    >>= \prices -> 
        let targets = map ((targetToFunc . target) strategy) prices
            sortLis = sortBy (\(s,t) (s',t') -> compare t t') (zip symbols targets)
            porSize = portfolioSize strategy
        in  return $ ((directionToTake . direction) strategy) porSize sortLis
            
        




