package timers;
import ajava.io.OutputStream;
import ajava.io.InputStream;
//import ajava.io.RawOutputStream;
import ajava.io.TimerStream;


public class Timer_Stop
{
	public void run(InputStream<Integer> in,
			OutputStream<Integer> out)
	{
		out.writeInt(in.readInt());
		TimerStream.stop(0);
		while(true)
			out.writeInt(in.readInt());
	}
	
}