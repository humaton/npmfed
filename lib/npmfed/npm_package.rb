module Npmfed
  require 'net/http'
  require 'json'
  class NpmPackage
    attr_accessor :name, :version, :npm_data, :tarball, :dependencies, :npmjs_url,
                  :fedora_rawhide_version, :koji_requests, :pkgdb_requests, :debug

    def initialize name, debug, version = nil
      #debuging options
      @koji_requests = 0
      @pkgdb_requests = 0
      @debug = debug

      @npmjs_url = URI("https://registry.npmjs.org/#{name}")
      @fedora_rawhide_version = "f24"
      @npm_data = JSON.parse Net::HTTP.get(@npmjs_url)
      @version = version || @npm_data["dist-tags"]["latest"] || abort("Can't determine version")
      @npm_data = @npm_data["versions"][@version] || abort("No such version: #{@version.inspect}")
      @name = @npm_data["name"]
      @dependencies = get_dependencies
      get_builds_for_deps
    end

    def tarball
      @npm_data["dist"]["tarball"]
    end

    def licenses
      @npm_data['license']
    end

    def get_dependencies
      puts "Getting infromation about #{@name} and its dependencies from pkgdb"
      result = {}
      @npm_data['dependencies'].each do |name, version|
        pkgdb_data = pkg_in_fedora? name
        if pkgdb_data
          result["#{name}"] = {distgit_branches: Array.new, builds: Array.new}
          result["#{name}"][:distgit_branches] = pkgdb_data
        else
          result["#{name}"] = nil
        end
      end unless @npm_data['dependencies'].nil?
      puts "DONE".green
      return result
    end

    def srcversion
      @srcversion ||= @version
    end

    def pkgversion
      @pkgversion ||= @version.tr('-', '_')
    end
    
    def rpmname
      "nodejs-#{@name}"
    end

    def pkg_in_fedora? name
      @pkgdb_requests += 1
      IO.popen("git ls-remote http://pkgs.fedoraproject.org/cgit/nodejs-" + name + ".git/") do |f|
        result = f.readlines.collect {|branch| branch.match(/\/[emf][a-z]*[0-9]*/).to_s[1..-1] }
        if result.empty?
          return false
        else
          return result.compact
        end
      end
    end

    def get_builds_for_deps
      puts "Getting infromation about builds of package dependencies from koji"
      @koji_requests +=1
      @dependencies.each do |name, data|
        IO.popen("koji search build -r 'nodejs-#{name}-[0-9]'") do |f|
          puts("checking builds for" + " #{name}".yellow)
          data[:builds] = f.readlines.collect {|build| build.chop }
        end unless data.nil?
      end
      puts "DONE".green
    end
  end
end