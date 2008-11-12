package derivative;

import ajava.io.InputStream;
import ajava.io.RawOutputStream;

public class DDR_Control_delay
{
	int width;
	int height;
	int offset;
	
	public DDR_Control_delay(int width, int height, int offset)
	{
		this.width=width;
		this.height=height;
		this.offset = offset;
	}
	public void run(InputStream<Integer> in, RawOutputStream out)
	{
		int frames=3*this.width*this.height*4;//width*height*4bytes;
			
		int top_frame=this.offset*4;
		int stop = top_frame+frames;

		int write_command = 0x9<<28 | 4<<16;
		for(int count=top_frame; count<stop; count+=4)// stop after 2nd to last to let DE=0 on last word
		{
			out.writeDE1(write_command );
			out.writeDE1(count);
			out.writeDE0(in.readInt());
				
		}
		//0x9 means long address extra addres bits sent after this command
		//			long addr	length
		write_command   = 0x9<<28 | 4<<16;
		int read_command= 0xB<<28 | 4<<16;
		while(true)
		{
			for(int offset=top_frame; offset<stop; offset+=4)
			{
				int temp_offset=offset;
				
				out.writeDE1(read_command);// | (temp_offset>>16)&0xFFFF);
				out.writeDE0(temp_offset);
				//write in newest pixel
				out.writeDE1(write_command);// | (temp_offset>>16)&0xFFFF);
				out.writeDE1(temp_offset);
				out.writeDE0(in.readInt());
			}//for(int offset=0; offset<one_frame; offset+=4)
		}
	}
}
