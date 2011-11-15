require 'peach'
class ServicesController < ApplicationController
  # GET /services
  def index
      services = Rails.cache.fetch('discovered', :timeout => 1.hour) {Service.discovery} 
  end

  # GET /services/noservice
  def noservice
  end

  # GET /services/:service_name
  def show
    unless params[:id]
      flash[:warn] = "You should be requesting a service..."
      redirect_to root_path and return
    end


    # fetch cache
    policies = nil # obtained from cache
    localload = Service.run_local(params[:id], policies)
    if localload    # run local service if it contains proper policy and is below threshold
        redirect_to "http://localhost:#{Service::APPS[params[:id]].first}/#{params[:id]}"
    else
       
    end
            



  end

  # GET /services/list
  def list
    s = []
    Service::APPS.keys.peach do |namepolicy|      
      s << [namepolicy, Service::APPS[namepolicy].last] if Service.up?(namepolicy)
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

