
/* 
 * Device code.
 */

#ifndef _SMOOTH2_KERNEL_H_
#define _SMOOTH2_KERNEL_H_

/**********************************************************************
* second_smooth()
*
* similar to outer product kernel of previous optical flow
***********************************************************************/
__global__ void 
second_smooth(float *gx, float *gy, float *gt, float *xx, float *yy, float *tt, float *xy, float *xt, float *yt, int image_width, int image_height, int pitch) {

	int idx = MUL(blockIdx.x, SMOOTH2_TILE_WIDTH) + threadIdx.x;
	int idy = MUL(blockIdx.y, SMOOTH2_TILE_HEIGHT) + threadIdx.y;
	int index = MUL(idy,pitch) + idx;

	if(idx < image_width && idy < image_height) {
		//float tmpX = DIV(gx[index],32.0f);
		//float tmpY = DIV(gy[index],32.0f);
		//float tmpT = DIV(gt[index],32.0f);

		/*xy[index] = tmpX * tmpY;
		yy[index] = tmpY * tmpY;
		yt[index] = tmpY * tmpT;
		tt[index] = tmpT * tmpT;
		xt[index] = tmpT * tmpX;
		xx[index] = tmpX * tmpX;*/

		xy[index] = gx[index] * gy[index];
		yy[index] = gy[index] * gy[index];
		yt[index] = gy[index] * gt[index];
		tt[index] = gt[index] * gt[index];
		xt[index] = gt[index] * gx[index];
		xx[index] = gx[index] * gx[index];
	}
}

/**********************************************************************
* second_smooth_match()
*
* The results of this kernel are scaled and saturated to match the 
* MATLAB results
***********************************************************************/
__global__ void 
second_smooth_match(float *gx, float *gy, float *gt, float *xx, float *yy, float *tt, float *xy, float *xt, float *yt, int image_width, int image_height, int pitch) {

	int idx = MUL(blockIdx.x, SMOOTH2_TILE_WIDTH) + threadIdx.x;
	int idy = MUL(blockIdx.y, SMOOTH2_TILE_HEIGHT) + threadIdx.y;
	int index = MUL(idy,pitch) + idx;
	float tmp[6];

	if(idx < image_width && idy < image_height) {		

		tmp[0] = (float)rintf(gx[index]*gx[index] / 1024.0f);
		tmp[1] = (float)rintf(gy[index]*gy[index] / 1024.0f);
		tmp[2] = (float)rintf(gt[index]*gt[index] / 1024.0f);
		tmp[3] = (float)rintf(gx[index]*gy[index] / 1024.0f);
		tmp[4] = (float)rintf(gy[index]*gt[index] / 1024.0f);
		tmp[5] = (float)rintf(gx[index]*gt[index] / 1024.0f);

		for( int i=0; i<6; i++ ) {
			if( tmp[i] > 8191.0f ) tmp[i] = 8191.0f;
			if( tmp[i] < -8192.0f ) tmp[i] = -8192.0f;		
		}		

		xx[index] = tmp[0];
		yy[index] = tmp[1];
		tt[index] = tmp[2];
		xy[index] = tmp[3];
		yt[index] = tmp[4];
		xt[index] = tmp[5];
	}
}


/**********************************************************************
* convolve2_x()
*
* This kernel calculates the convolution for an image in the x direction 
* using a [5 6 5] filter.  Non-tiled - works best if width is
* multiple of 16 or 32.  Only used when width <= 512, the max number
* of threads.
*
***********************************************************************/
extern __shared__ float sharedConv2Mem[];

__global__ void 
convolve2_x(float *d_Result, float *d_Data, int width, int height, int pitch) {

	int I = threadIdx.x;
	int B = blockIdx.x;
	//__shared__ float sequence[IMAGE_WIDTH];
	float* sequence = sharedConv2Mem;

	sequence[I] = d_Data[B*width + I];

	__syncthreads();

	float resultX = 0.0;

	if( !(I < 1 || I >= width-1) && !(B < 1 || B >= height-1) ) {
		//calculate gradient in the x direction
		resultX =  5*sequence[I-1] + 6*sequence[I] + 5*sequence[I+1];
		
		#if( MATCH_ROGER ) 
		{
			resultX = (float)rintf(resultX/8.0f);
			if( resultX > 16383 ) resultX = 16383;
			if( resultX < -16384 ) resultX = -16384;
		}
		#endif
	}

	d_Result[B*width + I] = resultX; 
}

