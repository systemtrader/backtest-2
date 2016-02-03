module Print where
import Text.PrettyPrint.Boxes
import Lib
import OptPort
import Data.Time
import Portfolio
import Text.Printf

alignDecimal :: String -> String
alignDecimal ns = 
    let 
        fs = break (=='e')
        fi = \x -> if (length (snd x)) == 3 
                   then x else (fst x, 
                        [head (snd x)] ++"0"++(tail (snd x)))
        fc = \(x,y) -> x ++ y
    in (fc . fi . fs) ns

round' :: Integer ->  Double -> Double
round' n x = ((fromIntegral . floor) (x * t)) / t where
    t = 10^n

printResult :: Double -> [Pair Day Day] -> [Portfolio] -> Box
printResult startWealth linkedDates portfolios =
    let dh  = text "Dates"
        vh  = text "Value"
        ul  = text "-------"
        ull  = text "----------"
        std = showGregorian $ (\(Pair x) -> fst x) (linkedDates!!0)
        tlp = text . alignDecimal . (\x -> x::String) . printf "%.2e"
        g   = map (text . showGregorian) . uninterLink 2 
        f   = map (tlp . portValue) 
        dts = [dh, ull] ++ [text std] ++ (g linkedDates)
        pvs = [vh, ul] ++ [tlp startWealth] ++ (f portfolios)
    in  (vcat left dts) <+> 
        (emptyBox (length portfolios) 4) <+> (vcat left pvs)

printTable :: Box -> IO()
printTable box = 
    putStrLn ""
    >> printBox box
    >> putStrLn ""

