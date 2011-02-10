class Object
  alias_method(:try, :__send__) unless respond_to?(:try)
end

class NilClass
  unless respond_to?(:try)
    def try(*args)
      nil
    end
  end
end
