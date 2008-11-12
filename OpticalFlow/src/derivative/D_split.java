package derivative;

import ajava.io.InputStream;
import ajava.io.OutputStream;

public class D_split
{
	int width;
	int height;
	public D_split(int width, int height)
	{
		this.width = width;
		this.height = height;
	}
	public void run(InputStream<Integer> in, OutputStream<Integer> dx, OutputStream<Integer> dy, OutputStream<Integer> dt)
	{
		//first 2 frames only dt
		int w=this.width;
		int h=this.height;
		for(int i=0;i<2;i++)//2 frames
		{
			for(int j=0,two_rows=w*2;j<two_rows;j++)
				in.readInt();//first two rows tossed out
			for(int k=0, middle_rows=h-4;k<middle_rows;k++)
			{
				
				in.readInt();in.readInt();//first two pixels gone
				for(int l=0, mid_col=w-4;l<mid_col;l++)
					dt.writeInt(in.readInt());//first two frames to dt only
				in.readInt();in.readInt();//last two pixels gone
			}
			for(int j=0,two_rows=w*2;j<two_rows;j++)
				in.readInt();//last two rows tossed out
		}
		//the rest of the frames
		while(true)
		{
			//first two rows
			in.readInt();in.readInt();
			for(int j=0,w_4=w-4;j<w_4;j++)
				dy.writeInt(in.readInt());//first two rows to dy only
			in.readInt();in.readInt();
			
			in.readInt();in.readInt();
			for(int j=0,w_4=w-4;j<w_4;j++)
				dy.writeInt(in.readInt());//first two to dy only
			in.readInt();in.readInt();
			
			for(int k=0, middle_rows=h-4;k<middle_rows;k++)
			{
				dx.writeInt(in.readInt());dx.writeInt(in.readInt());//first two pixels to dx only
				for(int l=0, mid_col=w-4;l<mid_col;l++)
				{//middle pixels go to all
					int pixel=in.readInt();
					dx.writeInt(pixel);
					dy.writeInt(pixel);
					dt.writeInt(pixel);
				}
				dx.writeInt(in.readInt());dx.writeInt(in.readInt());//last two pixels to dx only
			}
			
			//last two rows
			in.readInt();in.readInt();
			for(int j=0,w_4=w-4;j<w_4;j++)
				dy.writeInt(in.readInt());//last two rows to dy only
			in.readInt();in.readInt();
			
			in.readInt();in.readInt();
			for(int j=0,w_4=w-4;j<w_4;j++)
				dy.writeInt(in.readInt());//last two to dy only
			in.readInt();in.readInt();
		}
	}
}
