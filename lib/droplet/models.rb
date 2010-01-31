require 'dm-core'
require 'dm-types'
require 'dm-paperclip'
require 'nokogiri'
require 'dm-serializer'
require 'date'
require 'active_support'

DataMapper::setup(:default, "sqlite3://#{APP_ROOT}/db.sqlite3")

module Droplet
  module Models
    class Resource
      include DataMapper::Resource
      include Paperclip::Resource

      property :id,     Serial
      property :slug,   Slug

      has_attached_file :file,
                        :url => "/system/:attachment/:id/:style/:basename.:extension",
                        :path => "#{APP_ROOT}/public/system/:attachment/:id/:style/:basename.:extension"

      def name
        file_file_name
      end
      
      def path
        file.url
      end
      
      def size
        # file.size is missing in the latest gem
        file_file_size
      end

      def updated_at
        file_updated_at
      end

    end
  end
end
