include Math
class QuadController < ApplicationController

   def compute
       if !params[:ainput].match(/^[0-9]*$/) or params[:ainput] == 0 or !params[:binput].match(/^[0-9]*$/) or !params[:cinput].match(/^[0-9]*$/)
              @results = "Invalid input, try again"
       else
              a = params[:ainput].to_i 
  	      b = params[:binput].to_i
              c = params[:cinput].to_i
              if b**2 - 4*a*c <0
                   @results = "Imaginary roots"
              else
                  @results = [ (-b+sqrt(b**2-4*a*c))/(2.0*a), (-b-sqrt(b**2-4*a*c))/(2.0*a)]
             end



   end

end

end
