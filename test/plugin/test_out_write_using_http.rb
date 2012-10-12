# -*- coding: utf-8 -*-
require 'tools/rs_test_helper'

class HttpRequestOutputTest < Test::Unit::TestCase

  def setup
    Fluent::Test.setup
    require 'fluent/plugin/out_write_using_http'

    setup_mongod
  end

  def teardown
  end

  def default_config
    %[
      type httpRequest
      database #{MONGO_DB_DB}
      collection #{collection_name}
    ]
  end

  def test_write
    d = create_driver
    t = emit_documents(d)

    d.run
    documents = get_documents.map { |e| e['a'] }.sort
    assert_equal([1, 2], documents)
    assert_equal(2, documents.size)
  end

  def test_write_at_enable_tag
    d = create_driver(default_config + %[
      include_tag_key true
      include_time_key false
    ])
    t = emit_documents(d)

    d.run
    documents = get_documents.sort_by { |e| e['a'] }
    assert_equal([{'a' => 1, d.instance.tag_key => 'test'},
                  {'a' => 2, d.instance.tag_key => 'test'}], documents)
    assert_equal(2, documents.size)
  end

  def emit_invalid_documents(d)
    time = Time.parse("2011-01-02 13:14:15 UTC").to_i
    d.emit({'a' => 3, '$last' => '石動'}, time)
    d.emit({'a' => 4, 'first' => '菖蒲'.encode('EUC-JP').force_encoding('UTF-8')}, time)
    time
  end

  def test_write_with_invalid_recoreds
    d = create_driver
    t = emit_documents(d)
    t = emit_invalid_documents(d)

    d.run
    documents = get_documents
    assert_equal(4, documents.size)
    assert_equal([1, 2], documents.select { |e| e.has_key?('a') }.map { |e| e['a'] }.sort)
    assert_equal(2, documents.select { |e| e.has_key?(Fluent::MongoOutput::BROKEN_DATA_KEY)}.size)
    assert_equal([3, 4], @db.collection(collection_name).find({Fluent::MongoOutput::BROKEN_DATA_KEY => {'$exists' => true}}).map { |doc|
      Marshal.load(doc[Fluent::MongoOutput::BROKEN_DATA_KEY].to_s)['a']
    }.sort)
  end

  def test_write_with_invalid_recoreds_at_ignore
    d = create_driver(default_config + %[
      ignore_invalid_record true
    ])
    t = emit_documents(d)
    t = emit_invalid_documents(d)

    d.run
    documents = get_documents
    assert_equal(2, documents.size)
    assert_equal([1, 2], documents.select { |e| e.has_key?('a') }.map { |e| e['a'] }.sort)
    assert_equal(true, @db.collection(collection_name).find({Fluent::MongoOutput::BROKEN_DATA_KEY => {'$exists' => true}}).count.zero?)
  end
end

class MongoReplOutputTest < MongoOutputTest
  def setup
    Fluent::Test.setup
    require 'fluent/plugin/out_mongo_replset'

    ensure_rs
  end

  def teardown
    @rs.restart_killed_nodes
    if defined?(@db) && @db
      @db.collection(collection_name).drop
      @db.connection.close
    end
  end

  def default_config
    %[
      type mongo_replset
      database #{MONGO_DB_DB}
      collection #{collection_name}
      nodes #{build_seeds(3).join(',')}
      num_retries 30
    ]
  end

  def create_driver(conf = default_config)
    @db = Mongo::ReplSetConnection.new(build_seeds(3), :name => @rs.name).db(MONGO_DB_DB)
    Fluent::Test::BufferedOutputTestDriver.new(Fluent::MongoOutputReplset).configure(conf)
  end

  def test_configure
    d = create_driver(%[
      type mongo_replset

      database fluent_test
      collection test_collection
      nodes #{build_seeds(3).join(',')}
      num_retries 45

      capped
      capped_size 100
    ])

    assert_equal('fluent_test', d.instance.database)
    assert_equal('test_collection', d.instance.collection)
    assert_equal(build_seeds(3), d.instance.nodes)
    assert_equal(45, d.instance.num_retries)
    assert_equal({:capped => true, :size => 100}, d.instance.collection_options)
  end
end
