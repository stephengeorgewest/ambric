package outer_product;

import ajava.io.InputStream;
import ajava.io.OutputStream;

public class Outer_Product1
{
	public void run(InputStream<Integer> dx_smooth, InputStream<Integer> dy_smooth, InputStream<Integer> dt_smooth,
			
			OutputStream<Integer> g_xx, OutputStream<Integer> g_xy, OutputStream<Integer> g_xt)
	{
		int dx=dx_smooth.readInt();
		int dy=dy_smooth.readInt();
		int dt=dt_smooth.readInt();
		
		g_xx.writeInt((dx*dx));
		g_xy.writeInt((dx*dy));
		g_xt.writeInt((dx*dt));
	}
}
