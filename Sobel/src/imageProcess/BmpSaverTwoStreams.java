package imageProcess;

import ajava.io.InputStream;
import ajava.io.OutputStream;

public class BmpSaverTwoStreams {
	public void run(InputStream<Integer> in_1, InputStream<Integer> in_2, OutputStream<Integer> out)
	{
		//write header
		//write pixeldata
		int pixel1 = in_1.readInt();
		int pixel2 = in_2.readInt();
		int pixel3 = in_1.readInt();
		int pixel4 = in_2.readInt();
		int data = (pixel1<<24)|(pixel2<<16)|(pixel3<<8)|(pixel4&0xFF);
		out.writeInt(data);
		int pixel5 = in_1.readInt();
		int pixel6 = in_2.readInt();
		int pixel7 = in_1.readInt();
		int pixel8 = in_2.readInt();
		int data2 = (pixel5<<24)|(pixel6<<16)|(pixel7<<8)|(pixel8&0xFF);
		out.writeInt(data2);
	}
}
