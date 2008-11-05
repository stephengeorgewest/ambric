

void init_flow() {

	//************** DERIVATIVES ***********************
	width_in_bytes = width*sizeof(float);
	
	//allocate device memory for image sequence
	for(int i=0; i<NUM_IMAGES; i++) {
		CUDA_SAFE_CALL( cudaMallocPitch( (void**) &d_img[i], &d_pitch, width_in_bytes, height) );
		CUDA_SAFE_CALL( cudaMemcpy2D( d_img[i], d_pitch, sequence[i], width_in_bytes, width_in_bytes, height, cudaMemcpyHostToDevice));
	}

	//allocate device memory for results
	for( int i=0; i<3; i++ ) {
		CUDA_SAFE_CALL( cudaMallocPitch( (void**) &deriv_x[i], &d_pitch, width_in_bytes, height) );
		CUDA_SAFE_CALL( cudaMallocPitch( (void**) &deriv_y[i], &d_pitch, width_in_bytes, height) );
		CUDA_SAFE_CALL( cudaMallocPitch( (void**) &deriv_t[i], &d_pitch, width_in_bytes, height) );
	}

	if( !PADDED ) d_pitch = width_in_bytes;

	//configure block and grid dimensions for grad/derivative calculation
	xgrid1 = dim3((width+XGRAD_TILE_WIDTH-1)/XGRAD_TILE_WIDTH, height);
	xblock1 = FILTER_RAD_ALIGNED+XGRAD_TILE_WIDTH+FILTER1_RAD;

	ygrid1 = dim3((width+YGRAD_TILE_WIDTH-1)/YGRAD_TILE_WIDTH, (height+YGRAD_TILE_HEIGHT-1)/YGRAD_TILE_HEIGHT);
	yblock1 = dim3(YGRAD_TILE_WIDTH, YGRAD_TILE_HEIGHT + 2*FILTER1_RAD);

	tgrid1 = dim3((width+TGRAD_TILE_WIDTH-1)/TGRAD_TILE_WIDTH, (height+TGRAD_TILE_HEIGHT-1)/TGRAD_TILE_HEIGHT);
	tblock1 = dim3(TGRAD_TILE_WIDTH,TGRAD_TILE_HEIGHT);

	pitch1 = d_pitch/sizeof(float);


	
	//************** TMP SMOOTHING ***********************
	//allocate device memory for results
	for( int i=0; i<3; i++ ) {
		CUDA_SAFE_CALL( cudaMallocPitch( (void**) &smoothed[i], &d_pitch, width_in_bytes, height) );
		CUDA_SAFE_CALL( cudaMallocPitch( (void**) &convolved_x[i], &d_pitch, width_in_bytes, height) );
		CUDA_SAFE_CALL( cudaMallocPitch( (void**) &convolved_y[i], &d_pitch, width_in_bytes, height) );
	}

	if( !PADDED ) d_pitch = width_in_bytes;

	tgrid2 = dim3((width+TSMOOTH_TILE_WIDTH-1)/TSMOOTH_TILE_WIDTH, (height+TSMOOTH_TILE_HEIGHT-1)/TSMOOTH_TILE_HEIGHT);
	tblock2 = dim3(TSMOOTH_TILE_WIDTH,TSMOOTH_TILE_HEIGHT);
	
	xgrid2 = dim3((width+XCONV_TILE_WIDTH-1)/XCONV_TILE_WIDTH, height);
	xblock2 = FILTER_RAD_ALIGNED+XCONV_TILE_WIDTH+FILTER3_RAD;

	ygrid2 = dim3((width+YCONV_TILE_WIDTH-1)/YCONV_TILE_WIDTH, (height+YCONV_TILE_HEIGHT-1)/YCONV_TILE_HEIGHT);
	yblock2 = dim3(YCONV_TILE_WIDTH, YCONV_TILE_HEIGHT + 2*FILTER3_RAD);

	pitch2 = d_pitch/sizeof(float);


	//************** 2ND ORDER SMOOTHING *****************
	for( int i=0; i<6; i++ ) {
		CUDA_SAFE_CALL( cudaMallocPitch( (void**) &smoothed_2nd[i], &d_pitch, width_in_bytes, height) );
		CUDA_SAFE_CALL( cudaMallocPitch( (void**) &convolved2_x[i], &d_pitch, width_in_bytes, height) );
		CUDA_SAFE_CALL( cudaMallocPitch( (void**) &convolved2_y[i], &d_pitch, width_in_bytes, height) );
	}
	
	grid3 = dim3((width+SMOOTH2_TILE_WIDTH-1)/SMOOTH2_TILE_WIDTH, (height+SMOOTH2_TILE_HEIGHT-1)/SMOOTH2_TILE_HEIGHT);
	block3 = dim3(SMOOTH2_TILE_WIDTH,SMOOTH2_TILE_HEIGHT);

	xgrid3 = dim3((width+XCONV2_TILE_WIDTH-1)/XCONV2_TILE_WIDTH, height);
	xblock3 = FILTER_RAD_ALIGNED+XCONV2_TILE_WIDTH+FILTER4_RAD;

	ygrid3 = dim3((width+YCONV2_TILE_WIDTH-1)/YCONV2_TILE_WIDTH, (height+YCONV2_TILE_HEIGHT-1)/YCONV2_TILE_HEIGHT);
	yblock3 = dim3(YCONV2_TILE_WIDTH, YCONV2_TILE_HEIGHT + 2*FILTER4_RAD);

	xygrid = dim3((width+XYCONV_TILE_WIDTH-1)/XYCONV_TILE_WIDTH, (height+XYCONV_TILE_HEIGHT-1)/XYCONV_TILE_HEIGHT);
	xyblock = dim3(FILTER_RAD_ALIGNED+XYCONV_TILE_WIDTH+FILTER4_RAD, XYCONV_TILE_HEIGHT + 2*FILTER4_RAD);

	pitch3 = d_pitch/sizeof(float);


	//************** VELOCITY CALCULATION ****************
	CUDA_SAFE_CALL( cudaMallocPitch( (void**) &Vx, &d_pitch, width_in_bytes, height) );
	CUDA_SAFE_CALL( cudaMallocPitch( (void**) &Vy, &d_pitch, width_in_bytes, height) );

	grid4 = dim3((width+VELOCITY_TILE_WIDTH-1)/VELOCITY_TILE_WIDTH, (height+VELOCITY_TILE_HEIGHT-1)/VELOCITY_TILE_HEIGHT);
	block4 = dim3(VELOCITY_TILE_WIDTH,VELOCITY_TILE_HEIGHT);

	pitch4 = d_pitch/sizeof(float);


	//************** VELOCITY SMOOTHING *****************
	CUDA_SAFE_CALL( cudaMallocPitch( (void**) &Vx_x, &d_pitch, width_in_bytes, height) );
	CUDA_SAFE_CALL( cudaMallocPitch( (void**) &Vy_x, &d_pitch, width_in_bytes, height) );
	CUDA_SAFE_CALL( cudaMallocPitch( (void**) &Vx_y, &d_pitch, width_in_bytes, height) );
	CUDA_SAFE_CALL( cudaMallocPitch( (void**) &Vy_y, &d_pitch, width_in_bytes, height) );

	xgrid5 = dim3((width+XSMOOTHV_TILE_WIDTH-1)/XSMOOTHV_TILE_WIDTH, height);
	xblock5 = FILTER_RAD_ALIGNED+XSMOOTHV_TILE_WIDTH+FILTER5_RAD;

	ygrid5 = dim3((width+YSMOOTHV_TILE_WIDTH-1)/YSMOOTHV_TILE_WIDTH, (height+YSMOOTHV_TILE_HEIGHT-1)/YSMOOTHV_TILE_HEIGHT);
	yblock5 = dim3(YSMOOTHV_TILE_WIDTH, YSMOOTHV_TILE_HEIGHT + 2*FILTER5_RAD);

	pitch5 = d_pitch/sizeof(float);


	//GET RESULTS
	CUDA_SAFE_CALL( cudaMallocHost( (void**) &vx_final, width*height*sizeof(float)));
	CUDA_SAFE_CALL( cudaMallocHost( (void**) &vy_final, width*height*sizeof(float)));
	//vx_final = (float*) malloc(width*height*sizeof(float));
	//vy_final = (float*) malloc(width*height*sizeof(float));



}
