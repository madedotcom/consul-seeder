{-# LANGUAGE OverloadedStrings #-}
module Client (setKeys) where

import Options
import Model
import Network.HTTP.Simple
import qualified Data.ByteString.Char8 as BS
import qualified Data.ByteString.Lazy.Char8 as LBS

requestTemplate :: Options -> Request
requestTemplate opts = 
    let req = 
            case token opts of
                Nothing -> defaultRequest
                Just t -> 
                    setRequestQueryString
                        [(BS.pack "token", Just (BS.pack t))]
                        $defaultRequest
    in setRequestHost (BS.pack $ host opts) 
       $ setRequestMethod "PUT"
       $ setRequestPort (port opts) req

setKey :: Request -> ConsulKV -> IO ()
setKey req kv = do
    let request = 
            setRequestBodyLBS (LBS.pack $ value kv) $
            setRequestPath (BS.pack ("/v1/kv/" ++ key kv)) $ req
    response <- httpLBS request
    putStrLn $
        key kv ++
        " -> " ++ value kv ++ " " ++ show (getResponseStatusCode response)

setKeys :: Options -> [ConsulKV] -> IO ()
setKeys opts keys = 
    let template = requestTemplate opts
    in mapM_ (setKey template) keys
