require 'peach'
require 'json'
class ServicesController < ApplicationController
  # GET /services
  # can pass param to negate building a new cached object
  skip_before_filter :verify_authenticity_token 
  # this is disabled for the purpose of gathering metrics via exteranl ruby script
  def index

    render :json => Service.getindex 
  end

  # GET /services/noservice
  def noservice
  end

  def set_cache
    Rails.cache.write(Service.cache_key,JSON.parse(params[:newest]))
  end

  # GET /services/:service_name
  def show
    unless params[:id]
      flash[:warn] = "You should be requesting a service..."
      redirect_to root_path and return
    end

   #load balancing algorithm: run locally if below threshold, else redirect request to lowest absolute load of discovered services
    # fetch cache

    syscache = Rails.cache.fetch(Service.cache_key, :timeout => 1.hour) {Service.discovery}
    #run_local (service_name, service_policy on "localhost",  machine_policy, service_load_avg)
    if Service::APPS[params[:id]].nil?
        render :action => "noservice"
    elsif Service.run_local(params[:id], syscache[:services][params[:id]][:host_policy][`hostname`.strip], syscache[:machinepolicy], syscache[:services][params[:id]][:threshold])
       puts "runlocal true"
      redirect_to "http://localhost:#{Service::APPS[params[:id]].first}/#{params[:id]}"
    else
        minload = Service.minload(syscache[:services][params[:id]], syscache[:machinepolicy], Service::APPS[params[:id]].first)
        if !minload
            render :action =>  "noservice"
        else
             redirect_to minload 
        end

    end

end


  # GET /services/list
  def list
    render :json => Service.getlist
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
