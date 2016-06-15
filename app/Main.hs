{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE OverloadedStrings #-}
module Main where

import GHC.Generics
import Data.Yaml
import Network.HTTP.Simple 
import System.Environment
import qualified Data.ByteString.Lazy.Char8 as BS


data ConsulKV = ConsulKV { key :: String, value :: String } 
    deriving (Generic, Show)
instance FromJSON ConsulKV


read :: FilePath -> IO (Maybe [ConsulKV])
read = decodeFile  


setKey ::String -> ConsulKV -> IO ()
setKey hostname kv = do
    request' <- parseRequest ("PUT http://" ++ hostname ++ ":8500/v1/kv/" ++ key kv)
    let request 
            = setRequestBodyLBS (BS.pack $ value kv)
            $ request'
    response <- httpLBS request
    putStrLn $ key kv ++ " -> " ++ value kv ++ " " ++
               show (getResponseStatusCode response)
    
setKeys :: Maybe [ConsulKV] -> IO ()
setKeys Nothing = putStrLn "nope"
setKeys (Just keys) = mapM_ (setKey "localhost") keys




main :: IO ()
main = do
    args <- getArgs
    case length args of
        1 -> do s <- Main.read $ head args
                setKeys s
        _ -> putStrLn "arse"
