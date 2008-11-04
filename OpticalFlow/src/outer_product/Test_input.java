package outer_product;

import ajava.io.OutputStream;
	
public class Test_input
{
	public void run(OutputStream<Integer> x, OutputStream<Integer> y, OutputStream<Integer> t)
	{
		
		x.writeInt(0);
		y.writeInt(0);
		t.writeInt(0);
		//xx = 0
		//xy = 0
		//xt = 0
		//yy = 0
		//yt = 0
		//tt = 0
		/**/
		x.writeInt(1);
		y.writeInt(0);
		t.writeInt(0);
		//xx = 1
		//xy = 0
		//xt = 0
		//yy = 0
		//yt = 0
		//tt = 0
		x.writeInt(0);
		y.writeInt(1);
		t.writeInt(0);
		//xx = 0
		//xy = 0
		//xt = 0
		//yy = 1
		//yt = 0
		//tt = 0
		x.writeInt(0);
		y.writeInt(0);
		t.writeInt(1);
		//xx = 0
		//xy = 0
		//xt = 0
		//yy = 0
		//yt = 0
		//tt = 1
		
		
		
		
		
		x.writeInt(1);
		y.writeInt(1);
		t.writeInt(0);
		//xx = 1
		//xy = 1
		//xt = 0
		//yy = 1
		//yt = 0
		//tt = 0
		x.writeInt(0);
		y.writeInt(1);
		t.writeInt(1);
		//xx = 0
		//xy = 0
		//xt = 0
		//yy = 1
		//yt = 1
		//tt = 1
		x.writeInt(1);
		y.writeInt(0);
		t.writeInt(1);
		//xx = 1
		//xy = 0
		//xt = 1
		//yy = 0
		//yt = 0
		//tt = 1
		

		x.writeInt(4);
		y.writeInt(4);
		t.writeInt(4);
		//xx = 1
		//xy = 1
		//xt = 1
		//yy = 1
		//yt = 1
		//tt = 1
		while(true){}
	}
}
