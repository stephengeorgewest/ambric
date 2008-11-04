package velocity;

import ajava.io.InputStream;
import ajava.io.OutputStream;
//import java.math.*;

public class K_2
{
	int compare_val;
	int fraction_bits;
	
	public K_2(boolean match_roger, int fraction_bits)
	{
		this.fraction_bits = fraction_bits;
		this.compare_val = 4;
	}
	public void run(
			InputStream<Integer> Vx,
			InputStream<Integer> Vy,
			InputStream<Integer> xy,
			InputStream<Integer> yy,
			InputStream<Integer> yt,
			InputStream<Integer> denominator,
			
			OutputStream<Integer> k2
			)
	{
		int g_xy = xy.readInt();
		int g_yy = yy.readInt();
		int g_yt = yt.readInt();
		
		int Vx_div = Vx.readInt();
		int Vy_div = Vy.readInt();

		int denominator_= denominator.readInt();
		
		int k_2 = 0;
		int sign=0;
		if(denominator_<this.compare_val)
		{//see k1
			int k2a = -(g_yt<<this.fraction_bits)*Vy_div;//[a+n,2m]
			int k2b1 = g_xy<<this.fraction_bits;//[a,m]
			int k2b2 = (Vx_div*Vy_div);//[2n,2m]
			if (k2b2<0)
			{
				sign = -1;
				k2b2 = -k2b2;
			}
			else
				sign = 1;
			k2b2 = sign*(((k2b2>>(this.fraction_bits-1))+1)>>1);//div,round [2n,m]
			int k2b = k2b1*k2b2;//[a+2n,2m]
			
			int k2c1 = g_yy<<this.fraction_bits;//[a,m]
			int k2c2 = (Vy_div*Vy_div);//[2n,2m]
			if(k2c2<0)
			{
				sign=-1;
				k2c2 = -k2c2;
			}
			else
				sign=1;
			k2c2 = sign*(((k2c2>>(this.fraction_bits-1))+1)>>1);//div,round [2n,m]
			int k2c = k2c1*k2c2;//[a+2n,2m]
			int k2bc = k2b+k2b+k2c;//[a+2n+2,2m]
			if(k2bc<0)
			{
				sign=-1;
				k2bc = -k2bc;
			}
			else
				sign=1;
			k2bc = sign*(((k2bc>>(this.fraction_bits-1))+1)>>1);//div,round [a+2n+2,m]
			
			k_2 = k2a+ k2a+k2bc;//[a+2n+4,m]
			
			/*k_2 = (
					//- 2*(g_yt<<this.fraction_bits)*Vy_div
					- ((g_yt<<this.fraction_bits)*Vy_div)>>this.fraction_bits //[a+n,m]
					- ((g_yt<<this.fraction_bits)*Vy_div)>>this.fraction_bits //[a+n,m]
					//+ 2*(g_xy<<this.fraction_bits)*Vx_div*Vy_div
					+ (g_xy<<this.fraction_bits)*(
							(Vx_div*Vy_div)>>this.fraction_bits)//[a+2n,m]
					+ (g_xy<<this.fraction_bits)*(
							(Vx_div*Vy_div)>>this.fraction_bits)//[a+2n,m]
					+ (g_yy<<this.fraction_bits)*(
							(Vy_div*Vy_div)>>this.fraction_bits)//[a+2n,m]
					)>>this.fraction_bits;//[a+2n,0]
			*/
		}
		k2.writeInt(k_2);
	}
}
