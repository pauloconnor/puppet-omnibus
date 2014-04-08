require 'rubygems'
require 'puppet'
require 'puppet/util/autoload'

class Puppet::Util::Autoload
  class << self
    def search_directories(env=nil)
      @search_directories ||= {}
      # cache only after initialization
      if Puppet.settings.app_defaults_initialized?
        @search_directories[env] ||= search_directories_uncached(env)
      else
        search_directories_uncached(env)
      end
    end

    def search_directories_uncached(env)
      [gem_directories, module_directories(env), libdirs(), $LOAD_PATH].flatten
    end
  end
end
