class PolicyController < ApplicationController
  ##
  # returns xml for ws_policy needs
  def index
    Rails.cache.fetch('ws_policy',8.hours) do
      f = File.open("#{RAILS_ROOT}/config/my_policy.xml", 'r+')
      xml = f.readlines.collect{|x| x.strip}.join
      f.close
      render :xml => xml
    end
  end
end
