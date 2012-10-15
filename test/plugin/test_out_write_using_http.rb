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

end
