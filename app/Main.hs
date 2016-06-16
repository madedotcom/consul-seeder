{-# LANGUAGE OverloadedStrings #-}

module Main where

import Options
import Model
import Client (setKeys)
import System.Exit
import Data.Yaml
import System.Environment
import qualified Data.ByteString.Char8 as BS

main :: IO ()
main = do
    opts <- getArgs >>= parseArgs
    yaml <- BS.pack <$> input opts
    case decodeEither yaml :: Either String [ConsulKV] of
        Left err -> do
            putStrLn err
            exitFailure
        Right keys -> setKeys opts keys
