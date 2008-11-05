package imageProcess;

import ajava.io.InputStream;
import ajava.io.OutputStream;

public class BmpSaver {
	public void run(InputStream<Integer> in, OutputStream<Integer> out)
	{
		//write header
		//write pixeldata
		int pixel1 = in.readInt();
		int pixel2 = in.readInt();
		int pixel3 = in.readInt();
		int pixel4 = in.readInt();
		int data = (pixel1<<24)|(pixel2<<16)|(pixel3<<8)|(pixel4&0xFF);
		out.writeInt(data);
	}
}
