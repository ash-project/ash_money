import Ash.Type.Comparable

defcomparable left :: Money, right :: Integer do
  Money.compare!(left, Money.new(right, left.currency))
end

defcomparable left :: Money, right :: Money do
  Money.compare!(left, right)
end

defcomparable left :: Money, right :: Decimal do
  Money.compare!(left, Money.new(right, left.currency))
end

defcomparable left :: Money, right :: Float do
  Money.compare!(left, Money.new(right, left.currency))
end
