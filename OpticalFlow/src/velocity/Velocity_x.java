package velocity;

import ajava.io.InputStream;
import ajava.io.OutputStream;
//import java.math.*;

public class Velocity_x
{
	public void run(
			InputStream<Integer> k,
			InputStream<Integer> xy,
			InputStream<Integer> xt,
			InputStream<Integer> yt,
			InputStream<Integer> yy,
			
			OutputStream<Integer> Vx_numerator
			)
	{
		int _k_ = k.readInt();
		int _xy_ = xy.readInt();
		int _xt_ = xt.readInt();
		int _yy_ = yy.readInt()+_k_;
		int _yt_ = yt.readInt();
		
		int Vx_num = _xt_*_yy_-_xy_*_yt_;
		
		Vx_numerator.writeInt(Vx_num);
	}
}
