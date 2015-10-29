module Npmfed
  class RpmPackage
    attr_accessor :name,:npm_package

    def initialize name, npm_package
      @name = "nodejs-#{name}"
      @npm_package = npm_package
    end

    def npmname
      @npm_package.name
    end


    def dependencies deps
      result = Array.new
      deps ||= Hash.new
      deps.each do |name, version|
        case version
          # "~1.2.3"
          when /^~?(\d+(\.\d+)*)(-\d)?([a-z]+)?$/
            result << "npm(#{name}@#{$1})"
          # "^1.2.3"
          when /^\^(\d+(\.\d+)*)(-\d)?([a-z]+)?$/
            result << "npm(#{name}@#{$1})"
          # "1.2.0-1.2.3"
          when /^(\d+(\.\d+)*)-([\d\.]+)$/
            result << "npm(#{name}@#{$2})"
          # "1.2.x"
          when /^([^xY]+)(\.[xX])(.*)$/
            result << "npm(#{name}@#{$1})"
          # "1.2.x", "=0.7.x"
          when /^~?<?>?=?([^xY]+)(\.[xX])(.*)$/
            result << "npm(#{name}) >= #{$1}"
          # ">= 1.0.0 < 1.2.0"
          when /^\>=?\s*(\d+(\.\d+)+)(\s+\<\s*([\d\.]+))?$/
            result << "npm(#{name}) >= #{$1}"
            result << "npm(#{name}) < #{$3}" if $2
          # "*"
          # ""
          when "*", ""
            result << "npm(#{name})"
          when /\w+/
            result << "npm(#{name}@#{version})"
          else
            raise "Unrecognized dependency #{name.inspect}: #{version.inspect}"
        end
      end
      result
    end

 
  end
end
