module OptPort where 
import Control.Monad.Reader
import Control.Monad.Identity
import Database.HDBC 
import Database.HDBC.Sqlite3
import Portfolio
import Data.Time 
import Data.List 
import Lib
import SqlInterface

data Env = Env {
         theConnection :: Connection,
         theDate :: String,
         theSecurity :: Security
}

type TheDate = String
data Status = Active | Inactive
type Context a = ReaderT Env IO a

runContext  = runReaderT 


toSecurity::[SqlValue] -> Security
toSecurity xs = case xs of 
    [_, _,_] -> toSecurity (xs++[SqlDouble 0.0]) 
    [SqlByteString s, SqlByteString d, SqlDouble p, SqlDouble st] ->
        if length xs /= 4 then  error "Wrong number of input given\n"
        else Equity (filter (/= '\"') (show s)) (realToFrac p) dt (realToFrac st) where
            dt = parseTimeOrError True defaultTimeLocale "\"%Y%m%d\"" (show d) :: UTCTime
    _      -> error "toSecurity error"

toPort :: Double -> [Security] -> Portfolio
toPort totWealth xs = 
    let 
        alloc = totWealth / fromIntegral (length (xs))
        f x = floor (alloc /price x)
        tport = Portfolio {records = (zip xs (map f xs)),  cash = Cash "Dollars" 0.0}  
        tval = portValue tport
        dcash = Cash "Dollars" (totWealth - tval)
    in (\(Portfolio sx _) zcash -> Portfolio sx zcash) tport dcash

secValue :: Security -> Shares -> Double
secValue asset shares = 
    (price asset)*(fromIntegral shares)

portValue :: Portfolio -> Double
portValue (Portfolio xs c) = 
    (amount c) + sum [secValue asset share| (asset, share) <- xs]

wealthSeries :: Double -> [[Security]] ->  [[Security]] -> [(Portfolio, Portfolio)]
-- Return porfolio prices are the start and end of the investment period
-- the old portfolio is the fist in the pair.
wealthSeries _ [] _ = []
wealthSeries _ _ [] = []
wealthSeries value (x:xs) (y:ys) = (xport, yport) : wealthSeries (portValue yport) xs ys where
        -- The point of recomputing the portfolio is to figure out the
        -- shares. This makes no sense what so ever. The information about
        -- shares really out to be passed down.
        fsort a b = compare ((Portfolio.symbol)  a) ((Portfolio.symbol) b)
        xsorted = sortBy fsort x 
        ysorted = sortBy fsort y 
        xport = toPort value xsorted
        -- The (security, share) data is stored in ds
        shares = map snd (records xport)
        -- y has its own securities. It just needs the relevant shares
        -- information. The last item corresponds to cash. The cash
        -- information is presumably not coded in the y's.
        yport = Portfolio (zip ysorted shares) (cash xport)


buildCallBackSql :: Integer -> String
buildCallBackSql nassets = "select symbol, date, price from minireturn \
        \ where symbol in (" ++ marks ++ ") and date = ?;" where
    marks = intersperse ',' $ replicate (fromInteger nassets) '?' 

getEndPrice :: Connection -> [Security] -> Day  -> IO [Security] 
getEndPrice conn secs theDate =     
    let pars = [toSql (symbol sec) | sec <- secs] ++ [toSql dt]
        dt = filter (/= '-') (showGregorian theDate)  
        raws = quickQuery' conn (buildCallBackSql (fromIntegral (length secs))) pars 
    in raws >>= \rs -> return ( map toSecurity rs)
    >>= \ nsecs -> mapM  (verify dt conn) (findMissing secs nsecs)
    >>= \ ups -> return $ nsecs ++ ups

optPort :: Connection -> Integer -> Pair Day Day  -> IO [[SqlValue]] 
optPort conn n (Pair (sd, ed)) = quickQuery' conn sqlStr [toSql sds, toSql eds, toSql eds, toSql n] where
    sds = filter (/= '-') (showGregorian sd)  
    eds = filter (/= '-') (showGregorian ed)  

-----------------------------------------------------------------------------------------------------------
queryDB :: Env -> String -> IO [[SqlValue]]
queryDB env sqlStr = 
        let ([sym, dt], conn) = ([f env | f <- [symbol . theSecurity, theDate]], theConnection env)
        in  quickQuery' conn sqlStr [toSql sym, toSql dt] 

checkStatus :: Context Status
checkStatus  = 
    ask >>= \ env -> liftIO (queryDB env checkStr)
        >>= \ rs  -> case rs of
                         [[]] -> return Inactive
                         _    -> return Active

getLastTrade :: Status -> Context (Maybe [[SqlValue]])
getLastTrade Inactive  = return Nothing
getLastTrade Active    = 
    ask >>= \ env -> 
            let ltStr = "select date, price from " ++ dailyTable ++ " where symbol = ? and date < ? order by date desc limit 1;"
            in  liftIO (queryDB env ltStr)
        >>= \ rs  -> case rs of
                         [[]] -> error "last traded price not found"
                         _    -> return $ Just rs

updateSecurity :: Maybe [[SqlValue]] -> Context Security
updateSecurity Nothing  = error "Nothing found in updateSecurity" 
updateSecurity newprice = 
    ask >>= \ env -> 
                let f d = parseTimeOrError True defaultTimeLocale "\"%Y%m%d\"" (show d) :: UTCTime
                in  case newprice of
                         Just [[SqlByteString dt, SqlDouble p]] -> return $ (theSecurity env) {price = p, date = f dt}
                         _               -> error "updateSecurity error"
        
findMissing :: [Security] -> [Security] -> [Security]
findMissing old new = 
    let 
        ff :: Security -> [Security] -> Bool
        ff s ss = 
            let nss = map symbol ss
            in  not (symbol s `elem` nss)
    in  filter (`ff` new) old

verify :: TheDate -> Connection -> Security -> IO Security
verify dt con bs = 
    let env =  Env con dt bs
    in  runContext (    checkStatus 
                    >>= getLastTrade 
                    >>= updateSecurity) env



                     
              




