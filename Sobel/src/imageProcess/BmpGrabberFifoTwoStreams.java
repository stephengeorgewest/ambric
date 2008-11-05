package imageProcess;

import ajava.io.InputStream;
import ajava.io.OutputStream;

public class BmpGrabberFifoTwoStreams
{
	int width = 16;
	int height =16;
	/*int[] dataArray_top    =  new int[6];
	int[] dataArray_middle =  new int[6];*/
	int[] dataArray_bottom =  new int[6];
	int streamSelect = 1;
	int[] P = new int[9];
	public void run(InputStream<Integer> in,
			InputStream<Integer> FifoMiddle_out, OutputStream<Integer> FifoMiddle_in,
			InputStream<Integer> FifoTop_out, OutputStream<Integer> FifoTop_in,
			OutputStream<Integer> out_1, OutputStream<Integer> out_2
			)
	{
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
			
			P[0] = P[1] = P[2] = FifoTop_out.readInt();
			
			P[3] = P[4] = P[5] = FifoMiddle_out.readInt();
			FifoTop_in.writeInt(P[5]);
			
				data_in = in.readInt();
				dataArray_bottom[0] = dataArray_bottom[1] = (data_in>>24)&0xFF;
				dataArray_bottom[2] = (data_in>>16)&0xFF;
				dataArray_bottom[3] = (data_in>>8)&0xFF;
				dataArray_bottom[4] = (data_in)&0xFF;
				
				P[6] = P[7] = P[8] = dataArray_bottom[0];
				FifoMiddle_in.writeInt(P[8]);
				
				
				innerLoop(P, 5,
						FifoMiddle_out, FifoMiddle_in,
						FifoTop_out, FifoTop_in,
						out_1, out_2);
				dataArray_bottom[0] = dataArray_bottom[3];
				dataArray_bottom[1] = dataArray_bottom[4];
			//middle
			for(int j=1;j<(width-3);j+=4)
			{
				data_in = in.readInt();
				dataArray_bottom[2] = (data_in>>24)&0xFF;
				dataArray_bottom[3] = (data_in>>16)&0xFF;
				dataArray_bottom[4] = (data_in>>8)&0xFF;
				dataArray_bottom[5] = (data_in)&0xFF;
				
				innerLoop(P, 6,
						FifoMiddle_out, FifoMiddle_in,
						FifoTop_out, FifoTop_in,
						out_1, out_2);
				dataArray_bottom[0] = dataArray_bottom[4];
				dataArray_bottom[1] = dataArray_bottom[5];
			}
			//right edge special case
			
			writePixels(P,out_1,out_2);
		}
		//special case bottom

		P[0] = P[1] = P[2] = FifoTop_out.readInt();
		P[3] = P[4] = P[5] = FifoMiddle_out.readInt();
		FifoTop_in.writeInt(P[5]);
		
		P[6] = P[7] = P[7] = P[5];
		FifoMiddle_in.writeInt(P[5]);
		
		for(int k=2;k<5;k++)
		{
			P[2] = FifoTop_out.readInt();//topvalues dissapear
			P[5] = FifoMiddle_out.readInt();//middle becomes top
			P[8] = P[5];//bottom becomes middle
			
			writePixels(P,out_1,out_2);
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
				
				writePixels(P,out_1,out_2);
			}
		}
		//right edge special case


		writePixels(P,out_1,out_2);
	}
	
	public void innerLoop(int[] P, int max,
			InputStream<Integer> FifoMiddle_out, OutputStream<Integer> FifoMiddle_in,
			InputStream<Integer> FifoTop_out, OutputStream<Integer> FifoTop_in,
			OutputStream<Integer> out_1, OutputStream<Integer> out_2)
	{
		for(int k=2;k<max;k++)//this is for each new P3,P6,P9 // j+=4
		{
			P[2] = FifoTop_out.readInt();//topvalues dissapear
			P[5] = FifoMiddle_out.readInt();//middle becomes top
			FifoTop_in.writeInt(P[5]);
			
			P[8] = dataArray_bottom[k];//bottom becomes middle
			FifoMiddle_in.writeInt(P[8]);

			writePixels(P,out_1,out_2);
		}
	}
	
	public void writePixels(int[] P, OutputStream<Integer> out_1, OutputStream<Integer> out_2)
	{
		if(streamSelect==1)
		{
			out_1.writeInt(P[0]);//upper left
			out_1.writeInt(P[1]);//upper middle
			out_1.writeInt(P[2]);//upper right
			
			out_1.writeInt(P[3]);//left
			out_1.writeInt(P[5]);//right
			
			out_1.writeInt(P[6]);//lower left
			out_1.writeInt(P[7]);//lower
			out_1.writeInt(P[8]);//lower Right
			streamSelect=2;
		}
		else
		{
			out_2.writeInt(P[0]);//upper left
			out_2.writeInt(P[1]);//upper middle
			out_2.writeInt(P[2]);//upper right
			
			out_2.writeInt(P[3]);//left
			out_2.writeInt(P[5]);//right
			
			out_2.writeInt(P[6]);//lower left
			out_2.writeInt(P[7]);//lower
			out_2.writeInt(P[8]);//lower Right
			streamSelect=1;
		}
		
		P[0] = P[1];
		P[1] = P[2];
		
		P[3] = P[4];
		P[4] = P[5];
		
		P[6] = P[7];
		P[7] = P[8];
	}
	
}
