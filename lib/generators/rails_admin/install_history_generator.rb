module RailsAdmin
  class InstallHistoryGenerator < Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)
    argument :model_name, :type => :string, :default => 'user'

    desc "RailsAdmin Install"

#    def history_migration
#      puts "Also you need a new migration. We'll generate it for you now."
#      invoke 'rails_admin:install_migrations'
#    end

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

    def add_history_in_index_view
      gsub_file "#{File.expand_path('../../../../', __FILE__)}/app/views/rails_admin/main/index.html.erb", 
        /(#{Regexp.escape("<!-- history section -->")})/ do
      <<-END
      <!-- history section -->
          <div class="section">
            <h2><%= t("admin.history.name") %></h2>
            <div id="timeline">
              <a href="javascript:void(0)" id="arrowLeft" ref="-1"><%= image_tag("rails_admin/arrow_left.png", :alt=>"Left")%></a>
              <div id="timelineSlider">
                <% max = @history[0].number %>
                <% @history.each{|t| max = t.number if t.number > max} %>
                <ul>
                  <% @history.each do |t| %>
                  <% percent = (t.number * 100) / max unless max == 0 %>
                  <% indicator_type = get_indicator(percent)%>
                  <li>
                    <% month_names = t("date.month_names", :locale => :en) if (month_names = t("date.month_names")) =~ /translation/ %>
                    <span><%= month_names[t.month] %> <%= t.year %></span>
                    <span class="bars">
                      <span class="indicator <%= indicator_type %>" style="height:<%= percent %>%"></span>
                    </span>
                  </li>
                  <% end %>
                </ul>
                <div id="handler"><%= image_tag("rails_admin/handler.png")%></div>
              </div>

              <a href="javascript:void(0)" id="arrowRight" ref="1"><%= image_tag("rails_admin/arrow_right.png", :alt=>"Right")%></a>
            </div>
            <div id="listingHistory">
<%= render(:partial => 'history', :locals => {:month => Time.now.month, :year => Time.now.year, :history => @historyListing}) -%>
            </div>
          </div>
      END
      end
    end

    def add_history_list_view
      gsub_file "#{File.expand_path('../../../../', __FILE__)}/app/views/rails_admin/main/list.html.erb", 
        /(#{Regexp.escape("<!-- history link -->")})/ do
      <<-END
      <!-- history link -->
      <li>
       <%= link_to(t("admin.history.name"), rails_admin_history_model_path, :class => "addlink") %>
      </li>
      END
      end
    end
  end
end
