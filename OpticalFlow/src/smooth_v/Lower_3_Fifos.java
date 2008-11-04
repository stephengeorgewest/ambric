package smooth_v;

import ajava.io.InputStream;
import ajava.io.OutputStream;

public class Lower_3_Fifos
{
	int width;
	int height;
	
	public Lower_3_Fifos(int width, int height)
	{
		this.width=width;
		this.height=height;
	}
	public void run(InputStream<Integer> in,
							OutputStream<Integer> Top_in, 
					InputStream<Integer>Top_out,
							OutputStream<Integer> Middle_in,
					InputStream<Integer>Middle_out,
							OutputStream<Integer>Bottom_in,
					InputStream<Integer>Bottom_out,
							OutputStream<Integer> out,
							OutputStream<Integer> top_3_fifos_in)
	{
		int w=width;
		int h_3=height-3;
		for(int i=0,w_3=w*3; i<w_3; i++)//fill up the upper fifos
		{
			top_3_fifos_in.writeInt(in.readInt());
		}
		//fill up the local fifos
		for(int i=0; i<w; i++)
		{
			Top_in.writeInt(in.readInt());
		}
		for(int i=0; i<w; i++)
		{
			Middle_in.writeInt(in.readInt());
		}
		for(int i=0; i<w; i++)
		{
			Bottom_in.writeInt(in.readInt());
		}
		
		//do stuff
		for(int i=3;i<h_3;i++)
		{
			for(int j=0; j<w; j++)
			{
				int tmp1=Top_out.readInt();
				int tmp2=Middle_out.readInt();
				int tmp3=Bottom_out.readInt();
				
				out.writeInt(tmp1);
				out.writeInt(tmp2);
				out.writeInt(tmp3);
				
				top_3_fifos_in.writeInt(tmp1);
				Top_in.writeInt(tmp2);
				Middle_in.writeInt(tmp3);
				Bottom_in.writeInt(in.readInt());
			}
		}
		
		//flush the buffer for new frame
		for(int i=0; i<w; i++)
		{
			Top_out.readInt();
			Middle_out.readInt();
			Bottom_out.readInt();
		}
	}
}
