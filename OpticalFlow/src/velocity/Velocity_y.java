package velocity;

import ajava.io.InputStream;
import ajava.io.OutputStream;
//import java.math.*;

public class Velocity_y
{
	public void run(
			InputStream<Integer> k,
			InputStream<Integer> xx,
			InputStream<Integer> xy,
			InputStream<Integer> xt,
			InputStream<Integer> yt,
			
			OutputStream<Integer> Vy_numerator
			)
	{
		int _k_ = k.readInt();
		int _xx_ = xx.readInt()+_k_;
		int _xy_ = xy.readInt();
		int _xt_ = xt.readInt();
		int _yt_ = yt.readInt();
		
		int Vy_num = _xx_*_yt_-_xy_*_xt_;
		
		Vy_numerator.writeInt(Vy_num);
	}
}
