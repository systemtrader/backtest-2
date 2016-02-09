import Data.Binary
import Data.MonoTraversable
import System.Environment
import qualified Data.ByteString.Lazy.Char8 as C 
import qualified Data.ByteString.Lazy as L 

countBs n [] = n
countBs n xs = case take 5 xs of
    "B6034" -> countBs (n+1) (drop 5 xs)
    _       -> countBs n (tail xs)


main :: IO()
main = getArgs 
    >>= \[fileName] -> C.readFile fileName
    >>= print . countBs 0 . C.unpack 
