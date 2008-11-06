package ambricBatchDataConverter;

import java.io.*;
import javax.swing.*;

public class AmbricBatchDataConverter
{
	public static void main(String[] s) throws IOException, NumberFormatException
	{
		int width=316;//yos
		int height=252;//yos
		String str="";
		str = JOptionPane.showInputDialog("Width = "+width);
		if(str.length()>0)
			width=Integer.parseInt(str);
		str = JOptionPane.showInputDialog("Height = "+height);
		if(str.length()>0)
			height=Integer.parseInt(str);
		
		JOptionPane.showMessageDialog(null,"Width="+width+" Height="+height,"You choose",2);
		/*
		int width=352;//flower
		int height=240;//flower*/
		/*
		LinkedList<BufferedImage> files=new LinkedList<BufferedImage>();
		LinkedList<String> fileNames=new LinkedList<String>();
		
		System.out.println("s.length "+s.length);
		//InputStreamReader cin = new InputStreamReader(System.in);
		for( int i=0; i<s.length; i++)
		{
			System.out.println(s[i]);try
			{
				BufferedImage bi = ImageIO.read(new File(s[i]));
				files.add(bi);
				fileNames.add(s[i]);
				if(bi==null)
				{
					System.out.println("bi==null");
				}
				//System.out.println("added " +bi.toString()+"\n\n\n");//getWidth() +" " +bi.getHeight()+"\n\n");
			}
			catch (IOException e)
			{
				System.out.println("Image could not be read - " + s[i]);
				//System.exit(1);
			}
		}*/
		
		System.out.println("\n\n yosemite default width="+width+" height="+height);
		File openFile = new File("*.raw");
		JFileChooser chooser = new JFileChooser();
		chooser.setSelectedFile(openFile);
		chooser.setCurrentDirectory(new File("C:\\Documents and Settings\\stephen\\Desktop\\OpticalFlow2008\\opticalflow\\images\\raw yos sequence"));
		chooser.setMultiSelectionEnabled(true);
		int rval = chooser.showOpenDialog(null);
		if (rval == JFileChooser.APPROVE_OPTION)
		{
			File[] chooserFiles = chooser.getSelectedFiles();
			for(int i=0; i<chooserFiles.length;i++)
				System.out.println(chooserFiles[i].toString());
			
			File saveFile = new File("*"+width+"x"+height+"x"+chooserFiles.length+".ambricFile");
			JFileChooser savechooser = new JFileChooser();
			savechooser.setSelectedFile(saveFile);
			savechooser.setApproveButtonText("Save");
			rval = savechooser.showOpenDialog(null);
			if (rval == JFileChooser.APPROVE_OPTION)
			{
				saveFile = savechooser.getSelectedFile();
				BufferedWriter data_out = new BufferedWriter(new FileWriter(saveFile));
				//data.write("#"+w+"x"+h+"\n");
				for(int t=0; t<chooserFiles.length;t++)
				{
					FileInputStream data_in = new FileInputStream(chooserFiles[t]);
					data_out.write("#file = " + chooserFiles[t]+"\r\n");
					
					for(int i=0;i<height;i++)
						for(int j=0; j<width;j++)//write out 1 at a time
						{
							data_out.write("0000000");//lead 0+3 bytes of zeros
							int pixel = data_in.read();
							
							if(pixel<0x10)
								data_out.write("0");
							data_out.write(Integer.toHexString(pixel));
							
							data_out.write("\r\n");//windows line ending
						}
				}
				data_out.close();
			}
			
		}
		/*
		String a="";
		System.out.println("width or height or done");
		a=in.readLine();
		
		while(!a.equals("done"))
		{
			if(a.equals("width"))
				width=Integer.valueOf(in.readLine()).intValue();
			if(a.equals("height"))
				height=Integer.valueOf(in.readLine()).intValue();
			//dostuff
			
			System.out.println("width or height or done");
			a=in.readLine();
		}
		*/
		
		
		
	}
}
