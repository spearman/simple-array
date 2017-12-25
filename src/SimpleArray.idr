{------------------------------------------------------------------------------
    SimpleArray.idr
------------------------------------------------------------------------------}

||| A simple mutable array type built on `Data.IOArray`.

module SimpleArray

import Data.IOArray

%default total

||| A wrapper around `Data.IOArray` that also stores the number of elements in
||| the array.
public export
record SimpleArray (elem : Type) where
  constructor MkSimpleArray
  inner : IOArray elem
  size  : Int

||| Creates a new `SimpleArray` of the given size with all elements initialized
||| to the given default value.
export
new : Int -> elem -> IO (SimpleArray elem)
new n e = do
  inner <- newArray n e
  pure $ MkSimpleArray inner n

||| get an element from the array; yields `Nothing` if index is negative or
||| larger than the array size.
export
get : SimpleArray elem -> Int -> IO (Maybe elem)
get array@(MkSimpleArray inner size) i =
  pure $ if size <= i then Nothing else Just !(unsafeReadArray inner i)

||| Write a value into the array, yielding `Nothing` if the index is negative
||| or larger than the array size.
export
put : SimpleArray elem -> Int -> elem -> IO (Maybe ())
put array@(MkSimpleArray inner size) i e =
  pure $ if size <= i then Nothing else Just !(unsafeWriteArray inner i e)

||| map a function over the given array, creating a new array holding the
||| results.
export
map : Monoid b => (a -> b) -> SimpleArray a -> IO (SimpleArray b)
map f array@(MkSimpleArray from size) = do
  to <- newArray size neutral
  for (take (toNat size) $ iterate (+1) 0) (\i => do
    e <- unsafeReadArray from i
    unsafeWriteArray to i $ f e
  )
  pure $ MkSimpleArray to size

||| map a function over the given array, writing the result values directly
||| into the array.
export
mapInplace : (elem -> elem) -> SimpleArray elem -> IO (SimpleArray elem)
mapInplace f array@(MkSimpleArray inner size) = do
  for (take (toNat size) $ iterate (+1) 0) (\i => do
    e <- unsafeReadArray inner i
    unsafeWriteArray inner i $ f e
  )
  pure array

||| Fill array elements with result of applying the given function to each
||| element index.
export
fromIndex : SimpleArray elem -> (Int -> elem) -> IO (SimpleArray elem)
fromIndex array@(MkSimpleArray inner size) f = do
  for (take (toNat size) $ iterate (+1) 0) (\i => do
    unsafeWriteArray inner i $ f i
  )
  pure array

||| Check if a given element is contained in this array.
export
covering
contains : Eq elem => SimpleArray elem -> elem -> IO Bool
contains (MkSimpleArray inner size) e = rec 0 where
  covering
  rec : Int -> IO Bool
  rec i = if i == size then pure False else
    if e == !(unsafeReadArray inner i) then pure True else rec (i+1)

||| Array contents on a single line.
export
show : Show elem => SimpleArray elem -> IO String
show (MkSimpleArray inner size) = do
  elems <- for (take (toNat size) $ iterate (+1) 0) (\i =>
    pure $ show !(unsafeReadArray inner i)
      ++ if i < (size - 1) then "," else ""
  )
  pure $ "[" ++ (concat elems) ++ "]"

||| Array contents with a single element per line.
export
showPretty : Show elem => SimpleArray elem -> IO String
showPretty (MkSimpleArray inner size) = do
  elems <- for (take (toNat size) $ iterate (+1) 0) (\i => do
    pure $ show !(unsafeReadArray inner i)
      ++ if i < (size - 1) then ",\n  " else "\n"
  )
  pure $ "[\n  " ++ (concat elems) ++ "]"

export
covering
test : IO ()
test = do
  array <- new 5 9
  putStrLn !(show array)
  putStrLn $ "contains  9: " ++ show !(contains array  9)
  putStrLn $ "contains 10: " ++ show !(contains array 10)
  _ <- fromIndex array (\i => i * 3)
  putStrLn !(show array)
  _ <- mapInplace (+1) array
  putStrLn !(show array)
  _ <- mapInplace (*2) array
  putStrLn !(showPretty array)
