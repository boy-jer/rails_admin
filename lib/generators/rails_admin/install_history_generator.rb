module RailsAdmin
  class InstallHistoryGenerator < Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)
    argument :model_name, :type => :string, :default => 'user'

    desc "RailsAdmin Install"

    def add_history_in_controller
      gsub_file 'app/controllers/rails_admin/main_controller.rb', /def index/ do
      <<-RUBY
    def index
      @history = AbstractHistory.history_latest_summaries
      # history listing with ref = 0 and section = 4
      @historyListing, @current_month = AbstractHistory.history_for_month(0, 4)
      RUBY
      end

      gsub_file 'app/controllers/rails_admin/main_controller.rb', /@count[t.pretty_name] = current_count/ do
      <<-RUBY
    @count[t.pretty_name] = current_count    
      @most_recent_changes[t.pretty_name] = AbstractHistory.most_recent_history(t.pretty_name).last.try(:updated_at)
      RUBY
      end
    end
  end
end
