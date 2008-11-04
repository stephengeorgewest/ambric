package smooth_v;

import ajava.io.OutputStream;
import ajava.io.InputStream;

public class Conv_y_1_1_1_2_1_1_1
{
	int width;
	int height;
	public Conv_y_1_1_1_2_1_1_1  (int width, int height)
	{
		this.width = width;//should be 6 less than height
		this.height = height;
	}
	public void run(InputStream<Integer> in, InputStream<Integer> bottom_3_fifos_out, InputStream<Integer> top_3_fifos_out,
									OutputStream<Integer> bottom_3_fifos_in, OutputStream<Integer> out)
	{
		int w=this.width;
		int h_3=this.height-3;
		
		//start filling up the fifos
		//upper 3
		for(int i=0,w_3=w*6; i<w_3; i++)
			bottom_3_fifos_in.writeInt(in.readInt());
		
		//should be able to start now
		
		for(int j=3; j<h_3; j++)//necessary so the fifos flush only after a full frame
		{
			for(int i=0; i<w;i++)
			{
				int p0 = top_3_fifos_out.readInt();
				int p1 = top_3_fifos_out.readInt();
				int p2 = top_3_fifos_out.readInt();
				int p3 = bottom_3_fifos_out.readInt();
				int p4 = bottom_3_fifos_out.readInt();
				int p5 = bottom_3_fifos_out.readInt();
				int p6 = in.readInt();

				bottom_3_fifos_in.writeInt(p6);//newest pixel
				
				//[1 1 1 2 1 1 1]
				out.writeInt(p0+p1+p2+(p3*2)+p4+p5+p6);
			}
			//while(true){}//do only one row
		}
		//fifos flushed in fifo group
		//while(true){}//do only one frame
	}
}
