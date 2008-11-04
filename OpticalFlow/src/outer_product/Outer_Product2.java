package outer_product;

import ajava.io.InputStream;
import ajava.io.OutputStream;

public class Outer_Product2
{
	public void run(InputStream<Integer> dy_smooth, InputStream<Integer> dt_smooth,
			OutputStream<Integer> g_yy, OutputStream<Integer> g_yt,
			OutputStream<Integer> g_tt)
	{
		
		int dy=dy_smooth.readInt();
		int dt=dt_smooth.readInt();
		
		g_yy.writeInt((dy*dy));
		g_yt.writeInt((dy*dt));

		g_tt.writeInt((dt*dt));
	}
}
