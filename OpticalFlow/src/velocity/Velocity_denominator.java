package velocity;

import ajava.io.InputStream;
import ajava.io.OutputStream;
import ajava.lang.Math;


public class Velocity_denominator
{
	public void run(
			InputStream<Integer> k,
			InputStream<Integer> xx,
			InputStream<Integer> xy,
			InputStream<Integer> yy,
			
			OutputStream<Integer> denominator
			)
	{
		int _k_ = k.readInt();
		int _xx_ = xx.readInt()+_k_;
		int _xy_ = xy.readInt();
		int _yy_ = yy.readInt()+_k_;
		
		//int denominator_= _xx_*_yy_-_xy_*_xy_;
		Math.mult_32_32(_xx_, _yy_, Math.Marker.FIRST_LAST);
		int hi1 = Math.rdacc_hi(Math.Marker.FIRST);
		int low1 = Math.rdacc_lo(Math.Marker.LAST);
		if(hi1<0&&low1<0)
			hi1=0;
		
		Math.mult_32_32(_xy_, _xy_, Math.Marker.FIRST_LAST);
		int hi2 = Math.rdacc_hi(Math.Marker.FIRST);
		int low2 = Math.rdacc_lo(Math.Marker.LAST);
		if(hi2<0&&low2<0)
			hi2=0;
		
		Math.addacc(low1, -low2, Math.Marker.FIRST_LAST);
		int hi3 = Math.rdacc_hi(Math.Marker.FIRST);
		int low = Math.rdacc_lo(Math.Marker.LAST);
		if(hi3<0&&low<0)
			hi3=0;
		
		int hi = hi1+hi2+hi3;
		if(hi>0)
			low=Integer.MAX_VALUE;
		if(hi<0)
			low=Integer.MIN_VALUE;
		denominator.writeInt(low);
	}
}
