package velocity;

import ajava.io.InputStream;
import ajava.io.OutputStream;

public class Saturate
{
	public void run(InputStream<Integer> in, OutputStream<Integer> out)
	{
		int val = in.readInt();
		if(val<-8)
			val=(-8);
		if(val>7)
			val=7;
		
		out.writeInt(val);
	}
}
