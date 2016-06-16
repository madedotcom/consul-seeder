{-# LANGUAGE OverloadedStrings #-}

module Main where

import Options
import Model
import Client
import System.Exit
import Data.Yaml
import Control.Monad
import Text.Read
import System.IO
import System.Console.GetOpt
import Network.HTTP.Simple
import System.Environment
import qualified Data.ByteString.Char8 as BS
import qualified Data.ByteString.Lazy.Char8 as LBS

main :: IO ()
main = do
    opts <- getArgs >>= parseArgs
    yaml <- BS.pack <$> input opts
    case decodeEither yaml :: Either String [ConsulKV] of
        Left err -> do
            putStrLn err
            exitFailure
        Right keys -> putStrLn "yay"