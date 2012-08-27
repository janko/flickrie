module Flickrie
  class Comment
    # @!parse attr_reader :id, :author, :created_at,
    #   :permalink, :content, :photo, :video

    # @return [String]
    def id() @hash["id"] end

    # @return [Flickrie::User]
    def author() @author ||= User.new(@hash["author"], @api_caller) end

    # @return [Time]
    def created_at() Time.at(Integer(@hash["datecreate"])) rescue nil end

    # @return [String]
    def permalink() @hash["permalink"] end

    # @return [String]
    def content() @hash["_content"] end

    # @return [Flickrie::Photo]
    def photo() @photo ||= Photo.new({"id" => @hash["photo_id"]}, @api_caller) end
    # @return [Flickrie::Video]
    def video() @video ||= Video.new({"id" => @hash["photo_id"]}, @api_caller) end

    def to_s
      content
    end

    def initialize(hash, api_caller)
      @hash = hash
      @api_caller = api_caller
    end
  end
end
