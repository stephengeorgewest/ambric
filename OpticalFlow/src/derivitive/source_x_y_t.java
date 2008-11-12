package derivitive;

import ajava.io.OutputStream;

public class source_x_y_t
{
	int width;
	int height;
	public source_x_y_t(int width, int height)
	{
		this.width=width;
		this.height=height;
	}
	public void run(OutputStream<Integer> out)
	{
		int w=this.width;
		int h=this.height;
		for(int t=0;t<8;t++)
			for(int y=0;y<h; y++)
				for(int x=0; x<w;x++)
					out.writeInt(x<<20|y<<8|t);
		//while(true){}
	}
}
