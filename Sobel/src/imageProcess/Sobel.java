package imageProcess;

import ajava.io.InputStream;
import ajava.io.OutputStream;

public class Sobel
{
	public void run(
			InputStream<Integer> in,//cannot use 8 input channels
			/*InputStream<Integer> P1,
			InputStream<Integer> P2,
			InputStream<Integer> P3,
			InputStream<Integer> P4,
			InputStream<Integer> P6,
			InputStream<Integer> P7,
			InputStream<Integer> P8,
			InputStream<Integer> P9,*/
			OutputStream<Integer> out)
	{
		int P1=in.readInt();
		int P2=in.readInt();
		int P3=in.readInt();
		int P4=in.readInt();
		int P6=in.readInt();
		int P7=in.readInt();
		int P8=in.readInt();
		int P9=in.readInt();
		int max=255;
		int Px = (P1+P2>>1+P3)-(P7+P8>>1+P9);
		if(Px<0)
			Px = -Px;
		int Py = (P3+P6>>1+P9)-(P1+P4>>1+P7);
		if(Py<0)
			Py = -Py;
		int output = Px+Py;
		if(output>max)
			output = max;
		out.writeInt(output);
	}
}
