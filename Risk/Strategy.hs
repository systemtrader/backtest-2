module Strategy where
import Dates

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

baseMacroStrategy :: Strategy
baseMacroStrategy = MacroStrategy {
    name = "Base macrostrategy",
    investmentHorizon = Day 3,
    initialWealth = 10000,
    portfolioSize = 25,
    target = MeanReturn,
    direction = Desc}

 
            
        




