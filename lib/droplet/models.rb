require 'dm-core'
require 'dm-types'
require 'dm-paperclip'
require 'date'
require 'active_support'

module Droplet
  module Models
    class Resource
      include DataMapper::Resource
      include Paperclip::Resource

      property :id, Serial

      has_attached_file :file
    end
  end
end
