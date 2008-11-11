package utility;

import ajava.io.InputStream;
import ajava.io.OutputStream;

public class Three_in_One_out
{
	public void run(InputStream<Integer> in_1,
			InputStream<Integer> in_2,
			InputStream<Integer> in_3,
			OutputStream<Integer> out)
	{
		in_1.readInt();
		in_2.readInt();
		in_3.readInt();
		out.writeInt(1);
	}
}
