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
		char* buf=(char*)(malloc(1024*1024*16*sizeof(char)));//[1024*1024*16]; // Up to 16 Megabyte configuration file
		FILE *f;
		int i = 0;
		int ch;
		f = fopen("OpticalFlow.cfg", "r");
		while ((ch = fgetc(f)) != EOF)
			buf[i++] = ch;
		buf[i] = '\0';
		fclose(f);
		printf("Config %d bytes long\n",i);
		
		int reset_val = swift_reset(h);
		if(reset_val==0)
		{
			int config_val = swift_load_config(h, buf, 0);
			if(config_val==0)
			{
				puts("Device configured");
			}
			else
			{
				puts("Configuration failed");
				puts(swift_get_last_error_string());
			}
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
