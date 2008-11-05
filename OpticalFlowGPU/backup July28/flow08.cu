/***************************************************************************************
* John Bodily
* Brigham Young University
* CHREC project B2
*
* Started June 12, 2008
*
* Optical flow on the GPU
****************************************************************************************/

// includes, system
#include <stdlib.h>
#include <stdio.h>
#include <cstdio>
#include <string.h>
#include <math.h>
#include <assert.h>
#include <cutil.h>

// includes, kernels
#include <flow08.h>
#include <initialize_flow.cu>
#include <derivative_kernel.cu>
#include <smoothing_kernel.cu>
#include <second_smooth_kernel.cu>
#include <velocity_kernel.cu>
#include <smooth_velocity.cu>
#include <check_results.cu>

/***************************************************************************************
* read_images()
*
* 1st step: Read in an image sequence from memory.  Currently reads an entire sequence.  
* In the future streaming functionality may be added.
****************************************************************************************/
void read_images( char* argv[] ) 
{
	char *filepath, tmppath[50];
	char *ext, *read_type;
	char num[5];
	int start_image = 0;
	total_images = 0;

	assert( strlen(argv[1]) < 15 );
	strcpy( seq_name, argv[1] );

	if( strcmp(seq_name, "yosemite") == 0 ) {
		printf( "Running yosemite sequence\n" );
		total_images = 15;
		start_image = 2;
		read_type = "rb";
		filepath = "images/raw yos sequence/yos";
		ext = ".raw";
		width = 316;
		height = 252;
	} else if( strcmp(seq_name, "flower garden") == 0 ) {
		printf( "Running flower garden sequence\n" );
		total_images = 31;
		read_type = "r";
		filepath = "images/raw flower garden/flowg";
		ext = ".raw";
		width = 352;
		height = 240;
	} 
	else {
		printf( "Unrecognized image sequence\n" );
		exit(0);
	}

	FILE* images[MAX_IMAGES];

	// open up image files
	for( int i=0; i<total_images; i++ ) {
		strcpy( tmppath, filepath );
		sprintf(num, "%d", i+start_image);
		strcat(tmppath,num);
		strcat(tmppath,ext);	
		
		images[i] = fopen(tmppath, read_type);	
		if( !images[i] ) {
			printf("ERROR: Invalid image file: %s\n", tmppath);
			exit(0);
		}	

		//printf("Image to read in: %s\n", tmppath);
	}

	// allocate host memory for the sequence of images	
	sequence = (float **) malloc( total_images * sizeof(float*) );
	for( int i=0; i<total_images; i++) 
		sequence[i] = (float *) malloc( width*height*sizeof(float)  );

	//read the images into host memory
	for( int i=0; i<total_images; i++) {
		for( int j=0; j<width*height; j++ ) 
			sequence[i][j] = (float)getc( images[i] );
	}

	//close the image files now that the info is on the heap
	for( int i=0; i<total_images; i++) 
		fclose(images[i]);
}

/***************************************************************************************
* read_random_images()
*
* 1st step: Fill image sequence with random data for performance testing
****************************************************************************************/
void read_random_images( char* argv[], int argc ) 
{
	assert( strlen(argv[1]) < 15 );
	strcpy( seq_name, argv[1] );

	if( strcmp(seq_name, "yosemite") == 0 ) {
		width = 316;
		height = 252;
	} else if( strcmp(seq_name, "flower garden") == 0 ) {
		width = 352;
		height = 240;
	} 
	else if( strcmp(seq_name, "random") == 0 ) {
		if( argc != 5 ) {
			printf("Usage:\n%s %s 2 [width] [height]\n", argv[0], seq_name);
			exit(0);
		}
		width = atoi(argv[3]);
		height = atoi(argv[4]);
	}
	else {
		printf( "Unrecognized image sequence\n" );
		exit(0);
	}

	sequence = (float **) malloc( NUM_IMAGES * sizeof(float*) );
	for( int i=0; i<NUM_IMAGES; i++) 
		sequence[i] = (float *) malloc( width*height*sizeof(float)  );

	// fill sequence with random data
	for( int i=0; i<NUM_IMAGES; i++ ) {	
		for( int j=0; j<width*height; j++ ) 
			sequence[i][j] = (float) rand()/RAND_MAX;
	}
}



