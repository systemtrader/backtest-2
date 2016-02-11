module Portfolio   where
import Data.Time


type Shares = Integer
type Share = Integer

<<<<<<< HEAD
data Cash = Cash {
                currency :: String,
                amount   :: Double
            } deriving (Show, Eq)
=======
>>>>>>> e2bb0da6eef2215aa4f58b8e8b04e0f74a2b18d4
data Security = Equity {
                    symbol :: String,
                    price :: Double,
                    date :: UTCTime,
<<<<<<< HEAD
                    statistic :: Double
                }
=======
                    statistic :: Double}
>>>>>>> e2bb0da6eef2215aa4f58b8e8b04e0f74a2b18d4
                |Bond {
                    symbol :: String,
                    price :: Double,
                    date :: UTCTime,
<<<<<<< HEAD
                    statistic :: Double
                }
                deriving(Show,Eq)

data Portfolio = Portfolio { 
                    records :: [(Security, Integer)],
                    cash :: Cash
                    } 
                    deriving (Show, Eq)
=======
                    statistic :: Double}
                |Cash {
                    symbol :: String,
                    price :: Double}
                deriving(Show,Eq)

newtype Portfolio = Portfolio { 
                    records :: [(Security, Integer)]} 
    deriving (Show, Eq)
>>>>>>> e2bb0da6eef2215aa4f58b8e8b04e0f74a2b18d4

data Action = Buy Share | Sell Share
    deriving (Show)
