module Portfolio   where
import Data.Time


type Shares = Integer
type Share = Integer

data Security = Equity {
                    symbol :: String,
                    price :: Double,
                    date :: UTCTime,
                    statistic :: Double}
                |Bond {
                    symbol :: String,
                    price :: Double,
                    date :: UTCTime,
                    statistic :: Double}
                |Cash {
                    symbol :: String,
                    price :: Double}
                deriving(Show,Eq)

newtype Portfolio = Portfolio { 
                    records :: [(Security, Integer)]} 
    deriving (Show, Eq)

data Action = Buy Share | Sell Share
    deriving (Show)
