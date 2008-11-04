package velocity;

import ajava.io.InputStream;
import ajava.io.OutputStream;
//import java.math.*;

public class K_1
{
	int compare_val;
	int fraction_bits;

	public K_1(boolean match_roger, int fraction_bits)
	{
		this.fraction_bits = fraction_bits;
		this.compare_val = 4;//(1<<(this.fraction_bits))>>1;//(1/2)//val<=0.5
	}
	public void run(
			InputStream<Integer> Vx,
			InputStream<Integer> xx,
			InputStream<Integer> xt,
			InputStream<Integer> tt,
			InputStream<Integer> denominator,
			
			OutputStream<Integer> k1
			)
	{
		int g_xx = xx.readInt();
		int g_xt = xt.readInt();
		int g_tt = tt.readInt();
		
		int Vx_div = Vx.readInt();
		int denominator_in= denominator.readInt();
		
		int k_1 = 0;
		int sign;
		if(denominator_in<this.compare_val)
		{// NEED TO MATCH FIXED POINTED-NESS
			//[integer_bits, fraction_bits]
			//integer_bits+fraction_bits<32
			//g_## == [a,                  0] format
			//V#_  == [n, this.fraction_bits ==m] format
			//g_##<<this.fraction_bits == [a,m]
			//g_##*V#_div == [a+n, 2*m]
			//2*g_##*V#_div ==[a+n, 2*m,1extra] -- doesn't work so well
				//- 2*(g_xt<<this.fraction_bits)*Vx_div // doesn't work as nicely
				// use -1x -1x
			//(g_##)*(V#_div*V#_div) ==[a,0]*[n,m]*[n,m]
			//						==[a,0]*[2*n,2*m]
			//						==[a+2*n,2*m]
			//or
			//g_<<bits*((V#*V#)>>bits) ==[a,m]*(([n,m]*[n,m])>>m)
			//							==[a,m]*([2n,2m]>>m)
			//							==[a+2n,2m]
			
			// so [a,m]+[a+n,2m]+[a+2n,2m] needs to be
			//    [a,m]+([a+n,2m]>>m+[a+2n,2m]>>m)
			// == [a,m]+([a+n,m]+[a+2n,m]
			
			// final result needs to be in [a,0] format to add back to g_##
			// so >>m
			// will be divided by 28? later
			
			int k1a = g_tt<<this.fraction_bits;//[a,m]
			int k1b = -((g_xt<<this.fraction_bits)*Vx_div);//[a+n,2m]
			int k1c1 = g_xx<<this.fraction_bits;//[a,m]
			int k1c2 = Vx_div*Vx_div;//[2n,2m]
			if(k1c2<0)
			{
				sign= -1;
				k1c2= -k1c2;
			}
			else
				sign=1;
			k1c2 = sign*(((k1c2>>(this.fraction_bits-1))+1)>>1);//div,round [2n,m]
			int k1c = k1c1*k1c2;//[a+2n,2m]
			k_1 = k1b+k1b+k1c;//[a+2n+2,2m]
			if(k_1<0)
			{
				sign= -1;
				k_1= -k_1;
			}
			else
				sign= 1;
			k_1 = sign*(((k_1>>(this.fraction_bits-1))+1)>>1);//div,round [a+2n+2,m]
			k_1 += k1a;//[a+2n+3,m]
			
			// maybe I need to make these individual variables for easy reading
			/*k_1=(	g_tt<<this.fraction_bits +
						(
						- (g_xt<<this.fraction_bits)*Vx_div 
						- (g_xt<<this.fraction_bits)*Vx_div 
						+ (g_xx<<this.fraction_bits)*(
								(Vx_div*Vx_div)>>this.fraction_bits)
						)>>(this.fraction_bits)
					)>>(this.fraction_bits);
				*/
		}
		k1.writeInt(k_1);
	}
}
