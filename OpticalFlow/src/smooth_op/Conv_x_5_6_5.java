package smooth_op;

import ajava.io.InputStream;
import ajava.io.OutputStream;

public class Conv_x_5_6_5
{
	int width;//should be start_img_width-8 by now
	//drops 2 edge pixels
	public Conv_x_5_6_5(int width)
	{
		this.width=width;
	}
	public void run(InputStream<Integer> in, OutputStream<Integer>out)
	{
		int w_1=this.width-1;
		int p0;//5 populated in loop 
		int p1 = in.readInt();//6
		int p2 = in.readInt();//5
		for(int i=1; i<w_1; i++)
		{
			p0=p1;
			p1=p2;
			p2=in.readInt();
			//[5 6 5]
			out.writeInt((5*p0+6*p1+5*p2));
		}
	}
}
