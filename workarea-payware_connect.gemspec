$:.push File.expand_path("../lib", __FILE__)

require "workarea/payware_connect/version"

Gem::Specification.new do |s|
  s.name        = "workarea-payware_connect"
  s.version     = Workarea::PaywareConnect::VERSION
  s.authors     = ["Mark Platt"]
  s.email       = ["mplatt@weblinc.com"]
  s.homepage    = "https://github.com/workarea-commerce/workarea-payware_connect"
  s.summary     = "ActiveMerchant Gateway and supporting classes for Payware Connect"
  s.description = "Adds ability checkout and store credit cards using Payware Connect"
  s.files       = `git ls-files`.split("\n")

  s.required_ruby_version = ">= 2.0.0"

  s.add_dependency "workarea", "~> 3.x", ">= 3.4.0"
end