/***************************************************************************************
* calculate_derivates()
*
* 2nd step in Roger's new algorithm.  Similar to gradient calculation in previous 
* algorithm, except done on 3 images rather than 1
****************************************************************************************/
void calculate_derivatives( int mid ) 
{
	for( int i=0; i<3; i++ ) {
		if( width<=512 && width%16 == 0 )
			derivative_x<<<height,width,width_in_bytes>>>(deriv_x[i], d_img[mid-1+i], width, height, pitch1); //faster if width<512
		else
			derivative_x_t<<<xgrid1,xblock1>>>(deriv_x[i], d_img[mid-1+i], width, height, pitch1); //tiled version
		CUT_CHECK_ERROR("Kernel Execution Failed");

		derivative_y<<<ygrid1,yblock1>>>(deriv_y[i], d_img[mid-1+i], width, height, pitch1);   //tiled version - faster for y
		CUT_CHECK_ERROR("Kernel Execution Failed");

		derivative_t<<<tgrid1,tblock1>>>(deriv_t[i], d_img[mid-3+i], d_img[mid-2+i], d_img[mid+i], d_img[mid+1+i], width, height, pitch1);
		CUT_CHECK_ERROR("Kernel Execution Failed");
	}

	cudaThreadSynchronize();
}



/***************************************************************************************
* temporal_smoothing()
*
* 3rd step in Roger's new algorithm.  Temporally smooth over 3 derivative result frames
* using [2 4 2] mask.  Followed by x and y convolution on result using [3 3 4 3 3].
****************************************************************************************/
void temporal_smoothing() 
{
	smooth_t<<<tgrid2,tblock2>>>(smoothed[0], deriv_x[0], deriv_x[1], deriv_x[2], width, height, pitch2);
	CUT_CHECK_ERROR("Kernel Execution Failed");

	smooth_t<<<tgrid2,tblock2>>>(smoothed[1], deriv_y[0], deriv_y[1], deriv_y[2], width, height, pitch2);
	CUT_CHECK_ERROR("Kernel Execution Failed");

	smooth_t<<<tgrid2,tblock2>>>(smoothed[2], deriv_t[0], deriv_t[1], deriv_t[2], width, height, pitch2);
	CUT_CHECK_ERROR("Kernel Execution Failed");

	cudaThreadSynchronize();

	for( int i=0; i<3; i++ ) {
		if( width<=512 && width%16 == 0 )
			convolve_x<<<height,width,width_in_bytes>>>(convolved_x[i], smoothed[i], width, height, pitch2); //faster if width<512
		else
			convolve_x_t<<<xgrid2,xblock2>>>(convolved_x[i], smoothed[i], width, height, pitch2); //tiled version
		CUT_CHECK_ERROR("Kernel Execution Failed");
		
		convolve_y<<<ygrid2,yblock2>>>(convolved_y[i], convolved_x[i], width, height, pitch2);   //tiled version - faster for y
		CUT_CHECK_ERROR("Kernel Execution Failed");

	}

	cudaThreadSynchronize();
}


