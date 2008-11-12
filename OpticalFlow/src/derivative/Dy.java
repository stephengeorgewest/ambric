package derivative;

import ajava.io.OutputStream;
import ajava.io.InputStream;

public class Dy
{
	int width;
	int height;
	public Dy  (int width, int height)
	{
		this.width = width;
		this.height = height;
	}
	public void run(InputStream<Integer> in, InputStream<Integer> bottom_8_fifo_out, InputStream<Integer> top_8_fifo_out, InputStream<Integer> top_1_fifo_out,
									OutputStream<Integer> bottom_8_fifo_in, OutputStream<Integer> top_8_fifo_in, OutputStream<Integer> top_1_fifo_in, OutputStream<Integer> out)
	{
		int w=this.width;
		int h_2=this.height-2;
		//
		//start filling up the fifos
		
		for(int i=0; i<w; i++)
			top_1_fifo_in.writeInt(in.readInt());
	
		for(int i=0,w_2=w*2; i<w_2; i++)//both middle and top
			top_8_fifo_in.writeInt(in.readInt());
		
		for(int i=0; i<w; i++)
			bottom_8_fifo_in.writeInt(in.readInt());
		
		//should be able to start now
		
		for(int j=0; j<w; j++)//necessary so the fifos flush only after a full frame
			for(int i=2; i<h_2;i++)//top 2 and bottom 2 pixels not outputed
			{
				int p0 = top_1_fifo_out.readInt();
					//p0 dropped
				int p1 = top_8_fifo_out.readInt();
					top_1_fifo_in.writeInt(p1);//pass through to above
				int p3 = bottom_8_fifo_out.readInt();
					top_8_fifo_in.writeInt(p3);//pass through to above
				int p4 = in.readInt();
					bottom_8_fifo_in.writeInt(p4);
				int output=(-p0+(p1*8)-(p3*8)+p4);
				//-p0+8*p1-8*p3+p4
				out.writeInt(output);
			}
		for(int i=0; i<w; i++)//flush the fifos for new image
		{
			top_1_fifo_out.readInt();
			top_8_fifo_out.readInt();
			top_8_fifo_out.readInt();
			bottom_8_fifo_out.readInt();
		}
	}
}
