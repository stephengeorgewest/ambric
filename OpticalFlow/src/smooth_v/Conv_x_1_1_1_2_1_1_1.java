package smooth_v;

import ajava.io.InputStream;
import ajava.io.OutputStream;

public class Conv_x_1_1_1_2_1_1_1
{
	int width;
	public Conv_x_1_1_1_2_1_1_1(int width)
	{
		this.width=width;//loose 6 edge pixels
	}
	public void run(InputStream<Integer> in, OutputStream<Integer> out)
	{
		int w_3=width-3;
		while(true)
		{
			int p0;//--1 will get passed in// = in.readInt();
			int p1 = in.readInt();//--1
			int p2 = in.readInt();//--1
			int p3 = in.readInt();//--2
			int p4 = in.readInt();//--1
			int p5 = in.readInt();//--1
			int p6 = in.readInt();//--1
			for(int i=3; i<w_3; i++)//loose first 2 and last 2 pixels in this
			{//could do a running sum as well but i don't think this is the bottleneck
				p0=p1;
				p1=p2;
				p2=p3;
				p3=p4;
				p4=p5;
				p5=p6;
				p6=in.readInt();
				//[1 1 1 2 1 1 1]
				int val =p0+p1+p2+(p3*2)+p4+p5+p6;
				out.writeInt(val);
			}//done with row start over
		}
	}
}
