if Flickrie.pagination == :will_paginate
  require 'will_paginate/collection'
end

module Flickrie
  if Flickrie.pagination == :will_paginate
    const_set(:Collection, Class.new(WillPaginate::Collection) do
      def initialize(hash)
        current_page = Integer(hash['page'])
        per_page = Integer(hash['per_page'] || hash['perpage'])
        total_entries = Integer(hash['total'])
        super(current_page, per_page, total_entries)
      end
    end)
  else
    const_set(:Collection, Class.new(Array) do
      attr_reader :current_page, :per_page, :total_entries, :total_pages

      def initialize(hash)
        @current_page = Integer(hash['page'])
        @per_page = Integer(hash['per_page'] || hash['perpage'])
        @total_entries = Integer(hash['total'])
        @total_pages = Integer(hash['pages'])
      end
    end)
  end

  # You can think of this as a richer Array. It defines some pagination attributes
  # (you can even use it with [will_paginate](https://github.com/mislav/will_paginate),
  # see {Flickrie.pagination}). It also has the method {#find} which finds by ID
  # (just like ActiveRecord).
  class Collection
    # @!parse attr_reader :current_page, :per_page, :total_entries, :total_pages

    # Finds an object by ID (just like ActiveRecord does). This is just a
    # shorthand for
    #
    #     find { |object| object.id == id }
    def find(id = nil)
      if block_given?
        super
      else
        super() { |object| object.id == id.to_s }
      end
    end
  end
end
