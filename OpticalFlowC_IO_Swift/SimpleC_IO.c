/*
 ============================================================================
 Name        : OpticalFlowC_IO.c
 Author      : 
 Version     :
 Copyright   : Your copyright notice
 Description : Hello World in C, Ansi-style
 ============================================================================
 */

#include <stdio.h>
#include <stdlib.h>
#include <swift.h>
#include <windows.h>// needed for Sleep(millisec);
#include <time.h>
int data_size=1000;
int main(int argc, char *argv[])
{
	/*puts("Starting up\n");*/
	//puts(argv[0]);
	if(argc==1)
	{
		puts("Needs a single number < 10");
		return -1;
	}
	int add_val=(int)argv[1][0]-48;
	//printf("val %d", add_val);
	char* lib_ver = swift_library_version();
	//printf("Using library version %s\n",lib_ver);
	//printf("\t%s\n",swift_lib_version_number());
	//int swift_device_count(int trans_type);
	/*int count = swift_device_count(SWIFT_PCIE);
	printf("%d pcie devices found\n",count);
	count = swift_device_count(SWIFT_USB);
	printf("%d usb devices found\n",count);*/
	//swift_handle swift_open(int trans_type, int device_id, int exclusive flag);
	swift_handle h = swift_open(SWIFT_PCIE, 0,0);
	if(h!=0)
	{
		//printf("Using Driver Version %s\n",swift_driver_version(h));
		/*int driver_ver[4];
		swift_driver_version_number(h,&driver_ver[0],&driver_ver[1],&driver_ver[2],&driver_ver[3]);
		printf("\tmajor-%d, minor-%d, rev-%d, build-%d\n",driver_ver[0],driver_ver[1],driver_ver[2],driver_ver[3] );
		puts("Opened first pcie device\n");
		*/
		
		int reset_val = swift_reset(h);
		if(reset_val==0)
		{
			//puts("Device reset\n");
			
			char* config=(char*)(malloc(1024*1024*16*sizeof(char)));//[1024*1024*16]; // Up to 16 Megabyte configuration file
			//puts("Config malloced");
			FILE *f;
			int i = 0;
			int ch;
			f = fopen("Simple.cfg", "r");
			while ((ch = fgetc(f)) != EOF)
				config[i++] = ch;
			config[i] = '\0';
			fclose(f);
			
			clock_t config_start_time = clock();
			int config_val = swift_load_config(h, config, 0);
			clock_t config_stop_time = clock();
			if(config_val==0)
			{
				int run_time = (config_stop_time-config_start_time)*CLOCKS_PER_SEC/1000;
				/*puts("Device configured");
				printf("\tConfig %d bytes long\n",i);
				printf("\tConfig time = %dms\n\n",run_time);
				*/
				int data[data_size];
				data[0]=-add_val;
				//data[1]=add_val;
				for(i=1;i<data_size;i++)
				{
					data[i]=i;
					//Sleep(100);
				}
				if(data_size>SWIFT_MAX_IO_WORDS)
					puts("Write is too big");
				
				clock_t write_start_time = clock();
				int write_handle = swift_write_async(h,data,data_size,0,SWIFT_CHANNEL0);
				if(!(write_handle==0 | write_handle==-1))
				{
					//Sleep(1000);
					int Add5[data_size];
					int Inv[data_size];
					for(i=0; i<data_size;i++)
					{
						Add5[i]=0;
						Inv[i]=0;
					}
					int read_handle_x = swift_read_async(h, Add5, data_size, 0, SWIFT_CHANNEL0);
					if(read_handle_x==0)
						puts("broken read x");
					int read_handle_y = swift_read_async(h, Inv, data_size, 0, SWIFT_CHANNEL1);
					if(read_handle_y==0)
						puts("broken read y");
						
						
					int write_done = swift_check_async(h, write_handle);
					if(write_done==-1)
						puts(swift_get_last_error_string());
					while(write_done==0)
					{
						write_done=swift_check_async(h, write_handle);
						if(write_done==-1)
							puts(swift_get_last_error_string());
						//printf(".");
						 Sleep(10);
					}
					int write_size = swift_wait_async(h, write_handle);
					clock_t write_stop_time = clock();
					int write_time = (write_stop_time - write_start_time)*CLOCKS_PER_SEC/1000;
					/*
					puts("Write done");
					printf("\t%d words written \n",write_size);
					printf("%\tWrite time = %dms\n",write_time);
					*/
					//swift_wait_async_timeout(h, write_handle,100);
					//swift_wait_async(h, read_handle_x);
					/*
					int read_size = swift_wait_async_timeout(h, read_handle_x,100);
					printf("num read %d", read_size);
					if(read_size<0)
						puts(swift_get_last_error_string());
					*/
					int read_x_done = swift_check_async(h, read_handle_x);
					int read_y_done = swift_check_async(h, read_handle_y);
					int num_x_read=-1;
					int num_y_read=-1;
					int time=0;
					if(read_x_done==-1 || read_y_done ==-1)
						puts(swift_get_last_error_string());
					while(read_x_done == 0 || read_y_done ==0)
					{
						if(read_x_done==1&&num_x_read!=-1)
						{
							num_x_read = swift_wait_async(h, read_handle_x);
							//printf("Add5 done %d",num_x_read);
						}
						else
							read_x_done = swift_check_async(h, read_handle_x);
						
						if(read_y_done==1&&num_y_read!=-1)
						{
							num_y_read = swift_wait_async(h, read_handle_y);
							//printf("Inv done %d",num_y_read);
						}
						else
						{
							read_y_done = swift_check_async(h, read_handle_y);
							
						}
						
						//printf(".");
						Sleep(100);
						time++;
						if(time>30)
						{
							//puts("Nothing has happened for a while. Aborting read.");
							int ch1 = swift_channel_abort(h, SWIFT_CHANNEL0, SWIFT_CHANNEL_READ);
							int ch2 = swift_channel_abort(h, SWIFT_CHANNEL1, SWIFT_CHANNEL_READ);
							if(ch1|ch2)
								puts(swift_get_last_error_string());
							else
								//puts("Aborted");
							break;
						}
					}
					//puts("Read done");
					//int words_skipped[data_size];
					int j;
					//printf("\n");
					for(i=0; i<data_size; i++)
					{
						if(data[i]!=Inv[j])
							printf("%d ",i+1);
						else
							j++;
						//printf("data[%02d]=%03d\tadd5=%03d\tinv=%03d\n",i,data[i], Add5[i], Inv[i]);
					}
					printf("\n");
				}
				else
				{
					puts("Write failed");
					puts(swift_get_last_error_string());
				}
				free(data);
				//puts("Data freed");
			}
			else
			{
				puts("Configuration failed");
				puts(swift_get_last_error_string());
			}
			free(config);
			//puts("Config freed");
		}
		else
		{
			puts("error on reset");
			puts(swift_get_last_error_string());
		}
		int close_val = swift_close(h);
		if(close_val!=0)
		{
			puts("error on close");
			puts(swift_get_last_error_string());
		}
		//else
			//puts("Closed");
	}
	else
	{
		puts("board failed to open");
		puts(swift_get_last_error_string());
	}
	//puts("\nIt's over!");
	return EXIT_SUCCESS;
}
