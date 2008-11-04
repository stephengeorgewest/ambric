package velocity;
import ajava.io.InputStream;
import ajava.io.OutputStream;

public class Divider
{
	int fraction_bits;
	int max_int;
	public Divider(int fraction_bits, int max_int)
	{
		this.fraction_bits = fraction_bits;
		this.max_int = max_int;
	}
	public void run(InputStream<Integer> numerator,
			InputStream<Integer> denominator,
			OutputStream<Integer> value)
	{
		//integer part
		int num, den;
		int sign = 0;
		int quotient =0, remainder;
		int precision = this.fraction_bits;
		int fraction = 0;
		
		num = numerator.readInt();
		den = denominator.readInt();
		
		
		// or sign = (num>>31)*(den>>31);?
		if(den!=0)//value set to zero at end if den== zero because of sign
		{
			if(num>0)
			{
				if(den>0)
				{
					sign=1;
				}
				else
				{
					den = (-den);
					sign=(-1);
				}
			}
			else//num <0
			{
				num=(-num);
				if(den>0)
				{
					sign=(-1);
				}
				else
				{
					den=(-den);
					sign=1;
				}	
			}
			quotient = 0;
			remainder = num;
			while (remainder>=den)
			{
				quotient++;
				remainder -= den;
				if(quotient>this.max_int)
				{
					remainder=0;
				}
			}
			if(remainder!=0)
			{
				//do fractional part
				remainder=remainder<<precision;
				while(remainder>=den)
				{
					fraction++;
					remainder-=den;
				}
				//round here
				remainder=remainder<<1;
				if(remainder>=den)
					fraction++;// the quotient+fraction will roll over fraction if necessary
			}
		}
		int val;
		val = (quotient*(1<<precision)+fraction)*sign;
		//val = quotient*sign;
		value.writeInt(val);
	}
}
