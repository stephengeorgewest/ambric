package stuff;

import ajava.io.InputStream;
import ajava.io.OutputStream;

public class Repeat9
{
	public void run(InputStream<Integer> in, OutputStream<Integer> out)
	{
		int val=in.readInt();
		for(int i=0;i<9;i++)
			out.writeInt(val);
	}
}
