package source;
import ajava.io.OutputStream;
import ajava.io.InputStream;

public class Image2coord
{
	int image_width;
	int image_height;
	public Image2coord(int image_width, int image_height)
	{
		this.image_width=image_width;
		this.image_height=image_height;
	}
	public void run(InputStream<Integer> in,
					OutputStream<Integer> out)
	{
		int width=this.image_width; //use local variable to reference registers instead of memory access
		int height=this.image_height;
		for(int y=0; y<height;y++)
			for(int x=0; x<width;x++)
				if(in.readInt()!=0)
				{
					//System.out.println("2Coord("+x+","+y+")\n");
					out.writeInt(x);
					out.writeInt(y);
				}
				else
				{
					//System.out.println("2coord("+x+","+y+")\n");
				}
		out.writeInt(width);
		out.writeInt(height);
	}
}
