module Backtest where
import System.Environment
import OptPort
import Database.HDBC 
import Database.HDBC.Sqlite3
import Dates
import Lib
import Control.Monad
import Print
import Text.PrettyPrint.Boxes
import SqlInterface
import Strategy

backTest strategy = connectSqlite3 dbName 
    >>= \conn -> quickQuery' conn getDateSqlStr [] 
    -- sqlToDates is in the Dates module and works
    -- as promised
    >>= return . (map sqlToDates)
    >>= return . (getBalancingDates $ investmentHorizon strategy) . reverse 
    >>= return . interLink . reverse 
    -- Interlink conveniently put consecutive
    -- investment and rebalancing dates in pairs
    >>= \datePairs-> 
        let size = portfolioSize strategy
        in  mapM (optPort conn size) datePairs
    >>= return . (map (map toSecurity))
    -- The above obtains the optimal securities according to the 
    -- specified strategy for all the dates 
    >>= \securities -> 
        let ds = [dt | Pair (_, dt) <- tail datePairs]
        in  zipWithM (getEndPrice conn) (init securities) ds  
    -- The dates are shifted by one investment period
    -- and the price of the socalled optimal portfolios are assessed
    -- The rawsymbols and prices are intermediate
    >>= \rawSymbols ->  disconnect conn
    >>  return (map (map toSecurity ) rawSymbols)
    >>= \updatedSecs -> 
        let startWealth = initialWealth strategy 
        -- Get getWealthseries produces values for the 
        -- porfolio at the end of each investment period
        in  return (wealthSeries startWealth (init securities) updatedSecs) 
    >>= printTable . printResult startWealth (tail datePairs) . map snd 
    


       
    

