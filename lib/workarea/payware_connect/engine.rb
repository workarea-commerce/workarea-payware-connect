module Workarea
  module PaywareConnect
    class Engine < ::Rails::Engine
      include Workarea::Plugin
      isolate_namespace Workarea::PaywareConnect
    end
  end
end
