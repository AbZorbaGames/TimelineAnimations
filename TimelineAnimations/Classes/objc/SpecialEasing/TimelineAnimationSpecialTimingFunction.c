/*!
 *  @file TimelineAnimationSpecialTimingFunction.m
 *  @brief TimelineAnimations
 *
 *  Created by @author Georges Boumis
 *  @date 01/03/2016.
 *  @copyright Copyright © 2016-2017 Abzorba Games. All rights reserved.
 */

#include <math.h>
#include "TimelineAnimationSpecialTimingFunction.h"

// Modeled after the line y = x
double LinearInterpolation(double p)
{
	return p;
}

// Modeled after the parabola y = x^2
double QuadraticEaseIn(double p)
{
	return p * p;
}

// Modeled after the parabola y = -x^2 + 2x
double QuadraticEaseOut(double p)
{
	return -(p * (p - 2));
}

// Modeled after the piecewise quadratic
// y = (1/2)((2x)^2)             ; [0, 0.5)
// y = -(1/2)((2x-1)*(2x-3) - 1) ; [0.5, 1]
double QuadraticEaseInOut(double p)
{
	if(p < 0.5)
	{
		return 2 * p * p;
	}
	else
	{
		return (-2 * p * p) + (4 * p) - 1;
	}
}

// Modeled after the cubic y = x^3
double CubicEaseIn(double p)
{
	return p * p * p;
}

// Modeled after the cubic y = (x - 1)^3 + 1
double CubicEaseOut(double p)
{
	double f = (p - 1);
	return (double)(f * f * f + 1);
}

// Modeled after the piecewise cubic
// y = (1/2)((2x)^3)       ; [0, 0.5)
// y = (1/2)((2x-2)^3 + 2) ; [0.5, 1]
double CubicEaseInOut(double p)
{
	if(p < 0.5)
	{
		return 4 * p * p * p;
	}
	else
	{
		double f = ((2 * p) - 2);
        return (double)(0.5 * f * f * f + 1);
	}
}

// Modeled after the quartic x^4
double QuarticEaseIn(double p)
{
	return (double)(p * p * p * p);
}

// Modeled after the quartic y = 1 - (x - 1)^4
double QuarticEaseOut(double p)
{
	double f = (p - 1);
	return (double)(f * f * f * (1 - p) + 1);
}

// Modeled after the piecewise quartic
// y = (1/2)((2x)^4)        ; [0, 0.5)
// y = -(1/2)((2x-2)^4 - 2) ; [0.5, 1]
double QuarticEaseInOut(double p)
{
	if(p < 0.5)
	{
		return (double)(8 * p * p * p * p);
	}
	else
	{
		double f = (p - 1);
		return (double)(-8 * f * f * f * f + 1);
	}
}

// Modeled after the quintic y = x^5
double QuinticEaseIn(double p)
{
	return (double)(p * p * p * p * p);
}

// Modeled after the quintic y = (x - 1)^5 + 1
double QuinticEaseOut(double p)
{
	double f = (p - 1);
	return (double)(f * f * f * f * f + 1);
}

// Modeled after the piecewise quintic
// y = (1/2)((2x)^5)       ; [0, 0.5)
// y = (1/2)((2x-2)^5 + 2) ; [0.5, 1]
double QuinticEaseInOut(double p)
{
	if(p < 0.5)
	{
		return 16 * p * p * p * p * p;
	}
	else
	{
		double f = ((2 * p) - 2);
		return  (double)(0.5 * f * f * f * f * f + 1);
	}
}

// Modeled after quarter-cycle of sine wave
double SineEaseIn(double p)
{
	return (double)(sin((p - 1) * M_PI_2) + 1);
}

// Modeled after quarter-cycle of sine wave (different phase)
double SineEaseOut(double p)
{
	return (double)(sin(p * M_PI_2));
}

// Modeled after half sine wave
double SineEaseInOut(double p)
{
	return (double)(0.5 * (1 - cos(p * M_PI)));
}

// Modeled after shifted quadrant IV of unit circle
double CircularEaseIn(double p)
{
	return (double)(1 - sqrt(1 - (p * p)));
}

// Modeled after shifted quadrant II of unit circle
double CircularEaseOut(double p)
{
	return (double)(sqrt((2 - p) * p));
}

// Modeled after the piecewise circular function
// y = (1/2)(1 - sqrt(1 - 4x^2))           ; [0, 0.5)
// y = (1/2)(sqrt(-(2x - 3)*(2x - 1)) + 1) ; [0.5, 1]
double CircularEaseInOut(double p)
{
	if(p < 0.5)
	{
		return (double)(0.5 * (1 - sqrt(1 - 4 * (p * p))));
	}
	else
	{
		return (double)(0.5 * (sqrt(-((2 * p) - 3) * ((2 * p) - 1)) + 1));
	}
}

// Modeled after the exponential function y = 2^(10(x - 1))
double ExponentialEaseIn(double p)
{
	return (p == 0.0) ? p : (double)(pow(2, 10 * (p - 1)));
}