/**********************************************************************
* convolve2_x_t()
*
* This kernel calculates the convolution for an image in the x direction 
* using a [5 6 5] filter.  Tiled - works for any image size.  A
* bit slower than non-tiled if width < 512 and is a multiple of 16.
*
***********************************************************************/
__global__ void 
convolve2_x_t(float *d_Result, float *d_Data, int width, int height, int pitch) {

	__shared__ float data[XCONV2_TILE_WIDTH + 2*FILTER4_RAD + 1];

	//Current tile and apron limits, relative to row start
	const int         tileStart = IMUL(blockIdx.x, XCONV2_TILE_WIDTH);
	const int           tileEnd = tileStart + XCONV2_TILE_WIDTH - 1;
	const int        apronStart = tileStart - FILTER4_RAD;
	const int          apronEnd = tileEnd   + FILTER4_RAD;

	//Clamp tile and apron limits by image borders
	const int    tileEndClamped = min(tileEnd, width - 1);
	const int apronStartClamped = max(apronStart, 0);
	const int   apronEndClamped = min(apronEnd, width - 1);

	//Row start index in d_Data[]
	const int          rowStart = IMUL(blockIdx.y, pitch);

	const int apronStartAligned = tileStart - FILTER_RAD_ALIGNED;

	const int loadPos = apronStartAligned + threadIdx.x;
	//Set the entire data cache contents
	//Load global memory values, if indices are within the image borders,
	//or initialize with zeroes otherwise
	if(loadPos >= apronStart) {
		const int smemPos = loadPos - apronStart;

		data[smemPos] =  ((loadPos >= apronStartClamped) && (loadPos <= apronEndClamped)) ? d_Data[rowStart + loadPos] : 0;
	}

	__syncthreads();

	const int writePos = tileStart + threadIdx.x;
	//Assuming width and XGRAD_TILE_WIDTH are multiples of half-warp size,
	//rowStart + tileStart is also a multiple of half-warp size,
	//thus having proper alignment for coalesced d_Result[] write.
	if(writePos <= tileEndClamped) {
		const int smemPos = writePos - apronStart;
		float sum = 0;

		if(!(writePos<FILTER4_RAD || writePos>=width-FILTER4_RAD || blockIdx.y<FILTER4_RAD || blockIdx.y>=height-FILTER4_RAD))
			sum =  5*data[smemPos-1] + 6*data[smemPos] + 5*data[smemPos+1];

		#if( MATCH_ROGER ) 
		{
			sum = (float)rintf(sum/8.0f);
			if( sum > 16383 ) sum = 16383;
			if( sum < -16384 ) sum = -16384;
		}
		#endif

		d_Result[rowStart + writePos] = sum;
	}
}


/**********************************************************************
* convolve2_y()
*
* This kernel calculates the convolution for an image in the y direction 
* using a [5 6 5] filter.
*
***********************************************************************/
__global__ void 
convolve2_y(float *d_Result, float *d_Data, int image_width, int image_height, int pitch) {

	__shared__ float data[YCONV2_TILE_WIDTH*(2*FILTER4_RAD+1+YCONV2_TILE_HEIGHT)];

	//Current tile and apron limits, in rows
	const int         tileStart = IMUL(blockIdx.y, YCONV2_TILE_HEIGHT);
	const int           tileEnd = tileStart + YCONV2_TILE_HEIGHT - 1;
	const int        apronStart = tileStart - FILTER4_RAD;
	const int          apronEnd = tileEnd   + FILTER4_RAD;

	//Clamp tile and apron limits by image borders
	// const int    tileEndClamped = min(tileEnd, image_height - 1);
	const int apronStartClamped = max(apronStart, 0);
	const int   apronEndClamped = min(apronEnd, image_height - 1);

	//Current column index
	const int       columnStart = IMUL(blockIdx.x, YCONV2_TILE_WIDTH) + threadIdx.x;

	if(columnStart < image_width) {
		//Shared and global memory indices for current column
		int smemPos = IMUL(threadIdx.y, YCONV2_TILE_WIDTH) + threadIdx.x;
		int gmemPos = IMUL(apronStart + threadIdx.y, pitch) + columnStart;

		//Load global memory values, if indices are within the image borders,
		//or initialize with zero otherwise
		data[smemPos] = ((apronStart + threadIdx.y >= apronStartClamped) && (apronStart + threadIdx.y <= apronEndClamped)) 
				? d_Data[gmemPos] : 0;
	}
	
	__syncthreads();

	if(columnStart < image_width && threadIdx.y < YCONV2_TILE_HEIGHT && tileStart + threadIdx.y < image_height) {
		//Shared and global memory indices for current column
		int smemPos = IMUL(threadIdx.y + FILTER4_RAD, YCONV2_TILE_WIDTH) + threadIdx.x;
		int gmemPos = IMUL(tileStart + threadIdx.y, pitch) + columnStart;

		float sum = 0;

		if(!( ( columnStart < FILTER4_RAD ) || ( columnStart >= (image_width-FILTER4_RAD) ) || ( (tileStart + threadIdx.y) < FILTER4_RAD) || ( (tileStart + threadIdx.y) >= (image_height-FILTER4_RAD) ) ))
			sum = 5*data[smemPos-1*YCONV2_TILE_WIDTH] + 6*data[smemPos] + 5*data[smemPos+1*YCONV2_TILE_WIDTH];
		
		#if( MATCH_ROGER ) 
		{
			sum = (float)rintf(sum/8.0f); 
			if( sum > 32767 ) sum = 32767;
			if( sum < -32768 ) sum = -32768;
			
			// this scaling is done at the beginning of the velocity calculation in the matlab code.  
			sum = (float)rintf(sum/8.0f); 
		}
		#endif

		d_Result[gmemPos] = sum;
	}
}


