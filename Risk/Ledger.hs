module Ledger where
import Portfolio
import Data.Time

-- The ledger makes it possibe to obain detailed information about the
-- trades at each rebalancing stage. It gets fed into a printing function
-- afterwards and makes it possible to get a sense of the correctness 
-- of the backtest
data Ledger = Ledger {
                 date :: Day,
                 symbols :: [String],
                 begStats :: [Double],
                 endStats :: [Double],
                 begPrices :: [Double],
                 endPrices :: [Double],
                 begShares :: [Integer], 
                 endShares :: [Integer], 
                 netPnLs :: [Double],
                 totalPnL :: Double
                 }

buildLedger :: Portfolio -> Portfolio -> Ledger
buildLedger oldPort newPort = 
    let
        -- theDate : the rbalancing date
        -- bs, es  : starting and ending statistics
        -- bp, ep  : starting and ending price
        -- sh      : shares in each symbol
        -- n       : net pnl on each symbol
        -- t       : total pnl
        dotProd a b = zipWith (*) a (map fromIntegral b)
        -- Dot product used later
        syms  =  apply symbol oldPort
        getDt    = utctDay . Portfolio.date . fst . head . records 
        -- Date extraction function
        apply x  = map (x . fst) . records
        theDate  = getDt newPort
        -- Newportfolio date is presumably the rebalancing date
        fs    = map apply [statistic, statistic, price, price] 
        ps    = [oldPort, oldPort, newPort, newPort]
        [bs, es, bp , ep] = zipWith ( $ ) fs ps
        [esh, bsh]  = map (map snd . records) [newPort, oldPort]
        n        = zipWith (-) (ep `dotProd` esh) (bp `dotProd` bsh)
        t        = sum n
    in Ledger theDate syms bs es bp ep bsh esh  n t 
    
    


