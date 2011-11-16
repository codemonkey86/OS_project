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

   #load balancing algorithm: run locally if below threshold, else redirect request to lowest absolute load of discovered services
    # fetch cache
    syscache = Rails.cache.fetch('discovered', :timeout => 1.hour) {Service.discovery}
    #run_local (service_name, service_policy on "localhost",  machine_policy, service_load_avg)
    if run_local(params[:id], syscacne[:services][params[:id]][:host_policy][`hostname`.strip], syscache[:machinepolicy], syscache[:services][params[:id]][:threshold])
        redirect_to "http://localhost:#{Service::APPS[params[:id]].first}/#{params[:id]}"
    else
        minload(syscache)
        if !minload
            redirect_to noservice
        else
             redirect to minload
        end
      
    end

  # obtained from cache
     #run_local(service_name, service_policy, system_policy service_average_load
   # if Service.run_local(params[:id], syscache[:services][params[:id]][:policies], syscache[:services][params[:id]][:threshold])   # run local service if it contains proper policy and is below threshold
   #     
   # else
       
   # end
            



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

