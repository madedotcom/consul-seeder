module Options (parseArgs, Options, port, host, token, input) where

import System.Exit
import Control.Monad
import Text.Read
import System.IO
import System.Console.GetOpt
import GHC.Generics
import Data.Yaml
import System.Environment
import qualified Data.ByteString.Char8 as BS
import qualified Data.ByteString.Lazy.Char8 as LBS

parseArgs :: [String] -> IO Options
parseArgs args = do
    let (actions,nonOptions,errors) = getOpt RequireOrder options args
    foldl (>>=) (return emptyOptions) actions

data Options = Options
    { host :: String
    , port :: Int
    , input :: IO String
    , token :: Maybe String
    } 

emptyOptions :: Options
emptyOptions = 
    Options
    { host = "localhost"
    , port = 8500
    , input = getContents
    , token = Nothing
    }

options :: [OptDescr (Options -> IO Options)]
options = 
    [ Option
          "h"
          ["host"]
          (ReqArg
               (\arg opt -> 
                     return
                         opt
                         { host = arg
                         })
               "localhost")
          "The hostname or IP of a consul node. Defaults to localhost"
    , Option
          "i"
          ["input"]
          (ReqArg
               (\arg opt -> 
                     return
                         opt
                         { input = readFile arg
                         })
               "FILE")
          "The path to a yaml file containing key/value pairs. Defaults to stdin"
    , Option
          "t"
          ["token"]
          (ReqArg
               (\arg opt -> 
                     return
                         opt
                         { token = Just arg
                         })
               "")
          "The ACL token to use when talking to consul. Default None"
    , Option
          "help"
          ["help"]
          (NoArg
               (\_ -> 
                     do prg <- getProgName
                        hPutStrLn stderr (usageInfo prg options)
                        exitSuccess))
          "Show usage"
    , Option
          "p"
          ["port"]
          (ReqArg
               (\arg opt -> 
                     do let val = readEither arg :: Either String Int
                        case val of
                            Left err -> do
                                BS.hPutStrLn stderr $
                                    BS.pack $
                                    "Failed reading '" ++
                                    arg ++ "' as a number"
                                exitFailure
                            Right p -> 
                                return
                                    opt
                                    { port = p
                                    })
               "8500")
          "The port of the consul node. Defaults to 8500"]