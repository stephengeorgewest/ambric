package derivitive;

import ajava.io.InputStream;
import ajava.io.RawOutputStream;

public class DDR_Control_dt
{
	int width;
	int height;
	
	public DDR_Control_dt(int width, int height)
	{
		this.width=width;
		this.height=height;
		
	}
	public void run(InputStream<Integer> in, RawOutputStream out)
	{
		int one_frame=this.width*this.height*4;//width*height*4bytes;
			
		int top_frame=0;
		int top_mid_frame=top_frame+one_frame;
		int mid_frame=top_mid_frame+one_frame;
		int bottom_mid_frame=mid_frame+one_frame;
		int bottom_frame=bottom_mid_frame+one_frame;
		/*
		//copy in the first 5 frames
		int write_command =0x8<<28 | 0<<16 | 0;//0 length == write until DE0
			//		de=1	[31:28]=0x8		[27:16]=length	[15:0]=address
			//out.writeDE1(	0x8<<28		| 	4<<16 		|	address);
			//DE1 length=0 for write until DE0
			out.writeDE1(write_command);
			
			
		for(int count=0, stop=bottom_frame+one_frame-4; count<stop; count+=4)//count by 4 bytes stop at bottom_frame+one_frame
		{
			out.writeDE1(in.readInt());//only one word
		}
		out.writeDE0(in.readInt());
		*/
		int write_command = 0x9<<28 | 4<<16;
		for(int count=0, stop=bottom_frame+one_frame; count<stop; count+=4)// stop after 2nd to last to let DE=0 on last word
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
			for(int offset=0; offset<one_frame; offset+=4)
			{
				int temp_offset=offset+top_frame;
				out.writeDE1(read_command);// | (temp_offset>>16)&0xFFFF);
				out.writeDE0(temp_offset);
				//write in newest pixel
				out.writeDE1(write_command);// | (temp_offset>>16)&0xFFFF);
				out.writeDE1(temp_offset);
				out.writeDE0(in.readInt());
				
				
				temp_offset=offset+top_mid_frame;
				out.writeDE1(read_command);// | (temp_offset>>16)&0xFFFF);
				out.writeDE0(temp_offset);
				
				/* don't need this data yet
				temp_offset=offset+mid_frame;
				out.writeDE1(read_command);// | (temp_offset>>16)&0xFFFF);
				out.writeDE0(temp_offset&0xFFFF);
				*/
				
				temp_offset=offset+bottom_mid_frame;
				out.writeDE1(read_command);// | (temp_offset>>16)&0xFFFF);
				out.writeDE0(temp_offset);
				
				
				temp_offset=offset+bottom_frame;
				out.writeDE1(read_command);// | (temp_offset>>16)&0xFFFF);
				out.writeDE0(temp_offset);
			}//for(int offset=0; offset<one_frame; offset+=4)
			
			//shuffle pointers
			int temp_frame=top_frame+1;//+1 -1 is a workaround for a compiler bug.
			top_frame=top_mid_frame;
			top_mid_frame=mid_frame;
			mid_frame=bottom_mid_frame;
			bottom_mid_frame=bottom_frame;
			bottom_frame=temp_frame-1;
		}
	}
}
