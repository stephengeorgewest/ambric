package source;

import ajava.io.InputStream;
import ajava.io.OutputStream;
public class Unpack {
	public void run(InputStream<Integer> in, OutputStream<Integer> out)
	{
		int data = in.readInt();
		System.out.println("unpack"+Integer.toHexString(data));
		out.writeInt((data>>24)&0xFF);
		out.writeInt((data>>16)&0xFF);
		out.writeInt((data>>8)&0xFF);
		out.writeInt(data&0xFF);
	}
}