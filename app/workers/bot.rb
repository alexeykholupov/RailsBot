class Bot
  attr_reader :session, :environment, :authenticate, :placement_list
  DEVELOPMENT = 'https://target-sandbox.my.com'.freeze
  PRODUCTION = 'https://target.my.com'.freeze
  def initialize(user_id, url, environment, session, app_id)
    @user_id = user_id
    @url = url
    @session = session
    @app_id = app_id
    @environment = DEVELOPMENT if environment == '2'
    @environment = PRODUCTION if environment == '1'
    @authenticate = false
  end

  def authenticate_user
    signin_button = "//span[@class= 'js-button ph-button ph-button_profilemenu ph-button_light ph-button_profilemenu_signin']"
    @app = App.find(@app_id)
    @app.status = "In progress"
    @app.save
    begin
      @session.visit @environment
    rescue => e
      @app.status = "Error: #{e.class}"
      @app.save
    end
    sleep 10
    begin
      @session.find(:xpath, signin_button).click
    rescue => e
      @app.status = "Error: #{e.class}"
      @app.save
    end
    @session.fill_in('login', with: User.find(@user_id).email)
    @session.fill_in('password', with: User.find(@user_id).password)
    @session.click_on('Sign in')
    @authenticate = true
  end

  def create_app
    if @authenticate == true
      create_app_button = "//span[@class= 'main-button__label']"
      next_button = "//div[@class= 'paginator__button paginator__button_right js-control-inc']"
      appname_text = "//span[@class= 'pad-setting__platform-preview__title js-platform-preview-app-title']"
      @session.visit environment + '/create_pad_groups/'
      sleep 10
      @session.fill_in('Enter site/app URL', with: @url)
      while @session.has_no_selector?(:xpath, appname_text)
        sleep 1
      end
      @appname = @session.find(:xpath, appname_text).text
      @app.appname = @appname
      @app.save
      @session.fill_in('Site/app name', with: @appname)
      sleep 10
      begin
        @session.find(:xpath, create_app_button).click
      rescue => e
        @app.status = "Error: #{e.class}"
        @app.save
      end
      sleep 20
      while @session.has_no_selector?('a', text: @appname)
        while @session.has_no_selector?(:xpath, next_button)
          sleep 1
        end
        @session.find(:xpath, next_button).click
        sleep 5
      end
      @session.find('a', text: @appname).click
    else
      p 'You are not authenticated'
    end
    @pad_group_id = @session.current_url.gsub(/[^0-9]/, '')
  end

  def created?
    if !@pad_group_id.nil?
      true
    else
      false
    end
  end

  def create_placements(n)
    create_placement = "//span[@class= 'create-pad-page__save-button js-save-button']"
    n.times do
      session.visit environment + "/pad_groups/#{@pad_group_id}/create"
      while @session.has_no_selector?(:xpath, create_placement)
        sleep 1
      end
      session.find(:xpath, create_placement).click
      sleep 5
    end
    sleep 20
    @placement_list = session.all(:xpath, "//a[@class= 'pads-list__link js-pads-list-label']").map do |a|
      "name: #{a['text']}, id: #{a['href'].gsub(/[^0-9]/, '')}"
    end
  end

  def finish_work
    puts 'Bot finished his work, information about app/placements: '
    puts "App name: #{@appname} \nApp url: #{@url} \nApp id: #{@pad_group_id}"
    puts "Placements number: #{@placement_list.count}"
    puts "Placements list:\n"
    @placement_list.each { |a| puts a }
    @app.status = "Synchronized"
    @app.save
  end
end
