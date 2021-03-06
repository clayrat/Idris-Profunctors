module Data.Profunctor.Ran

import Data.Profunctor
import Data.Profunctor.Composition
import Data.Profunctor.Monad

%access public export

||| The right Kan extension of a profunctor
record Ran : (Type -> Type -> Type) -> (Type -> Type -> Type) ->
             Type -> Type -> Type where
  Run : {x : _} -> (runRan : p x a -> q x b) -> Ran p q a b

implementation (Profunctor p, Profunctor q) => Profunctor (Ran p q) where
  dimap ca bd f = Run $ rmap bd . runRan f . rmap ca
  lmap  ca    f = Run $           runRan f . rmap ca
  rmap     bd f = Run $ rmap bd . runRan f

implementation Profunctor q => Functor (Ran p q a) where
  map bd f = Run $ rmap bd . runRan f

||| Split up composed Profunctors by putting a Ran in the middle
curryRan : (Procomposed p q -/-> r) -> p -/-> Ran q r
curryRan f a b p = Run $ \q => f a b $ Procompose p q
