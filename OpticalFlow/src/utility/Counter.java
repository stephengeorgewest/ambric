package utility;

import ajava.io.InputStream;
import ajava.io.OutputStream;

public class Counter
{
	int stop=0;
	int count=0;
	public Counter(int stop)
	{
		this.stop=stop;
	}
	public void run(InputStream<Integer> in, OutputStream<Integer> out)
	{
		this.count++;
		in.readInt();
		if(this.count==this.stop)
		{
			out.writeInt(this.count);
			this.count=0;
		}
	}
}
