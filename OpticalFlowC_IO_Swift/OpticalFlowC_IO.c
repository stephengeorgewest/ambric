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
int width=316;
int height=252;
int frames=15;
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
		puts("Opened first pcie device");
		
		
		int reset_val = swift_reset(h);
		if(reset_val==0)
		{
			puts("Device reset");
			
			char* config=(char*)(malloc(1024*1024*16*sizeof(char)));//[1024*1024*16]; // Up to 16 Megabyte configuration file
			puts("config malloced");
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
			int config_val = swift_load_config(h, config, 0);
			if(config_val==0)
			{
				puts("Device configured");
				FILE *data_file;
				int* data=(int *)(malloc(width*height*frames*sizeof(int)));
				puts("data malloced");
				int frames_end = frames+frames_start;
				printf("start %d, end %d\n",frames_start,frames_end);
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
				puts("data read");
				
				int write_handle = swift_write_async(h,data,width*height*frames,0,0);
				if(!(write_handle==0 | write_handle==-1))
				{
					int size = width_final*height_final*frames_final;
					int* Vx = (int *)(malloc(size*(sizeof(int))));
					int* Vy = (int *)(malloc(size*(sizeof(int))));
					puts("Vx,Vy malloced");
					int read_handle_x = swift_read_async(h, Vx, size, 0, 0);
					int read_handle_y = swift_read_async(h, Vy, size, 0, 1);
					swift_wait_async_timeout(h, write_handle,100);
					swift_wait_async(h, read_handle_x);
					swift_wait_async(h, read_handle_y);
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
			puts("config freed");
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
