module Npmfed
  class RpmPackage
    attr_accessor :name,:npm_package, :scl

    def initialize name, npm_package, scl=false
      @name = "nodejs-#{name}"
      @npm_package = npm_package
      @scl = scl
    end

    def npmname
      @npm_package.name
    end


    def dependencies deps
      result = Array.new
      deps ||= Hash.new
      deps.each do |name, version|
        result << "npm(#{name})"
=begin
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
=end
      end
      result
    end

    def licenses
      if @npm_package.licenses.nil?
        [ "Unknown" ]
      else
        [@npm_package.licenses]
      end
    end

    def summary
      @npm_package.npm_data["description"]
    end

    def description
      @npm_package.npm_data["description"]
    end

    def homepage
      @npm_package.npm_data["homepage"] || @npm_package.tarball || abort('FIXME: No homepage found')
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
      @npm_package.npm_data["bin"]
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
      req = dependencies(@npm_package.npm_data["dependencies"])
      req += dependencies(@npm_package.npm_data["peerDependencies"])
      req
    end

    def build_requires
      dependencies @npm_package.npm_data["devDependencies"]
    end

    def version
      @npm_package.version
    end

    def tests
      @npm_package.npm_data["test"]
    end

    def build
      @npm_package.npm_data["scripts"].nil? ? '#nothing to do' : @npm_package.npm_data["scripts"]["build"]
    end

    def write path = nil
      require 'erb'

      template_name = File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "templates", "nodejs-fedora.spec.erb"))
      template = File.read(template_name)
      # -:  omit blank lines ending in -%>
      erb = ERB.new(template, nil, "-")
      File.open("#{path unless path.nil?}" + "#{@name}/#{@name}.spec", "w+") do |f|
        spec = self
        f.puts(erb.result(binding()))
      end

      `rpmdev-bumpspec  -c "Initial build" "#{path unless path.nil?}#{@name}/#{@name}.spec"`
      `spec2scl -i "#{path unless path.nil?}#{@name}/#{@name}.spec"` if @scl
      command = "cd #{path unless path.nil?}#{@name}/ && fedpkg --dist=f24 srpm"
      `#{command}`
    end
  end
end
