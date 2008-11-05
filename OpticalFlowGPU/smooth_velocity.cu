
/* 
 * Device code.
 */

#ifndef _VSMOOTH_KERNEL_H_
#define _VSMOOTH_KERNEL_H_



/**********************************************************************
* smooth_velocity_x()
*
* This kernel calculates the convolution for an image in the x direction 
* using a [1 1 1 2 1 1 1] filter.  Non-tiled - works best if width is
* multiple of 16 or 32.  Only used when width <= 512, the max number
* of threads.
*
***********************************************************************/
extern __shared__ float sharedMemSV[];

__global__ void 
smooth_velocity_x(float *d_Result, float *d_Data, int width, int height, int pitch) {

	int I = threadIdx.x;
	int B = blockIdx.x;
	float* sequence = sharedMemSV;

	sequence[I] = d_Data[B*width + I];

	__syncthreads();

	float resultX = 0.0;

	if( !(I < 3 || I >= width-3) && !(B < 3 || B >= height-3) ) {
		//calculate gradient in the x direction
		resultX =  .125*sequence[I-3] + .125*sequence[I-2] + .125*sequence[I-1] + .25*sequence[I] + .125*sequence[I+1] + .125*sequence[I+2] + .125*sequence[I+3];
	}

	d_Result[B*width + I] = resultX; 
}

/**********************************************************************
* smooth_velocity_x_t()
*
* This kernel calculates the convolution for an image in the x direction 
* using a [1 1 1 2 1 1 1] filter.  Tiled - works for any image size.  A
* bit slower than non-tiled if width < 512 and is a multiple of 16.
*
***********************************************************************/
__global__ void 
smooth_velocity_x_t(float *d_Result, float *d_Data, int width, int height, int pitch) {

	__shared__ float data[FILTER5_RAD + XSMOOTHV_TILE_WIDTH + FILTER5_RAD];

	//Current tile and apron limits, relative to row start
	const int         tileStart = IMUL(blockIdx.x, XSMOOTHV_TILE_WIDTH);
	const int           tileEnd = tileStart + XSMOOTHV_TILE_WIDTH - 1;
	const int        apronStart = tileStart - FILTER5_RAD;
	const int          apronEnd = tileEnd   + FILTER5_RAD;

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
	if(loadPos >= apronStart){
	const int smemPos = loadPos - apronStart;

	data[smemPos] = 
	        ((loadPos >= apronStartClamped) && (loadPos <= apronEndClamped)) ?
	        d_Data[rowStart + loadPos] : 0;
	}

	__syncthreads();

	const int writePos = tileStart + threadIdx.x;
	//Assuming width and XSMOOTHV_TILE_WIDTH are multiples of half-warp size,
	//rowStart + tileStart is also a multiple of half-warp size,
	//thus having proper alignment for coalesced d_Result[] write.
	if(writePos <= tileEndClamped){
	const int smemPos = writePos - apronStart;
	float sum = 0;

	if(!(writePos<FILTER5_RAD || writePos>=width-FILTER5_RAD || blockIdx.y<FILTER5_RAD || blockIdx.y>=height-FILTER5_RAD))
		sum = .125*data[smemPos-3] + .125*data[smemPos-2] + .125*data[smemPos-1] + .25*data[smemPos] + .125*data[smemPos+1] + .125*data[smemPos+2] + .125*data[smemPos+3];

		d_Result[rowStart + writePos] = sum;
	}
}


/**********************************************************************
* smooth_velocity_y()
*
* This kernel calculates the convolution for an image in the y direction 
* using a [1 1 1 2 1 1 1] filter.
*
***********************************************************************/
__global__ void 
smooth_velocity_y(float *d_Result, float *d_Data, int image_width, int image_height, int pitch) {
    
	__shared__ float data[YSMOOTHV_TILE_WIDTH * (FILTER5_RAD + YSMOOTHV_TILE_HEIGHT + FILTER5_RAD)];

	//Current tile and apron limits, in rows
	const int         tileStart = IMUL(blockIdx.y, YSMOOTHV_TILE_HEIGHT);
	const int           tileEnd = tileStart + YSMOOTHV_TILE_HEIGHT - 1;
	const int        apronStart = tileStart - FILTER5_RAD;
	const int          apronEnd = tileEnd   + FILTER5_RAD;

	//Clamp tile and apron limits by image borders
	// const int    tileEndClamped = min(tileEnd, height - 1);
	const int apronStartClamped = max(apronStart, 0);
	const int   apronEndClamped = min(apronEnd, image_height - 1);

	//Current column index
	const int       columnStart = IMUL(blockIdx.x, YSMOOTHV_TILE_WIDTH) + threadIdx.x;

	if(columnStart < image_width) {
		//Shared and global memory indices for current column
		int smemPos = IMUL(threadIdx.y, YSMOOTHV_TILE_WIDTH) + threadIdx.x;
		int gmemPos = IMUL(apronStart + threadIdx.y, pitch) + columnStart;

		//Load global memory values, if indices are within the image borders,
		//or initialize with zero otherwise
		data[smemPos] = ((apronStart + threadIdx.y >= apronStartClamped) && (apronStart + threadIdx.y <= apronEndClamped)) ? d_Data[gmemPos] : 0;
	}
	
	__syncthreads();

	if(columnStart < image_width && threadIdx.y < YSMOOTHV_TILE_HEIGHT && tileStart + threadIdx.y < image_height) {
		//Shared and global memory indices for current column
		int smemPos = IMUL(threadIdx.y + FILTER5_RAD, YSMOOTHV_TILE_WIDTH) + threadIdx.x;
		int gmemPos = IMUL(tileStart + threadIdx.y, pitch) + columnStart;

		float sum = 0;

		if(!( ( columnStart < FILTER5_RAD ) || ( columnStart >= (image_width-FILTER5_RAD) ) || ( (tileStart + threadIdx.y) < FILTER5_RAD) || ( (tileStart + threadIdx.y) >= (image_height-FILTER5_RAD) ) ))
			sum = .125*data[smemPos-3*YSMOOTHV_TILE_WIDTH] + .125*data[smemPos-2*YSMOOTHV_TILE_WIDTH] + .125*data[smemPos-1*YSMOOTHV_TILE_WIDTH] + .25*data[smemPos] + .125*data[smemPos+1*YSMOOTHV_TILE_WIDTH] + .125*data[smemPos+2*YSMOOTHV_TILE_WIDTH] + .125*data[smemPos+3*YSMOOTHV_TILE_WIDTH];

		d_Result[gmemPos] = sum;
	}
}








#endif // #ifndef _VSMOOTH_KERNEL_H_


