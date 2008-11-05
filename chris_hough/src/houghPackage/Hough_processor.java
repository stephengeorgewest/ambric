package houghPackage;

import ajava.io.InputStream;
import ajava.io.OutputStream;
public class Hough_processor {
	private int[][] accumulator;
	private int[] my_bins;
	private int[] my_sine;
	private int[] my_cosine;
	private int x, y, coordinate, max_r, bin_count, col_size, bp;
	
	// Constructor
	public Hough_processor(int start_bin, // My starting theta value 
						   int col_size, // How deep to make accumulator
						   int bin_count, // How many theta's am I resposible for?
						   int cosine_val_0,  // My cosine values (fixed point)
						   int sine_val_0, // My sine values (fixed point)
						   int cosine_val_1,  // My cosine values (fixed point)
						   int sine_val_1, // My sine values (fixed point)
						   int cosine_val_2,  // My cosine values (fixed point)
						   int sine_val_2, // My sine values (fixed point)
						   int cosine_val_3,  // My cosine values (fixed point)
						   int sine_val_3, // My sine values (fixed point)
						   int max_r, // Maximum rho value
						   int bp){ // Binary Point
		
		this.accumulator = new int[bin_count][col_size];
		this.my_bins = new int[bin_count];
		this.my_sine = new int[bin_count];
		this.my_cosine = new int[bin_count];
		for(int i=0; i < bin_count; i++){
			this.my_bins[i] = start_bin + i;
		}
		this.my_sine[0] = sine_val_0;
		this.my_cosine[0] = cosine_val_0;
		this.my_sine[1] = sine_val_1;
		this.my_cosine[1] = cosine_val_1;
		this.my_sine[2] = sine_val_2;
		this.my_cosine[2] = cosine_val_2;
		this.my_sine[3] = sine_val_3;
		this.my_cosine[3] = cosine_val_3;
		
		this.x = 0;
		this.y = 0;
		this.coordinate = 0;
		this.bin_count = bin_count;
		this.max_r = max_r;
		this.col_size = col_size;
		this.bp = bp;
	}
	
	public void run(InputStream<Integer> in, OutputStream<Integer> out){

		while(true){
			if((this.coordinate = in.readInt()) != 0){
				out.writeInt(this.coordinate); // Pass pixel coordinates to next processor
				this.x = (((this.coordinate) & 0xffff0000) >> 16) & 0x0000ffff;
				this.y = this.coordinate & 0x0000ffff;
				
				for(int i=0; i < this.bin_count; i++){
					int r = this.x*this.my_cosine[i] + this.y*this.my_sine[i];
					r = (r >> (1+bp))+1;
					r = r >> 1;
					this.accumulator[i][this.max_r + r]++;
				}
			}
			else{
				do 
				{
					out.writeInt(this.coordinate);	
				}
				while((this.coordinate = in.readInt()) != 0xFFFFFFFF);

				for(int i=0; i < this.bin_count; i++){
					for(int j=0; j < this.col_size; j++){
						out.writeInt(this.accumulator[i][j]);
					}
				}
				out.writeInt(0xFFFFFFFF);
			}
		}
	}
}


