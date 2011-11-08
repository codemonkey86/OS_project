include Math
class ConvertController < ApplicationController

   def compute
       # ruby precision limits result in 15 place cap
        if params[:value].match(/\D/) or params[:base].to_i < 2 or params[:base].to_i > 64 
             @result = "Invalid Input: Try Again"
        else
            puts params[:value] 
             @result = params[:value].to_i.to_s(params[:base].to_i)
        end
             
   end



end
