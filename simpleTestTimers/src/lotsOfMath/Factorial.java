package lotsOfMath;

import ajava.io.InputStream;
import ajava.io.OutputStream;
/*
0 	1
1 	1
2 	2
3 	6
4 	24
5 	120
6 	720
7 	5,040
8 	40,320
*/
public class Factorial
{
	public void run(InputStream<Integer> in,
					OutputStream<Integer>out)
	{
		while(true)
		{
			int count=in.readInt();
			int tmp=1;
			for(int i=1;i<=count;i++)
				tmp*=i;
			out.writeInt(tmp);
		}
	}
}
