-- target is the data set
import Rand(getRands)

data Date = Date {
    year :: Int,
    month :: Int,
    day :: Int,
    hour :: Int,
    minute :: Int,
    second :: Int,
    millisecond :: Int}

data Security = Equity {
                    symbol :: String,
                    exchange :: String,
                    lastOpen :: Float,
                    lastClose :: Float,
                    lastHigh :: Float,
                    lastLow :: Float,
                    lastVolume :: Int,
                    marketCap :: Float}
                |Bond {
                    symbol :: String,
                    exchange :: String,
                    maturity :: Date}

mean xs = (sum xs)/n where
    n = fromIntegral $ length xs
var xs = mean $ [(x - mxs)**2 | x <- xs] where
    mxs = mean xs
sharpe_ratio xs = (mean xs) /sqrt (var xs)

factor statistic windowSize target
    |windowSize > targetSize = Nothing 
    |otherwise = Just $ statistic $ take windowSize target  where
        targetSize = length target

factors statistics windowSize target = 
    map (ff windowSize target) statistics where
        ff windowSize target statistic = 
            factor statistic windowSize target
