require 'dm-core'
require 'dm-types'
require 'dm-paperclip'
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
    end
  end
end
