module Strategy where
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
        investmentHorizon :: TimeUnit,
        initialWealth :: Double,
        portfolioSize :: Integer,
        target :: Target,
        direction :: OrderDirection}  
    deriving (Show, Eq)

baseMacroStrategy = MacroStrategy {
    name = "",
    investmentHorizon = Day 1,
    initialWealth = 10000,
    portfolioSize = 5,
    target = MeanReturn,
    direction = Asc}

 
            
        




