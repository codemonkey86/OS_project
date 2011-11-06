class ServicesController < ApplicationController
  # GET /services
  def index
  end

  # GET /services/:service_name
  def show
    unless params[:id]
      flash[:warn] = "You should be requesting a service..."
      redirect_to root_path and return
    end

    unless Service::APPS.include?(params[:id])
      redirect_to "http://lmgtfy.com/?q=#{params[:id]}" and return
    end

    # normally only if below threshold and host service but...
    if service_up?(params[:id])
      redirect_to "http://localhost:#{Service::APPS[params[:id]]}"
    else
      redirect_to "http://www.google.com"
    end
  end

  # GET /services/list
  def list
    s = []
    Service::APPS.keys.each do |name|
      s << name if service_up?(name)
    end
    render :json => s
  end

  # GET /services/new
  def new
  end

  # POST /services
  def create
  end

  private
  def service_up?(name)
    begin
      c = Curl::Easy.perform("http://localhost:#{Service::APPS[name]}")
    rescue Curl::Err::ConnectionFailedError
      return false
    end
    c.response_code == 200
  end
end

