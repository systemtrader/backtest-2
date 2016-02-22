import Data.Int (Int64)
import Control.Monad.Except
import Control.Monad.State
import Control.Monad.Writer
import System.Environment
import qualified Data.ByteString.Lazy.Char8 as C 

data Msg = Msg {
    dataType    :: Maybe String,  -- 2
    infoType    :: Maybe String,  -- 2
    mktType     :: Maybe String,  -- 1
    issueCode   :: Maybe String,  -- 12
    issueSeq    :: Maybe Int,     -- 3
    mktStatus   :: Maybe String,  -- 2
    totBidQuant :: Maybe Int,     -- 7
    fstBidPrice :: Maybe Float,   -- 5
    fstBidQuant :: Maybe Int,     -- 7
    sndBidPrice :: Maybe Float,   -- 5
    sndBidQuant :: Maybe Int,     -- 7
    thrBidPrice :: Maybe Float,   -- 5
    thrBidQuant :: Maybe Int,     -- 7
    fouBidPrice :: Maybe Float,   -- 5
    fouBidQuant :: Maybe Int,     -- 7
    fivBidPrice :: Maybe Float,   -- 5
    fivBidQuant :: Maybe Int,     -- 7
    totAskQuant :: Maybe Int,     -- 7
    fstAskPrice :: Maybe Float,   -- 5
    fstAskQuant :: Maybe Int,     -- 7
    sndAskPrice :: Maybe Float,   -- 5
    sndAskQuant :: Maybe Int,     -- 7
    thrAskPrice :: Maybe Float,   -- 5
    thrAskQuant :: Maybe Int,     -- 7
    fouAskPrice :: Maybe Float,   -- 5
    fouAskQuant :: Maybe Int,     -- 7
    fivAskPrice :: Maybe Float,   -- 5
    fivAskQuant :: Maybe Int,     -- 7
    quoteTime   :: Maybe String   -- 8
    } deriving Show

type StateByte a = StateT C.ByteString IO a
type ErrorStateByteIO a = ExceptT String (StateT C.ByteString IO) a
type WriterStateByteIO a = WriterT [Msg] (StateT C.ByteString IO) a

key :: String
key = "B6034"

keyLength :: Int64
keyLength = (fromIntegral (length key))::Int64

hasBytes :: Bool -> Int64 -> C.ByteString -> Bool
hasBytes bool  0 _  = bool  
hasBytes False _ _  = False 
hasBytes bool n dat = if C.null dat then False else (hasBytes True (n-1) (C.tail dat))

findKey :: StateByte (Maybe ())
findKey = get >>= 
    \dat -> if hasBytes True keyLength dat  
               then if (C.unpack . C.take keyLength) dat == key  
                       then return (Just ())
                       else put (C.tail dat) >> findKey
               else return Nothing
           
parseDataType :: Maybe () -> StateByte (Maybe String)
parseDataType Nothing  = return Nothing
parseDataType (Just _) = get >>=
    \dat -> put (C.drop 2 dat) >> 
    return (Just ( C.unpack (C.take 2 dat))) 

parse :: (String -> b) -> Int64 -> Maybe a -> StateByte (Maybe b)
parse _ _      Nothing  = return Nothing
parse f nBytes (Just _) = get >>=
    \dat -> 
        let g = f . C.unpack . C.take nBytes 
        in  put (C.drop nBytes dat) >> return (Just (g dat))

readInt :: String -> Int
readInt s = (read s)::Int

readFloat :: String -> Float
readFloat s = (read s)::Float

readString :: String -> String
readString = id
           
to64 :: Int -> Int64
to64 n = (fromIntegral n)::Int64

parseMsg :: Maybe () -> StateByte (Maybe Msg)
parseMsg outcome = parseDataType outcome            >>=
    \dat    -> parse readString (to64 2)    dat     >>=
    \inf    -> parse readString (to64 1)    inf     >>=
    \mkt    -> parse readString (to64 12)   mkt     >>=
    \isc    -> parse readInt    (to64 3)    isc     >>=
    \iss    -> parse readString (to64 2)    iss     >>=
    \mks    -> parse readInt    (to64 7)    mks     >>=
    \tbv    -> parse readFloat  (to64 5)    tbv     >>=
    \fibp   -> parse readInt    (to64 7)    fibp    >>=
    \fibq   -> parse readFloat  (to64 5)    fibq    >>=
    \snbp   -> parse readInt    (to64 7)    snbp    >>=
    \snbq   -> parse readFloat  (to64 5)    snbq    >>=
    \thbp   -> parse readInt    (to64 7)    thbp    >>=
    \thbq   -> parse readFloat  (to64 5)    thbq    >>=
    \fobp   -> parse readInt    (to64 7)    fobp    >>=
    \fobq   -> parse readFloat  (to64 5)    fobq    >>=
    \fvbp   -> parse readInt    (to64 7)    fvbp    >>=
    \fvbq   -> parse readInt    (to64 7)    fvbq    >>=
    \tav    -> parse readFloat  (to64 5)    tbv     >>=
    \fiap   -> parse readInt    (to64 7)    fiap    >>=
    \fiaq   -> parse readFloat  (to64 5)    fiaq    >>=
    \snap   -> parse readInt    (to64 7)    snap    >>=
    \snaq   -> parse readFloat  (to64 5)    snaq    >>=
    \thap   -> parse readInt    (to64 7)    thap    >>=
    \thaq   -> parse readFloat  (to64 5)    thaq    >>=
    \foap   -> parse readInt    (to64 7)    foap    >>=
    \foaq   -> parse readFloat  (to64 5)    foaq    >>=
    \fvap   -> parse readInt    (to64 7)    fvap    >>=
    \fvaq   -> parse readString (to64 8)    fvaq    >>=
    \qtim   -> return $ Just (Msg dat inf mkt isc iss mks tbv fibp fibq 
                 snbp snbq thbp thbq fobp fobq fvbp fvbq
                 tav fiap fiaq snap snaq thap thaq foap 
                 foaq fvap fvaq qtim)

parseFeed :: WriterStateByteIO (Maybe Msg)
parseFeed  =  lift findKey 
    >>= \out -> lift (parseMsg out) 
    >>= \msg -> case msg of
                  Nothing -> error "Nothing left to parse"
                  Just x  -> tell [x] 
    >>  liftIO (print msg) >> parseFeed

runWSBIO = runStateT . runWriterT

main :: IO()
main = getArgs 
    >>= \[fileName] -> C.readFile fileName
    >>= \dat -> runWSBIO parseFeed dat >> return ()
