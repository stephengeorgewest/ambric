
#ifndef _VELOCITY_KERNEL_H_
#define _VELOCITY_KERNEL_H_


__global__ void 
velocity_kernel(float *vx, float* vy, float *xx, float *yy, float *tt, float *xy, float *xt, float *yt, int img_width, int img_height, int pitch) {

	int idx = MUL(blockIdx.x, VELOCITY_TILE_WIDTH) + threadIdx.x;
	int idy = MUL(blockIdx.y, VELOCITY_TILE_HEIGHT) + threadIdx.y;
	int index = MUL(idy,pitch) + idx;

	if(idx < img_width && idy < img_height) {

		//shared memory is not used in this kernel, but none of these values will be accessed by other threads
		float tmp1x2 = xx[index] * yy[index]; //GxGx.*GyGy
		float tmp1x5 = xx[index] * yt[index]; //GxGx.*GyGt
		float tmp3x5 = xy[index] * yt[index]; //GxGy.*GyGt
		float tmp3x4 = xy[index] * xt[index]; //GxGy.*GxGt
		float tmp2x4 = yy[index] * xt[index]; //GyGy.*GxGt
		float tmp3x3 = xy[index] * xy[index]; //GxGy.*GxGy

		float Vx_dividend = tmp2x4 - tmp3x5;	//GyGy.*GxGt - GxGy.*GyGt
		float Vy_dividend = tmp1x5 - tmp3x4;	//GxGx.*GyGt - GxGy.*GxGt
		float divisor = tmp1x2 - tmp3x3;	//GxGx.*GyGy - GxGy.*GxGy

		float tempVx, tempVy;

		if( divisor == 0 ) {
			tempVx = 0;
			tempVy = 0;
		} else {
			tempVx = DIV(Vx_dividend, divisor);
			tempVy = DIV(Vy_dividend, divisor);
		}

		if( divisor < 0.5f ) {
			//k must be calculated, velocity recalculated - Roger recalculates velocity using the velocity calculated in the previous pixel 
			//(either to the left or up one pixel).  I am doing it using the velocity originally calculated for that pixel. 
			float k = (tt[index] - 2*xt[index]*tempVx - 2*yt[index]*tempVy + xx[index]*tempVx*tempVx + 2*xy[index]*tempVx*tempVy + yy[index]*tempVy*tempVy)/28.0f;
			
			float gxx_n = xx[index] + k;
			float gyy_n = yy[index] + k;

			tmp1x2 = gxx_n * gyy_n; 	//GxGx.*GyGy
			tmp1x5 = gxx_n * yt[index]; 	//GxGx.*GyGz
			tmp2x4 = gyy_n * xt[index]; 	//GyGy.*GxGz

			Vx_dividend = tmp2x4 - tmp3x5;	//GyGy.*GxGt - GxGy.*GyGt
			Vy_dividend = tmp1x5 - tmp3x4;	//GxGx.*GyGz - GxGy.*GxGz
			divisor = tmp1x2 - tmp3x3;	//GxGx.*GyGy - GxGy.*GxGy			

			if( divisor == 0 ) {
				tempVx = 0;
				tempVy = 0;
			} else {
				tempVx = DIV(Vx_dividend, divisor);
				tempVy = DIV(Vy_dividend, divisor);
			}
		}

		#if( MATCH_ROGER ) 
		{
			if( tempVx > 7 ) tempVx = 7;
			if( tempVx < -8 ) tempVx = -8;
			if( tempVy > 7 ) tempVy = 7;
			if( tempVy < -8 ) tempVy = -8;
		}
		#endif

		vx[index] = tempVx;
		vy[index] = tempVy;

	}

}



#endif // #ifndef _VELOCITY_KERNEL_H_
