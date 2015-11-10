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

    def licenses
      if @npm_package.licenses.nil?
        [ "Unknown" ]
      else
        @npm_package.licenses.map do |l|
          l['type']
        end
      end
    end

    def summary
      @npm_package.npmdata["description"]
    end

    def description
      @npm_package.npmdata["description"]
    end

    def homepage
      @npm_package.npmdata["homepage"] || @npm_package.tarball || abort('FIXME: No homepage found')
    end

    def add_source name
      @sources << name
    end

    def dir
      # Find out the top-level directory from tarball
      # The upstreams often use very weird ones
      `tar tzf #{@local_source}` =~ /([^\/]+)/
      $1
    end

    def binfiles
      @npm_package.npmdata["bin"]
    end

    # helper for provides
    def _provides version
      prv = Array.new
      v = version.split "."
      until v.empty? do
        prv << "npm(#{self.npmname}@#{v.join('.')})"
        v.pop
      end
      prv
    end

    def provides
      prv = Array.new
      prv << "npm(#{self.npmname}) = %{version}"
      minversion, maxversion = self.srcversion.split "-"
      if maxversion
        prv.concat( _provides maxversion )
      end
      prv.concat( _provides minversion ).uniq
    end

    def requires
      req = dependencies(@npm_package.npmdata["dependencies"])
      req += dependencies(@npm_package.npmdata["peerDependencies"])
      req
    end

    def build_requires
      dependencies @npm_package.npmdata["devDependencies"]
    end

    def version
      @npm_package.version
    end

    def write
      require 'uri'
      require 'pathname'
      url = @npm_package.tarball
      uri = URI url
      path = Pathname.new(uri.path).basename
      if File.readable? path
        @local_source = path
      else
        puts "DOWNLOAD THE FILE".red
      end

      require 'erb'

      template_name = File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "templates", "nodejs-fedora.spec.erb"))
      template = File.read(template_name)
      # -:  omit blank lines ending in -%>
      erb = ERB.new(template, nil, "-")
      File.open("#{@name}/#{@name}.spec", "w+") do |f|
        spec = self
        f.puts(erb.result(binding()))
      end
      `rpmdev-bumpspec  "#{@name}.spec" -c Initial build`
    end
  end
end
