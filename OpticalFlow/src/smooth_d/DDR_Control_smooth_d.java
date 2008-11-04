package smooth_d;

import ajava.io.InputStream;
import ajava.io.RawOutputStream;

public class DDR_Control_smooth_d
{
	int width;
	int height;
	int offset;
	public DDR_Control_smooth_d(int width, int height, int offset)
	{
		this.width=width;
		this.height=height;
		this.offset=offset;
	}
	public void run(InputStream<Integer> in, RawOutputStream out)
	{
		int one_frame=this.width*this.height*4;//width*height*4bytes;
		
		int top_frame=offset;//start above other frames
		int mid_frame=top_frame+one_frame;//width*height*4bytes
		int bottom_frame=mid_frame+one_frame;
		
	/*	// i don't know why this doesn't work now
		// write until de0
		//copy in the first 2 frames
		int write_command =0x8<<28 | 0;//0 length == write until DE0
			//		de=1	[31:28]=0x8		[27:16]=length	[15:0]=address
			//out.writeDE1(	0x8<<28		| 	4<<15 		|	address);
			//DE1 length=0 for write until DE0
			out.writeDE1(write_command);
			
								//count words instead of bytes
		for(int count=top_frame, stop=bottom_frame+one_frame-4; count<stop; count+=4)// stop after 2nd to last to let DE=0 on last word
		{
			out.writeDE1(in.readInt());//only one word
		}
		out.writeDE0(in.readInt());
	*/	
		//individual writes
		int write_command = 0x9<<28 | 4<<16;
		for(int count=top_frame, stop=bottom_frame+one_frame; count<stop; count+=4)// stop after 2nd to last to let DE=0 on last word
		{
			out.writeDE1(write_command );
			out.writeDE1(count);
			out.writeDE0(in.readInt());
				
		}
		//0x9 means long address extra addres bits sent after this command
		//			long addr	length
		write_command   =  0x9<<28 | 4<<16;
		int read_command = 0xB<<28 | 4<<16;
		while(true)
		{
			for(int count=0; count<one_frame; count+=4)
			{
				
				//send command to read 3 pixels
				int temp_offset=count+top_frame;
				out.writeDE1(read_command );
				out.writeDE0(temp_offset);
				//write in newest pixel
				out.writeDE1(write_command );
				out.writeDE1(temp_offset);
				out.writeDE0(in.readInt());
				
				temp_offset=count+mid_frame;
				out.writeDE1(read_command);
				out.writeDE0(temp_offset);
				
				temp_offset=count+bottom_frame;
				out.writeDE1(read_command);
				out.writeDE0(temp_offset);
				
			}
			//shuffle pointers
			int temp_frame=bottom_frame+1;
			bottom_frame=top_frame;
			top_frame=mid_frame;
			mid_frame=temp_frame-1;
		}
	}
}