// Modeled after the exponential function y = -2^(-10x) + 1
double ExponentialEaseOut(double p)
{
	return (p == 1.0) ? p : (double)(1 - pow(2, -10 * p));
}

// Modeled after the piecewise exponential
// y = (1/2)2^(10(2x - 1))         ; [0,0.5)
// y = -(1/2)*2^(-10(2x - 1))) + 1 ; [0.5,1]
double ExponentialEaseInOut(double p)
{
	if(p == 0.0 || p == 1.0) return p;
	
	if(p < 0.5)
	{
		return (double)(0.5 * pow(2, (20 * p) - 10));
	}
	else
	{
		return (double)(-0.5 * pow(2, (-20 * p) + 10) + 1);
	}
}

// Modeled after the damped sine wave y = sin(13pi/2*x)*pow(2, 10 * (x - 1))
double ElasticEaseIn(double p)
{
	return (double)(sin(13 * M_PI_2 * p) * pow(2, 10 * (p - 1)));
}

// Modeled after the damped sine wave y = sin(-13pi/2*(x + 1))*pow(2, -10x) + 1
double ElasticEaseOut(double p)
{
	return (double)(sin(-13 * M_PI_2 * (p + 1)) * pow(2, -10 * p) + 1);
}

// Modeled after the piecewise exponentially-damped sine wave:
// y = (1/2)*sin(13pi/2*(2*x))*pow(2, 10 * ((2*x) - 1))      ; [0,0.5)
// y = (1/2)*(sin(-13pi/2*((2x-1)+1))*pow(2,-10(2*x-1)) + 2) ; [0.5, 1]
double ElasticEaseInOut(double p)
{
	if(p < 0.5)
	{
		return (double)(0.5 * sin(13 * M_PI_2 * (2 * p)) * pow(2, 10 * ((2 * p) - 1)));
	}
	else
	{
		return (double)(0.5 * (sin(-13 * M_PI_2 * ((2 * p - 1) + 1)) * pow(2, -10 * (2 * p - 1)) + 2));
	}
}

// Modeled after the overshooting cubic y = x^3-x*sin(x*pi)
double BackEaseIn(double p)
{
	return (double)(p * p * p - p * sin(p * M_PI));
}

// Modeled after overshooting cubic y = 1-((1-x)^3-(1-x)*sin((1-x)*pi))
double BackEaseOut(double p)
{
	double f = (1 - p);
	return (double)(1 - (f * f * f - f * sin(f * M_PI)));
}

// Modeled after the piecewise overshooting cubic function:
// y = (1/2)*((2x)^3-(2x)*sin(2*x*pi))           ; [0, 0.5)
// y = (1/2)*(1-((1-x)^3-(1-x)*sin((1-x)*pi))+1) ; [0.5, 1]
double BackEaseInOut(double p)
{
	if(p < 0.5)
	{
		double f = 2 * p;
		return (double)(0.5 * (f * f * f - f * sin(f * M_PI)));
	}
	else
	{
		double f = (1 - (2*p - 1));
		return (double)(0.5 * (1 - (f * f * f - f * sin(f * M_PI))) + 0.5);
	}
}

double BounceEaseIn(double p)
{
	return 1 - BounceEaseOut(1 - p);
}

double BounceEaseOut(double p)
{
	if(p < 4/11.0)
	{
		return (double)((121 * p * p)/16.0);
	}
	else if(p < 8/11.0)
	{
		return (double)((363/40.0 * p * p) - (99/10.0 * p) + 17/5.0);
	}
	else if(p < 9/10.0)
	{
		return (double)((4356/361.0 * p * p) - (35442/1805.0 * p) + 16061/1805.0);
	}
	else
	{
		return (double)((54/5.0 * p * p) - (513/25.0 * p) + 268/25.0);
	}
}

double BounceEaseInOut(double p)
{
	if(p < 0.5)
	{
		return (double)(0.5 * BounceEaseIn(p*2));
	}
	else
	{
		return (double)(0.5 * BounceEaseOut(p * 2 - 1) + 0.5);
	}
}

double SlowMotion(const double p) {
    double elapsedTimeRate = p;
    const double p1 = 0.25;
    const double p2 = 0.7;
    const double p3 = p1 + p2;
    
    double r = elapsedTimeRate + (0.5f - elapsedTimeRate) * p;
    if (elapsedTimeRate < p1) {
        elapsedTimeRate = 1 - (elapsedTimeRate/p1);
        return r - (elapsedTimeRate * elapsedTimeRate * elapsedTimeRate * elapsedTimeRate * r);
    } else if (elapsedTimeRate > p3) {
        double elapsedTimeRate1 = (double)(elapsedTimeRate - p3)/p1;
        return r + (elapsedTimeRate - r) * (elapsedTimeRate1 * elapsedTimeRate1 * elapsedTimeRate1 * elapsedTimeRate1);
    }
    return r;
}
