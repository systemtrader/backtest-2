module OptPort where 
import Database.HDBC 
import Database.HDBC.Sqlite3
import Portfolio
import Dates 
import Data.Time 
import Data.List 
import Lib
import SqlInterface

toSecurity::[SqlValue] -> Security
toSecurity xs@[_, _,_] = toSecurity (xs++[SqlDouble 0.0]) 
toSecurity xs@[SqlByteString s, SqlByteString d, SqlDouble p, SqlDouble st] 
    | length xs /= 4 = error "Wrong number of input given\n"
    | otherwise = Equity (filter (/= '\"') (show s)) (realToFrac p) dt (realToFrac st) where
    dt = parseTimeOrError True defaultTimeLocale "\"%Y%m%d\"" (show d) :: UTCTime

toPort :: Double -> [Security] -> Portfolio
toPort totWealth xs = 
    let 
        alloc = totWealth / fromIntegral (length (xs))
        f x = floor (alloc /price x)
        tport = Portfolio (zipWith (\a b -> (a, b)) xs (map f xs))  
        tval = portValue tport
    in (\(Portfolio sx) -> Portfolio (sx ++ [(Cash {symbol = "Dollars", price = (totWealth - tval)}, 1)])) tport

secValue :: Security -> Shares -> Double
secValue asset shares = 
    (price asset)*(fromIntegral shares)

portValue :: Portfolio -> Double
portValue (Portfolio xs) = 
    sum [secValue asset share| (asset, share) <- xs]

wealthSeries :: Double -> [[Security]] ->  [[Security]] -> [Portfolio]
wealthSeries _ _ [] = []
wealthSeries value (x:xs) (y:ys) 
    | value <= 0.0 = []  
    | otherwise = yport : wealthSeries (portValue yport) xs ys where
        xport = toPort value x
        ds = (\(Portfolio s) -> s) xport
        yport = Portfolio ((zipWith (\a b -> (a,b)) y [s| (_, s) <- init ds]) ++ [last ds])


buildCallBackSql :: Int -> String
buildCallBackSql nassets = "select symbol, date, price from miniprice \
        \ where symbol in (" ++ marks ++ ") and date = ?;" where
    marks = intersperse ',' $ take nassets (repeat '?') 

getEndPrice :: Connection -> [Security] -> Day  -> IO [[SqlValue]] 
getEndPrice conn secs date = quickQuery' conn (buildCallBackSql (length secs)) pars where
    pars = [toSql (symbol sec) | sec <- secs] ++ [toSql dt]
    dt = filter (/= '-') (showGregorian date)  

optPort :: Connection -> Int -> Pair Day Day  -> IO [[SqlValue]] 
optPort conn n (Pair (sd, ed)) = quickQuery' conn sqlStr [toSql sds, toSql eds, toSql n] where
    sds = filter (/= '-') (showGregorian sd)  
    eds = filter (/= '-') (showGregorian ed)  


