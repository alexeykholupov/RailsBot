class Bot
  attr_reader :session, :environment, :authenticate, :placement_list
  DEVELOPMENT = 'https://target-sandbox.my.com'.freeze
  PRODUCTION = 'https://target.my.com'.freeze
  def initialize(user_id, url, environment, session)
    @user_id = user_id
    @url = url
    @session = session
    @environment = DEVELOPMENT if environment == '2'
    @environment = PRODUCTION if environment == '1'
    @authenticate = false
  end

  def authenticate_user
    signin_button = "//span[@class= 'js-button ph-button ph-button_profilemenu ph-button_light ph-button_profilemenu_signin']"
    @session.visit @environment
    sleep 10
    @session.find(:xpath, signin_button).click
    @session.fill_in('login', with: User.find(@user_id).email)
    @session.fill_in('password', with: User.find(@user_id).password)
    @session.click_on('Sign in')
    @authenticate = true
  end

  def create_app
    if @authenticate == true
      create_app_button = "//span[@class= 'main-button__label']"
      next_button = "//div[@class= 'paginator__button paginator__button_right js-control-inc']"
      @session.visit environment + '/create_pad_groups/'
      @session.fill_in('Enter site/app URL', with: @url)
      @appname = @session.find(:xpath, "//span[@class= 'pad-setting__platform-preview__title js-platform-preview-app-title']").text
      sleep 10
      @session.fill_in('Site/app name', with: @appname)
      sleep 10
      @session.find(:xpath, create_app_button).click
      sleep 20
      while @session.has_no_selector?('a', text: @appname)
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
    n.times do
      session.visit environment + "/pad_groups/#{@pad_group_id}/create"
      sleep 5
      session.find(:xpath, "//span[@class= 'create-pad-page__save-button js-save-button']").click
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
  end
end