/***************************************************************************************
* second_order_smoothing()
*
* 4th step in Roger's new algorithm.  Calculates outer product, then smooths each of 6
* frames using [5 6 5] mask. 
****************************************************************************************/
void second_order_smoothing() 
{
	#if( MATCH_ROGER )
		second_smooth_match<<<grid3,block3>>>(convolved_y[0], convolved_y[1], convolved_y[2], smoothed_2nd[0], smoothed_2nd[1],
						smoothed_2nd[2], smoothed_2nd[3], smoothed_2nd[4], smoothed_2nd[5], width, height, pitch3);
	#else
		second_smooth<<<grid3,block3>>>(convolved_y[0], convolved_y[1], convolved_y[2], smoothed_2nd[0], smoothed_2nd[1],
						smoothed_2nd[2], smoothed_2nd[3], smoothed_2nd[4], smoothed_2nd[5], width, height, pitch3);
	#endif

	for( int i=0; i<6; i++ ) {
		/**/if( width<=512 && width%16 == 0 )
			convolve2_x<<<height,width,width_in_bytes>>>(convolved2_x[i], smoothed_2nd[i], width, height, pitch2); //faster if width<512
		else
			convolve2_x_t<<<xgrid3,xblock3>>>(convolved2_x[i], smoothed_2nd[i], width, height, pitch2); //tiled version
		CUT_CHECK_ERROR("Kernel Execution Failed");
		
		convolve2_y<<<ygrid3,yblock3>>>(convolved2_y[i], convolved2_x[i], width, height, pitch2);   //tiled version - faster for y
		CUT_CHECK_ERROR("Kernel Execution Failed");
		
		//convolve_xy<<<height,320,width*sizeof(float)*3>>>(convolved2_y[i], smoothed_2nd[i], width, height);
		//convolve_xy_t<<<xygrid,xyblock>>>(convolved2_y[i], smoothed_2nd[i], width, height, pitch3);

	}

	cudaThreadSynchronize();
}

/***************************************************************************************
* calculate_velocity()
*
* 5th step in Roger's new algorithm.  
****************************************************************************************/
void calculate_velocity() 
{
	velocity_kernel<<<grid4,block4>>>(Vx, Vy, convolved2_y[0], convolved2_y[1], convolved2_y[2], convolved2_y[3], convolved2_y[4],
						convolved2_y[5], width, height, pitch4);
	CUT_CHECK_ERROR("Kernel Execution Failed");
	
	cudaThreadSynchronize();
}

/***************************************************************************************
* smooth_velocity()
*
* 6th step in Roger's new algorithm.  
****************************************************************************************/
void smooth_velocity() 
{
	if( width<=512 && width%16 == 0 ) {
		smooth_velocity_x<<<xgrid5,xblock5,width_in_bytes>>>(Vx_x, Vx, width, height, pitch5);
		CUT_CHECK_ERROR("Kernel Execution Failed");

		smooth_velocity_x<<<xgrid5,xblock5,width_in_bytes>>>(Vy_x, Vy, width, height, pitch5);
		CUT_CHECK_ERROR("Kernel Execution Failed");
	}
	else {
		smooth_velocity_x_t<<<xgrid5,xblock5>>>(Vx_x, Vx, width, height, pitch5);
		CUT_CHECK_ERROR("Kernel Execution Failed");

		smooth_velocity_x_t<<<xgrid5,xblock5>>>(Vy_x, Vy, width, height, pitch5);
		CUT_CHECK_ERROR("Kernel Execution Failed");
	}

	smooth_velocity_y<<<ygrid5,yblock5>>>(Vx_y, Vx_x, width, height, pitch5);
	CUT_CHECK_ERROR("Kernel Execution Failed");

	smooth_velocity_y<<<ygrid5,yblock5>>>(Vy_y, Vy_x, width, height, pitch5);
	CUT_CHECK_ERROR("Kernel Execution Failed");
	
	cudaThreadSynchronize();
}



