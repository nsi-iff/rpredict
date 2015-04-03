require 'matrix'

module RPredict
  module SGPMath
    extend self
    include Math


    def vector_sub(v1, v2)

      v3 = vector_t()
      v3.x = v1.x - v2.x
      v3.y = v1.y - v2.y
      v3.z = v1.z - v2.z
      v3.w = magnitude(v3)
      v3
    end #Procedure vector_sub

=begin
     magnitude

    this procedure finds the magnitude of a vector.  the tolerance is set to
    0.000001, thus the 1.0e-12 for the squared test of underflows.
=end

    def magnitude(vector)
      Vector.elements([vector.x,vector.y,vector.z,vector.w]).magnitude
    end



    def pow(base,exponent)
      base**exponent
    end

    def deg2rad(degrees=0.0)
      degrees * Math::PI / 180
    end

    def signal(value=0.0)
      -1.0 if value < 0.0 else 1.0
    end

    def frac(arg)
      # Returns fractional part of double argument */
      arg-arg.floor
    end

    def modulus(arg1,  arg2)

    # Returns arg1 mod arg2 */
       fmod(arg1,arg2)
    end

    def sqr(arg1)
        arg1**2
    end

    def cube(arg1)
        arg1**3
    end


    def vdot(vector1,vector2)
      Vector.elements(vector1).inner_product(Vector.elements(vector2))
    end

    def fmod(value1,value2)
        value1%value2
    end

    def cross(vextor1,vector2)
        Vector.elements(vector2).cross_product(vector1)
    end



    def scale_Vector(k, v)

      #Multiplies the vector v by the scalar k */

      v.x *= k
      v.y *= k
      v.z *= k
      v.w = magnitude(v)
      v
    end

    def scalar_Multiply(k, v1)
      v2 = RPredict::Norad.vector_t()
      v2.x = k * v1.x
      v2.y = k * v1.y
      v2.z = k * v1.z
      v2.w = k.abs * v1.w;
      v2
    end #Procedure Scalar_Multiply


    def convert_Sat_State(pos,vel)
      # Converts the satellite's position and velocity
      # vectors from normalized values to km and km/sec */
      # ???????
        return scale_Vector(RPredict::Norad.XKMPER, pos), \
        scale_Vector(RPredict::Norad.XKMPER*RPredict::Norad::XMNPDA/RPredict::Norad::SECDAY, vel)


    end

=begin

anglevector

     this procedure calculates the angle between two vectors.  the output is
     set to 999999.1 to indicate an undefined value.  be sure to check for
     this at the output phase.
=end

    def angle(vector1,vector2)

        small     = 0.00000001
        undefined = 999999.1

        magnitudevector1 = magnitude(vector1)
        magnitudevector2 = magnitude(vector2)
        if (magnitudevector1*magnitudevector2) > (small**2)
            aux = vdot(vector1,vector2)/(magnitudevector1*magnitudevector2)
            if aux.abs> 1.0
                aux = signal(aux) * 1.0
            end
            return Math.acos(aux)
        else
            return undefined
        end
    end

    def fMod2p(x)

      # Returns mod 2PI of argument */

      ret_val=x
      i=ret_val/twopi
      ret_val-=i*twopi

      if (ret_val<0.0)
        ret_val+=twopi
      end
      ret_val
    end



  end
end