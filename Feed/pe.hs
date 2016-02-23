import Data.Int (Int64)
import Control.Monad.Except
import Control.Monad.State
import Control.Monad.Writer
import System.Environment
import qualified Data.ByteString.Lazy.Char8 as C 

data Msg = Msg {
    dataType    :: String,  -- 2
    infoType    :: String,  -- 2
    mktType     :: String,  -- 1
    issueCode   :: String,  -- 12
    issueSeq    :: Int,     -- 3
    mktStatus   :: String,  -- 2
    totBidQuant :: Int,     -- 7
    fstBidPrice :: Float,   -- 5
    fstBidQuant :: Int,     -- 7
    sndBidPrice :: Float,   -- 5
    sndBidQuant :: Int,     -- 7
    thrBidPrice :: Float,   -- 5
    thrBidQuant :: Int,     -- 7
    fouBidPrice :: Float,   -- 5
    fouBidQuant :: Int,     -- 7
    fivBidPrice :: Float,   -- 5
    fivBidQuant :: Int,     -- 7
    totAskQuant :: Int,     -- 7
    fstAskPrice :: Float,   -- 5
    fstAskQuant :: Int,     -- 7
    sndAskPrice :: Float,   -- 5
    sndAskQuant :: Int,     -- 7
    thrAskPrice :: Float,   -- 5
    thrAskQuant :: Int,     -- 7
    fouAskPrice :: Float,   -- 5
    fouAskQuant :: Int,     -- 7
    fivAskPrice :: Float,   -- 5
    fivAskQuant :: Int,     -- 7
    quoteTime   :: String   -- 8
    } deriving Show

type ExceptStateIO  a = ExceptT String (StateT C.ByteString IO) a
type WriterExceptIO a = WriterT [Msg] (IO) a

key :: String
key = "B6034"

keyLength :: Int64
keyLength = (fromIntegral (length key))::Int64

hasBytes :: Bool -> Int64 -> C.ByteString -> Bool
hasBytes bool  0 _  = bool  
hasBytes False _ _  = False 
hasBytes bool n dat = if C.null dat then False else (hasBytes True (n-1) (C.tail dat))

findKey :: ExceptStateIO ()
findKey = lift get >>= 
    \dat -> if hasBytes True keyLength dat  
               then if (C.unpack . C.take keyLength) dat == key  
                       then return ()
                       else lift (put (C.tail dat)) >> findKey
               else return ()
           
parseDataType :: ExceptStateIO String
parseDataType = get >>=
    \dat -> put (C.drop 2 dat) >> 
    return( C.unpack (C.take 2 dat))

readInt :: String -> Int
readInt s = (read s)::Int

readFloat :: String -> Float
readFloat s = (read s)::Float

readString :: String -> String
readString = id
           
to64 :: Int -> Int64
to64 n = (fromIntegral n)::Int64

parse :: (String -> b) -> Int64 -> ExceptStateIO b
parse f nBytes = get >>=
    \dat -> 
        let g = f . C.unpack . C.take nBytes 
        in  put (C.drop nBytes dat) >> lift (return(g dat))

parseMsg :: ExceptStateIO Msg
parseMsg  = parseDataType    >>=
    \dat    -> parse readString (to64 2)     >>=
    \inf    -> parse readString (to64 1)     >>=
    \mkt    -> parse readString (to64 12)    >>=
    \isc    -> parse readInt    (to64 3)     >>=
    \iss    -> parse readString (to64 2)     >>=
    \mks    -> parse readInt    (to64 7)     >>=
    \tbv    -> parse readFloat  (to64 5)     >>=
    \fibp   -> parse readInt    (to64 7)     >>=
    \fibq   -> parse readFloat  (to64 5)     >>=
    \snbp   -> parse readInt    (to64 7)     >>=
    \snbq   -> parse readFloat  (to64 5)     >>=
    \thbp   -> parse readInt    (to64 7)     >>=
    \thbq   -> parse readFloat  (to64 5)     >>=
    \fobp   -> parse readInt    (to64 7)     >>=
    \fobq   -> parse readFloat  (to64 5)     >>=
    \fvbp   -> parse readInt    (to64 7)     >>=
    \fvbq   -> parse readInt    (to64 7)     >>=
    \tav    -> parse readFloat  (to64 5)     >>=
    \fiap   -> parse readInt    (to64 7)     >>=
    \fiaq   -> parse readFloat  (to64 5)     >>=
    \snap   -> parse readInt    (to64 7)     >>=
    \snaq   -> parse readFloat  (to64 5)     >>=
    \thap   -> parse readInt    (to64 7)     >>=
    \thaq   -> parse readFloat  (to64 5)     >>=
    \foap   -> parse readInt    (to64 7)     >>=
    \foaq   -> parse readFloat  (to64 5)     >>=
    \fvap   -> parse readInt    (to64 7)     >>=
    \fvaq   -> parse readString (to64 8)     >>= 
    \qtim   -> return (Msg dat inf mkt isc iss mks tbv fibp fibq 
                 snbp snbq thbp thbq fobp fobq fvbp fvbq
                 tav fiap fiaq snap snaq thap thaq foap 
                 foaq fvap fvaq qtim)

parseFeed :: C.ByteString -> WriterT [Msg] (ExceptT String IO) ()
parseFeed  dat = (lift . lift) (runESIO (findKey >> parseMsg) dat)  
    >>= \(r, s) -> case r of
                     (Left  s) -> throwError s
                     (Right b) -> tell [b] >> parseFeed s

runESIO = runStateT . runExceptT
runParser =  runExceptT . runWriterT

main :: IO()
main  = C.readFile "bin.pcap" 
    >>= runParser . parseFeed 
    >>= \c -> case c of
                Right (_, b) -> print b
                Left  s     -> print s
