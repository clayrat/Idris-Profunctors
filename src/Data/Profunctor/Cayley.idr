module Data.Profunctor.Cayley

import Control.Arrow
import Control.Category
import Data.Profunctor
import Data.Profunctor.Strong
import Data.Profunctor.Choice
import Data.Profunctor.Unsafe

%access public export

||| Converts Monads on standard types to Monads on Profunctors
record Cayleyed (f : Type -> Type) (p : Type -> Type -> Type) a b where
  ||| ````idris example
  ||| Cayley $ Just $ Kleisli $ \x => Just $ reverse x
  ||| ````
  constructor Cayley
  runCayley : f (p a b)

implementation (Functor f, Profunctor p) => Profunctor (Cayleyed f p) where
  dimap f g = Cayley . map (dimap f g) . runCayley
  lmap  f   = Cayley . map (lmap  f  ) . runCayley
  rmap    g = Cayley . map (rmap    g) . runCayley

implementation (UnsafeProfunctor p, Functor f) =>
         UnsafeProfunctor (Cayleyed f p) where
  w          #. (Cayley p) = Cayley $ map (w #.) p
  (Cayley p) .# w          = Cayley $ map (.# w) p

implementation (Functor f, Strong p) => Strong (Cayleyed f p) where
  first'  = Cayley . map first'  . runCayley
  second' = Cayley . map second' . runCayley

implementation (Functor f, Choice p) => Choice (Cayleyed f p) where
  left'  = Cayley . map left'  . runCayley
  right' = Cayley . map right' . runCayley

implementation (Applicative f, Category p) => Category (Cayleyed f p) where
  id                            = Cayley $ pure id
  (Cayley fpbc) . (Cayley fpab) = Cayley $ liftA2 (.) fpbc fpab

implementation (Applicative f, Arrow p) => Arrow (Cayleyed f p) where
  arrow                       = Cayley . pure . arrow
  first                       = Cayley . map first  . runCayley
  second                      = Cayley . map second . runCayley
  (Cayley ab) *** (Cayley cd) = Cayley $ liftA2 (***) ab cd
  (Cayley ab) &&& (Cayley ac) = Cayley $ liftA2 (&&&) ab ac

implementation (Applicative f, ArrowChoice p) => ArrowChoice (Cayleyed f p) where
  left                        = Cayley . map left . runCayley
  right                       = Cayley . map right . runCayley
  (Cayley ab) +++ (Cayley cd) = Cayley $ liftA2 (+++) ab cd
  (Cayley ac) \|/ (Cayley bc) = Cayley $ liftA2 (\|/) ac bc

implementation (Applicative f, ArrowLoop p) => ArrowLoop (Cayleyed f p) where
  loop = Cayley . map loop . runCayley

implementation (Applicative f, ArrowZero p) => ArrowZero (Cayleyed f p) where
  zeroArrow = Cayley $ pure zeroArrow

implementation (Applicative f, ArrowPlus p) => ArrowPlus (Cayleyed f p) where
  (Cayley f) <++> (Cayley g) = Cayley $ liftA2 (<++>) f g
