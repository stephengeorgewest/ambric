package source;
import ajava.io.OutputStream;
import ajava.io.InputStream;
import ajava.lang.Simulator;

public class Hough
{
	int[][] accumulator;
	int[] cos_table;
	int[] sin_table;
	int total_angle_bins,local_angle_bins;
	int trig_log2_range;
	int radius_bins;
	int image_width, image_height, max_radius;
	int num_processors,num_processors_upstream,this_processor;
	public Hough(int image_width, int image_height, 
			int radius_bins, int angle_bins, 
			int trig_log2_range,
			int num_processors, int this_processor,
			int cos0, int cos1,//int cos2, int cos3,
			int sin0, int sin1//, int sin2, int sin3
		)
	{
		this.image_height=image_height;
		this.image_width=image_width;
		
		this.num_processors=num_processors;
		this.this_processor=this_processor;
		this.num_processors_upstream=this_processor;
		
		this.radius_bins = radius_bins;
		this.total_angle_bins = angle_bins;
		this.local_angle_bins = angle_bins/num_processors;
		
		// (int)(image_width*Math.sqrt(2.0)+image_height*Math.sqrt(2.0));
		this.max_radius = (image_width+image_height)*577/408;//  577/408~sqrt(2)
		this.accumulator = new int[this.local_angle_bins][this.radius_bins];
		
		this.trig_log2_range = trig_log2_range;
		createTrigRange();
		
		this.cos_table = new int[this.local_angle_bins];
		this.sin_table = new int[this.local_angle_bins];
		this.cos_table[0] = cos0;
		this.cos_table[1] = cos1;
		this.sin_table[0] = sin0;
		this.sin_table[1] = sin1;
		createLookUpTables();
		
		
		if(this.this_processor==0)
		{
			simPrintGlobals();
			simPrintSinTable();
			simPrintCosTable();
		}
		//simPrintAngle();
	}
	@Simulator public void createTrigRange()
	{// calculate the max possible trig_log2_range that prevents overflow
		this.trig_log2_range = 1;
		while((1<<(this.trig_log2_range+1))*2*this.max_radius*this.radius_bins>0)
			this.trig_log2_range +=1;
		
	}
	@Simulator public void createLookUpTables()
	{//can't use floats in ISS or hardware
		for(int i=0;i<this.local_angle_bins;i++)
		{
			this.cos_table[i] = (int)(Math.cos(   ((double)(i+this.num_processors_upstream*this.local_angle_bins))*Math.PI/(double)this.total_angle_bins   )*(1<<this.trig_log2_range));
			this.sin_table[i] = (int)(Math.sin(   ((double)(i+this.num_processors_upstream*this.local_angle_bins))*Math.PI/(double)this.total_angle_bins   )*(1<<this.trig_log2_range));
		}
	}
	@Simulator public void simPrintGlobals ()
	{
		System.out.println("max_r = "+this.max_radius);
		System.out.println("r_bins = "+this.radius_bins);
		System.out.println("total_angle_bins = "+ this.total_angle_bins);
		System.out.println("local_angle_bins = " + this.local_angle_bins);
		System.out.println("\n\n\n");
		System.out.println("const int trig_log2_range = "+this.trig_log2_range + "; // trig_range = "+(1<<this.trig_log2_range));
		
	}
	@Simulator public void simPrintAngle()
	{
		for(int i=0;i<this.local_angle_bins;i++)
			System.out.println(" proc: "+this.this_processor+"   inval: "+(i+this.num_processors_upstream*this.local_angle_bins)+"   cos["+i+"] = "+this.cos_table[i] +"\tsin["+i+"] = "+ this.sin_table[i]);
	}
	@Simulator public void simPrintR(int x, int y, int a, int r)
	{
		//if(this.this_processor==0 && x==1 && y==19 && a==3)
			System.out.println("bigest r "+r);
	}
	@Simulator public void simPrintStuff(int x, int y, int a, int r)
	{
		//if(this.this_processor==0 && x==1 && y==19 && a==3)
			System.out.println("Proc="+this.this_processor+"\tx=" + x +"\ty="+ y+ "\ta="+a+"\tr="+r);
	}
	@Simulator public void simPrintSinTable()
	{
		System.out.print("const int sineInitValues[] = {\n\t\t");
		for(int i=0;i<this.total_angle_bins;i++)
		{
			int sin_i = (int)(Math.sin(   ((double)(i))*Math.PI/(double)this.total_angle_bins   )*(1<<this.trig_log2_range));;
			System.out.print(sin_i+"");
			if(i<this.total_angle_bins-1)
				System.out.print(", ");
			if((i+1)%this.local_angle_bins==0)
				System.out.print("\n\t\t");
		}
		System.out.println("};");
	}
	@Simulator public void simPrintCosTable()
	{

		System.out.print("const int cosineInitValues[] = {\n\t\t");
		for(int i=0;i<this.total_angle_bins;i++)
		{
			int cos_i = (int)(Math.cos(   ((double)(i))*Math.PI/(double)this.total_angle_bins   )*(1<<this.trig_log2_range));;
			System.out.print(cos_i+"");
			if(i<this.total_angle_bins-1)
				System.out.print(", ");
			if((i+1)%this.local_angle_bins==0)
				System.out.print("\n\t\t");
		}
		System.out.println("};");
	}
	
	
	public void run(InputStream<Integer> in,
					OutputStream<Integer> out)
	{
		int x=in.readInt();
		int y=in.readInt();
		if(this.this_processor!=this.num_processors-1)
		{
			out.writeInt(x);
			out.writeInt(y);
		}
		if(x==this.image_width && y==this.image_height)
		{
			int local_angle_bins = this.local_angle_bins;
			int radius_bins = this.radius_bins;
			
			int loop_count = local_angle_bins*this.num_processors_upstream*radius_bins;
			for(int i=0;i<loop_count;i++)//0th processor starts first -- should skip
				out.writeInt(in.readInt());
			//after all upstream processors print me
			for(int i=0;i<local_angle_bins;i++)
			{
				for(int j=0;j<radius_bins;j++)
				{
					out.writeInt(this.accumulator[i][j]);
				}
			}
		}
		else
		{
			int max_radius = this.max_radius;// force register use
			int radius_bins = this.radius_bins;
			int trig_log2_range = this.trig_log2_range;
			int local_angle_bins = this.local_angle_bins;
			int max_radius_times_trig_range = max_radius*(1<<trig_log2_range);
			for(int angle=0; angle<local_angle_bins; angle++)
			{//fixed point max == 2*sqrt(2)*(x+y)*radius_bins == 2*max_radius*range*radius_bins
				int radius=(x*this.cos_table[angle]+y*this.sin_table[angle]);
				//[-max_radius*range...max_radius*range]
				radius+=max_radius_times_trig_range;
				//[0...2*max_radius*range]
				radius*=radius_bins;
				//[0...2*max_radius*range*radius_bins]
				//simPrintR(x,y,angle,radius);
				radius=radius>>(trig_log2_range);
				//[0...2*max_radius*radius_bins]
				
				//radius=radius/this.max_radius;//[0...2*radius_bins]
				//fake divide
				int radius_tmp;
				for(radius_tmp=0;radius>=0;radius-=max_radius)
				{radius_tmp++;}
				radius=radius_tmp;//[0...2*radius_bins]

				radius=(radius)>>1;//[0...radius_bins] -- truncated -- use (radius +1)>1 to round
				//simPrintStuff(x, y, angle, radius);
				this.accumulator[angle][radius]++;
			}
		}
	}
}
