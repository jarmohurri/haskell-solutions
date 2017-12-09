module Parser where
import Control.Applicative
import Data.Char

newtype Parser a = P { parse :: String -> Maybe (a, String) }

instance Functor Parser where
  fmap f p = P $ \s -> fmap (\(v, r) -> (f v, r)) $ parse p s

instance Applicative Parser where
  pure v = P $ \s -> Just (v, s)
  pf <*> p = P (\s -> case parse pf s of
                        Nothing -> Nothing
                        Just (f, r) -> parse (fmap f p) r)
  
instance Monad Parser where
  return = pure
  p >>= f = P (\s -> case parse p s of
                       Nothing -> Nothing
                       Just (v, r) -> parse (f v) r)
                          
instance Alternative Parser where
  empty = P $ \_ -> Nothing
  pa <|> pb = P $ \s -> parse pa s <|> parse pb s

empty :: Parser Bool
empty = P $ \s -> if null s then Just (True, s) else Nothing
             
accept :: (Char -> Bool) -> Parser Char
accept p = P (\s -> case s of
                      [] -> Nothing
                      (c:cs) -> if p c then Just (c, cs) else Nothing)

acceptChar :: Char -> Parser Char
acceptChar c = accept (== c)

comma :: Parser Char
comma = acceptChar ','

whitespace :: Parser Char
whitespace = acceptChar '\t' <|> acceptChar ' '

newline :: Parser Char
newline = acceptChar '\n'

doubleQuote :: Parser Char
doubleQuote = acceptChar '"'

digit :: Parser Int
digit = do
  d <- accept isDigit
  pure (read (d:[]) :: Int)

token :: Parser a -> Parser a
token p = do
  _ <- many whitespace
  t <- p
  _ <- many whitespace
  pure t

quotedString :: Parser String
quotedString = do
  _ <- token doubleQuote
  str <- many (accept (/= '"'))
  _ <- token doubleQuote
  pure str

natural :: Parser Int
natural = do
  d <- some digit
  pure $ foldl (\acc v -> 10*acc + v) 0 d

-- integer :: Parser Integer
-- integer = do
--   _ <- acceptChar '-'
  

data CSVItem = CSVString String | CSVInteger Integer
csvRow :: Parser [CSVItem]
csvRow = undefined

csvParser :: Parser [[CSVItem]]
csvParser = undefined
