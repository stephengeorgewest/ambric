package smooth_op;

import ajava.io.InputStream;
import ajava.io.OutputStream;

public class Conv_y_5_6_5
{

	int width;
	int height;
	public Conv_y_5_6_5(int width, int height)
	{
		this.width = width;//should be img width-10
		this.height = height;//should be img height-8
		//drops edge(top/bottom) 2 pixels
	}
	public void run(InputStream<Integer> in,
										OutputStream<Integer> fifo_1_in,
						InputStream<Integer> fifo_1_out,
										OutputStream<Integer> fifo_0_in,
						InputStream<Integer> fifo_0_out,
											OutputStream<Integer> out)
	{
		int w=this.width;
		int h=this.height;
		
		//start filling up the fifos
		
		for(int i=0; i<w; i++)//topTop row --5
			fifo_0_in.writeInt(in.readInt());
		for(int i=0; i<w; i++)//topMiddle --6
			fifo_1_in.writeInt(in.readInt());
		
		//should be able to start now
		
		for(int j=0; j<w; j++)//necessary so the fifos flush only after a full frame
			for(int i=1,h_1=h-1; i<h_1;i++)
			{
				int p0 = fifo_0_out.readInt();
					//p0 dropped
				int p1 = fifo_1_out.readInt();
					fifo_0_in.writeInt(p1);//pass through to above
				int p2= in.readInt();
					fifo_1_in.writeInt(p2);//pass through to above
				
				//[5 6 5]
				out.writeInt((5*p0+6*p1+5*p2));
			}
		for(int i=0; i<w; i++)//flush the fifos for new image
		{
			fifo_0_out.readInt();
			fifo_1_out.readInt();
		}
	}
}
