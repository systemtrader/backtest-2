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
<<<<<<< HEAD
    name = "Base macrostrategy",
    investmentHorizon = Day 3,
    initialWealth = 10000,
    portfolioSize = 25,
=======
    name = "",
    investmentHorizon = Day 2,
    initialWealth = 10000,
    portfolioSize = 15,
>>>>>>> e2bb0da6eef2215aa4f58b8e8b04e0f74a2b18d4
    target = MeanReturn,
    direction = Desc}

 
            
        




