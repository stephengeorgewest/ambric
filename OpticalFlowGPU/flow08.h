#ifndef _FLOW08_H_
#define _FLOW08_H_

// preprocessor defines
#define MAX_IMAGES 32
#define NUM_IMAGES 7
#define PADDED 1
#define MATCH_ROGER 0	

#define MUL(A,B) __mul24(A, B)
#define DIV(A,B) fdividef(A, B)
#define IMUL(x,y) __mul24(x,y)
#define IDIV(x, y) ((int)((x) / (float)(y)))
//#define IMAGE_WIDTH 352
//#define IMAGE_HEIGHT 240

// global variables
int width, height, total_images;
char seq_name[20];
float** sequence;
unsigned int timer=0;
static unsigned int d_pitch;
static int width_in_bytes;
float *vx_final, *vy_final;

// declaration, forward
//int readRawImage(char *path, float *img, int width, int height, int seq);
__global__ void empty_kernel() {}
void check_results( int step_num );


// STEP 2: CALCULATE DERIVATIVES ------------------------------------------------------------------
#define XGRAD_TILE_WIDTH 320 
#define YGRAD_TILE_WIDTH 16
#define YGRAD_TILE_HEIGHT 20
#define TGRAD_TILE_WIDTH 64
#define TGRAD_TILE_HEIGHT 1
#define FILTER1_RAD 2		// [-1 8 0 -8 1]
#define FILTER_RAD_ALIGNED 16

// global variables for derivative
static dim3 xgrid1,ygrid1,tgrid1,xblock1,yblock1,tblock1;
static int pitch1;
float* d_img[NUM_IMAGES];
float* deriv_x[3], *deriv_y[3], *deriv_t[3];

// derivative kernels
__global__ void derivative_x(float *d_Result, float *d_Data, int width, int height, int pitch);
__global__ void derivative_x_t(float *d_Result, float *d_Data, int width, int height, int pitch);
__global__ void derivative_y(float *d_Result, float *d_Data, int width, int height, int pitch);
__global__ void derivative_t(float *d_Result, float *img0, float *img1, float *img2, float *img3, int width, int height, int pitch);
// END CALCULATE DERIVATIVES ----------------------------------------------------------------------




// STEP 3: TEMPORAL SMOOTHING    ------------------------------------------------------------------
#define TSMOOTH_TILE_WIDTH 64
#define TSMOOTH_TILE_HEIGHT 1
#define XCONV_TILE_WIDTH 320 
#define YCONV_TILE_WIDTH 16
#define YCONV_TILE_HEIGHT 20 	// 18?
#define FILTER2_RAD 1		// [2 4 2]
#define FILTER3_RAD 2		// [3 3 4 3 3]

// global variables for temporal smoothing
static dim3 xgrid2,ygrid2,tgrid2,xblock2,yblock2,tblock2;
static int pitch2;
float* smoothed[3];
float* convolved_x[3];
float* convolved_y[3];

// temporal smoothing kernels
__global__ void smooth_t(float *d_Result, float *frame0, float *frame1, float *frame2, int width, int height, int pitch);
__global__ void convolve_x(float *d_Result, float *d_Data, int width, int height, int pitch);
__global__ void convolve_x_t(float *d_Result, float *d_Data, int width, int height, int pitch);
__global__ void convolve_y(float *d_Result, float *d_Data, int width, int height, int pitch);
// END TEMPORAL SMOOTHING    ----------------------------------------------------------------------




// STEP 4: 2ND ORDER SMOOTHING    -----------------------------------------------------------------
#define SMOOTH2_TILE_WIDTH 32
#define SMOOTH2_TILE_HEIGHT 2
#define XCONV2_TILE_WIDTH 320 
#define YCONV2_TILE_WIDTH 16
#define YCONV2_TILE_HEIGHT 20 
#define XYCONV_TILE_WIDTH 16
#define XYCONV_TILE_HEIGHT 12//20 makes this have too many threads 
#define FILTER4_RAD 1		// [5 6 5]

// global variables for smoothing
static dim3 grid3,block3,xgrid3,ygrid3,xblock3,yblock3, xygrid, xyblock;
static int pitch3;
float* smoothed_2nd[6]; //stored in this order: [xx yy tt xy xt yt]
float* convolved2_x[6];
float* convolved2_y[6];

// 2nd order smoothing kernels
__global__ void second_smooth(float *gx, float *gy, float *gt, float *xx, float *yy, float *tt, float *xy, float *xt, float *yt, int width, int height, int pitch);
__global__ void second_smooth_match(float *gx, float *gy, float *gt, float *xx, float *yy, float *tt, float *xy, float *xt, float *yt, int width, int height, int pitch);
__global__ void convolve2_x(float *d_Result, float *d_Data, int width, int height, int pitch);
__global__ void convolve2_x_t(float *d_Result, float *d_Data, int width, int height, int pitch);
__global__ void convolve2_y(float *d_Result, float *d_Data, int width, int height, int pitch);
__global__ void convolve_xy_t(float *d_Result, float *d_Data, int width, int height, int pitch);
__global__ void convolve_xy(float *d_Result, float *d_Data, int width, int height);
// END 2ND ORDER SMOOTHING    ---------------------------------------------------------------------




// STEP 5: CALCULATE VELOCITY    ------------------------------------------------------------------
#define VELOCITY_TILE_WIDTH 32
#define VELOCITY_TILE2_WIDTH 320
#define VELOCITY_TILE_HEIGHT 4

// global variables for velocity
static dim3 grid4,block4; 
static int pitch4;
float* Vx; //[2]; // one for old, one for new?
float* Vy; //[2];

__global__ void velocity_kernel(float *vx, float *vy, float *xx, float *yy, float *tt, float *xy, float *xt, float *yt, int img_width, int img_height, int pitch);
// END CALCULATE VELOCITY    ----------------------------------------------------------------------




// STEP 6: SMOOTH VELOCITY    ------------------------------------------------------------------
#define XSMOOTHV_TILE_WIDTH 320 
#define YSMOOTHV_TILE_WIDTH 16
#define YSMOOTHV_TILE_HEIGHT 18 
#define FILTER5_RAD 3		// [1 1 1 2 1 1 1]

// global variables for smoothing
static dim3 xgrid5,ygrid5,xblock5,yblock5;
static int pitch5;
float *Vx_x, *Vy_x; 
float *Vx_y, *Vy_y; 

__global__ void smooth_velocity_x(float *d_Result, float *d_Data, int width, int height, int pitch);
__global__ void smooth_velocity_x_t(float *d_Result, float *d_Data, int width, int height, int pitch);
__global__ void smooth_velocity_y(float *d_Result, float *d_Data, int width, int height, int pitch);
// END CALCULATE VELOCITY    ----------------------------------------------------------------------

#endif
