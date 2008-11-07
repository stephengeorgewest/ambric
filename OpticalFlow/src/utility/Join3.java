package utility;

import ajava.io.InputStream;
import ajava.io.OutputStream;

public class Join3
{
	public void run(InputStream<Integer> in_1,
			InputStream<Integer> in_2,
			InputStream<Integer> in_3,
			OutputStream<Integer> out)
	{
		out.writeInt(in_1.readInt());
		out.writeInt(in_2.readInt());
		out.writeInt(in_3.readInt());
	}
}
