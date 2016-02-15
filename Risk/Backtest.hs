module Backtest where
import OptPort
import Database.HDBC 
import Database.HDBC.Sqlite3
import Dates
import Lib
import Control.Monad
import Print
import SqlInterface
import Strategy
import Ledger 

backTest :: Strategy -> IO()
backTest strategy = connectSqlite3 dbName 
    >>= \conn -> 
        let zdates = liftM (map sqlToDates) (quickQuery' conn getDateSqlStr [])
            bDateFun = getBalancingDates ( investmentHorizon strategy) . reverse 
            bDates = liftM bDateFun zdates
        in  liftM (interLink . reverse) bDates
    >>= \datePairs-> 
        let size = portfolioSize strategy
        in  liftM (map (map toSecurity)) (mapM (optPort conn size) datePairs)
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
            oldNewPs = wealthSeries startWealth (init securities) updatedSecs 
        in  mapM printLedger (map buildLedger oldNewPs) 
    >> (printTable . printResult startWealth (tail datePairs) . map snd) oldNewPs
