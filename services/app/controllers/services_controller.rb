require 'peach'
class ServicesController < ApplicationController
  # GET /services
  def index
      services = Rails.cache.fetch(Service.cache_key, :timeout => 1.hour) {Service.discovery}
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

    localload = Service.run_local(params[:id], true)
    if localload[0]    #1st parameter is true if service is available locally and below threshold
        redirect_to "http://localhost:#{Service::APPS[params[:id]]}/#{params[:id]}"
    else
        services = Rails.cache.fetch(Service.cache_key, :timeout => 1.hour) {Service.discovery}
        if !Service.min_load(services, params[:id]) #service not found anywhere else
             if Service.run_local(params[:id], false)[0] #run it locally, this time regardless of load
                redirect_to "http://localhost:#{Service::APPS[params[:id]]}/#{params[:id]}"
             else
                 redirect_to "http://localhost:3000/services/noservice" #todo build this view, service not found anywhere
             end
        else  #redirect request to machine identified as having lowest balance (including local machine's balance!)
            redirect_to Service.min_load(services.services, params[:id], localload[1]))
        end
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
  # used to save cache state may move to new if can't hit this
  def create
    service = Services.new(:state=>Rails.cache.fetch(Service.cache_key))
    return service.save!
  end
end
