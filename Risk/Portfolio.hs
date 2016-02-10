module Portfolio   where
import Data.Time


type Shares = Integer
type Share = Integer

data Cash = Cash {
                currency :: String,
                amount   :: Double
            } deriving (Show, Eq)
data Security = Equity {
                    symbol :: String,
                    price :: Double,
                    date :: UTCTime,
                    statistic :: Double
                }
                |Bond {
                    symbol :: String,
                    price :: Double,
                    date :: UTCTime,
                    statistic :: Double
                }
                deriving(Show,Eq)

data Portfolio = Portfolio { 
                    records :: [(Security, Integer)],
                    cash :: Cash
                    } 
                    deriving (Show, Eq)

data Action = Buy Share | Sell Share
    deriving (Show)
