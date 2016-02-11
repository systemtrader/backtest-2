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

<<<<<<< HEAD
buildLedger :: (Portfolio, Portfolio) -> Ledger
buildLedger (oldPort, newPort) = 
=======
buildLedger :: Portfolio -> Portfolio -> Ledger
buildLedger oldPort newPort = 
>>>>>>> e2bb0da6eef2215aa4f58b8e8b04e0f74a2b18d4
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
<<<<<<< HEAD
        ps    = [oldPort, newPort, oldPort , newPort]
=======
        ps    = [oldPort, oldPort, newPort, newPort]
>>>>>>> e2bb0da6eef2215aa4f58b8e8b04e0f74a2b18d4
        [bs, es, bp , ep] = zipWith ( $ ) fs ps
        [esh, bsh]  = map (map snd . records) [newPort, oldPort]
        n        = zipWith (-) (ep `dotProd` esh) (bp `dotProd` bsh)
        t        = sum n
    in Ledger theDate syms bs es bp ep bsh esh  n t 
    
    


