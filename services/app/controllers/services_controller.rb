#This is the primary controller that contains the load balancing algorithm,
# determines our restful API, and contains a method to calculate the machine load

require 'peach'
require 'json'
class ServicesController < ApplicationController
  # this is disabled for the purpose of gathering metrics via exteranl ruby script
  skip_before_filter :verify_authenticity_token

  # GET /services
  def index
    render :json => Service.getindex
  end

  # GET /services/noservice
  def noservice
  end

  # GET /services/set_cache
  # jump straight to cache writing via passed param
  def set_cache
    Rails.cache.write(Service.cache_key,JSON.parse(params[:newest]))
  end

  # GET /services/:service_name
  def show
    unless params[:id]
      flash[:warn] = "You should be requesting a service..."
      redirect_to root_path and return
    end

    # TODO: decide if empty array or nil is better
    req_pol = params[:policies] ? params[:policies].split(',') : []
    puts "Using " + req_pol.inspect + " as polices from user"

    # load balancing algorithm: run locally if below threshold
    # else redirect request to lowest absolute load of discovered services

    # check if cached, else build service knowledge from Service.discovery
    syscache = Rails.cache.fetch(Service.cache_key, :timeout => 1.hour) {Service.discovery}
    service_info = nil
    #without this condition the service gets added incorrectly to local cache
    #NOTE: this cannot be turned into online if, as soon as the assignment is scene, cache is messed up
    if syscache[:services].keys.include?(params[:id])
        service_info = syscache[:services][params[:id]]
    end
    #run_local (service_name, service_policy on "localhost",  machine_policy, service_load_avg)
    if Service::APPS[params[:id]].nil? || service_info.nil?
      render :action => "noservice"
  elsif Service.run_local(params[:id],service_info[:host_policy][`hostname`.strip], req_pol, service_info[:threshold])
      redirect_to "http://localhost:#{Service::APPS[params[:id]]}/#{params[:id]}"
    else
      minload = Service.minload(service_info, req_pol, Service::APPS[params[:id]])
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

  #this method is an interface for running metrics  and easily find the system load
  def sysload
    sysmem = 0
    # the pops here is to not include the two "process" found with ps the command itself which are gone by time pmap occurs
    pid_array =  `ps -ef | grep java`.split(/\n/)
    pid_array.pop
    pid_array.pop
    puts pid_array.last.to_s
    pid_array.each do |jproc|
         pid = jproc.match(/.+?([0-9]+)/)[1].to_i    #pid
         sysmem += (`pmap #{pid} | tail -1`[10,40].strip.gsub!("K","").to_f*100.0) / (1024* `free -mt`.match(/Mem:\s*([0-9]+)/)[1].to_f)
    end

      render :text => sysmem
  end

  # POST /services
  # used to save cache state may move to new if can't hit this
  def create
    service = Services.new(:state=>Rails.cache.fetch(Service.cache_key))
    return service.save!
  end
end
