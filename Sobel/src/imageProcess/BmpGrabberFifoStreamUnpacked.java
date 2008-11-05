package imageProcess;

import ajava.io.InputStream;
import ajava.io.OutputStream;

public class BmpGrabberFifoStreamUnpacked
{
	
	/*int[] dataArray_top    =  new int[6];
	int[] dataArray_middle =  new int[6];
	int[] dataArray_bottom =  new int[6];*/
	int width_global;
	int height_global;
	public BmpGrabberFifoStreamUnpacked(int width, int height)
	{
		this.width_global=width;
		this.height_global=height;
	}
	public void run(InputStream<Integer> in,
			InputStream<Integer> FifoMiddle_out, OutputStream<Integer> FifoMiddle_in,
			InputStream<Integer> FifoTop_out, OutputStream<Integer> FifoTop_in,
			OutputStream<Integer> out 
			)
	{
		int width = width_global;
		int height = height_global;
		int data_in;
		
		for(int j=0;j<width;j++)//copy pixels into fifos, duplicate the top row
		{
			data_in = in.readInt();
			FifoTop_in.writeInt(data_in);
			FifoMiddle_in.writeInt(data_in);
		}
		for(int i=0;i<height-1;i++)
		{//left egde special case
			int P1,P2,P3,P4,P5,P6,P7,P8,P9;
			P1 = P2 = FifoTop_out.readInt();
			
			P4 = P5 = FifoMiddle_out.readInt();
			FifoTop_in.writeInt(P5);
			
			P7 = P8 = in.readInt();
			FifoMiddle_in.writeInt(P8);
			
			for(int j=0;j<width-1;j++)
			{
				P3 = FifoTop_out.readInt();//topvalues dissapear
				
				P6 = FifoMiddle_out.readInt();//middle becomes top
				FifoTop_in.writeInt(P6);
				
				P9 = in.readInt();//bottom becomes middle
				FifoMiddle_in.writeInt(P9);
				
				out.writeInt(P1);//upper left
				out.writeInt(P2);//upper middle
				out.writeInt(P3);//upper right
				
				out.writeInt(P4);//left
				out.writeInt(P6);//right
				
				out.writeInt(P7);//lower left
				out.writeInt(P8);//lower
				out.writeInt(P9);//lower Right
				P1 = P2;
				P2 = P3;
				
				P4 = P5;
				P5 = P6;
				
				P7 = P8;
				P8 = P9;
			}
			//right edge special case
			out.writeInt(P1);//upper left
			out.writeInt(P2);//upper middle
			out.writeInt(P2);//upper right
			
			out.writeInt(P4);//left
			out.writeInt(P5);//right
			
			out.writeInt(P7);//lower left
			out.writeInt(P8);//lower
			out.writeInt(P8);//lower Right
		}
		//special case bottom
		int P1,P2,P3,P4,P5,P6,P7,P8,P9;
		P1 = P2 = FifoTop_out.readInt();
		P4 = P5 = FifoMiddle_out.readInt();;
		P7 = P8 = P5;
		
		for(int k=0;k<width-1;k++)//left
		{
			P3 = FifoTop_out.readInt();//topvalues dissapear
			P6 = FifoMiddle_out.readInt();//middle becomes top
			P9 = P6;//bottom becomes middle
			
			out.writeInt(P1);//upper left
			out.writeInt(P2);//upper middle
			out.writeInt(P3);//upper right
			
			out.writeInt(P4);//left
			out.writeInt(P6);//right
			
			out.writeInt(P7);//lower left
			out.writeInt(P8);//lower
			out.writeInt(P9);//lower Right
			P1 = P2;
			P2 = P3;
			
			P4 = P5;
			P5 = P6;
			
			P7 = P8;
			P8 = P9;
		}
		//right
		out.writeInt(P1);//upper left
		out.writeInt(P2);//upper middle
		out.writeInt(P2);//upper right
		
		out.writeInt(P4);//left
		out.writeInt(P5);//right
		
		out.writeInt(P7);//lower left
		out.writeInt(P8);//lower
		out.writeInt(P8);//lower Right
		
	}
}
