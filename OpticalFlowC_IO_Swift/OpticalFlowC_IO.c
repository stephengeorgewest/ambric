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

int width=316;
int height=252;
int frames=1;
int frames_start=2;
const char file_name1[] = "yos02.raw";
char file_name_format[] = "yos%d%d.raw"; 
char file_name[12];

int width_final=300;
int height_final=236;
int frames_final=7;
int main(void) {
	puts("Starting up\n");
	char* ver = swift_library_version();
	printf("Using library version %s\n",ver);
	//int swift_device_count(int trans_type);
	int count = swift_device_count(SWIFT_PCIE);
	printf("%d pcie devices found\n",count);
	count = swift_device_count(SWIFT_USB);
	printf("%d usb devices found\n",count);
	//swift_handle swift_open(int trans_type, int device_id, int exclusive flag);
	swift_handle h = swift_open(SWIFT_PCIE, 0,0);
	if(h!=0)
	{
		puts("Opened first pcie device\n");
		
		
		int reset_val = swift_reset(h);
		if(reset_val==0)
		{
			puts("Device reset\n");
			
			char* config=(char*)(malloc(1024*1024*16*sizeof(char)));//[1024*1024*16]; // Up to 16 Megabyte configuration file
			puts("Config malloced");
			FILE *f;
			int i = 0;
			int j = 0;
			int ch;
			f = fopen("OpticalFlow.cfg", "r");
			while ((ch = fgetc(f)) != EOF)
				config[i++] = ch;
			config[i] = '\0';
			fclose(f);
			printf("Config %d bytes long\n",i);
			
			clock_t config_start_time = clock();
			int config_val = swift_load_config(h, config, 0);
			clock_t config_stop_time = clock();
			if(config_val==0)
			{
				int run_time = (config_stop_time-config_start_time)*CLOCKS_PER_SEC/1000;
				puts("Device configured");
				printf("\tconfig time = %dms\n\n",run_time);
				
				FILE *data_file;
				int* data=(int *)(malloc(width*height*frames*sizeof(int)));
				puts("Data malloced");
				int frames_end = frames+frames_start;
				printf("Start Frame =%d, End Frame =%d\n",frames_start,frames_end-1);
				i=0;
				for(j=frames_start;j<frames_end;j++)
				{
					sprintf(file_name, file_name_format, j/10, j%10);
					puts(file_name);
					data_file=fopen(file_name, "r");
					if(data_file==0)
					{
						puts("DataFile not opened");
						return 0 ;
					}
					else
						while((ch=fgetc(data_file))!= EOF)
							data[i++]=(int)ch;
				}
				puts("Data read from file(s)");
				if(width*height*frames>SWIFT_MAX_IO_WORDS)
					puts("toobig");
				
				clock_t write_start_time = clock();
				int write_handle = swift_write_async(h,data,width*height*frames,0,0);
				if(!(write_handle==0 | write_handle==-1))
				{
					int size = width_final*height_final*frames_final;
					int frame_size= width_final*height_final;
					int* Vx = (int *)(malloc(size*(sizeof(int))));
					int* Vy = (int *)(malloc(size*(sizeof(int))));
					for(i=0; i<30;i++)
					{
						Vx[i]=0;
						Vy[i]=0;
					}
					puts("Vx,Vy malloced");
					//try to read back any data
					int read_handle_x = swift_read_async(h, Vx, 1, 0, 0);
					if(read_handle_x==0)
						puts("broken read x");
					int read_handle_y = swift_read_async(h, Vy, 1, 0, 1);
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
						printf(".");
						Sleep(10);
					}
					int write_size = swift_wait_async(h, write_handle);
					clock_t write_stop_time = clock();
					int write_time = (write_stop_time - write_start_time)*CLOCKS_PER_SEC/1000;
					puts("Write done");
					printf("\t%d words written --- %d=15 frames of words\n",write_size, width*height*frames);
					printf("%\t%dms\n",write_time);
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
					if(read_x_done==-1 | read_y_done ==-1)
						puts(swift_get_last_error_string());
					while(read_x_done == 0 | read_y_done ==0)
					{
						if(read_x_done==1&&num_x_read!=-1)
						{
							num_x_read = swift_wait_async(h, read_handle_x);
							printf("Vx_done %d",num_x_read);
						}
						else
							read_x_done = swift_check_async(h, read_handle_x);
						
						if(read_y_done==1&&num_y_read!=-1)
						{
							num_y_read = swift_wait_async(h, read_handle_y);
							printf("Vy_done %d",num_y_read);
						}
						else
						{
							read_y_done = swift_check_async(h, read_handle_y);
							
						}
						
						printf(".");
						Sleep(100);
						time++;
						if(time>30)
						{
							puts("nothing has happened");
							break;
						}
					}
					for(i=0; i<30; i++)
						printf("in[%02d]=%03d\tadd5=%03d\tinv=%03d\n",i,data[i], Vx[i], Vy[i]);
					puts("Read done, Vx,Vy freed");
					free(Vx);
					free(Vy);
				}
				else
				{
					puts("Write failed");
					puts(swift_get_last_error_string());
				}
				free(data);
				puts("Data freed");
			}
			else
			{
				puts("Configuration failed");
				puts(swift_get_last_error_string());
			}
			free(config);
			puts("Config freed");
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
		else
			puts("Closed");
	}
	else
	{
		puts("board failed to open");
		puts(swift_get_last_error_string());
	}
	puts("\nIt's over!");
	return EXIT_SUCCESS;
}
