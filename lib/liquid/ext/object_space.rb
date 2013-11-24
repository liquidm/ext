module Memory
  WORD_SIZE = 8
  OBJ_SIZE = 40 # some are smaller
  OBJ_OVERHEAD = WORD_SIZE + OBJ_SIZE

  def self.size(obj)
    return WORD_SIZE if obj.is_a?(Fixnum)

    case obj
    when String
      obj.size
    when Array
      obj.size * WORD_SIZE
    when Hash
      obj.size * WORD_SIZE * 2
    #when Enumerable
    #  result = 0
    #  obj.each do |ref|
    #    result += WORD_SIZE
    #  end
    #  result
    else
      0
    end + OBJ_OVERHEAD
  rescue => e
    puts "failed to get object size for #{obj.inspect}: #{e}"
    return OBJ_OVERHEAD
  end
end

module ObjectSpace
  def self.memory_stats(*args)
    stats = {}

    self.each_object do |obj|
      stats[obj.class] ||= []
      stats[obj.class] << Memory.size(obj)
    end

    stats.map do |cls, sizes|
      cnt = sizes.length
      sum = sizes.reduce(:+)
      avg = sum / cnt
      [cls, [cnt, avg, sum]]
    end.sort_by do |cls, sizes|
      sizes[2]
    end.reverse
  end
end
