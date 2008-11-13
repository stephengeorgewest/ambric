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
	puts("!!!Hello World!!!"); /* prints !!!Hello World!!! */
	char* ver = swift_library_version();
	puts(ver);
	//int swift_device_count(int trans_type);
	int count = swift_device_count(SWIFT_PCIE);
	printf("%d pcie devices found\n",count);
	count = swift_device_count(SWIFT_USB);
	printf("%d usb devices found\n",count);
	//swift_handle swift_open(int trans_type, int device_id, int exclusive flag);
	swift_handle h = swift_open(SWIFT_PCIE, 0,0);
	if(h!=0)
	{
		puts("Opened");
		//int load_val = swift_load_config(h, ,0);
		
		
		int close_val = swift_close(h);
		if(close_val!=0)
			puts("error on close");
		else
			puts("Closed");
	}
	else
		puts("board failed to open");
	return EXIT_SUCCESS;
}
