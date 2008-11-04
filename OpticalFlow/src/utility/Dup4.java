package utility;

import ajava.io.InputStream;
import ajava.io.OutputStream;

public class Dup4
{
	public void run(InputStream<Integer> in,
			OutputStream<Integer> out1,
			OutputStream<Integer> out2,
			OutputStream<Integer> out3,
			OutputStream<Integer> out4)
	{
		int value = in.readInt();
		out1.writeInt(value);
		out2.writeInt(value);
		out3.writeInt(value);
		out4.writeInt(value);
	}
}
