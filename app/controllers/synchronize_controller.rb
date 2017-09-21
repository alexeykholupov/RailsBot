class SynchronizeController < ApplicationController
  def workpage
    @user = User.all
  end
  def work
    url = params['a']
    user_id = params['user_id']['id']
    BotWorker.perform_async(user_id, url)
    redirect_to synchronize_workpage_url
  end
end
