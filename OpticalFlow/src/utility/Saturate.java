package utility;

import ajava.io.InputStream;
import ajava.io.OutputStream;

public class Saturate
{
	int max;
	int min;
	public Saturate(int max, int min)
	{
		this.max = max;
		this.min = min;
	}
	public void run(InputStream<Integer> in, OutputStream<Integer> out)
	{
		int max_ = this.max;
		int min_ = this.min;
		while(true)
		{
			int value = in.readInt();
			if( value > max_)
				value = max_;
			if( value < min_)
				value = min_;
			out.writeInt(value);
		}
	}
}
