module Print where
import Text.PrettyPrint.Boxes
import Lib
import OptPort
import Data.Time
import Portfolio

alignDecimal :: String -> String
alignDecimal ns = 
    let 
        fs = break (=='.')
        fi = \x -> if (length (snd x)) == 3 
                   then x else (fst x, (snd x)++"0")
        fc = \(x,y) -> x ++ y
    in (fc . fi . fs) ns

round' :: Int ->  Double -> Double
round' n x = ((fromIntegral . floor) (x * t)) / t where
    t = 10^n

printResult :: Double -> [Pair Day Day] -> [Portfolio] -> Box
printResult startWealth linkedDates portfolios =
    let dtl = text "Exec. Date"
        pvl = text "Port. Value"
        std = showGregorian $ (\(Pair x) -> fst x) (linkedDates!!0)
        tas = text . alignDecimal . show . round' 2
        f   = map (tas . portValue)
        g   = map (text . showGregorian) . uninterLink 2 
        dts = [dtl] ++ [text std] ++ (g linkedDates)
        pvs = [pvl] ++ [tas startWealth] ++ (f portfolios)
    in  (vcat left dts) <+> (vcat right pvs)

