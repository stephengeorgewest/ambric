package velocity;
import ajava.io.InputStream;
import ajava.io.OutputStream;

public class DividerEmpty
{
	int fraction_bits;
	int max_int;
	public DividerEmpty(int fraction_bits, int max_int)
	{
		this.fraction_bits = fraction_bits;
		this.max_int = max_int;
	}
	public void run(InputStream<Integer> numerator,
			InputStream<Integer> denominator,
			OutputStream<Integer> value)
	{

		int num = numerator.readInt();
		int den = denominator.readInt();
		
		value.writeInt(num+den);
	}
}
