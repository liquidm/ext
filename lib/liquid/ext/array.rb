class Array

  def pick(n=1)
    Array.new(n) { self[Kernel::rand(size)-1] }
  end

  def pick_one
    self[Kernel::rand(size)-1]
  end

  def / parts
    inject([[]]) do |ary, x|
      ary << [] if [*ary.last].nitems == length / parts
      ary.last << x
      ary
    end
  end

end
