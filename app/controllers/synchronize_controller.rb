class SynchronizeController < ApplicationController
  def workpage
    @user = User.all
    @apps = App.all
  end
  def work
    @app = App.new(params.require(:appurl).permit(:url))
    @app.save
    app = App.find(@app.id)
    app.status = "Not Synchronized"
    app.appname = "Not defined yet"
    app.save
    url = params[:appurl][:url]
    user_id = params['user_id']['id']
    BotWorker.perform_async(user_id, url, @app.id)
    redirect_to synchronize_workpage_url
  end
end
