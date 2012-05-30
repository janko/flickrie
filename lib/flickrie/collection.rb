if Flickrie.pagination == :will_paginate
  require 'will_paginate/collection'
end

module Flickrie
  # You can think of this as a richer Array. It defines some pagination attributes
  # (you can evem use it with [will_paginate](https://github.com/mislav/will_paginate),
  # see {Flickrie.pagination}). It also has the method {#find} which finds by ID
  # (just like ActiveRecord).
  class Collection < (defined?(WillPaginate) ? WillPaginate::Collection : Array)
    attr_reader :current_page, :per_page, :total_entries, :total_pages

    def initialize(params)
      hash = params[:pagination]
      if defined?(WillPaginate)
        @current_page = WillPaginate::PageNumber(Integer(hash['page']))
      else
        @current_page = Integer(hash['page'])
      end
      @per_page = Integer(hash['per_page'] || hash['perpage'])
      @total_entries = Integer(hash['total'])
      @total_pages = Integer(hash['pages'])

      Array.instance_method(:initialize).bind(self).call(params[:array])
    end

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
