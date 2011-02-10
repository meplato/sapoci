class Object #:nodoc:
  unless respond_to?(:blank?)
    def blank?
      respond_to?(:empty?) ? empty? : !self
    end
  end
end

class NilClass #:nodoc:
  unless respond_to?(:blank?)
    def blank?
      true
    end
  end
end

class FalseClass #:nodoc:
  unless respond_to?(:blank?)
    def blank?
      true
    end
  end
end

class TrueClass #:nodoc:
  unless respond_to?(:blank?)
    def blank?
      false
    end
  end
end

class Array #:nodoc:
  unless respond_to?(:blank?)
    alias_method :blank?, :empty?
  end
end

class Hash #:nodoc:
  unless respond_to?(:blank?)
    alias_method :blank?, :empty?
  end
end

class String #:nodoc:
  unless respond_to?(:blank?)
    def blank?
      self !~ /\S/
    end
  end
end

class Numeric #:nodoc:
  unless respond_to?(:blank?)
    def blank?
      false
    end
  end
end
