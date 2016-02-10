import Network.HTTP
symbol = "ADXS"
datyear = "2015"
datmonth = "12"
datday = "00"
url1 =  "http://real-chart.finance.yahoo.com/table.csv?s="++symbol++"&a="++datday++"&b="++datmonth++"&c="++datyear++"&d="++datday++"&e="++datmonth++"&f="++datyear++"&g=d&ignore=.csv"
type Value = Double
type Shares = Int
type Price = Double
url2 = "http://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20yahoo.finance.quotes%20where%20symbol%20in%20%28%22GLD,SLV%22%29&env=store://datatables.org/alltableswithkeys&format=json"

url ="http://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20yahoo.finance.historicaldata%20where%20symbol%20%3D%20%22AAPL%22%20and%20startDate%20%3D%20%222012-09-11%22%20and%20endDate%20%3D%20%222014-02-11%22&format=json&diagnostics=true&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys&callback="
currPosition :: Shares -> Price -> Value
currPosition s p = (fromIntegral s) * p

primes = filterPrime [2..] where 
    filterPrime (p:xs) = p : filterPrime [x | x <- xs, x `mod` p /= 0]
resp = simpleHTTP (getRequest url)
dat = resp >>= getResponseBody
       
