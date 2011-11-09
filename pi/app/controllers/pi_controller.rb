include Math
require 'bigdecimal'
class PiController < ApplicationController
  def compute
    # ruby precision limits result in 15 place cap
    if  !params[:digits].match(/^[1-9][0-9]*$/) or params[:digits].to_i > 15
      @result = "Invalid Input: Try Again"
    else # use Gauss-Legendre algo to calculate pi
      # initial values
      a = 1
      b  = 1/sqrt(2)
      t = 0.25
      p = 1
      found = false
      while !found
        an = (a+b)/2
        bn = sqrt(a*b)
        tn = t -p*(a-an)**2
        pn = 2*p
        a = an
        b = bn
        t = tn
        p = pn
        pi = (a+b)**2/(4*t)
        if (a-b < 10**(-1*params[:digits].to_i) )
          found = true
        end
      end
      @result = pi.to_s[0, params[:digits].to_i+2]
    end
  end
end
