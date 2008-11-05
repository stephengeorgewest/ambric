package imageProcess;

import ajava.io.InputStream;
import ajava.io.OutputStream;

public class BmpGrabberSimple
{
	int width = 512;
	int height = 512;
	int[][] dataArray =  new int[width][height];
	public void run(InputStream<Integer> in, OutputStream<Integer> out)
	{
		
		int data_in=0;
		for(int i=0;i<height;i++)
		{
			for(int j=0;j<width;j+=4)
			{
				data_in = in.readInt();
				dataArray[j  ][i] = (data_in>>24)&0xFF;
				dataArray[j+1][i] = (data_in>>16)&0xFF;
				dataArray[j+2][i] = (data_in>>8)&0xFF;
				dataArray[j+3][i] = data_in&0xFF;
			}
		}
		for(int i=0;i<height;i++)
		{
			for(int j=0;j<width;j++)
			{
				int jLeft = j-1;
				int jRight = j+1;
				if(j==0)
					jLeft = 0;
				if(j==width-1)
					jRight = j;
				
				int iTop = i-1;
				int iBottom = i+1;
				if(i==0)
					iTop = 0;
				if(i==height-1)
					iBottom = i;
				
				out.writeInt(dataArray[jLeft ][iTop]);//upper left
				out.writeInt(dataArray[j     ][iTop]);//upper middle
				out.writeInt(dataArray[jRight][iTop]);//upper right
				
				out.writeInt(dataArray[jLeft ][i]);//left
				out.writeInt(dataArray[jRight][i]);//right
				
				out.writeInt(dataArray[jLeft ][iBottom]);//lower left
				out.writeInt(dataArray[j     ][iBottom]);//lower
				out.writeInt(dataArray[jRight][iBottom]);//lower Right
			}
		}
	}
}
