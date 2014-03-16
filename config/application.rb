require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Bday
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'Asia/Seoul'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    config.assets.precompile += [
      'application.js', 'application.css', 
      'admin.js', 'admin.css', 
      'web.css', 'web.js',
      'mobile.css', 'mobile.js'
    ]
    config.middleware.use Rack::Facebook::SignedRequest, 
      app_id: Rails.application.secrets.fb_app_id, 
      secret: Rails.application.secrets.fb_app_secret, 
      inject_facebook: false
  end
end
