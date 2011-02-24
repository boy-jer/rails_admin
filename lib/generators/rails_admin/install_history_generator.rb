module RailsAdmin
  class InstallHistoryGenerator < Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)
    argument :model_name, :type => :string, :default => 'user'

    desc "RailsAdmin Install"

    def add_history_in_index_main_controller
      gsub_file "#{File.expand_path('../../../../', __FILE__)}/app/controllers/rails_admin/main_controller.rb", 
        /(#{Regexp.escape("def index")})/ do
      <<-RUBY
def index
      @history = AbstractHistory.history_latest_summaries
      # history listing with ref = 0 and section = 4
      @historyListing, @current_month = AbstractHistory.history_for_month(0, 4)
      RUBY
      end
      gsub_file "#{File.expand_path('../../../../', __FILE__)}/app/controllers/rails_admin/main_controller.rb", /(#{Regexp.escape("@count[t.pretty_name] = current_count")})/ do
      <<-RUBY
@count[t.pretty_name] = current_count    
        @most_recent_changes[t.pretty_name] = AbstractHistory.most_recent_history(t.pretty_name).last.try(:updated_at)
      RUBY
      end
      gsub_file "#{File.expand_path('../../../../', __FILE__)}/app/controllers/rails_admin/main_controller.rb", 
        /(#{Regexp.escape("flash[:notice] = t(\"admin.delete.flash_confirmation\", :name => @model_config.list.label)")})/ do
      <<-END
flash[:notice] = t("admin.delete.flash_confirmation", :name => @model_config.list.label)
      AbstractHistory.create_history_item("Created \#{@model_config.list.with(:object => @object).object_label}", @object, @abstract_model, _current_user)
      END
      end
      gsub_file "#{File.expand_path('../../../../', __FILE__)}/app/controllers/rails_admin/main_controller.rb", 
        /(#{Regexp.escape("if @object.save")})/ do
      <<-END
if @object.save
        AbstractHistory.create_history_item("Created \#{@model_config.list.with(:object => @object).object_label}", @object, @abstract_model, _current_user)
      END
      end
      gsub_file "#{File.expand_path('../../../../', __FILE__)}/app/controllers/rails_admin/main_controller.rb", 
        /(#{Regexp.escape("message = \"Destroyed \#{@model_config.list.with(:object => object).object_label}\"")})/ do
      <<-END
message = "Destroyed \#{@model_config.list.with(:object => object).object_label}"
        AbstractHistory.create_history_item(message, object, @abstract_model, _current_user)
      END
    end
  end
end