/***************************************************************************************
* clean_up()
*
****************************************************************************************/
void clean_up() {
	//clean up memory
	free( sequence );

	for( int i=0; i<3; i++ ) {
		CUDA_SAFE_CALL( cudaFree(convolved_x[i]) );
		CUDA_SAFE_CALL( cudaFree(convolved_y[i]) );
		CUDA_SAFE_CALL( cudaFree(smoothed[i]) );
		CUDA_SAFE_CALL( cudaFree(deriv_x[i]) );
		CUDA_SAFE_CALL( cudaFree(deriv_y[i]) );
		CUDA_SAFE_CALL( cudaFree(deriv_t[i]) );
	}

	for( int i=0; i<6; i++ ) {
		CUDA_SAFE_CALL( cudaFree(smoothed_2nd[i]) );
		CUDA_SAFE_CALL( cudaFree(convolved2_x[i]) );
		CUDA_SAFE_CALL( cudaFree(convolved2_y[i]) );
	}

	CUDA_SAFE_CALL( cudaFree(Vx) );
	CUDA_SAFE_CALL( cudaFree(Vy) );
	CUDA_SAFE_CALL( cudaFree(Vx_x) );
	CUDA_SAFE_CALL( cudaFree(Vy_x) );
	CUDA_SAFE_CALL( cudaFree(Vx_y) );
	CUDA_SAFE_CALL( cudaFree(Vy_y) );
	CUDA_SAFE_CALL(cudaFreeHost(vx_final));
	CUDA_SAFE_CALL(cudaFreeHost(vy_final));

	CUT_SAFE_CALL( cutDeleteTimer( timer));
}

