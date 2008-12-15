package utility;

import ajava.io.InputStream;
import ajava.io.OutputStream;

public class Shift
{
	int val;
	public Shift(int shift_by)
	{
		this.val = shift_by;
	}
	public void run(InputStream<Integer> in, OutputStream<Integer> out)
	{
		int value = this.val-1;
		if(value<0)
		{
			while(true)
			out.writeInt(in.readInt());
		}
		else if(value==0)//shift by one
		{
			while(true)
			{
				int num = in.readInt();
				int sign = 1;
				if(num<0)
				{
					num=(-num);
					sign = -1;
				}
				num = num +1;
				num = num>>1;
				out.writeInt(num*sign);
			}
		}
		else
		{
			while(true)
			{
				int num = in.readInt();
				int sign = 1;
				if(num<0)
				{
					num=(-num);
					sign = -1;
				}
	
				num = num>>(value);
				num = num +1;
				num = num>>1;
				out.writeInt(num*sign);
			}
		}
	}
}
