# Be sure to restart your server when you modify this file

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.5' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Specify gems that this application depends on and have them installed with rake gems:install
  # config.gem "bj"
  # config.gem "hpricot", :version => '0.6', :source => "http://code.whytheluckystiff.net"
  # config.gem "sqlite3-ruby", :lib => "sqlite3"
  # config.gem "aws-s3", :lib => "aws/s3"
  # config.gem 'calendar_date_select' 

  # Only load the plugins named here, in the order given (default is alphabetical).
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  # Skip frameworks you're not going to use. To use Rails without a database,
  # you must remove the Active Record framework.
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  config.action_controller.session_store = :active_record_store
  config.action_controller.allow_forgery_protection    = false

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

  # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
  # Run "rake -D time" for a list of tasks for finding time zone names.
  config.time_zone = 'UTC'

  # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
  config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}')]
  # config.i18n.default_locale = :de
  config.i18n.default_locale = :es

  #
  # Configura los paths para multisitio. Con la variable de entorno LIBRETPV_SITEID se 
  # define los paths particulares de una instancia concreta.
  # En apache se define a traves de la directiva:
  #         SetEnv LIBRETPV_SITEID "nombre_instancia"
  #
  ENV['RAILS_ETC'] ||= "/etc/libretpv/#{ENV['LIBRETPV_SITEID']}"
  ENV['RAILS_LOG'] ||= "/var/log/libretpv/#{ENV['LIBRETPV_SITEID']}"
  ENV['RAILS_CACHE'] ||= "/var/cache/libretpv/#{ENV['LIBRETPV_SITEID']}"
  ENV['RAILS_TMP'] ||= ENV['LIBRETPV_SITEID'] ? "/tmp/libretpv" : Rails.root.join('tmp')

  # Si no existe, genera el directorio temporal
  Dir.mkdir(ENV['RAILS_TMP']) unless File.directory?(ENV['RAILS_TMP'])
  # Si no existe, genera el directorio de cache
  Dir.mkdir(ENV['RAILS_CACHE']) unless File.directory?(ENV['RAILS_CACHE']) || !ENV['LIBRETPV_SITEID']

  config.database_configuration_file = ENV['RAILS_ETC'] + '-database.yml' unless !ENV['LIBRETPV_SITEID']
  config.log_path = ENV['RAILS_LOG'] + "." + ENV['RAILS_ENV'] + ".log" unless !ENV['LIBRETPV_SITEID']
  config.cache_store = :file_store, ENV['RAILS_CACHE'] unless !ENV['LIBRETPV_SITEID']

  #
  # Obtiene la version para mostrarla en el header de la pagina
  #
  File.open(RAILS_ROOT + "/changelog", "r") do |fichero|
    while (linea=fichero.gets) && ENV['TPV_VERSION'].nil?
      linea =~ /^\s*(\S+).+Version\s+(.+)$/
      ENV['TPV_VERSION'] = $2 + " (" + $1 + ")" if $1 && $2
    end
  end if File.exists?(RAILS_ROOT + "/changelog")
  ENV['TPV_VERSION'] ||= "desconocida"


  ENV['TPV-PAGINADO'] = "25"

  ENV['TPV-CIF'] = 'F86139771'
  ENV['TPV-DIRECCION'] = "c/ Arroyo del Olivar, 34"
  ENV['TPV-FACTURA-PREFIX'] = "LEDZ-"
  ENV['TPV-PRINTER'] = "lpr -P TM-T70 -o cpi=20"

end

 #CalendarDateSelect.format = :db
 CalendarDateSelect.format = :finnish
 #CalendarDateSelect.format = :italian

