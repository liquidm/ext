if RUBY_PLATFORM == "java"
  java_import 'gnu.trove.TIntCollection'
  java_import 'gnu.trove.set.hash.TIntHashSet'
  java_import 'gnu.trove.set.hash.TLongHashSet'
  java_import 'gnu.trove.map.hash.TIntObjectHashMap'
  java_import 'gnu.trove.map.hash.TLongObjectHashMap'

  module TMap
    def each
      it = iterator
      while it.has_next
        it.advance
        yield it.key, it.value
      end
    end
  end

  module TSet
    def each
      it = iterator
      while it.has_next
        yield it.next
      end
    end

    def inspect
      if size > 1000
        "#{self.class.name}{too large to display,l=#{size}}"
      else
        to_string
      end
    end
  end

  class TLongObjectHashMap
    include TMap
    alias :has_key? :containsKey
    alias :[] :get
    alias :[]= :put
    alias :length :size
    alias :delete :remove
  end

  class TIntObjectHashMap
    include TMap
    alias :has_key? :containsKey
    alias :[] :get
    alias :[]= :put
    alias :length :size
    alias :delete :remove
  end

  class TLongHashSet
    include TSet
    alias :include? :contains
    alias :length :size
    alias :delete :remove
  end

  class TIntHashSet
    include TSet
    alias :include? :contains
    alias :length :size
    alias :delete :remove

    java_alias :concat_ints, :addAll, [TIntCollection.java_class]

    def concat(list)
      return if !list
      concat_ints list
    end
  end
end
