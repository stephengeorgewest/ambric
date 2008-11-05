
/* 
 * Device code.
 */

#ifndef _SMOOTH_KERNEL_H_
#define _SMOOTH_KERNEL_H_

/**********************************************************************
* smooth_t()
*
* This kernel temporally smooths the derivative images using [2 4 2]
* mask.
*
***********************************************************************/
__global__ void 
smooth_t(float *d_Result, float *frame0, float *frame1, float *frame2, int width, int height, int pitch) {

	__shared__ float data[TSMOOTH_TILE_HEIGHT*TSMOOTH_TILE_WIDTH*(2*FILTER2_RAD+1)];

	const int columnStart = MUL(blockIdx.x, TSMOOTH_TILE_WIDTH) + threadIdx.x;
	const int rowStart = MUL(blockIdx.y, TSMOOTH_TILE_HEIGHT) + threadIdx.y;

    	const int columnClamped = min(columnStart, width-1);
	const int rowClamped = min(rowStart, height-1);

	const int tile_size = MUL(TSMOOTH_TILE_WIDTH,TSMOOTH_TILE_HEIGHT);

	int gmem = MUL(rowClamped, pitch) + columnClamped;

	// Cache tile in the shared memoy array
	int smem = MUL(threadIdx.y, TSMOOTH_TILE_WIDTH) + threadIdx.x;

	data[smem] = frame0[gmem];
	data[smem + tile_size] = frame1[gmem];
	data[smem + 2*tile_size] = frame2[gmem];

	__syncthreads();

    	// Filter output pixels per thread
	if (columnStart < width && rowStart < height) {
		float sum=0;

		if(!(columnStart<2 || columnStart>=width-2 || rowStart<2 || rowStart>=height-2))
			sum = 2*data[smem] + 4*data[smem+tile_size] + 2*data[smem+2*tile_size];

		#if( MATCH_ROGER != 0 ) 
		{
			sum = (float)rintf(sum/2.0f);
			if( sum > 255 ) sum = 255;
			if( sum < -256 ) sum = -256;
		}
		#endif

		d_Result[gmem] = sum;
	}

}

/**********************************************************************
* convolve_x()
*
* This kernel calculates the convolution for an image in the x direction 
* using a [3 3 4 3 3] filter.  Non-tiled - works best if width is
* multiple of 16 or 32.  Only used when width <= 512, the max number
* of threads.
*
***********************************************************************/
extern __shared__ float sharedConvMem[];

__global__ void 
convolve_x(float *d_Result, float *d_Data, int width, int height, int pitch) {

	int I = threadIdx.x;
	int B = blockIdx.x;
	//__shared__ float sequence[IMAGE_WIDTH];
	float* sequence = sharedConvMem;

	sequence[I] = d_Data[B*width + I];

	__syncthreads();

	float resultX = 0.0;

	if( !(I < 2 || I >= width-2) && !(B < 2 || B >= height-2) ) {
		//calculate gradient in the x direction
		resultX =  3*sequence[I-2] + 3*sequence[I-1] + 4*sequence[I] + 3*sequence[I+1] + 3*sequence[I+2];
		
		#if( MATCH_ROGER ) 
		{
			resultX = (float)rintf(resultX/4.0f);
			if( resultX > 1023 ) resultX = 1023;
			if( resultX < -1024 ) resultX = -1024;
		}
		#endif
	}

	d_Result[B*width + I] = resultX; 
}

