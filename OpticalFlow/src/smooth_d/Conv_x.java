package smooth_d;

import ajava.io.InputStream;
import ajava.io.OutputStream;

public class Conv_x
{
	int width;//should be img_width-4 if dropped pixels
	public Conv_x(int width)
	{
		this.width=width;
	}
	public void run(InputStream<Integer> in, OutputStream<Integer>out)
	{
		int w=this.width;
		int p0;//3 populated in loop //drops 4 edge pixels
		int p1 = in.readInt();//3
		int p2 = in.readInt();//4
		int p3 = in.readInt();//3
		int p4 = in.readInt();//3
		for(int i=2,w_2=w-2; i<w_2; i++)
		{
			p0=p1;
			p1=p2;
			p2=p3;
			p3=p4;
			p4=in.readInt();
			//[3 3 4 3 3]
			out.writeInt(3*p0+3*p1+4*p2+3*p3+3*p4);
		}
	}
}
