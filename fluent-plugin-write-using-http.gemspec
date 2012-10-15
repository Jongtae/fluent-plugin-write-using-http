# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "fluent-plugin-write-using-http"
  s.version     = "1.0.0"
  s.authors     = ["Jongtae Lee"]
  s.email       = ["jp-jongtae@daumcorp.com"]
  s.homepage    = "http://www.daum.net"
  s.summary     = %q{Fluentd Output write plugin. It has designed to write data using http url.}
  # s.description = %q{Fluentd Output filter plugin. It has designed to rewrite tag like mod_rewrite. Also you can change a tag from apache log by domain, status-code(ex. 500 error), user-agent, and request-uri and so on with regular expression.}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  s.add_development_dependency "fluentd"
  s.add_runtime_dependency "fluentd"
end
