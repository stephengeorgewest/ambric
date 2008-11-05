
/* 
 * Device code.
 */

#ifndef _DERIV_KERNEL_H_
#define _DERIV_KERNEL_H_

#define IMUL(x,y) __mul24(x,y)
#define MUL(A,B) __mul24(A, B)
#define IDIV(x, y) ((int)((x) / (float)(y)))


/**********************************************************************
* derivative_x()
*
* This kernel calculates the derivative for an image in the x direction 
* using a [-1 8 0 -8 1] filter.  Non-tiled - works best if width is
* multiple of 16 or 32.  Only used when width <= 512, the max number
* of threads.
*
***********************************************************************/
extern __shared__ float sharedMem[];

__global__ void 
derivative_x(float *d_Result, float *d_Data, int width, int height, int pitch) {

	int I = threadIdx.x;
	int B = blockIdx.x;
	//__shared__ float sequence[IMAGE_WIDTH];
	float* sequence = sharedMem;

	sequence[I] = d_Data[B*width + I];

	__syncthreads();

	float resultX = 0.0;

	if( !(I < 2 || I >= width-2) && !(B < 2 || B >= height-2) ) {
		//calculate gradient in the x direction
		resultX =  -1*sequence[I-2] + 8*(sequence[I-1] - sequence[I+1]) + sequence[I+2];
		
		#if( MATCH_ROGER ) 
		{
			resultX = (float)rintf(resultX/8.0);
			if( resultX > 127 ) resultX = 127;
			if( resultX < -127 ) resultX = -127;
		}
		#endif
	}

	d_Result[B*width + I] = resultX; 
}

/**********************************************************************
* derivative_x_t()
*
* This kernel calculates the derivative for an image in the x direction 
* using a [-1 8 0 -8 1] filter.  Tiled - works for any image size.  A
* bit slower than non-tiled if width < 512 and is a multiple of 16.
*
***********************************************************************/
__global__ void 
derivative_x_t(float *d_Result, float *d_Data, int width, int height, int pitch) {

	__shared__ float data[XGRAD_TILE_WIDTH + 2*FILTER1_RAD];

	//Current tile and apron limits, relative to row start
	const int         tileStart = IMUL(blockIdx.x, XGRAD_TILE_WIDTH);
	const int           tileEnd = tileStart + XGRAD_TILE_WIDTH - 1;
	const int        apronStart = tileStart - FILTER1_RAD;
	const int          apronEnd = tileEnd   + FILTER1_RAD;

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

		if(!(writePos<FILTER1_RAD || writePos>=width-FILTER1_RAD || blockIdx.y<FILTER1_RAD || blockIdx.y>=height-FILTER1_RAD))
			sum = -1 * data[smemPos-2] + 8 * data[smemPos-1] - 8 * data[smemPos+1] + data[smemPos+2];

		#if( MATCH_ROGER ) 
		{
			sum = (float)rintf(sum/8.0);
			if( sum > 127 ) sum = 127;
			if( sum < -127 ) sum = -127;
		}
		#endif

		d_Result[rowStart + writePos] = sum;
	}
}


