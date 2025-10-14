# SPDX-FileCopyrightText: 2023 ash_money contributors <https://github.com/ash-project/ash_money/graphs.contributors>
#
# SPDX-License-Identifier: MIT

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
