module Ledger where
import Portfolio
import Data.Time
import Data.List

-- The ledger makes it possibe to obain detailed information about the
-- trades at each rebalancing stage. It gets fed into a printing function
-- afterwards and makes it possible to get a sense of the correctness 
-- of the backtest
data Ledger = Ledger {
                 begDate :: [Day],
                 endDate :: [Day],
                 begSymbols :: [String],
                 endSymbols :: [String],
                 begStats :: [Double],
                 endStats :: [Double],
                 begPrices :: [Double],
                 endPrices :: [Double],
                 begShares :: [Integer], 
                 endShares :: [Integer], 
                 netPnLs :: [Double],
                 totalPnL :: Double
                 } deriving (Show)

buildLedger :: (Portfolio, Portfolio) -> Ledger
buildLedger (oldPort, newPort) = 
    let fsort x y = compare ((Portfolio.symbol . fst)  x) ((Portfolio.symbol . fst) y)
        oldRecs = sortBy fsort $ records oldPort
        newRecs = sortBy fsort $ records newPort
        dotProd a b = zipWith (*) a (map fromIntegral b)
        begsyms  =  apply symbol oldRecs
        endsyms  =  apply symbol newRecs
        getDt    = utctDay . Portfolio.date 
        apply x  = map (x . fst) 
        bd       = apply getDt oldRecs
        ed       = apply getDt newRecs
        fs    = map apply [statistic, statistic, price, price] 
        ps    = [oldRecs, newRecs, oldRecs , newRecs]
        [bs, es, bp , ep] = zipWith ( $ ) fs ps
        bsh  =  map snd $ oldRecs
        esh  =  map snd $ newRecs
        n        = zipWith (-) (ep `dotProd` esh) (bp `dotProd` bsh)
        t        = sum n
    in Ledger bd ed begsyms endsyms bs es bp ep bsh esh  n t 
    
    


