module SpreeOnePageCheckout
  class Engine < Rails::Engine
    require 'apotomo'
    require 'formtastic'
    require 'reform'

    require 'spree/core'
    isolate_namespace Spree
    engine_name 'spree_one_page_checkout'

    config.autoload_paths += %W(#{config.root}/lib)

    # use rspec for tests
    config.generators do |g|
      g.test_framework :rspec
    end

    def self.activate
      Dir.glob(File.join(File.dirname(__FILE__), '../../app/**/*_decorator*.rb')) do |c|
        Rails.configuration.cache_classes ? require(c) : load(c)
      end

      Dir.glob(File.join(File.dirname(__FILE__), '../../lib/extensions/**/*.rb')) do |c|
        Rails.configuration.cache_classes ? require(c) : load(c)
      end
    end

    initializer 'spree_one_page_checkout.setup_widget_view_paths', after: 'apotomo.setup_view_paths' do |app|
      Apotomo::Widget.append_view_path self.root.join('app/widgets')
    end

    config.to_prepare &method(:activate).to_proc
  end
end
