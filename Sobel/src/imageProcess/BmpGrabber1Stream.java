package imageProcess;

import ajava.io.InputStream;
import ajava.io.OutputStream;

public class BmpGrabber1Stream
{
	int width = 512;
	int height = 512;
	public void run(InputStream<Integer> in,
			OutputStream<Integer> out)/*,//cannot have 8 output channels
			OutputStream out_2,
			OutputStream out_3,
			OutputStream out_4,
			OutputStream out_6,
			OutputStream out_7,
			OutputStream out_8,
			OutputStream out_9)*/
	{
		int[][] dataArray = new int[width][3];
		int data_in =0;
		int pixel_out =0;
		
		
		/*
		 * top stuff
		 * 
		 * 
		 * 
		 * 
		 * corner
		 */
		//grab first pixel(s)
		for(int i =0;i<width;i+=4)
		{
			data_in = in.readInt();
			dataArray[i  ][0] = (data_in>>24)&0xFF;
			dataArray[i+1][0] = (data_in>>16)&0xFF;
			dataArray[i+2][0] = (data_in>>8)&0xFF;
			dataArray[i+3][0] = data_in&0xFF;
		}

		data_in = in.readInt();
		dataArray[0][1] = (data_in>>24)&0xFF;
		dataArray[1][1] = (data_in>>16)&0xFF;
		dataArray[2][1] = (data_in>>8)&0xFF;
		dataArray[3][1] = data_in&0xFF;
		out.writeInt(dataArray[0][0]);//upperleft
		out.writeInt(dataArray[0][0]);//upper
		out.writeInt(dataArray[1][0]);//upperright
		out.writeInt(dataArray[0][0]);//left
		out.writeInt(dataArray[1][0]);//right
		out.writeInt(dataArray[0][1]);//lowerleft
		out.writeInt(dataArray[0][1]);//lower
		out.writeInt(dataArray[1][1]);//lowerRight
		pixel_out++;
		
		
		/*
		 *middle top 
		 */
			//pixel_out<(i+3)
		for(;pixel_out<3;pixel_out++)
		{
			out.writeInt(dataArray[pixel_out-1][0]);//upperleft
			out.writeInt(dataArray[pixel_out  ][0]);//upper
			out.writeInt(dataArray[pixel_out+1][0]);//upperright
			
			out.writeInt(dataArray[pixel_out  ][0]);//left
			out.writeInt(dataArray[pixel_out+1][0]);//right
			
			out.writeInt(dataArray[pixel_out-1][1]);//lowerleft
			out.writeInt(dataArray[pixel_out  ][1]);//lower
			out.writeInt(dataArray[pixel_out+1][1]);//lowerRight
		}
		
		for(int i=0;i<width;i+=4)//top row not corners
		{
			data_in = in.readInt();
			dataArray[i  ][1] = (data_in>>24)&0xFF;
			dataArray[i+1][1] = (data_in>>16)&0xFF;
			dataArray[i+2][1] = (data_in>>8)&0xFF;
			dataArray[i+3][1] = data_in&0xFF;
			
			for(;pixel_out<i+3;pixel_out++)
			{
				out.writeInt(dataArray[pixel_out-1][0]);//upperleft
				out.writeInt(dataArray[pixel_out  ][0]);//upper
				out.writeInt(dataArray[pixel_out+1][0]);//upperright
				
				out.writeInt(dataArray[pixel_out-1][0]);//left
				out.writeInt(dataArray[pixel_out+1][0]);//right
				
				out.writeInt(dataArray[pixel_out-1][1]);//lowerleft
				out.writeInt(dataArray[pixel_out  ][1]);//lower
				out.writeInt(dataArray[pixel_out+1][1]);//lowerRight
			}
		}
		/*
		 * 
		 * corner
		 * 
		 * 
		 */
		out.writeInt(dataArray[pixel_out-1][0]);//upperleft
		out.writeInt(dataArray[pixel_out  ][0]);//upper
		out.writeInt(dataArray[pixel_out  ][0]);//upperright
		
		out.writeInt(dataArray[pixel_out-1][0]);//left
		out.writeInt(dataArray[pixel_out  ][0]);//right
		
		out.writeInt(dataArray[pixel_out-1][1]);//lowerleft
		out.writeInt(dataArray[pixel_out  ][1]);//lower
		out.writeInt(dataArray[pixel_out  ][1]);//lowerRight
		pixel_out=0;
		
		
		/*
		 * *  middle rows
		 * *
		 * *
		 * *
		*/
		//grab first pixel(s)
		for(int i =0;i<width;i+=4)
		{
			data_in = in.readInt();
			dataArray[i  ][0] = (data_in>>24)&0xFF;
			dataArray[i+1][0] = (data_in>>16)&0xFF;
			dataArray[i+2][0] = (data_in>>8)&0xFF;
			dataArray[i+3][0] = data_in&0xFF;
		}

		data_in = in.readInt();
		dataArray[0][1] = (data_in>>24)&0xFF;
		dataArray[1][1] = (data_in>>16)&0xFF;
		dataArray[2][1] = (data_in>>8)&0xFF;
		dataArray[3][1] = data_in&0xFF;
		out.writeInt(dataArray[0][0]);//upperleft
		out.writeInt(dataArray[0][0]);//upper
		out.writeInt(dataArray[1][0]);//upperright
		out.writeInt(dataArray[0][0]);//left
		out.writeInt(dataArray[1][0]);//right
		out.writeInt(dataArray[0][1]);//lowerleft
		out.writeInt(dataArray[0][1]);//lower
		out.writeInt(dataArray[1][1]);//lowerRight
		pixel_out++;
			//pixel_out<(i+3)
		for(;pixel_out<3;pixel_out++)
		{
			out.writeInt(dataArray[pixel_out-1][0]);//upperleft
			out.writeInt(dataArray[pixel_out  ][0]);//upper
			out.writeInt(dataArray[pixel_out+1][0]);//upperright
			
			out.writeInt(dataArray[pixel_out  ][0]);//left
			out.writeInt(dataArray[pixel_out+1][0]);//right
			
			out.writeInt(dataArray[pixel_out-1][1]);//lowerleft
			out.writeInt(dataArray[pixel_out  ][1]);//lower
			out.writeInt(dataArray[pixel_out+1][1]);//lowerRight
		}
		
		for(int i=0;i<width;i+=4)//top row not corners
		{
			data_in = in.readInt();
			dataArray[i  ][1] = (data_in>>24)&0xFF;
			dataArray[i+1][1] = (data_in>>16)&0xFF;
			dataArray[i+2][1] = (data_in>>8)&0xFF;
			dataArray[i+3][1] = data_in&0xFF;
			
			for(;pixel_out<i+3;pixel_out++)
			{
				out.writeInt(dataArray[pixel_out-1][0]);//upperleft
				out.writeInt(dataArray[pixel_out  ][0]);//upper
				out.writeInt(dataArray[pixel_out+1][0]);//upperright
				
				out.writeInt(dataArray[pixel_out-1][0]);//left
				out.writeInt(dataArray[pixel_out+1][0]);//right
				
				out.writeInt(dataArray[pixel_out-1][1]);//lowerleft
				out.writeInt(dataArray[pixel_out  ][1]);//lower
				out.writeInt(dataArray[pixel_out+1][1]);//lowerRight
			}
		}
		//corner
		out.writeInt(dataArray[pixel_out-1][0]);//upperleft
		out.writeInt(dataArray[pixel_out  ][0]);//upper
		out.writeInt(dataArray[pixel_out  ][0]);//upperright
		
		out.writeInt(dataArray[pixel_out-1][0]);//left
		out.writeInt(dataArray[pixel_out  ][0]);//right
		
		out.writeInt(dataArray[pixel_out-1][1]);//lowerleft
		out.writeInt(dataArray[pixel_out  ][1]);//lower
		out.writeInt(dataArray[pixel_out  ][1]);//lowerRight
		pixel_out=0;
		
		
	}
}
