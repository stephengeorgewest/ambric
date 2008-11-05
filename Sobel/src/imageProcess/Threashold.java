package imageProcess;

import ajava.io.InputStream;
import ajava.io.OutputStream;


public class Threashold
{
	int threasholdValue = 0xAA;
	public void run(InputStream<Integer> in, OutputStream<Integer> out)
	{
		int pixel = in.readInt();
		//out.writeInt(pixel);
		
		if(pixel>threasholdValue)
			out.writeInt(0xFF);
		else
			out.writeInt(0);
	}
}