package utility;

import ajava.io.OutputStream;
public class Source_range {
	int start;
	int stop;
	public Source_range(int start, int stop)
	{
		this.start=start;
		this.stop=stop;
	}
	public void run(OutputStream<Integer> out)
	{
		int start_local=this.start;
		int stop_local=this.stop;
		for(int i=start_local;i<stop_local;i++)
					out.writeInt(i);
	}
}
