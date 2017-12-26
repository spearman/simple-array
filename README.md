# `SimpleArray`

> Simple wrapper around `Data.IOArray` mutable arrays.

## Installation

    idris --install package.ipkg

Make the package available to Idris with the flag `-p simple-array`.

## Usage

```idris
import SimpleArray

main : IO ()
main = do
  array <- SimpleArray.new 5 9
  putStrLn !(SimpleArray.show array)
  putStrLn $ "contains  9: " ++ show !(SimpleArray.contains array  9)
  putStrLn $ "contains 10: " ++ show !(SimpleArray.contains array 10)
  _ <- SimpleArray.fromIndex array (\i => i * 3)
  putStrLn !(SimpleArray.show array)
  _ <- SimpleArray.mapInplace (+1) array
  putStrLn !(SimpleArray.show array)
```
