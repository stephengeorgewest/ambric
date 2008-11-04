package velocity;

import ajava.io.InputStream;
import ajava.io.OutputStream;
//import java.math.*;

public class Velocity
{
	public void run(
			InputStream<Integer> g_xx_smooth,
			InputStream<Integer> g_xy_smooth,
			InputStream<Integer> g_xt_smooth,
			InputStream<Integer> g_yt_smooth,
			InputStream<Integer> g_yy_smooth,
			InputStream<Integer> g_tt_smooth,
			
			OutputStream<Integer> Vx,
			OutputStream<Integer> Vy)
	{
		int g_xx = g_xx_smooth.readInt();
		int g_xy = g_xy_smooth.readInt();
		int g_xt = g_xt_smooth.readInt();
		int g_yy = g_yy_smooth.readInt();
		int g_yt = g_yt_smooth.readInt();
		int g_tt = g_tt_smooth.readInt();
		
		int Vx_div = g_xt*g_yy-g_xy*g_yt;
		int Vy_div = g_xx*g_yt-g_xy*g_yt;
		int divisor= g_xx*g_yy-g_xy*g_xy;
		
		int divisor_valu;
		int divisor_sign;
		if(divisor>=0)
		{
			divisor_valu=divisor;
			divisor_sign=1;
		}
		else
		{
			divisor_valu=-divisor;
			divisor_sign=-1;
		}
		
		int Vx_quotient=0;
		int Vx_fraction=0;
		int Vx_quotient_sign;
		if(Vx_div>=0)
			Vx_quotient_sign=1;
		else
			Vx_quotient_sign=-1;
		int Vx_remainder; 
		if(Vx_div>=0)
			Vx_remainder=Vx_div;
		else
			Vx_remainder=-Vx_div;
		
		int Vy_quotient=0;
		int Vy_fraction=0;
		int Vy_quotient_sign;
		if(Vy_div>=0)
			Vy_quotient_sign=1;
		else
			Vy_quotient_sign=-1;
		int Vy_remainder;
		if(Vy_div>=0)
			Vy_remainder=Vy_div;
		else
			Vy_remainder=-Vy_div;
		
		if(divisor_valu==0)
		{
				Vx_quotient=0;
				Vx_remainder=0;
				Vy_quotient=0;
				Vy_remainder=0;
		}
		else
		{
			// integer part of vx/divisor
			while (Vx_remainder>divisor_valu)
			{
				Vx_quotient++;
				Vx_remainder-=divisor;
			}
			//do fractional part
			int precision=4;
			Vx_remainder=Vx_remainder<<precision;
			while(Vx_remainder>divisor_valu)
			{
				Vx_fraction++;
				Vx_remainder-=divisor;
			}
			
			
			while (Vy_remainder>divisor)
			{
				Vy_quotient++;
				Vy_remainder-=divisor;
			}
			//do fractional part
			Vy_remainder=Vy_remainder<<precision;
			while(Vy_remainder>divisor_valu)
			{
				Vy_fraction++;
				Vy_remainder-=divisor;
			}
		}
		
		if(divisor_valu<=0)
		{//recalculate stuff
			int k=(g_tt-g_xt*Vx_quotient - 2*g_yt*Vy_quotient + g_xx*Vx_quotient*Vx_quotient + 2*g_xy*Vx_quotient*Vy_quotient + g_yy*Vy_quotient*Vy_quotient);///28;
			int g_xx_n=g_xx+k;
			int g_yy_n=g_yy+k;
			Vx_div = g_xt*g_yy_n-g_xy*g_yt;
			Vy_div = g_xx_n*g_yt-g_xy*g_yt;
			divisor= g_xx_n*g_yy_n-g_xy*g_xy;
			
			
			
			/*int Vx_quotient=0;
			int Vx_fraction=0;
			int Vx_quotient_sign;*/
			if(Vx_div>=0)
				Vx_quotient_sign=1;
			else
				Vx_quotient_sign=-1;
			//int Vx_remainder; 
			if(Vx_div>=0)
				Vx_remainder=Vx_div;
			else
				Vx_remainder=-Vx_div;
			
			/*int Vy_quotient=0;
			int Vy_fraction=0;
			int Vy_quotient_sign;*/
			if(Vy_div>=0)
				Vy_quotient_sign=1;
			else
				Vy_quotient_sign=-1;
			//int Vy_remainder;
			if(Vy_div>=0)
				Vy_remainder=Vy_div;
			else
				Vy_remainder=-Vy_div;
			
			if(divisor_valu==0)
			{
					Vx_quotient=0;
					Vx_remainder=0;
					Vy_quotient=0;
					Vy_remainder=0;
			}
			else
			{
				// integer part of vx/divisor
				while (Vx_remainder>divisor_valu)
				{
					Vx_quotient++;
					Vx_remainder-=divisor;
				}
				//do fractional part
				int precision=4;
				Vx_remainder=Vx_remainder<<precision;
				while(Vx_remainder>divisor_valu)
				{
					Vx_fraction++;
					Vx_remainder-=divisor;
				}
				
				
				while (Vy_remainder>divisor)
				{
					Vy_quotient++;
					Vy_remainder-=divisor;
				}
				//do fractional part
				Vy_remainder=Vy_remainder<<precision;
				while(Vy_remainder>divisor_valu)
				{
					Vy_fraction++;
					Vy_remainder-=divisor;
				}
			}
			
			
		}
		Vx.writeInt(Vx_quotient<<4|Vx_fraction);
		Vy.writeInt(Vy_quotient<<4|Vy_fraction);
	}
}
