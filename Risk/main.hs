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

backTest' dbName daysBtwTrans portfolioSize startWealth = 
    connectSqlite3 dbName >>= \conn -> quickQuery' conn getDateSqlStr [] 
    >>= return . (map sqlToDates)
    >>= return . (turnOverDates daysBtwTrans) . reverse
    >>= return . interLink . reverse 
    >>= \seds -> mapM (optPort conn portfolioSize) seds 
    >>= return . (map (map toSecurity))
    >>= \secss -> 
        let ds = [dt | Pair (_, dt) <- tail seds]
        in  zipWithM (endPrice conn) (init secss) ds  
    >>= \fromDb ->  disconnect conn
    >>  return (map (map toSecurity ) fromDb)
    >>= \esecss -> return (wealthSeries startWealth (init secss) esecss) 
    >>= printBox . printResult startWealth (tail seds)  
    
main :: IO ()
main = getArgs
    >>= \argv -> 
        let dbName = databaseName 
            execInt = Day (read (argv !! 1):: Integer)  
            size = (read (argv !! 2)) :: Integer
            wealth  = (read (argv !! 3)) :: Double
        in  backTest' dbName execInt size wealth 

        
    

