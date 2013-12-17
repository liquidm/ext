# encoding: utf-8

class WeightedSelector

  def initialize
    @sums = []
    @elements = []
    @total = 0
  end

  def add(element, probability)
    @elements << element
    @total += probability
    @sums << @total
  end

  def delete(element)
    idx = @elements.index(element)
    if idx
      @total -= @sums[idx]
      @sums.delete_at(idx)
      @elements.delete_at(idx)
    end
  end

  def fill_up(element)
    add(element, 1 - @total) if @total < 1
  end

  def empty?
    @elements.empty?
  end

  # http://stackoverflow.com/questions/4463561/weighed-random-selection-from-array
  def pick_one_with_index
    rnd = Kernel.rand * @total
    idx = @sums.index { |x| x >= rnd }
    [@elements[idx], idx]
  end

  def pick_one
    pick_one_with_index[0]
  end

end
