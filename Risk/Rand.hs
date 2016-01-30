module Rand where 
import System.Random
type Errors = [Float]
type Returns = [Float]
type Start = Float
b :: IO Int
b = (return 3)::(IO Int)

data Model = AR Float

addMonad :: IO Int -> Int -> IO Int
addMonad a b = a >>= \x -> return (x + b) 

getRands :: Int -> IO [Float]
getRands n = newStdGen >>= \x -> return (take n (randoms x))  

sim [] y p  = []
sim (x:xs) z p = ((x+y) : sim xs (x + y) p) where
    y = p*z

simar n p =  getRands n >>= \es ->  return $sim es (head es) p

