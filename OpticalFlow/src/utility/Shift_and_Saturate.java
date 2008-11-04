package utility;

import ajava.io.InputStream;
import ajava.io.OutputStream;

public class Shift_and_Saturate
{
	int shift_by;
	int max;
	int min;
	public Shift_and_Saturate(int shift_by, int max, int min)
	{
		this.max = max;
		this.min = min;
		this.shift_by = shift_by;
	}
	public void run(InputStream<Integer> in, OutputStream<Integer> out)
	{
		int max_ = this.max;
		int min_ = this.min;
		int shift_by_ = this.shift_by;
		while(true)
		{
			int value = in.readInt();
			value = value >> shift_by_;
			if( value > max_)
				value = max_;
			if( value < min_)
				value = min_;
			out.writeInt(value);
		}
	}
}
