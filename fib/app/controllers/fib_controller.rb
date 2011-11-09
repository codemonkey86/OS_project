include Math
class FibController < ApplicationController
  def compute
    if  !params[:digits].match(/^[1-9][0-9]*$/)
      @result = "Invalid Input: Try Again"
    else # use Gauss-Legendre algo to calculate pi
      # initial values
      if params[:digits] == "1"
           @result = 0
      elsif params[:digits] == "2"
           @result = 1
      else
        index=2
        fn2 = 0
        fn1 = 1
        while(index<= params[:digits].to_i)
             f = fn2 + fn1
             fn2 = fn1
             fn1 = f
             index = index + 1
        end
        @result = f
      end
    end
  end
end
