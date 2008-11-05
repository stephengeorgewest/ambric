package timers;
import ajava.io.OutputStream;
import ajava.io.InputStream;
//import ajava.io.RawOutputStream;
import ajava.io.TimerStream;


public class Timer_Start
{
	public void run(InputStream<Integer> in,
			OutputStream<Integer> out)
	{
		out.writeInt(in.readInt());
		TimerStream.start(0);
		while(true)
			out.writeInt(in.readInt());
	}
	
}