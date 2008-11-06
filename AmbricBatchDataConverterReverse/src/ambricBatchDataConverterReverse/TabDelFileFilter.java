package ambricBatchDataConverterReverse;

import java.io.File;
import javax.swing.filechooser.*;

public class TabDelFileFilter extends FileFilter
{
	//Accept all directories and all gif, jpg, tiff, or png files.
	public boolean accept(File f) {
		if (f.isDirectory())
		{
			return true;
		}
		
		
		String extension = null;
        String s = f.getName();
        int i = s.lastIndexOf('.');

        if (i > 0 &&  i < s.length() - 1) {
        	extension = s.substring(i+1).toLowerCase();
        }
        //System.out.println(extension);
		if (extension != null)
		{
			return extension.equals("tab_delimited");
		}
		
		return false;
	}

	//The description of this filter
	public String getDescription()
	{
		return "tab_delimited File";
	}
}
