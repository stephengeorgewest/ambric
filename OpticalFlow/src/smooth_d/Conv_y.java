package smooth_d;

import ajava.io.InputStream;
import ajava.io.OutputStream;

public class Conv_y
{

	int width;
	int height;
	public Conv_y(int width, int height)
	{
		this.width = width;//should be img width-8
		this.height = height;//should be img height-4
	}
	public void run(InputStream<Integer> in,
										OutputStream<Integer> fifo_3_in,
						InputStream<Integer> fifo_3_out,
										OutputStream<Integer> fifo_2_in,
						InputStream<Integer> fifo_2_out,
										OutputStream<Integer> fifo_1_in,
						InputStream<Integer> fifo_1_out,
										OutputStream<Integer> fifo_0_in,
						InputStream<Integer> fifo_0_out,
											OutputStream<Integer> out)
	{
		int w=this.width;
		int h=this.height;
		
		//start filling up the fifos
		
		for(int i=0; i<w; i++)//topTop row -3
			fifo_0_in.writeInt(in.readInt());
		for(int i=0; i<w; i++)//topMiddle -3
			fifo_1_in.writeInt(in.readInt());
		for(int i=0; i<w; i++)//middle -4
			fifo_2_in.writeInt(in.readInt());
		for(int i=0; i<w; i++)//bottomMiddle -3
			fifo_3_in.writeInt(in.readInt());
		
		//should be able to start now
		
		for(int i=2,h_2=h-2; i<h_2;i++)//necessary so the fifos flush only after a full frame
			for(int j=0; j<w; j++)
			{
				int p0 = fifo_0_out.readInt();
					//p0 dropped
				int p1 = fifo_1_out.readInt();
					fifo_0_in.writeInt(p1);//pass through to above
				int p2= fifo_2_out.readInt();
					fifo_1_in.writeInt(p2);//pass through to above
				int p3 = fifo_3_out.readInt();
					fifo_2_in.writeInt(p3);//pass through to above
				int p4 = in.readInt();
					fifo_3_in.writeInt(p4);//pass through to above
				
				//[3 3 4 3 3]=3*p0+3*p1+4*p2+3*p3+3*p4
				out.writeInt( (3*p0+3*p1+4*p2+3*p3+3*p4));// will overflow later
			}
		//outerLoop ends as well
		for(int i=0; i<w; i++)//flush the fifos for new image
		{
			fifo_0_out.readInt();
			fifo_1_out.readInt();
			fifo_2_out.readInt();
			fifo_3_out.readInt();
		}
	}
}
