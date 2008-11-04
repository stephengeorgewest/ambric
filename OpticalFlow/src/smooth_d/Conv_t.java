package smooth_d;

import ajava.io.InputStream;
import ajava.io.OutputStream;

public class Conv_t
{
	public void run(InputStream<Integer> in, OutputStream<Integer> out)
	{
		int p0=in.readInt();
		int p1=in.readInt();
		int p2=in.readInt();
		out.writeInt((p0+p1*2+p2));//<<1);//[2 4 2] == 2 [1 2 1] 
	}
}
