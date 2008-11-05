package houghPackage;

import ajava.io.InputStream;
import ajava.io.OutputStream;

public class translate_pixels_to_coordinates {
	private int x_counter = 1;
	private int y_counter = 1;
	private int coordinate = 0;

	public void run(InputStream<Integer> in, OutputStream<Integer> out){

		while (true){
			if(in.readInt() != 0){
				coordinate = (x_counter << 16) | y_counter; 
				out.writeInt(coordinate);			
			}
			x_counter++;
			if(x_counter == (640-1)){
				x_counter = 1;
				y_counter++;
				if(y_counter == (480-1)){
					y_counter = 1;
					out.writeInt(0);
					out.writeInt(0xFFFFFFFF);
				}
			}
		}
	}
}
