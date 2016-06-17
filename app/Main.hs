{-# LANGUAGE OverloadedStrings #-}

module Main where

import Options
import Data.Maybe
import Client (setKeys)
import Data.Yaml.YamlLight (unStr, YamlLight, parseYaml, getTerminalsKeys)
import System.Environment
import Data.ByteString.Char8 (ByteString, intercalate)

keysToStrings :: [YamlLight] -> [ByteString]
keysToStrings = reverse . mapMaybe unStr

flatten :: (ByteString, [YamlLight]) -> (ByteString, ByteString)
flatten (v,k) = (v, intercalate "/" $ keysToStrings k)

flatkeys :: YamlLight -> [(ByteString, ByteString)]
flatkeys = map flatten . getTerminalsKeys

main :: IO ()
main = do
    opts <- getArgs >>= parseArgs
    parseYaml <$> input opts >>= fmap flatkeys >>= setKeys opts
    
