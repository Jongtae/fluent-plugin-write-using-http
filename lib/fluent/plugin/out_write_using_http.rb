require 'httpclient'
require "socket"
class HttpRequestOutput < Fluent::BufferedOutput
  Fluent::Plugin.register_output('write_using_http', self)

  def initialize
    super
    require 'rubygems'
    
  end

  def configure(conf)
    super

#    if host = conf['host']
#      @host = host
#    end
#    unless @host
#      raise ConfigError, "'host' parameter is required on file output"
#    end 

#    if table  = conf['table']
#      @table = table
#    end 
#    unless @table
#      raise ConfigError, "'hbase_table' parameter is required on file output"
#    end 

  end 

  def start
    super
    # FIXME : authentication may be required.
    print "start write_using_http\n"
  end 

  def shutdown
  end 

  def format(tag, time, record)
    [time, record].to_msgpack
  end

  def write(chunk)   
        
    data = chunk.read
#    print data
    http = HTTPClient.new
    hostname = Socket.gethostname
    chunk.msgpack_each { |time, record|
      http.get("http://group1.magpie.daum.net/magpie/put/clix",{"hostname" => hostname, "message" => record["message"],"location" => record["location"]}) 
    }
  end 
end