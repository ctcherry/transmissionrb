require 'net/http'

require 'rubygems'
require 'json'

class Transmission

  DEFAULT_HOST = 'localhost'
  DEFAULT_PORT = 9091
  DEFAULT_PATH = '/transmission/rpc'

  SESSION_HEADER_NAME = "X-Transmission-Session-Id"

  attr_accessor :fields

  def initialize(options = {})
    @options = default_options.merge(options)
    @session_id = nil
    @fields = ['id', 'rateDownload', 'status', 'name', 'peersConnected', 'peersSendingToUs', 'percentDone']
  end
  
  def recently_active
    request("torrent-get", {:ids => "recently-active", :fields => @fields})
  end
  
  def stopped
    all.select { |t| t['status'] == 0 }
  end
  
  def dowloading
    all.select { |t| t['status'] == 4 }
  end
  
  def queued_for_dowloading
    all.select { |t| t['status'] == 3 }
  end
  
  def seeding
    all.select { |t| t['status'] == 6 }
  end
  
  def queued_for_seeding
    all.select { |t| t['status'] == 5 }
  end
  
  def all
    res = request("torrent-get", {:fields => @fields})
    return nil if res.nil?
    res['arguments']['torrents']
  end
  
  def default_options
    { 
      :host => DEFAULT_HOST, 
      :port => DEFAULT_PORT,
      :path => DEFAULT_PATH,
      :user => nil,
      :pass => nil
    }
  end
  
  private
    
    def fresh_http
      Net::HTTP.new(@options[:host], @options[:port])
    end
    
    def request(method, arguments = {})
      json = {:method => method, :arguments => arguments}.to_json
      req = Net::HTTP::Post.new(@options[:path])
      req.body = json
      req.basic_auth @options[:user], @options[:pass] if @options[:user]
      resp = fresh_http.start {|http| http.request(req) }
      if resp.code == '409'
        # need to set session
        req[SESSION_HEADER_NAME] = resp[SESSION_HEADER_NAME]
        resp = fresh_http.start {|http| http.request(req) }
      end
      
      if resp.code == '401'
        puts "Incorrect user or password"
        return nil
      end
      
      return JSON.parse(resp.body)
    end

end