module Enumerable
  def sum
    reduce(:+)
  end

  def mean
    sum.to_f / length
  end

  def variance
    m = mean
    reduce(0) {|accum, item| accum + (item - m) ** 2}.to_f / (length - 1)
  end

  def stdev
    Math.sqrt(variance)
  end

  def percentile(pc)
    sort[(pc * length).ceil - 1]
  end
end
