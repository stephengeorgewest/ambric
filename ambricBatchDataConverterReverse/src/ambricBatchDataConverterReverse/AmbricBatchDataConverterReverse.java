package ambricBatchDataConverterReverse;

import java.io.*;
/*
import java.util.TreeSet;
import java.util.LinkedList;
import java.awt.*;
import java.awt.event.*;
import java.awt.image.*;

import javax.imageio.*;
*/
import javax.swing.*;

public class AmbricBatchDataConverterReverse
{
	public static void main(String[] s) throws IOException, NumberFormatException
	{
		//InputStreamReader converter = new InputStreamReader(System.in);
		//BufferedReader in = new BufferedReader(converter);
		
		/*
		String folder = "\\Derivitive";
		int width=316-4;//yos
		int height=252-4;//yos
		/**/
		
		/*
		String folder = "\\Smooth_d";
		int width=316-8;//yos
		int height=252-8;//yos
		/**/
		
		/*
		String folder = "\\Outer_Product";
		int width=316-8;//yos
		int height=252-8;//yos
		/**/
		
		/*
		String folder = "\\Smooth_op";
		int width=316-10;//yos
		int height=252-10;//yos
		/**/
		
		/*
		String folder = "\\Velocity";
		int width=316-10;//yos
		int height=252-10;//yos
		/**/
		
		
		String folder = "\\Smooth_v";
		//String folder = "";
		int width=316-16;//yos
		int height=252-16;//yos
		/**/
		
		//JOptionPane options = new JOptionPane();
		String str="";
		str = JOptionPane.showInputDialog("Width = "+width);
		if(str.length()>0)
			width=Integer.parseInt(str);
		str = JOptionPane.showInputDialog("Height = "+height);
		if(str.length()>0)
			height=Integer.parseInt(str);
		
		//JOptionPane again = new JOptionPane();
		JOptionPane.showMessageDialog(null,"Width="+width+" Height="+height,"You choose",2);
		
		
		
		JFileChooser chooser = new JFileChooser();
		File openFile = new File("*.ambricFile");
		
		chooser.setSelectedFile(openFile);
		chooser.setFileFilter(new AmbricFileFilter());
		chooser.setCurrentDirectory(new File("C:\\Documents and Settings\\stephen\\My Documents\\workspace\\Optical Flow\\Output"+folder));
		//chooser.setCurrentDirectory(new File("C:\\Documents and Settings\\stephen\\My Documents\\workspace\\ambricBatchDataConverterReverse\\src\\ambricBatchDataConverterReverse"));
		
		int rval = chooser.showOpenDialog(null);
		if (rval == JFileChooser.APPROVE_OPTION)
		{
			File chooserFile = chooser.getSelectedFile();
			//System.out.println(chooserFile.toString());
			int chooserFile_length=0;
			File saveFile = new File("*"+width+"x"+height+"x"+chooserFile_length+".tab_delimited");
			JFileChooser savechooser = new JFileChooser();
			savechooser.setFileFilter(new TabDelFileFilter());
			savechooser.setSelectedFile(saveFile);
			savechooser.setCurrentDirectory(new File("C:\\Documents and Settings\\stephen\\My Documents\\workspace\\Optical Flow\\Output"+folder));
			//savechooser.setCurrentDirectory(new File("C:\\Documents and Settings\\stephen\\My Documents\\workspace\\ambricBatchDataConverterReverse\\src\\ambricBatchDataConverterReverse"));
			
			savechooser.setApproveButtonText("Save");
			rval = savechooser.showOpenDialog(null);
			
			if (rval == JFileChooser.APPROVE_OPTION)
			{
				saveFile = savechooser.getSelectedFile();
				BufferedWriter data_out = new BufferedWriter(new FileWriter(saveFile));
				//data.write("#"+w+"x"+h+"\n");
				
				FileInputStream data_in = new FileInputStream(chooserFile);
				//
				//data_out.write("#file = " + chooserFile+"\r\n");
				byte[] line={0,0,0,0,0,0,0,0};
				int data_read=data_in.read();//remove de bit
				while(data_read==35)
				{
					while(!(data_read==10 || data_read==13))
					{
						data_read=data_in.read();
						//System.out.println("data_read "+data_read);
					}
					while(data_read==10 || data_read==13)
					{
						data_read=data_in.read();
						//System.out.println("data_read "+data_read);
					}//remove cr, nl, de bit the last data_in.read(); should be DE bit
					
				}
				
				
				int w=0,h=0,t=0;
				while(data_in.read(line)==8)// && t==0)
				{
					//figure out the sign, because .valueOf looks for a leading "-" instead of a "ffff ffff"
					//System.out.println(""+new String(line,"US-ASCII"));
					
					String sign="";
					
					if(line[0]>=97)//lower case
					{
						sign="-";
						line[0]-=(97-50);//difference between ascii 2 and ascii a
					}
					if(line[0]>=65)//lower case
					{
						sign="-";
						line[0]-=(65-50);//difference between ascii 2 and ascii A
					}
					if(line[0]>=56)//8-9
					{
						sign="-";
						//System.out.println(new String(line,"US-ASCII"));
						line[0]-=(56-48);//difference between ascii 0 and ascii A
						//System.out.println(new String(line,"US-ASCII"));
						//System.out.println();
					}
					//
					//System.out.println(""+line.length);
					//for(int i=0;i<line.length;i++)
					int value=Integer.valueOf(new String(line,"US-ASCII"),16).intValue();
					
					String value_str;
					if(sign.equals("-"))
					{
						if(value==0)
						{
							value_str=Integer.MIN_VALUE+"";
						}
						else
						{
							value=Integer.MIN_VALUE+value;
							
							
							value_str=""+(-value);
							
							while(value_str.length()<10)
								value_str="0"+value_str;
							value_str="-"+value_str;
						}
						//if(value>0){System.out.println(value_str+"\n");
						//	return;}
					}
					else
					{
						value_str=""+value;
						while(value_str.length()<10)
							value_str="0"+value_str;
						value_str="0"+value_str;
					}
					//System.out.println(value_str+"\n");
					data_out.write(value_str+"\t");
					w++;
					if(w>=width)
					{
						w=0;
						h++;
						data_out.write("\n");
					}
					if(h>=height)
					{
						h=0;
						t++;
						data_out.write("\n");
						//data_out.write("newthingy");
					}
					
					data_read=data_in.read();
					while(data_read==10 || data_read==13)
					{
						data_read=data_in.read();
						//System.out.println("data_read "+data_read);
					}//remove cr, nl, de bit the last data_in.read(); should be DE bit
					if(data_read==35)
					{
						while(!(data_read==10 || data_read==13))
						{
							data_read=data_in.read();
							//System.out.println("data_read "+data_read);
						}//remove cr, nl, de bit the last data_in.read(); should be DE bit
						while(data_read==10 || data_read==13)
						{
							data_read=data_in.read();
							//System.out.println("data_read "+data_read);
						}//remove cr, nl, de bit the last data_in.read(); should be DE bit
						
					}
						
				}
				System.out.println(width+"x"+height+"x"+t+"\nleftover height="+h+"  width="+w);
				data_out.close();
			}
		}
	}
}
