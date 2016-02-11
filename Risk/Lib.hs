module Lib where

data Pair a b = Pair (a,b) deriving (Show, Eq)

interLink ::[a]->[Pair a a] 
interLink [] = []
interLink (_:[]) = []
interLink (y:x:xs) = Pair (y,x): interLink (x:xs)

uninterLink :: Int -> [Pair a a] -> [a]
uninterLink i xs 
    | i == 1 = [x | Pair (x, _) <- xs]
    | i == 2 = [x | Pair (_, x) <- xs]
    | otherwise = error "2nd arg can only be either 1 or 2"


