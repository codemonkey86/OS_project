require 'peach'
class ServicesController < ApplicationController
  # GET /services
  def index
      services = Service.discovery
      puts services
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

    # discover?
    services = Rails.cache.fetch('discovered', :timeout => 1.hour) {Service.discovery}
    puts services.inspect  
  
    #TODO;  implement load balancing here normally only if below threshold and host service but...
    if Service.up?(params[:id])
      redirect_to "http://localhost:#{Service::APPS[params[:id]]}"
    else
      redirect_to "http://www.google.com"
    end
  end

  # GET /services/list
  def list
    s = []
    Service::APPS.keys.peach do |name|
      s << name if Service.up?(name)
    end
    render :json => s
  end

  # GET /services/new
  def new
  end

  # POST /services
  def create
  end
end

