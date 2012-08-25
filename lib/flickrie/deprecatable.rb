module Flickrie
  module Deprecatable
    def deprecated_alias(name, replacement)
      define_method(name) do |*args, &block|
        warn "Flickrie: ##{name} is deprecated, please use ##{replacement} instead"
        send(replacement, *args, &block)
      end
    end
  end
end
