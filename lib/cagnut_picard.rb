require "cagnut_picard/version"

module CagnutPicard
  class << self
    def config
      @config ||= begin
        CagnutPicard::Configuration.load(Cagnut::Configuration.config, Cagnut::Configuration.params['picard'])
        CagnutPicard::Configuration.instance
      end
    end
  end
end

require 'cagnut_picard/configuration'
require 'cagnut_picard/check_tools'
require 'cagnut_picard/base'
require 'cagnut_picard/util'
