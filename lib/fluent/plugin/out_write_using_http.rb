module Fluent


class HttpRequestOutput < Fluent::BufferedOutput
  Fluent::Plugin.register_output('httpRequest', self)

  def initialize
    super
    require 'rubygems'
  end

  def configure(conf)
    super

    if host = conf['host']
      @host = host
    unless @host
      raise ConfigError, "'host' parameter is required on file output"
    end 


    if table  = conf['table']
      @table = table
    end 
    unless @table
      raise ConfigError, "'hbase_table' parameter is required on file output"
    end 

  end 

  def start
    super
    # FIXME : authentication may be required.
    @client = HTTPClient.new
  end 

  def shutdown
  end 

  def format(tag, time, record)
    [time, record].to_msgpack
  end

  def write(chunk)
    
    chunk.msgpack_each { |time, record|
      print record
      @client.get "http://group1.magpie.daum.net/magpie/put/clix" , "code" => "500"
    }
  
   end 

end