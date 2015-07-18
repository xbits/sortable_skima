require 'fileutils'
$app_ref = nil

module SortableSkima

  class Engine < ::Rails::Engine

    # requires all dependencies
   #Gem.loaded_specs['SortableSkima'].dependencies.each do |d|
   #   require d.name
   # end

    config.after_initialize do
      #require files to run after main app initialization is finished. 
      #require 'acc_skima/acc_skima_post_init_config'

    end

   # assets_dir = File.expand_path( File.dirname(__FILE__) + '/../../app/assets/**/*' )
   # initializer "assets_precompile" do |app|
      #puts "ADDING PRECOMPILE TO FILES IN #{assets_dir}"
   #   Dir[assets_dir+'*.{js,css,html,png,gif,jpg}'].each do |file|
      #  puts "ADDING TO FILE  #{file}"
        #app.config.assets.precompile << file.split('javascripts/').last
   #   end
   # end

    # Initializer to combine this engines static assets with the static assets of the hosting site.
    initializer "static assets" do |app|
      assets_path = "#{root}/app/assets"
      puts "===Sortable_skima: initializing!==="

      #app.middleware.insert_before(ActiveSupport::Cache::Strategy::LocalCache,::ActionDispatch::Static, assets_path)
      app.middleware.use(::ActionDispatch::Static, assets_path)
      js_assets_dir = File.expand_path( File.dirname(__FILE__) + '/../../app/assets/javascripts/*' )
      js_files = []
      Dir[js_assets_dir+'*.{js}'].each do |file|
        js_files<< file.split('/').last
      end
      puts "===Sortable_skima: adding js files to defaults!=== #{js_files.join(' - ')} ==="
      ActionView::Helpers::AssetTagHelper.register_javascript_expansion(
          :defaults=> js_files   #%w(jquery-ui.min.js jquery.ba-bbq.js skima-sortable-tables_2_0_7.js)
      )
     # end
    end

   # initializer :append_migrations do |app|
   #   unless app.root.to_s.match root.to_s
      #  app.config.paths["db/migrate"] += config.paths["db/migrate"].expanded
   #   end
#    end

  end


end







