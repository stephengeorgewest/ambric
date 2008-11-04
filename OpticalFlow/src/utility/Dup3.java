package utility;

import ajava.io.InputStream;
import ajava.io.OutputStream;

public class Dup3
{
	public void run(InputStream<Integer> in,
			OutputStream<Integer> out_1,
			OutputStream<Integer> out_2,
			OutputStream<Integer> out_3)
	{
		int value = in.readInt();
		out_1.writeInt(value);
		out_2.writeInt(value);
		out_3.writeInt(value);
	}
}
