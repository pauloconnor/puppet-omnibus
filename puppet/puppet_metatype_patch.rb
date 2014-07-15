require 'puppet'
require 'puppet/type'
require 'puppet/metatype/manager'

# this module wraps original Manager#type method and memoizez it
module Puppet::MetaType::FasterTypeLookup
  def type(name)
    return @types[name] if @types.include? name

    munged_name = name.downcase.intern if name.is_a? String
    return @types[munged_name] if @types.include? munged_name

    super.tap do |type|
      @types[name] = @types[munged_name] = type
    end
  end
end

class Puppet::Type
  include Puppet::MetaType::FasterTypeLookup
end