/***************************************************************************************
* Main()
*
****************************************************************************************/
int main(int argc, char *argv[]) {
	if( argc < 3 || argc > 5 ) {
		printf( "Usage:"
			"\nOption 1 (timing by kernel):"
			"\n%s [yosemite|\"flower garden\"] 1"
			"\nOption 2 (timing by frame):"
			"\n%s [yosemite|\"flower garden\"|random] 2 [width] [height] "
			"\nNote: random option requires a width and height\nOption 3 (write out results to verify):"
			"\n%s [yosemite|\"flower garden\"] 3\n", argv[0], argv[0], argv[0] );
		exit(0);
	}

	CUT_DEVICE_INIT();
	empty_kernel<<<1,1>>>();	//initialize runtime libraries.  Is this still necessary?

	//timer to measure performance
	CUT_SAFE_CALL( cutCreateTimer( &timer));	

	if( atoi(argv[2]) == 1 ) {
		printf( "Running with timing by kernel, size = %dx%d\n", width, height );

		//Step 1: read images into memory and initialize GPU variables
		read_images( argv );
		init_flow();

		//Step 2
		CUT_SAFE_CALL( cutStartTimer( timer));
		calculate_derivatives( 3 ); 			// ( middle_image )
		CUT_SAFE_CALL( cutStopTimer( timer));
		float deriv_time = cutGetTimerValue(timer);
		float total_time = deriv_time;

		//Step 3
		CUT_SAFE_CALL( cutResetTimer( timer));
		CUT_SAFE_CALL( cutStartTimer( timer));
		temporal_smoothing();			
		CUT_SAFE_CALL( cutStopTimer( timer));
		float smooth_time = cutGetTimerValue(timer);	
		total_time += smooth_time;

		//Step 4
		CUT_SAFE_CALL( cutResetTimer( timer));
		CUT_SAFE_CALL( cutStartTimer( timer));
		second_order_smoothing(); 		
		CUT_SAFE_CALL( cutStopTimer( timer));
		float smooth2_time = cutGetTimerValue(timer);	
		total_time += smooth2_time;

		//Step 5
		CUT_SAFE_CALL( cutResetTimer( timer));
		CUT_SAFE_CALL( cutStartTimer( timer));
		calculate_velocity(); 		
		CUT_SAFE_CALL( cutStopTimer( timer));
		float veloc_time = cutGetTimerValue(timer);	
		total_time += veloc_time;

		//Step 6
		CUT_SAFE_CALL( cutResetTimer( timer));
		CUT_SAFE_CALL( cutStartTimer( timer));
		smooth_velocity(); 	
		CUT_SAFE_CALL( cutStopTimer( timer));
		float sm_veloc_time = cutGetTimerValue(timer);	
		total_time += sm_veloc_time;

		//get results 
		CUT_SAFE_CALL( cutResetTimer( timer));
		CUT_SAFE_CALL( cutStartTimer( timer));

		CUDA_SAFE_CALL( cudaMemcpy2D( vx_final, width_in_bytes, Vx, d_pitch, width_in_bytes, height, cudaMemcpyDeviceToHost));
		CUDA_SAFE_CALL( cudaMemcpy2D( vy_final, width_in_bytes, Vy, d_pitch, width_in_bytes, height, cudaMemcpyDeviceToHost));

		CUT_SAFE_CALL( cutStopTimer( timer));
		float veloc_cpy_time = cutGetTimerValue(timer);	
		total_time += veloc_cpy_time;


		printf("\nDerivative time = %f ms\n",deriv_time); 
		printf("Total temporal smoothing time = %f ms\n",smooth_time);
		printf("Second order smoothing time = %f ms\n",smooth2_time);  
		printf("Velocity calculation time = %f ms\n",veloc_time); 
		printf("Smooth velocity time = %f ms\n",sm_veloc_time); 
		printf("Copy velocity results back to host = %f ms\n",veloc_cpy_time); 
		printf("Total calculation time = %f ms\n",total_time); 
		printf("------------------------------------------------\n"); 

	} else if( atoi(argv[2]) == 2 ) {
		const int TRIALS = 100;
		read_random_images( argv, argc );
		//read_images( argv );
		init_flow();
		
		printf( "Running with timing by frame for %d random data frames, size = %dx%d\n", TRIALS, width, height );
		
		float* h_img;
		CUDA_SAFE_CALL( cudaMallocHost( (void**) &h_img, width*height*sizeof(float)));
		//float *h_img = (float*) malloc(width*height*sizeof(float));

		for(int i=0; i<width*height; i++)
			h_img[i] = (float) rand()/RAND_MAX;
			
		for(int i=0; i<TRIALS; i++) {

			CUT_SAFE_CALL( cutStartTimer( timer));

			float *tmp = d_img[NUM_IMAGES-1];
			for(int img=NUM_IMAGES-1; img>0; img--)
				d_img[img] = d_img[img-1];
			d_img[0] = tmp;

			CUDA_SAFE_CALL( cudaMemcpy2D( d_img[0], d_pitch, h_img, width_in_bytes, width_in_bytes, height, cudaMemcpyHostToDevice));

			calculate_derivatives( 3 ); 	
			temporal_smoothing();
			second_order_smoothing(); 
			calculate_velocity(); 
			smooth_velocity(); 	
			CUDA_SAFE_CALL( cudaMemcpy2D( vx_final, width_in_bytes, Vx, d_pitch, width_in_bytes, height, cudaMemcpyDeviceToHost));
			CUDA_SAFE_CALL( cudaMemcpy2D( vy_final, width_in_bytes, Vy, d_pitch, width_in_bytes, height, cudaMemcpyDeviceToHost));
		
			CUT_SAFE_CALL( cutStopTimer( timer));
		}
		
		float time = cutGetAverageTimerValue(timer);
		CUT_SAFE_CALL( cutDeleteTimer( timer));

		CUDA_SAFE_CALL(cudaFreeHost(h_img));		

		printf("%f ms/f\n",time);
		printf("%f fps\n",1/(time*1e-3));	

	} else {
		printf( "Running with results being written out.  No timing results calculated. Size = %dx%d\n", width, height  );

		read_images( argv );
		init_flow();

		calculate_derivatives( 3 ); 	
		check_results( 2 );

		temporal_smoothing();
		check_results( 3 );

		second_order_smoothing(); 
		check_results( 4 );

		calculate_velocity();
		check_results( 5 );
 
		smooth_velocity(); 
		check_results( 6 );
	}

	clean_up();
}






