package velocity;

import ajava.io.InputStream;
import ajava.io.OutputStream;
//import java.math.*;

public class Add
{

	public void run(
			InputStream<Integer> in_1,
			InputStream<Integer> in_2,
			OutputStream<Integer> out
			)
	{
		int val1 = in_1.readInt();//[a+2n+3,m]
		int val2 = in_2.readInt();//[a+2n+4,m]
		int tmp = val1+val2;//[a+2n+5,m]

		out.writeInt(tmp);
	}
}
