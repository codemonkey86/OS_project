require 'peach'
require 'json'
class ServicesController < ApplicationController
  # GET /services
  # can pass param to negate building a new cached object
  def index

    render :json => Rails.cache.read(Service.cache_key)
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
    
    if Service.run_local(params[:id], syscache[:services][params[:id]][:host_policy][`hostname`.strip], syscache[:machinepolicy], syscache[:services][params[:id]][:threshold])
       puts "runlocal true"
      redirect_to "http://localhost:#{Service::APPS[params[:id]].first}/#{params[:id]}"
    else
        puts "runlocal false"
        minload = Service.minload(syscache[:services][params[:id]], syscache[:machinepolicy], Service::APPS[params[:id]].first)
        if !minload
            puts "no service redirect"
            render :action =>  "noservice"
        else
             puts "found it redirect"
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
