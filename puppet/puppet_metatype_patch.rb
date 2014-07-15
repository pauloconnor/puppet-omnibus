require 'rubygems'
require 'puppet'

if Puppet::PUPPETVERSION.to_s =~ /3.6/
  require 'puppet/type'
  require 'puppet/metatype/manager'

  # this module wraps original Manager#type method and memoizez it
  module Puppet::MetaType
  module Manager
    def type(name)
      return nil if name.to_s.include? ':'

      @types ||= {}
      return @types[name] if @types.include? name

      if name.is_a? String
        name = name.downcase.intern
        return @types[name] if @types.include? name
      end

      if typeloader.load(name, Puppet.lookup(:current_environment))
        Puppet.warning "Loaded puppet/type/#{name} but no class was created" unless @types.include? name
      else
        @types[name] = nil
      end

      @types[name]
    end
  end
  end
end
