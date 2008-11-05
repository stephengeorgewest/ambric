package imageProcess;

import ajava.io.InputStream;
import ajava.io.OutputStream;

public class BmpGrabberFifoStream
{
	/*int[] dataArray_top    =  new int[6];
	int[] dataArray_middle =  new int[6];*/
	int[] dataArray_bottom =  new int[6];
	int[] P = new int[9];
	int width_global;
	int height_global;
	public BmpGrabberFifoStream(int width, int height)
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
		int width= width_global;
		int height=height_global;
		int data_in;
		
		for(int j=1;j<=width-3;j+=4)//copy pixels into fifos, duplicate the top row
		{
			data_in = in.readInt();
			int Pixel1 = (data_in>>24)&0xFF;
			FifoTop_in.writeInt(Pixel1);
			FifoMiddle_in.writeInt(Pixel1);
			
			int Pixel2 = (data_in>>16)&0xFF;
			FifoTop_in.writeInt(Pixel2);
			FifoMiddle_in.writeInt(Pixel2);
			
			int Pixel3 = (data_in>>8)&0xFF;
			FifoTop_in.writeInt(Pixel3);
			FifoMiddle_in.writeInt(Pixel3);
			
			int Pixel4 = (data_in)&0xFF;
			FifoTop_in.writeInt(Pixel4);
			FifoMiddle_in.writeInt(Pixel4);
		}
		for(int i=0;i<height-1;i++)
		{//left egde special case
			P[0] = P[1] = FifoTop_out.readInt();
			
			P[3] = P[4] = FifoMiddle_out.readInt();
			FifoTop_in.writeInt(P[4]);
			
			data_in = in.readInt();
			dataArray_bottom[0] = dataArray_bottom[1] = (data_in>>24)&0xFF;
			dataArray_bottom[2] = (data_in>>16)&0xFF;
			dataArray_bottom[3] = (data_in>>8)&0xFF;
			dataArray_bottom[4] = (data_in)&0xFF;
			
			P[6] = P[7] = dataArray_bottom[0];
			FifoMiddle_in.writeInt(P[7]);
			
			writePixels(P,5,
					FifoTop_out, FifoTop_in,
					FifoMiddle_out, FifoMiddle_in,
					out);
			//middle
			for(int j=1;j<(width-3);j+=4)
			{
				data_in = in.readInt();
				dataArray_bottom[2] = (data_in>>24)&0xFF;
				dataArray_bottom[3] = (data_in>>16)&0xFF;
				dataArray_bottom[4] = (data_in>>8)&0xFF;
				dataArray_bottom[5] = (data_in)&0xFF;
				
				writePixels(P,6,
						FifoTop_out, FifoTop_in,
						FifoMiddle_out, FifoMiddle_in,
						out);
			}
			//right edge special case
			out.writeInt(P[0]);//upper left
			out.writeInt(P[1]);//upper middle
			out.writeInt(P[1]);//upper right
			
			out.writeInt(P[3]);//left
			out.writeInt(P[4]);//right
			
			out.writeInt(P[6]);//lower left
			out.writeInt(P[7]);//lower
			out.writeInt(P[7]);//lower Right
		}
		//special case bottom
		P[0] = P[1] = FifoTop_out.readInt();
		P[3] = P[4] = FifoMiddle_out.readInt();;
		P[6] = P[7] = P[4];
		
		for(int k=2;k<5;k++)//left
		{
			P[2] = FifoTop_out.readInt();//topvalues dissapear
			P[5] = FifoMiddle_out.readInt();//middle becomes top
			P[8] = P[5];//bottom becomes middle
			
			out.writeInt(P[0]);//upper left
			out.writeInt(P[1]);//upper middle
			out.writeInt(P[2]);//upper right
			
			out.writeInt(P[3]);//left
			out.writeInt(P[5]);//right
			
			out.writeInt(P[6]);//lower left
			out.writeInt(P[7]);//lower
			out.writeInt(P[8]);//lower Right
			P[0] = P[1];
			P[1] = P[2];
			
			P[3] = P[4];
			P[4] = P[5];
			
			P[6] = P[7];
			P[7] = P[8];
		}
		dataArray_bottom[0] = dataArray_bottom[3];
		dataArray_bottom[1] = dataArray_bottom[4];
		//middle
		for(int j=1;j<width-3;j+=4)
		{
			
			for(int k=2;k<6;k++)//this is for each new P3,P6,P9 // j+=4
			{
				P[2] = FifoTop_out.readInt();
				P[5] = FifoMiddle_out.readInt();
				P[8] = P[5];
				
				out.writeInt(P[0]);//upper left
				out.writeInt(P[1]);//upper middle
				out.writeInt(P[2]);//upper right
				
				out.writeInt(P[3]);//left
				out.writeInt(P[5]);//right
				
				out.writeInt(P[6]);//lower left
				out.writeInt(P[7]);//lower
				out.writeInt(P[8]);//lower Right
				P[0] = P[1];
				P[1] = P[2];
				
				P[3] = P[4];
				P[4] = P[5];
				
				P[6] = P[7];
				P[7] = P[8];
			}
		}
		//right
		out.writeInt(P[0]);//upper left
		out.writeInt(P[1]);//upper middle
		out.writeInt(P[1]);//upper right
		
		out.writeInt(P[3]);//left
		out.writeInt(P[4]);//right
		
		out.writeInt(P[6]);//lower left
		out.writeInt(P[7]);//lower
		out.writeInt(P[7]);//lower Right
		
	}
	public void writePixels(int[]P,int max,
			InputStream<Integer> FifoTop_out, OutputStream<Integer> FifoTop_in,
			InputStream<Integer> FifoMiddle_out, OutputStream<Integer> FifoMiddle_in,
			OutputStream<Integer> out)
	{
		for(int k=2;k<max;k++)//this is for each new P3,P6,P9 // j+=4
		{
			P[2] = FifoTop_out.readInt();//topvalues dissapear
			
			P[5] = FifoMiddle_out.readInt();//middle becomes top
			FifoTop_in.writeInt(P[5]);
			
			P[8] = dataArray_bottom[k];//bottom becomes middle
			FifoMiddle_in.writeInt(P[8]);
			
			out.writeInt(P[0]);//upper left
			out.writeInt(P[1]);//upper middle
			out.writeInt(P[2]);//upper right
			
			out.writeInt(P[3]);//left
			out.writeInt(P[5]);//right
			
			out.writeInt(P[6]);//lower left
			out.writeInt(P[7]);//lower
			out.writeInt(P[8]);//lower Right
			P[0] = P[1];
			P[1] = P[2];
			
			P[3] = P[4];
			P[4] = P[5];
			
			P[6] = P[7];
			P[7] = P[8];
		}
		dataArray_bottom[0] = dataArray_bottom[4];
		dataArray_bottom[1] = dataArray_bottom[5];
	}
}