/**********************************************************************
* convolve_x_t()
*
* This kernel calculates the convolution for an image in the x direction 
* using a [3 3 4 3 3] filter.  Tiled - works for any image size.  A
* bit slower than non-tiled if width < 512 and is a multiple of 16.
*
***********************************************************************/
__global__ void 
convolve_x_t(float *d_Result, float *d_Data, int width, int height, int pitch) {

	__shared__ float data[XCONV_TILE_WIDTH + 2*FILTER3_RAD];

	//Current tile and apron limits, relative to row start
	const int         tileStart = IMUL(blockIdx.x, XCONV_TILE_WIDTH);
	const int           tileEnd = tileStart + XCONV_TILE_WIDTH - 1;
	const int        apronStart = tileStart - FILTER3_RAD;
	const int          apronEnd = tileEnd   + FILTER3_RAD;

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
	if(loadPos >= apronStart) { //first 16 threads not used to load?
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

		if(!(writePos<FILTER3_RAD || writePos>=width-FILTER3_RAD || blockIdx.y<FILTER3_RAD || blockIdx.y>=height-FILTER3_RAD))
			sum =  3*data[smemPos-2] + 3*data[smemPos-1] + 4*data[smemPos] + 3*data[smemPos+1] + 3*data[smemPos+2];

		#if( MATCH_ROGER ) 
		{
			sum = (float)rintf(sum/4.0f);
			if( sum > 1023 ) sum = 1023;
			if( sum < -1024 ) sum = -1024;
		}
		#endif

		d_Result[rowStart + writePos] = sum;
	}
}


/**********************************************************************
* convolve_y()
*
* This kernel calculates the convolution for an image in the y direction 
* using a [3 3 4 3 3] filter.
*
***********************************************************************/
__global__ void 
convolve_y(float *d_Result, float *d_Data, int image_width, int image_height, int pitch) {

	__shared__ float data[YCONV_TILE_WIDTH*(2*FILTER3_RAD+YCONV_TILE_HEIGHT)];

	//Current tile and apron limits, in rows
	const int         tileStart = IMUL(blockIdx.y, YCONV_TILE_HEIGHT);
	const int           tileEnd = tileStart + YCONV_TILE_HEIGHT - 1;
	const int        apronStart = tileStart - FILTER3_RAD;
	const int          apronEnd = tileEnd   + FILTER3_RAD;

	//Clamp tile and apron limits by image borders
	// const int    tileEndClamped = min(tileEnd, image_height - 1);
	const int apronStartClamped = max(apronStart, 0);
	const int   apronEndClamped = min(apronEnd, image_height - 1);

	//Current column index
	const int       columnStart = IMUL(blockIdx.x, YCONV_TILE_WIDTH) + threadIdx.x;

	if(columnStart < image_width) {
		//Shared and global memory indices for current column
		int smemPos = IMUL(threadIdx.y, YCONV_TILE_WIDTH) + threadIdx.x;
		int gmemPos = IMUL(apronStart + threadIdx.y, pitch) + columnStart;

		//Load global memory values, if indices are within the image borders,
		//or initialize with zero otherwise
		data[smemPos] = ((apronStart + threadIdx.y >= apronStartClamped) && (apronStart + threadIdx.y <= apronEndClamped)) 
				? d_Data[gmemPos] : 0;
	}
	
	__syncthreads();

	if(columnStart < image_width && threadIdx.y < YCONV_TILE_HEIGHT && tileStart + threadIdx.y < image_height) {
		//Shared and global memory indices for current column
		int smemPos = IMUL(threadIdx.y + FILTER3_RAD, YCONV_TILE_WIDTH) + threadIdx.x;
		int gmemPos = IMUL(tileStart + threadIdx.y, pitch) + columnStart;

		float sum = 0;

		if(!( ( columnStart < FILTER3_RAD ) || ( columnStart >= (image_width-FILTER3_RAD) ) || ( (tileStart + threadIdx.y) < FILTER3_RAD) || ( (tileStart + threadIdx.y) >= (image_height-FILTER3_RAD) ) ))
			sum = 3*data[smemPos-2*YCONV_TILE_WIDTH] + 3*data[smemPos-1*YCONV_TILE_WIDTH] + 4*data[smemPos] + 3*data[smemPos+1*YCONV_TILE_WIDTH] + 3*data[smemPos+2*YCONV_TILE_WIDTH];
		
		#if( MATCH_ROGER ) 
		{
			sum = (float)rintf(sum/4.0f);
			if( sum > 8191 ) sum = 8191;
			if( sum < -8192 ) sum = -8192;
		}
		#endif

		d_Result[gmemPos] = sum;
	}
}






#endif // #ifndef _SMOOTH_KERNEL_H_



