package shuffleValues;
import ajava.io.OutputStream;
import ajava.io.InputStream;
public class ShuffleValues
{
	int [][]val = new int [3][3];
	public ShuffleValues()
	{
		
	}
	public void run(InputStream<Integer> in,
					OutputStream<Integer>out)
	{
		for(int i=0;i<3;i++)
			for(int j=0;j<3;j++)
				val[i][j]=in.readInt();
		for(int i=0;i<3;i++)
			for(int j=0;j<3;j++)
				out.writeInt(val[j][i]);
	}
}
