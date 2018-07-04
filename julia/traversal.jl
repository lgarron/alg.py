include("alg.jl")

module Traversal
using Alg

# Inverse

invert(a::Alg.Sequence)::Alg.Sequence = Alg.Sequence(
  reverse([invert(alg) for alg in a.nestedAlgs])
)

invert(a::Alg.Group)::Alg.Group = Alg.Group(
  invert(a.nestedAlg),
  a.amount
)

invert(a::Alg.BaseMove)::Alg.BaseMove = Alg.BaseMove(
  a.family,
  -a.amount
)

invert(a::Alg.Commutator)::Alg.Commutator = Alg.Commutator(
  a.B,
  a.A,
  a.amount
)

invert(a::Alg.Conjugate)::Alg.Conjugate = Alg.Conjugate(
  a.A,
  invert(a.B),
  a.amount
)

invert(a::Alg.Pause)::Alg.Pause = Alg.Pause()


# Equality

# For an alg of a given alg.Algorithm subtype, we first define it *not* to be
# equal to any other algorithm, and then we specialize equality if the subtypes
# match.

Base.:(==)(a1::Alg.Sequence, a2::Alg.Algorithm) = false
function Base.:(==)(a1::Alg.Sequence, a2::Alg.Sequence)
  s1 = size(a1.nestedAlgs, 1)
  if s1 != size(a2.nestedAlgs, 1)
    return false
  end
  for i = 1:size(a1.nestedAlgs, 1)
    if a1.nestedAlgs[i] != a2.nestedAlgs[i]
      return false
    end
  end
  return true
end

Base.:(==)(a1::Alg.Group, a2::Alg.Algorithm) = false
Base.:(==)(a1::Alg.Group, a2::Alg.Group) = (
  return a1.nestedAlg == a2.nestedAlg
)

Base.:(==)(a1::Alg.BaseMove, a2::Alg.Algorithm)::Bool = false
Base.:(==)(a1::Alg.BaseMove, a2::Alg.BaseMove)::Bool = (
  a1.family == a2.family &&
  a1.amount == a2.amount
)

Base.:(==)(a1::Alg.Commutator, a2::Alg.Algorithm)::Bool = false
Base.:(==)(a1::Alg.Commutator, a2::Alg.Commutator)::Bool = (
  return a1.A == a2.A && a1.B == a2.B
)

Base.:(==)(a1::Alg.Conjugate, a2::Alg.Algorithm)::Bool = false
Base.:(==)(a1::Alg.Conjugate, a2::Alg.Conjugate)::Bool = (
  return a1.A == a2.A && a1.B == a2.B
)

Base.:(==)(a1::Alg.Pause, a2::Alg.Algorithm)::Bool = false
Base.:(==)(a1::Alg.Pause, a2::Alg.Pause)::Bool = true

# toString

spacer(::Alg.Algorithm, ::Alg.Algorithm)::String = " "
spacer(::Alg.Pause, ::Alg.Pause)::String = ""

function toString(a::Alg.Sequence)::String
  out = IOBuffer()
  local last = nothing
  for (index, value) in enumerate(a.nestedAlgs)
    if index > 1
      write(out, spacer(last, value))
    end
    write(out, toString(value))
    last = value
  end
  return String(take!(out))
end

function toString(a::Alg.Group)::String
  return "(" * toString(a.nestedAlg) * ")" * repetitionSuffix(a.amount)
end

function repetitionSuffix(amount::Alg.AmountType)::String
  output = ""
  absAmount = abs(amount)
  if absAmount != 1
    output *= string(absAmount)
  end
  if absAmount !== amount
    output *= "'"
  end
  return output
end

function toString(a::Alg.BaseMove)::String
  return a.family * repetitionSuffix(a.amount)
end

function toString(a::Alg.Commutator)::String
  return "[" * toString(a.A) * ", " * toString(a.B) * "]" * repetitionSuffix(a.amount)
end

function toString(a::Alg.Conjugate)::String
  return "[" * toString(a.A) * ": " * toString(a.B) * "]" * repetitionSuffix(a.amount)
end

function toString(a::Alg.Pause)::String
  return "."
end

# clone
# invert
# expand
# countBaseMoves
# structureEquals
# coalesceMoves
# concat
# toString

end
