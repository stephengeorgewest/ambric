package stuff;

import ajava.io.InputStream;
import ajava.io.OutputStream;

public class Split
{
	public void run(InputStream<Integer> in,
					OutputStream<Integer> out_1,
					OutputStream<Integer> out_2)
	{
		int i=in.readInt();
		out_1.writeInt(i);
		out_2.writeInt(i);
	}
}