/**********************************************************************
* convolve2_xy()
*
* This kernel calculates the convolution for an image in the y direction 
* using a 3x3 filter.
*
***********************************************************************/
extern __shared__ float sharedMemxy[];

__global__ void 
convolve2_xy(float *d_Result, float *d_Data, int image_width, int image_height) {

	int I = threadIdx.x;	//represents column
	int B = blockIdx.x;	//represents row
	
	if( B>=image_height ) {
		B=B-image_height;	  	
		I=I+320;	
	}
	
	if( B==0 || B==image_height-1 ) {
		//zero out the top and bottom rows
		d_Result[B*image_width + I] = 0;
	}
	else {	
		float* data0 = (float*)sharedMemxy;
		float* data1 = (float*)&data0[image_width];
		float* data2 = (float*)&data1[image_width];
		
		for( int i = threadIdx.x; i<image_width; i+=320 ) {		
			data0[i] = d_Data[(B-1)*image_width + i];
			data1[i] = d_Data[B*image_width + i];
			data2[i] = d_Data[(B+1)*image_width + i];
			
		}
		__syncthreads();

		for( int i = threadIdx.x; i<image_width; i+=320 ) {	
			if( i==0 || i==image_width-1 ) {		
				//zero out first and last columns
				d_Result[B*image_width + i] = 0;
			}
			else {
				float sum = 25*data0[i-1] + 30*data0[i] + 25*data0[i+1]
			    	+ 30*data1[i-1] + 36*data1[i] + 30*data1[i+1]
			    	+ 25*data2[i-1] + 30*data2[i] + 25*data2[i+1];

				d_Result[B*image_width + i] = sum;
			}
		}
	}


	/*__shared__ float data[(2*FILTER4_RAD+YCONV2_TILE_WIDTH)*(2*FILTER4_RAD+1+YCONV2_TILE_HEIGHT)];

	//Current tile and apron limits, in rows
	const int         tileStart = IMUL(blockIdx.y, YCONV2_TILE_HEIGHT);
	const int           tileEnd = tileStart + YCONV2_TILE_HEIGHT - 1;
	const int        apronStart = tileStart - FILTER4_RAD;
	const int          apronEnd = tileEnd   + FILTER4_RAD;

	//Clamp tile and apron limits by image borders
	// const int    tileEndClamped = min(tileEnd, image_height - 1);
	const int apronStartClamped = max(apronStart, 0);
	const int   apronEndClamped = min(apronEnd, image_height - 1);

	//Current column index
	const int       columnStart = IMUL(blockIdx.x, YCONV2_TILE_WIDTH) + threadIdx.x;

	if(columnStart < image_width) {
		//Shared and global memory indices for current column
		int smemPos = IMUL(threadIdx.y, YCONV2_TILE_WIDTH) + threadIdx.x;
		int gmemPos = IMUL(apronStart + threadIdx.y, pitch) + columnStart;

		//Load global memory values, if indices are within the image borders,
		//or initialize with zero otherwise
		data[smemPos] = ((apronStart + threadIdx.y >= apronStartClamped) && (apronStart + threadIdx.y <= apronEndClamped)) 
				? d_Data[gmemPos] : 0;
	}
	
	__syncthreads();

	if(columnStart < image_width && threadIdx.y < YCONV2_TILE_HEIGHT && tileStart + threadIdx.y < image_height) {
		//Shared and global memory indices for current column
		int smemPos = IMUL(threadIdx.y + FILTER4_RAD, YCONV2_TILE_WIDTH) + threadIdx.x;
		int gmemPos = IMUL(tileStart + threadIdx.y, pitch) + columnStart;

		float sum = 0;

		if(!( ( columnStart < FILTER4_RAD ) || ( columnStart >= (image_width-FILTER4_RAD) ) || ( (tileStart + threadIdx.y) < FILTER4_RAD) || ( (tileStart + threadIdx.y) >= (image_height-FILTER4_RAD) ) ))
			sum = 25*data[smemPos-YCONV2_TILE_WIDTH-1] + 30*data[smemPos-YCONV2_TILE_WIDTH] + 25*data[smemPos-YCONV2_TILE_WIDTH+1]
			    + 30*data[smemPos-1] + 36*data[smemPos] + 30*data[smemPos+1]
			    + 25*data[smemPos+YCONV2_TILE_WIDTH-1] + 30*data[smemPos+YCONV2_TILE_WIDTH] + 25*data[smemPos+YCONV2_TILE_WIDTH+1];

		d_Result[gmemPos] = sum;
	}
	*/
}




#endif // #ifndef _SMOOTH2_KERNEL_H_

