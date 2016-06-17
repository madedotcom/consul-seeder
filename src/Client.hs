{-# LANGUAGE OverloadedStrings #-}

module Client (setKeys) where

import Options
import Model
import Network.HTTP.Simple
import qualified Data.ByteString.Char8 as BS
       (append, ByteString, pack, putStrLn)
import qualified Data.ByteString.Lazy.Char8 as LBS

join :: [BS.ByteString] -> BS.ByteString
join = foldl BS.append ""

requestTemplate :: Options -> Request
requestTemplate opts = 
  let req = 
        case token opts of
          Nothing -> defaultRequest
          Just t -> 
            setRequestQueryString [("token",Just (BS.pack t))] $
            defaultRequest
  in setRequestHost (BS.pack $ host opts) $
     setRequestMethod "PUT" $
     setRequestPort (port opts)
                    req

setKey :: Request -> ConsulKV -> IO ()
setKey req kv = 
  do let request = 
           setRequestBodyLBS (LBS.fromStrict $ fst kv) $
           setRequestPath (join ["/v1/kv/",snd kv]) $ req
     response <- httpLBS request
     BS.putStrLn $
       join [snd kv
            ," -> "
            ,fst kv
            ," "
            ,(BS.pack . show) (getResponseStatusCode response)]

setKeys :: Options -> [ConsulKV] -> IO ()
setKeys opts keys = 
  let template = requestTemplate opts
  in mapM_ (setKey template) keys
