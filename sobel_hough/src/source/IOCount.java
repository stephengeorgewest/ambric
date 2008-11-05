package source;
import ajava.io.OutputStream;
import ajava.io.InputStream;

public class IOCount
{
	int count=0;
	public void run(InputStream<Integer> in,
			OutputStream<Integer> out)
	{
		
		int data=in.readInt();
		out.writeInt(data);
		//System.out.print("\tio#="+count+" v"+Integer.toHexString(data));
		count++;
	}
	
}
