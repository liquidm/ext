class Array

  def pick(n=1)
    Array.new(n) { self[Kernel::rand(size)-1] }
  end

  def pick_one
    self[Kernel::rand(size)-1]
  end

  def to_h(&block)
    Hash[*self.map { |v| [v, block.call(v)] }.flatten]
  end

  def / parts
    inject([[]]) do |ary, x|
      ary << [] if [*ary.last].nitems == length / parts
      ary.last << x
      ary
    end
  end

end
