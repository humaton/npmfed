require 'openssl'
require 'uri'
require 'net/https'
require 'net/http'

module Npmfed
  class Download
    attr_reader :content
    # get url to local file, return local file name
    def initialize url
#      puts "Download #{url.inspect}"
      @uri = case url
               when URI then url
               else
                 URI url
             end
      http = Net::HTTP.new(@uri.host, @uri.port)
      if @uri.scheme == "https"
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_PEER

        store = OpenSSL::X509::Store.new
        store.set_default_paths # Optional method that will auto-include the system CAs.
        crtpath = File.expand_path(File.join(File.dirname(__FILE__), "..", "registry.npmjs.org.crt"))
        store.add_file(crtpath)
        http.cert_store = store
      end
      response = http.request(Net::HTTP::Get.new(@uri.request_uri))
      case response.code.to_i
        when 200
        when 404
          abort "No such NPM module #{url}"
        else
          abort "HTTP error #{response.code.inspect}"
      end
      @content = response.body
    end
    def save
      File.open(self.filename, "w+") { |f| f.write @content }
      self
    end
    def filename
      @filename ||= File.basename(@uri.path)
    end
  end
end