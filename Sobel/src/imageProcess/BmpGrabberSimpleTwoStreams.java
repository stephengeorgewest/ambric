package imageProcess;

import ajava.io.InputStream;
import ajava.io.OutputStream;

public class BmpGrabberSimpleTwoStreams
{
	int width = 1280;
	int height = 1024;
	int[] dataArray_top    =  new int[width+2];
	int[] dataArray_middle =  new int[width+2];
	int[] dataArray_bottom =  new int[width+2];
	int outPixel = 1;
	public void run(InputStream<Integer> in, OutputStream<Integer> out_1, OutputStream<Integer> out_2)
	{
		int data_in=0;
		int toggle = 1;
		for(int j=1;j<=width-3;j+=4)
		{
			data_in = in.readInt();
			dataArray_middle[j  ] = dataArray_top[j  ] = (data_in>>24)&0xFF;
			dataArray_middle[j+1] = dataArray_top[j+1] = (data_in>>16)&0xFF;
			dataArray_middle[j+2] = dataArray_top[j+2] = (data_in>>8)&0xFF;
			dataArray_middle[j+3] = dataArray_top[j+3] = data_in&0xFF;
			if(j==1)
			{
				dataArray_top[0] = dataArray_middle[1];
				dataArray_middle[0] = dataArray_top[0];
				
			}
			else if(j==width-3)
			{
				dataArray_middle[width+1] = dataArray_top[width+1] = dataArray_middle[width];
			}
		}
		for(int i=0;i<height-1;i++)
		{
			for(int j=1;j<=(width-3);j+=4)
			{
				data_in = in.readInt();
				dataArray_bottom[j  ] = (data_in>>24)&0xFF;
				dataArray_bottom[j+1] = (data_in>>16)&0xFF;
				dataArray_bottom[j+2] = (data_in>>8)&0xFF;
				dataArray_bottom[j+3] = data_in&0xFF;

				if(j==1)
				{
					 dataArray_bottom[0] = dataArray_bottom[1];
				}
				else if(j==width-3)
				{
					dataArray_bottom[width+1] = dataArray_bottom[width];
				}
				

				for(;outPixel<j+3;outPixel++)
				{
					if(toggle == 1)
					{
						out_1.writeInt(dataArray_top[outPixel-1]);//upper left
						out_1.writeInt(dataArray_top[outPixel  ]);//upper middle
						out_1.writeInt(dataArray_top[outPixel+1]);//upper right
						
						out_1.writeInt(dataArray_middle[outPixel-1]);//left
						out_1.writeInt(dataArray_middle[outPixel+1]);//right
						
						out_1.writeInt(dataArray_bottom[outPixel-1]);//lower left
						out_1.writeInt(dataArray_bottom[outPixel  ]);//lower
						out_1.writeInt(dataArray_bottom[outPixel+1]);//lower Right
						toggle = 2; 
					}
					else
					{
						out_2.writeInt(dataArray_top[outPixel-1]);//upper left
						out_2.writeInt(dataArray_top[outPixel  ]);//upper middle
						out_2.writeInt(dataArray_top[outPixel+1]);//upper right
						
						out_2.writeInt(dataArray_middle[outPixel-1]);//left
						out_2.writeInt(dataArray_middle[outPixel+1]);//right
						
						out_2.writeInt(dataArray_bottom[outPixel-1]);//lower left
						out_2.writeInt(dataArray_bottom[outPixel  ]);//lower
						out_2.writeInt(dataArray_bottom[outPixel+1]);//lower Right
						toggle = 1;
					}
				}
				//last one
				if(outPixel==width)
				{
					out_2.writeInt(dataArray_top[outPixel-1]);//upper left
					out_2.writeInt(dataArray_top[outPixel  ]);//upper middle
					out_2.writeInt(dataArray_top[outPixel+1]);//upper right
					
					out_2.writeInt(dataArray_middle[outPixel-1]);//left
					out_2.writeInt(dataArray_middle[outPixel+1]);//right
					
					out_2.writeInt(dataArray_bottom[outPixel-1]);//lower left
					out_2.writeInt(dataArray_bottom[outPixel  ]);//lower
					out_2.writeInt(dataArray_bottom[outPixel+1]);//lower Right
					toggle = 1;
				}
			}
			outPixel=1;

			for(int j =0;j<(width+2);j++)
			{
				dataArray_top[j] = dataArray_middle[j];
				dataArray_middle[j] = dataArray_bottom[j];
			}
		}
		//bottom row
		for(outPixel=1;outPixel<=width;outPixel++)
		{
			if(toggle == 1)
			{
				out_1.writeInt(dataArray_top[outPixel-1]);//upper left
				out_1.writeInt(dataArray_top[outPixel ]);//upper middle
				out_1.writeInt(dataArray_top[outPixel+1]);//upper right
				
				out_1.writeInt(dataArray_middle[outPixel-1]);//left
				out_1.writeInt(dataArray_middle[outPixel+1]);//right
				
				out_1.writeInt(dataArray_middle[outPixel-1]);//lower left
				out_1.writeInt(dataArray_middle[outPixel  ]);//lower
				out_1.writeInt(dataArray_middle[outPixel+1]);//lower Right
				toggle = 2;
			}
			else
			{
				out_2.writeInt(dataArray_top[outPixel-1]);//upper left
				out_2.writeInt(dataArray_top[outPixel ]);//upper middle
				out_2.writeInt(dataArray_top[outPixel+1]);//upper right
				
				out_2.writeInt(dataArray_middle[outPixel-1]);//left
				out_2.writeInt(dataArray_middle[outPixel+1]);//right
				
				out_2.writeInt(dataArray_middle[outPixel-1]);//lower left
				out_2.writeInt(dataArray_middle[outPixel  ]);//lower
				out_2.writeInt(dataArray_middle[outPixel+1]);//lower Right
				toggle = 1;
			}
		}
	}
}
