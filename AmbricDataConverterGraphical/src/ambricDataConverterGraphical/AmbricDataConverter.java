package ambricDataConverterGraphical;


//Derived from example code
//http://java.sun.com/docs/books/tutorial/2d/images/saveimage.html
/*
* Copyright (c) 1995 - 2008 Sun Microsystems, Inc.  All rights reserved.
*
* Redistribution and use in source and binary forms, with or without
* modification, are permitted provided that the following conditions
* are met:
*
*   - Redistributions of source code must retain the above copyright
*     notice, this list of conditions and the following disclaimer.
*
*   - Redistributions in binary form must reproduce the above copyright
*     notice, this list of conditions and the following disclaimer in the
*     documentation and/or other materials provided with the distribution.
*
*   - Neither the name of Sun Microsystems nor the names of its
*     contributors may be used to endorse or promote products derived
*     from this software without specific prior written permission.
*
* THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
* IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
* THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
* PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR
* CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
* EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
* PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
* PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
* LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
* NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
* SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/


import java.io.*;
import java.util.TreeSet;
import java.awt.*;
import java.awt.event.*;
import java.awt.image.*;
import javax.imageio.*;
import javax.swing.*;

public class AmbricDataConverter extends JPanel implements ActionListener
{
	static final long serialVersionUID=0;
		String descs[] = {
		"Original",
		"LookupOp",
		"Sobel",
		"Sobel Aproximate",
		"Threashold",
		"Sobel-Threashold",
		"Hough",
		"deHough",
	};
	int opIndex;
	private BufferedImage bi, biFiltered;
	int w, h;

	protected JTextField widthField;
	protected JTextField heightField;

	public AmbricDataConverter()
	{
		super(new BorderLayout());
		widthField = new JTextField(4);
		
		heightField = new JTextField(4);
		JComboBox choices = new JComboBox(this.getDescriptions());
		choices.setActionCommand("SetFilter");
		choices.addActionListener(this);
		JComboBox formats = new JComboBox(this.getFormats());
		formats.addItem("ambricFile");
		formats.addItem("javaArray");
		formats.setActionCommand("Formats");
		formats.addActionListener(this);
		JButton imports = new JButton("Import");
		imports.setActionCommand("Import");
		imports.addActionListener(this);
		//widthField = new JTextField(4);
		JPanel panel = new JPanel();
		panel.add(choices);
		panel.add(new JLabel("Save As"));
		panel.add(formats);
		panel.add(imports);
		panel.add(widthField);
		panel.add(heightField);
		add("South", panel);
		try
		{
			//bi = ImageIO.read(new File("./lena512.bmp"));
			//bi = ImageIO.read(new File("/Documents and Settings/stephen/My Documents/My Pictures/fsa-green1280.jpg"));
			//bi = ImageIO.read(new File("/Documents and Settings/stephen/My Documents/My Pictures/fsa-blue1280.jpg"));
			//bi = ImageIO.read(new File("/Documents and Settings/stephen/My Documents/My Pictures/fsa-red1280.jpg"));
			//bi = ImageIO.read(new File("/Documents and Settings/stephen/My Documents/My Pictures/fsa-purple1280.jpg"));
			//bi = ImageIO.read(new File("/Documents and Settings/stephen/My Documents/My Pictures/line.bmp"));
			//bi = ImageIO.read(new File("/Documents and Settings/stephen/My Documents/My Pictures/edge.bmp"));
			//bi = ImageIO.read(new File("/Documents and Settings/stephen/My Documents/My Pictures/line.jpg"));
			//bi = ImageIO.read(new File("/Documents and Settings/stephen/My Documents/My Pictures/sqr1.gif"));
			//bi = ImageIO.read(new File("/Documents and Settings/stephen/My Documents/My Pictures/box.bmp"));
			//bi = ImageIO.read(new File("/Documents and Settings/stephen/My Documents/My Pictures/sff1sca1.gif"));
			//bi = ImageIO.read(new File("/Documents and Settings/stephen/My Documents/My Pictures/horizontal_line32x32.bmp"));
			bi = ImageIO.read(new File("/Documents and Settings/stephen/My Documents/My Pictures/triangle512x512.bmp"));
			//bi = ImageIO.read(new File("/Documents and Settings/stephen/My Documents/My Pictures/line64x64.bmp"));
			//bi = ImageIO.read(new File("/Documents and Settings/stephen/My Documents/My Pictures/greendragonBW64x64.bmp"));
			//bi = ImageIO.read(new File("/Documents and Settings/stephen/My Documents/My Pictures/n64.jpg"));
			biFiltered=bi;
			
			
			
			w = bi.getWidth(null);
			widthField.setText(""+w);
			h = bi.getHeight(null);
			heightField.setText(""+h);
			if (bi.getType() != BufferedImage.TYPE_BYTE_GRAY)
			{
				BufferedImage bi2 =
				new BufferedImage(w, h, BufferedImage.TYPE_BYTE_GRAY);
				Graphics big = bi2.getGraphics();
				big.drawImage(bi, 0, 0, null);
				biFiltered = bi = bi2;
			}
		}
		catch (IOException e)
		{
			System.out.println("Image could not be read");
			System.exit(1);
		}
	}
	public Raster SobelFloat(Raster image)
	{
		WritableRaster sobelWritableRaster_f =image.createCompatibleWritableRaster();
		int[] P1_f = {0};
		int[] P2_f = {0};
		int[] P3_f = {0};
		int[] P4_f = {0};
		int[] P6_f = {0};
		int[] P7_f = {0};
		int[] P8_f = {0};
		int[] P9_f = {0};
		
		int[] Pout_int = {0};
		
		for(int i=0; i<image.getHeight();i++)
		{
			for(int j=0; j<image.getWidth()-1;j++)
			{
				int jLeft = j-1;
				int jRight = j+1;
				if(j==0)
					jLeft = 0;
				if(j==image.getWidth()-1)
					jRight = j;
				
				int iTop = i-1;
				int iBottom = i+1;
				if(i==0)
					iTop = 0;
				if(i==image.getHeight()-1)
					iBottom = i;
				
				image.getPixel(jLeft , iBottom ,P1_f);
				image.getPixel(j     , iBottom ,P2_f);
				image.getPixel(jRight, iBottom ,P3_f);
				image.getPixel(jLeft , i       ,P4_f);
				//image.getPixel(j+0,i+0,P4);
				image.getPixel(jRight ,i       ,P6_f);
				image.getPixel(jLeft  ,iTop    ,P7_f);
				image.getPixel(j      ,iTop    ,P8_f);
				image.getPixel(jRight ,iTop    ,P9_f);
				double Px = (P1_f[0]+2*P2_f[0]+P3_f[0])-(P7_f[0]+2*P8_f[0]+P9_f[0]);
				double Py = (P3_f[0]+2*P6_f[0]+P9_f[0])-(P1_f[0]+2*P4_f[0]+P7_f[0]);
				
				Double Pout_f = Math.sqrt(Px*Px+Py*Py);
				Pout_int[0] = Math.min(Pout_f.intValue(),255);
				sobelWritableRaster_f.setPixel(j,i,Pout_int);
			}
		}
		return sobelWritableRaster_f;
	}
	public Raster SobelInteger(Raster image)
	{/*
		out.writeInt(
		Math.min(
		Math.abs( (P1+2*P2+P3)-(P7+2*P8+P9) )+
		Math.abs( (P3+2*P6+P9)-(P1+2*P4+P7) )
		,255)
		);*/
		WritableRaster sobelWritableRaster =image.createCompatibleWritableRaster();
		int[] P1 = {0};
		int[] P2 = {0};
		int[] P3 = {0};
		int[] P4 = {0};
		int[] P6 = {0};
		int[] P7 = {0};
		int[] P8 = {0};
		int[] P9 = {0};
		
		int[] Pout = {0};
		
		for(int i=0; i<image.getHeight();i++)
		{
			for(int j=0; j<image.getWidth()-1;j++)
			{
				int jLeft = j-1;
				int jRight = j+1;
				if(j==0)
					jLeft = 0;
				if(j==image.getWidth()-1)
					jRight = j;
				
				int iTop = i-1;
				int iBottom = i+1;
				if(i==0)
					iTop = 0;
				if(i==image.getHeight()-1)
					iBottom = i;
				
				image.getPixel(jLeft , iBottom ,P1);
				image.getPixel(j     , iBottom ,P2);
				image.getPixel(jRight, iBottom ,P3);
				image.getPixel(jLeft , i       ,P4);
				//SobelRaster.getPixel(j+0,i+0,P4);
				image.getPixel(jRight ,i       ,P6);
				image.getPixel(jLeft  ,iTop    ,P7);
				image.getPixel(j      ,iTop    ,P8);
				image.getPixel(jRight ,iTop    ,P9);
				Pout[0] =
				Math.min(
					Math.abs( (P1[0]+2*P2[0]+P3[0])-(P7[0]+2*P8[0]+P9[0]) )+
					Math.abs( (P3[0]+2*P6[0]+P9[0])-(P1[0]+2*P4[0]+P7[0]) )
					,255);
				sobelWritableRaster.setPixel(j,i,Pout);
			}
		}
		return sobelWritableRaster;
	}
	public Raster Threashold(Raster image,int value)
	{
		WritableRaster threasholdWritableRaster =image.createCompatibleWritableRaster();
		for(int y=0;y<image.getHeight();y++)
		{
			for(int x=0; x<image.getWidth();x++)
			{
				int [] iArray = {0};
				int[] zeros = {0};
				int[] ones = {255};
				image.getPixel(x, y, iArray);
				if((iArray[0])>value)
					threasholdWritableRaster.setPixel(x, y, ones);
				else
					threasholdWritableRaster.setPixel(x, y, zeros);
			}
		}
		return threasholdWritableRaster;
	}
	public Raster Hough(Raster image)
	{
		int [] pixel={0};
		int image_max_radius = (int)(image.getWidth()*Math.sqrt(2.0)+image.getHeight()*Math.sqrt(2.0));
		int normalized_max_radius = 128;//512;//1024;
		int normalized_max_angle = 128;//512;//1280;
		int [][] accumulator = new int[normalized_max_angle][normalized_max_radius];
		int accumulator_max=0;
		for(int y=0;y<image.getHeight();y++)
		{
			for(int x=0;x<image.getWidth();x++)
			{
				pixel = image.getPixel(x, y, pixel);
				if(pixel[0]==255)
				{
					for(int this_angle=0;this_angle<normalized_max_angle;this_angle++)
					{
						double angle_rad = ((double)this_angle)/normalized_max_angle*Math.PI;
						double this_radius = x*Math.cos(angle_rad)+y*Math.sin(angle_rad);
						double normalized_radius = this_radius/image_max_radius*normalized_max_radius+normalized_max_radius/2;
						if(normalized_radius<normalized_max_radius && normalized_radius>=0)
						{
							//System.out.println("("+ x +","+y+")angle:"+this_angle+" radius:"+this_radius +" normalized radius:"+normalized_radius);
							accumulator[this_angle][(int)normalized_radius]++;
							if(accumulator[(int)this_angle][(int)normalized_radius]>accumulator_max)
								accumulator_max=accumulator[(int)this_angle][(int)normalized_radius];
							/*if(accumulator[(int)this_angle][(int)normalized_radius]<accumulator_min)
								accumulator_max=accumulator[(int)this_angle][(int)normalized_radius];*/
						}
						else
							System.out.println("too big("+ x +","+y+")angle:"+this_angle+" radius:"+this_radius +" normalized radius:"+normalized_radius);
					}
				}
			}
		}
		//System.out.println(accumulator_max);
		WritableRaster Hough_image = image.createCompatibleWritableRaster(normalized_max_angle,normalized_max_radius);
		for(int y=0;y<normalized_max_radius;y++)
			for(int x=0;x<normalized_max_angle;x++)
			{
				pixel[0] = (int)((double)accumulator[y][x]/accumulator_max*255);
				Hough_image.setPixel(x, y, pixel);
			}
		return Hough_image;
	}
	public Raster deHough(Raster hough_image,int threashold)
	{
		WritableRaster deHough_image = bi.getRaster().createCompatibleWritableRaster();
		double max_radius_deHough =
						deHough_image.getHeight()*Math.sqrt(2.0)
						+deHough_image.getWidth()*Math.sqrt(2.0);
		double max_radius_hough = hough_image.getHeight()/2; 
		int r=45;
		int a=45;
		int i = 0xaa;
		/*
		for(a=0;a<180;a+=10)
		lineDraw(
				max_radius_normal/4,
				a*3.14159/180,
				deHough_image,
				i+a*2);
		
		for(r=0;r<max_radius_deHough/2;r+=10)
		lineDraw(
				r,
				a*3.14159/180,
				deHough_image,
				i);//+r*2);
		*/
		
		 
		//System.out.println("**max-radius_normal: "+ max_radius_deHough+", max_radius_hough: "+max_radius_hough);
		//System.out.println("90:"+Math.PI/2);
		for(a=0;a<hough_image.getWidth();a++)
			for(r=0;r<hough_image.getHeight();r++)
			{
				int[] intensity  ={0};
				hough_image.getPixel(r, a, intensity);
				if(intensity[0]>threashold)
				{
					double radius =  (r-max_radius_hough)*max_radius_deHough/max_radius_hough/2;
					double angle =  a*Math.PI/(double)hough_image.getWidth();
					//System.out.println( "r:"+r+" -> radius: " + radius +", a:"+a+" -> angle: " + angle +" intensity: "+intensity[0]);
					lineDraw(radius,angle,deHough_image,intensity[0]);
				}
			}
		return deHough_image;
	}
	
	public void lineDraw(double radius, double angle, WritableRaster image, int intensity)
	{
		int[] pix={0};
		int [] point = new int[2];
		float m, b;
		if (angle < 45.0/180.0*Math.PI)//more vertical
		{
			//first half
			point = getStartPoint(radius, angle);
			m = (float)(1/Math.tan(angle+Math.PI/2));
			b = point[0] - m*point[1];
			while (
					point[0]<image.getWidth() &&
					point[1]<image.getHeight() &&
					point[1]>=0 &&
					point[0]>=0
					)//while in the image
			{
				//System.out.println("("+point[0]+","+point[1]+") m: "+m+" b:"+b);
				image.getPixel(point[0], point[1], pix);
				pix[0] = Math.min(intensity+pix[0],255);
				image.setPixel(point[0], point[1], pix);
				point[1] += 1;// go down one
				point[0] = Math.round(m*point[1] + b);
			}
			//other half
			point = getStartPoint(radius, angle);
			point[1]-=1;//already done go up 1
			point[0] = Math.round(m*point[1] + b);
			while (
					point[0]<image.getWidth() &&
					point[1]<image.getHeight()&&
					point[1]>=0 &&
					point[0]>=0
					)
			{
				//System.out.println("("+point[0]+","+point[1]+") m: "+m+" b:"+b);
				image.getPixel(point[0], point[1], pix);
				pix[0] = Math.min(intensity+pix[0],255);
				image.setPixel(point[0], point[1], pix);
				point[1] -= 1;//go up
				point[0] = Math.round(m*point[1] + b);
			}
		}
		else if(angle<120.0*3.14259/180.0)
		{
			point = getStartPoint(radius, angle);
			m = (float)Math.tan(angle+Math.PI/2);
			b = point[1] - m*point[0];
			while((point[0]<0 || point[1]<0)
					&&
					(point[0] < image.getWidth()&&
					point[1] < image.getHeight()))//give up if not in image anymore
			{
				//System.out.println("("+point[0]+","+point[1]+") m: "+m+" b:"+b);
				point[0] += 1;
				point[1] = Math.round(m*point[0]+b);
			}
			while (point[0] < image.getWidth()&&
					point[1] < image.getHeight()&&
					point[1]>=0 &&
					point[0]>=0
					)
			{
				//System.out.println("("+point[0]+","+point[1]+") m: "+m+" b:"+b);
				image.getPixel(point[0], point[1], pix);
				pix[0] = Math.min(intensity+pix[0],255);
				image.setPixel(point[0], point[1],pix);
				point[0] += 1;
				point[1] = Math.round(m*point[0]+b);
			}
			point = getStartPoint(radius, angle);
			point[0] -= 1;//already done
			point[1] = Math.round(m*point[0]+b);
			while (point[0] < image.getWidth() &&
					point[1] < image.getHeight() &&
					point[1]>=0 &&
					point[0]>=0
					)
			{
				//System.out.println("("+point[0]+","+point[1]+")");
				image.getPixel(point[0], point[1], pix);
				pix[0] = Math.min(intensity+pix[0],255);
				image.setPixel(point[0], point[1],pix);
				point[0] -= 1;
				point[1] = Math.round(m*point[0]+b);
			}
		}
		else if (angle < 3.14159)//more vertical
		{
			//first half
			point = getStartPoint(radius, angle);
			m = (float)(1/Math.tan(angle+Math.PI/2));
			b = point[0] - m*point[1];
			//System.out.println("("+point[0]+","+point[1]+") m: "+m+" b:"+b);
			while(point[0]<0 || point[1]<0
					&&
					(point[0] < image.getWidth()&&
					point[1] < image.getHeight()))
			{
				//point[0] += 0;
				//point[1] = Math.round((m*point[0])+b1);

				point[1] += 1;// go down one
				point[0] = Math.round(m*point[1] + b);
			}
			//System.out.println("("+point[0]+","+point[1]+") m: "+m+" b:"+b);
			while (
					point[0]<image.getWidth() && point[1]<image.getHeight()
					&&
					point[1]>=0 && point[0]>=0
					)//while in the image
			{
				//System.out.println("("+point[0]+","+point[1]+") m: "+m+" b:"+b);
				image.getPixel(point[0], point[1], pix);
				pix[0] = Math.min(intensity+pix[0],255);
				image.setPixel(point[0], point[1], pix);
				point[1] += 1;// go down one
				point[0] = Math.round(m*point[1] + b);
			}
		}
	}
	public int[] getStartPoint(double r, double a)
	{
		int[] point = new int[2];
		point[0]=(int)(r*Math.cos(a));//x
		point[1]=(int)(r*Math.sin(a));//y
		return point;
	}
	
	
	public void SetImage(BufferedImage B)
	{
		bi = B;
		setOpIndex(0);
		repaint();
	}
	
	public Dimension getPreferredSize()
	{
		//if(w>512 || h>512)
			return new Dimension(512,512);
		//else
		//	return new Dimension(w, h);
	}

	String[] getDescriptions(){return descs;}
	
	void setOpIndex(int i) { opIndex = i;}
	
	public void paint(Graphics g)
	{
		filterImage();
		g.drawImage(biFiltered, 0, 0, null);
	}
	
	int lastOp;
	public void filterImage()
	{
		//BufferedImageOp op = null;
		Raster image;
		
		if (opIndex == lastOp)
			return;
		lastOp = opIndex;
		switch (opIndex)
		{
			case 0:
				biFiltered = bi; /* original */
				w = 512;
				h = 512;
				return;
			case 1 ://pixelValue is pixel location - ish
				w = 0x10;
				h = 0x10;
				WritableRaster sobelWritableRaster_1 = bi.getRaster().createCompatibleWritableRaster(w,h);
				int[] Pout_int_1 = {0};
				
				for(int i=0; i<sobelWritableRaster_1.getHeight();i++)
				{
					for(int j=0; j<sobelWritableRaster_1.getWidth();j++)
					{
						Pout_int_1[0] = (i+1)<<4|(j+1);
						sobelWritableRaster_1.setPixel(j,i,Pout_int_1);
					}
				}
				biFiltered = new BufferedImage(w,h, BufferedImage.TYPE_BYTE_GRAY);
				biFiltered.setData(sobelWritableRaster_1);
				return;
			case 2://sobel float
				biFiltered = new BufferedImage(w,h, BufferedImage.TYPE_BYTE_GRAY);
				biFiltered.setData(SobelFloat(bi.getRaster()));
				return;
			case 3://sobel Aproximate
				biFiltered = new BufferedImage(w,h, BufferedImage.TYPE_BYTE_GRAY);
				biFiltered.setData(SobelInteger(bi.getRaster()));
				return;
			case 4://threashold
				biFiltered = new BufferedImage(w,h, BufferedImage.TYPE_BYTE_GRAY);
				biFiltered.setData(Threashold(bi.getRaster(),0xfe));
				return;
			case 5://sobel threashold
				biFiltered = new BufferedImage(w,h, BufferedImage.TYPE_BYTE_GRAY);
				biFiltered.setData(Threashold(SobelInteger(bi.getRaster()),0xaa));
				return;
			case 6://hough
				image = Hough(Threashold(SobelInteger(bi.getRaster()),0xaa));
				biFiltered = new BufferedImage(image.getWidth(),image.getHeight(), BufferedImage.TYPE_BYTE_GRAY);
				biFiltered.setData(image);
				return;
			case 7://dehough
				image = deHough(Hough(Threashold(SobelInteger(bi.getRaster()),0xaa)),0xc0);
				biFiltered = new BufferedImage(image.getWidth(),image.getHeight(), BufferedImage.TYPE_BYTE_GRAY);
				biFiltered.setData(image);
				return;
		}
	}

	/* Return the formats sorted alphabetically and in lower case */
	public String[] getFormats()
	{
		String[] formats = ImageIO.getWriterFormatNames();
		TreeSet<String> formatSet = new TreeSet<String>();
		for (String s : formats)
			formatSet.add(s.toLowerCase());
		return formatSet.toArray(new String[0]);
	}

	public void actionPerformed(ActionEvent e)
	{
		JComboBox cb;
		if ("SetFilter".equals(e.getActionCommand()))
		{
			cb = (JComboBox)e.getSource();
			setOpIndex(cb.getSelectedIndex());
			repaint();
		}
		else if ("Formats".equals(e.getActionCommand()))
		{
			cb = (JComboBox)e.getSource();
			/* Save the filtered image in the selected format.
			* The selected item will be the name of the format to use
			*/
			String format = (String)cb.getSelectedItem();
			/* Use the format name to initialise the file suffix.
			* Format names typically correspond to suffixes
			*/
			File saveFile = new File("*"+w+"x"+h+"."+format);
			JFileChooser chooser = new JFileChooser();
			chooser.setSelectedFile(saveFile);
			int rval = chooser.showSaveDialog(cb);
			if (rval == JFileChooser.APPROVE_OPTION)
			{
				saveFile = chooser.getSelectedFile();
				/* Write the filtered image in the selected format,
				* to the file chosen by the user.
				*/
				try
				{
					if(format.equalsIgnoreCase("ambricFile"))
					{
						BufferedWriter data = new BufferedWriter(new FileWriter(saveFile));
						Raster raster = bi.getRaster();
						//data.write("#"+w+"x"+h+"\n");
						for(int i=0;i<h;i++)
						{

							Boolean packed=false;
							if(packed)
							{
								//data.write("#new img line "+(i+1)+"\n");
								for(int j=0; j<w;j+=4)//write out 4 at a time
								{
									data.write("0");//lead 0
									for(int k=0;k<4;k++)
									{
										
										int[] pixel={0};
										raster.getPixel(j+k, i, pixel);
										
										if(pixel[0]<0x10)
											data.write("0");
										data.write(Integer.toHexString(pixel[0]));
									}
									data.write("\r\n");//windows line ending
								}
							}
							else//not packed
							{
//								data.write("#new img line "+(i+1)+"\n");
								for(int j=0; j<w;j++)//write out 1 at a time
								{
									data.write("0000000");//lead 0+3 bytes of zeros
									int[] pixel={0};
									raster.getPixel(j, i, pixel);
									
									if(pixel[0]<0x10)
										data.write("0");
									data.write(Integer.toHexString(pixel[0]));
									
									data.write("\r\n");//windows line ending
								}
							}
						}
						data.close();
					}
					else if(format.equalsIgnoreCase("javaArray"))
					{
						BufferedWriter data = new BufferedWriter(new FileWriter(saveFile));
						Raster img = biFiltered.getRaster();
						data.write("int width="+img.getWidth()+";\n");
						data.write("int height="+img.getHeight()+";\n");
						
						data.write("\tint[][] img=new int[][]{\n");
						for(int y=0; y<img.getHeight();y++)
						{
							data.write("\t\t{");
							for(int x=0; x<img.getWidth()-1;x+=4)
							{
								int[] pixels = {0,0,0,0};
								img.getPixels(x ,y ,4,1,pixels);
								data.write(" 0x");
								if(pixels[0]<0x10)
									data.write("0");
								data.write(Integer.toHexString(pixels[0]));
								if(pixels[1]<0x10)
									data.write("0");
								data.write(Integer.toHexString(pixels[1]));
								if(pixels[2]<0x10)
									data.write("0");
								data.write(Integer.toHexString(pixels[2]));
								if(pixels[3]<0x10)
									data.write("0");
								data.write(Integer.toHexString(pixels[3]));
								data.write(",");
							}
							data.write("},\n");
						}
						data.write("};");
						data.close();
					}
					else
					ImageIO.write(biFiltered, format, saveFile);
				}
				catch (IOException ex){}
			}
		}
		else if("Import".equals(e.getActionCommand()))
		{
			JButton button = (JButton)e.getSource();
			File openFile = new File("*.ambricFile");
			JFileChooser chooser = new JFileChooser();
			chooser.setSelectedFile(openFile);
			int rval = chooser.showOpenDialog(button);
			if (rval == JFileChooser.APPROVE_OPTION)
			{
				openFile = chooser.getSelectedFile();
				/* Write the filtered image in the selected format,
				* to the file chosen by the user.
				*/
				try
				{
					String getWidth = widthField.getText();
					w = Integer.valueOf(getWidth);
					String getHeight = heightField.getText();
					h = Integer.valueOf(getHeight);
					FileInputStream data = new FileInputStream(openFile);
					BufferedImage buffered_image = new BufferedImage (w, h, BufferedImage.TYPE_BYTE_GRAY);
					
					Raster raster = buffered_image.getRaster();
					WritableRaster writableRaster = raster.createCompatibleWritableRaster();
					int [] Pixel = {0};
					for(int i=0;i<h;i++)
					{
						int bytes_per_line=1;
						for(int j=0;j<w;j+=bytes_per_line)//4 bytes per line
						{
							//data.skip(1);
							int lineStart = data.read();
							while(lineStart == 35)//#
							{
								while((data.read())!=0xD){}//\r
								data.skip(1);//\n
								lineStart = data.read();
							}
							//if(lineStart!=48)//"0" // should be the lead zero
							//	System.out.println("off at ("+i+","+j+")");
							if(bytes_per_line==4)
							{
								for(int k=0;k<4;k++)
								{
									int char1 = data.read();
									//System.out.print("("+(j+k)+","+i+") %% "+char1+" ** ");
									// ascii-hex to binary
									if(char1>47&&char1<(58))//0-9
										char1=char1-48;
									else if(char1>64&&char1<71)//A-F
										char1=char1-64+9;
									else// if(char1>96)//a-f  shouldn't be anything past F
										char1=char1-96+9;
									int char2 = data.read();
									// ascii-hex to binary
									if(char2>47&&char2<(58))//0-9
										char2 =char2-48;
									else if(char2>64&&char2<71)//A-F
										char2=char2-64+9;
									else// if(char2>64)//a-  shouldn't be anything past F
										char2=char2-96+9;
									
									Pixel[0] = char1<<4|char2;
									//System.out.println(char1+" ^^ " + char2 +" !! "+Pixel[0]);
									writableRaster.setPixel(j+k,i,Pixel);
									//imgOut.write(char1<<4|char2);
								}
							}
							else
							{
								data.skip(6);
								int char1 = data.read();
								//System.out.print("("+(j)+","+i+") %% "+char1+" ** ");
								// ascii-hex to binary
								if(char1>47&&char1<(58))//0-9
									char1=char1-48;
								else if(char1>64&&char1<71)//A-F
									char1=char1-64+9;
								else// if(char1>96)//a-f  shouldn't be anything past F
									char1=char1-96+9;
								int char2 = data.read();

								//System.out.print(char2+" ** ");
								// ascii-hex to binary
								if(char2>47&&char2<(58))//0-9
									char2 =char2-48;
								else if(char2>64&&char2<71)//A-F
									char2=char2-64+9;
								else// if(char2>64)//a-  shouldn't be anything past F
									char2=char2-96+9;
								
								Pixel[0] = char1<<4|char2;
								//System.out.println(Pixel[0]);
								writableRaster.setPixel(j,i,Pixel);
							}
							//int lineEnd = data.read();
							data.skip(2);
							//skip newline carrage return
						}
					}
					data.close();
					buffered_image.setData(writableRaster);
					SetImage(buffered_image);
				}
				catch (IOException ex){}
			}
		}
	}

	public static void main(String s[])
	{
		JFrame f = new JFrame("Ambric Data Converter");
		f.addWindowListener(new WindowAdapter() {
		public void windowClosing(WindowEvent e) {System.exit(0);}});
		AmbricDataConverter si = new AmbricDataConverter();
		f.add("Center",si);
		f.pack();
		f.setVisible(true);
	}
}
