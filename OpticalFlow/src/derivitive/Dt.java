package derivitive;

import ajava.io.InputStream;
import ajava.io.OutputStream;

public class Dt
{
	public void run( InputStream<Integer> in, OutputStream<Integer> out)
	{
		int p0=in.readInt();//come in from ddr as serialized stream
		int p1=in.readInt();
		int p3=in.readInt();
		int p4=in.readInt();
		//[-1 8 0 -8 1]
		out.writeInt(-p0+p1*8-p3*8+p4);
	}
}
