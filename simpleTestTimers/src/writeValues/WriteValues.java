package writeValues;
import ajava.io.OutputStream;
public class WriteValues
{
	public WriteValues()
	{
		
	}
	public void run(OutputStream<Integer>out)
	{
		for(int stop=0;stop<20;stop++)
			for(int i=0;i<9;i++)
				out.writeInt(i);

		//while(true);
	}
}