/**********************************************************************
* derivative_y()
*
* This kernel calculates the derivative for an image in the y direction 
* using a [-1 8 0 -8 1] filter.
*
***********************************************************************/
__global__ void 
derivative_y(float *d_Result, float *d_Data, int image_width, int image_height, int pitch) {

	__shared__ float data[YGRAD_TILE_WIDTH*(2*FILTER1_RAD+YGRAD_TILE_HEIGHT)];

	//Current tile and apron limits, in rows
	const int         tileStart = IMUL(blockIdx.y, YGRAD_TILE_HEIGHT);
	const int           tileEnd = tileStart + YGRAD_TILE_HEIGHT - 1;
	const int        apronStart = tileStart - FILTER1_RAD;
	const int          apronEnd = tileEnd   + FILTER1_RAD;

	//Clamp tile and apron limits by image borders
	// const int    tileEndClamped = min(tileEnd, image_height - 1);
	const int apronStartClamped = max(apronStart, 0);
	const int   apronEndClamped = min(apronEnd, image_height - 1);

	//Current column index
	const int       columnStart = IMUL(blockIdx.x, YGRAD_TILE_WIDTH) + threadIdx.x;

	if(columnStart < image_width) {
		//Shared and global memory indices for current column
		int smemPos = IMUL(threadIdx.y, YGRAD_TILE_WIDTH) + threadIdx.x;
		int gmemPos = IMUL(apronStart + threadIdx.y, pitch) + columnStart;

		//Load global memory values, if indices are within the image borders,
		//or initialize with zero otherwise
		data[smemPos] = ((apronStart + threadIdx.y >= apronStartClamped) && (apronStart + threadIdx.y <= apronEndClamped)) 
				? d_Data[gmemPos] : 0;
	}
	
	__syncthreads();

	if(columnStart < image_width && threadIdx.y < YGRAD_TILE_HEIGHT && tileStart + threadIdx.y < image_height) {
		//Shared and global memory indices for current column
		int smemPos = IMUL(threadIdx.y + FILTER1_RAD, YGRAD_TILE_WIDTH) + threadIdx.x;
		int gmemPos = IMUL(tileStart + threadIdx.y, pitch) + columnStart;

		float sum = 0;

		if(!( ( columnStart < FILTER1_RAD ) || ( columnStart >= (image_width-FILTER1_RAD) ) || ( (tileStart + threadIdx.y) < FILTER1_RAD) || ( (tileStart + threadIdx.y) >= (image_height-FILTER1_RAD) ) ))
			sum = -1*data[smemPos-2*YGRAD_TILE_WIDTH] + 8*(data[smemPos-1*YGRAD_TILE_WIDTH] - data[smemPos+1*YGRAD_TILE_WIDTH]) + data[smemPos+2*YGRAD_TILE_WIDTH];
		
		#if( MATCH_ROGER != 0 ) 
		{
			sum = (float)rintf(sum/8.0);
			if( sum > 127 ) sum = 127;
			if( sum < -127 ) sum = -127;
		}
		#endif

		d_Result[gmemPos] = sum;
	}
}




/**********************************************************************
* derivative_t()
*
* This kernel calculates the derivative for an image in the time
* direction using a [-1 8 0 -8 1] filter on 5 different images.
*
***********************************************************************/
__global__ void 
derivative_t(float *d_Result, float *img0, float *img1, float *img2, float *img3, int width, int height, int pitch) {

	__shared__ float data[TGRAD_TILE_HEIGHT*TGRAD_TILE_WIDTH*2*FILTER1_RAD];

	const int columnStart = MUL(blockIdx.x, TGRAD_TILE_WIDTH) + threadIdx.x;
	const int rowStart = MUL(blockIdx.y, TGRAD_TILE_HEIGHT) + threadIdx.y;

    	const int columnClamped = min(columnStart, width-1);
	const int rowClamped = min(rowStart, height-1);

	const int tile_size = MUL(TGRAD_TILE_WIDTH,TGRAD_TILE_HEIGHT);

	int gmem = MUL(rowClamped, pitch) + columnClamped;

	// Cache tile in the shared memoy array
	int smem = MUL(threadIdx.y, TGRAD_TILE_WIDTH) + threadIdx.x;

	data[smem] = img0[gmem];
	data[smem + tile_size] = img1[gmem];
	data[smem + 2*tile_size] = img2[gmem];
	data[smem + 3*tile_size] = img3[gmem];

	__syncthreads();

    	// Filter output pixels per thread
	if (columnStart < width && rowStart < height) {
		float sum=0;

		if(!(columnStart<2 || columnStart>=width-2 || rowStart<2 || rowStart>=height-2))
			sum = -1*data[smem] + 8*data[smem+tile_size] - 8*data[smem+2*tile_size] + data[smem+3*tile_size];

		#if( MATCH_ROGER != 0 ) 
		{
			sum = (float)rintf(sum/8.0);
			if( sum > 127 ) sum = 127;
			if( sum < -127 ) sum = -127;
		}
		#endif

		d_Result[gmem] = sum;
	}
}




#endif // #ifndef _DERIV_KERNEL_H_




