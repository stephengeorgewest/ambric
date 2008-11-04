package derivitive;

import ajava.io.InputStream;
import ajava.io.OutputStream;

public class Dx
{
	int width;//width of convolution should be 4 less than image width
	public Dx(int width)
	{
		this.width = width;
	}
	public void run(InputStream<Integer> in, OutputStream<Integer> out)
	{
		int w_2=this.width-2;
		while(true)
		{
			int p0=0;//will get passed in// = in.readInt(); // come in in order
			int p1 = in.readInt();
			int p2 = in.readInt();
			int p3 = in.readInt();
			int p4 = in.readInt();
			for(int i=2; i<w_2; i++)//loose first 2 and last 2 pixels in this
			{
				p0=p1;
				p1=p2;
				p2=p3;
				p3=p4;
				p4=in.readInt();
				//[-1 8 0 -8 1]-p0+8*p1-8*p3+p4
				int output=(-p0+(p1*8)-(p3*8)+p4);
				out.writeInt(output);
			}//done with row start over
		}
	}
}
