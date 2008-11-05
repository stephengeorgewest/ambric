package lotsOfMath;

import ajava.io.InputStream;
import ajava.io.OutputStream;

public class RunningSum
{
	public void run(InputStream<Integer> in, OutputStream<Integer> out)
	{
		int sum=0;
		for(int i=0;i<9; i++)
		{
			sum+=in.readInt();
			out.writeInt(sum);
		}
	}
}
