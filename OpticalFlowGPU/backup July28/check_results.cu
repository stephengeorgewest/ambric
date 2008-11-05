

/***************************************************************************************
* check_results()
*
* Compares the results of the GPU calculation with that of the Matlab calculation. 
* Compares results for each step of the algorithm, depending on the step_num parameter.
****************************************************************************************/
void check_results( int step_num ) {

	FILE* results_files[3];

	switch( step_num ) {
		case 2:	
			printf("\nCreating output for step 2 results: Calculation of derivatives\n");
			float *h_deriv_x = (float*) malloc(width*height*sizeof(float));
			float *h_deriv_y = (float*) malloc(width*height*sizeof(float));
			float *h_deriv_t = (float*) malloc(width*height*sizeof(float));

			char x_result[40]; 
			char y_result[40]; 
			char t_result[40];
			
			for( int i=0; i<3; i++) {
				sprintf( x_result, "results/step2/x_results%d.txt", i);
				sprintf( y_result, "results/step2/y_results%d.txt", i);
				sprintf( t_result, "results/step2/t_results%d.txt", i);

				results_files[0] = fopen( x_result, "w" );
				results_files[1] = fopen( y_result, "w" );
				results_files[2] = fopen( t_result, "w" );

				CUDA_SAFE_CALL( cudaMemcpy2D( h_deriv_x, width*sizeof(float), deriv_x[i], d_pitch, width*sizeof(float), height, cudaMemcpyDeviceToHost));
				CUDA_SAFE_CALL( cudaMemcpy2D( h_deriv_y, width*sizeof(float), deriv_y[i], d_pitch, width*sizeof(float), height, cudaMemcpyDeviceToHost));
				CUDA_SAFE_CALL( cudaMemcpy2D( h_deriv_t, width*sizeof(float), deriv_t[i], d_pitch, width*sizeof(float), height, cudaMemcpyDeviceToHost));

				//printf("x deriv(%d) value: %f\n",i,h_deriv_x[34*width+140]);
				//printf("y deriv(%d) value: %f\n",i,h_deriv_y[34*width+140]);
				//printf("t deriv(%d) value: %f\n",i,h_deriv_t[34*width+140]);
				
				for( int j=0; j<height; j++) {
					for( int k=0; k<width; k++ ) {
						fprintf( results_files[0], "%f\t", h_deriv_x[j*width + k] );
						fprintf( results_files[1], "%f\t", h_deriv_y[j*width + k] );
						fprintf( results_files[2], "%f\t", h_deriv_t[j*width + k] );
					}

					fprintf( results_files[0], "\n" );
					fprintf( results_files[1], "\n" );
					fprintf( results_files[2], "\n" );
				}

				for( int j=0; j<3; j++ ) fclose( results_files[j] ); 
			}
			printf("Derivative results files created.\n");

			free(h_deriv_x);
			free(h_deriv_y);
			free(h_deriv_t);
		break;
		case 3:
			printf("\nCreating output for step 3 results: Temporal Smoothing\n");
			float *h_smooth_t = (float*) malloc(width*height*sizeof(float));
			float *h_conv_x = (float*) malloc(width*height*sizeof(float));
			float *h_conv_y = (float*) malloc(width*height*sizeof(float));

			char t_smooth_result[40];
			char x_conv_result[40];
			char y_conv_result[40];
			
			for( int i=0; i<3; i++) {
				sprintf( t_smooth_result, "results/step3/t_smoothed%d.txt", i);
				sprintf( x_conv_result, "results/step3/x_conv%d.txt", i);
				sprintf( y_conv_result, "results/step3/y_conv%d.txt", i);

				results_files[0] = fopen( t_smooth_result, "w" );
				results_files[1] = fopen( x_conv_result, "w" );
				results_files[2] = fopen( y_conv_result, "w" );

				CUDA_SAFE_CALL( cudaMemcpy2D( h_smooth_t, width*sizeof(float), smoothed[i], d_pitch, width*sizeof(float), height, cudaMemcpyDeviceToHost));				
				CUDA_SAFE_CALL( cudaMemcpy2D( h_conv_x, width*sizeof(float), convolved_x[i], d_pitch, width*sizeof(float), height, cudaMemcpyDeviceToHost));				
				CUDA_SAFE_CALL( cudaMemcpy2D( h_conv_y, width*sizeof(float), convolved_y[i], d_pitch, width*sizeof(float), height, cudaMemcpyDeviceToHost));

				//printf("t smooth value: %f\n",h_smooth_t[4*width+4]);
				
				for( int j=0; j<height; j++) {
					for( int k=0; k<width; k++ ) {
						fprintf( results_files[0], "%f\t", h_smooth_t[j*width + k] );
						fprintf( results_files[1], "%f\t", h_conv_x[j*width + k] );
						fprintf( results_files[2], "%f\t", h_conv_y[j*width + k] );
					}

					fprintf( results_files[0], "\n" );
					fprintf( results_files[1], "\n" );
					fprintf( results_files[2], "\n" );
				}

				for( int j=0; j<3; j++ ) fclose( results_files[j] );
			}
			printf("Smoothing results files created.\n");

			free(h_conv_x);
			free(h_conv_y);
			free(h_smooth_t);
		break;
		case 4:
			printf("\nCreating output for step 4 results: 2nd Order Smoothing\n");
			float *h_smooth2 = (float*) malloc(width*height*sizeof(float));
			float *h_conv2_x = (float*) malloc(width*height*sizeof(float));
			float *h_conv2_y = (float*) malloc(width*height*sizeof(float));

			char smooth2_result[40];
			char x_conv2_result[40];
			char y_conv2_result[40];
			
			for( int i=0; i<6; i++) {
				sprintf( smooth2_result, "results/step4/smoothed_2nd%d.txt", i);
				sprintf( x_conv2_result, "results/step4/x_conv2nd%d.txt", i);
				sprintf( y_conv2_result, "results/step4/y_conv2nd%d.txt", i);

				results_files[0] = fopen( smooth2_result, "w" );
				results_files[1] = fopen( x_conv2_result, "w" );
				results_files[2] = fopen( y_conv2_result, "w" );

				CUDA_SAFE_CALL( cudaMemcpy2D( h_smooth2, width*sizeof(float), smoothed_2nd[i], d_pitch, width*sizeof(float), height, cudaMemcpyDeviceToHost));								
				CUDA_SAFE_CALL( cudaMemcpy2D( h_conv2_x, width*sizeof(float), convolved2_x[i], d_pitch, width*sizeof(float), height, cudaMemcpyDeviceToHost));				
				CUDA_SAFE_CALL( cudaMemcpy2D( h_conv2_y, width*sizeof(float), convolved2_y[i], d_pitch, width*sizeof(float), height, cudaMemcpyDeviceToHost));


				//printf("smooth2 value: %f\n",h_smooth2[4*width+4]);
				
				for( int j=0; j<height; j++) {
					for( int k=0; k<width; k++ ) {
						fprintf( results_files[0], "%f\t", h_smooth2[j*width + k] );
						fprintf( results_files[1], "%f\t", h_conv2_x[j*width + k] );
						fprintf( results_files[2], "%f\t", h_conv2_y[j*width + k] );
					}

					fprintf( results_files[0], "\n" );
					fprintf( results_files[1], "\n" );
					fprintf( results_files[2], "\n" );
				}

				for( int j=0; j<3; j++ ) fclose( results_files[j] );
			}
			printf("Second order smoothing results files created.\n");

			free(h_conv2_x);
			free(h_conv2_y);
			free(h_smooth2);
		break;
		case 5:
			printf("\nCreating output for step 5 results: Velocity Calculation\n");
			float *h_vx = (float*) malloc(width*height*sizeof(float));
			float *h_vy = (float*) malloc(width*height*sizeof(float));

			char *vx_result = "results/step5/vx.txt";
			char *vy_result = "results/step5/vy.txt";
			
			results_files[0] = fopen( vx_result, "w" );
			results_files[1] = fopen( vy_result, "w" );

			CUDA_SAFE_CALL( cudaMemcpy2D( h_vx, width*sizeof(float), Vx, d_pitch, width*sizeof(float), height, cudaMemcpyDeviceToHost));				
			CUDA_SAFE_CALL( cudaMemcpy2D( h_vy, width*sizeof(float), Vy, d_pitch, width*sizeof(float), height, cudaMemcpyDeviceToHost));

			//printf("Vx value: %f\n",h_vx[34*width+140]);
			
			for( int j=0; j<height; j++) {
				for( int k=0; k<width; k++ ) {
					fprintf( results_files[0], "%f\t", h_vx[j*width + k] );
					fprintf( results_files[1], "%f\t", h_vy[j*width + k] );
				}

				fprintf( results_files[0], "\n" );
				fprintf( results_files[1], "\n" );
			}

			for( int j=0; j<2; j++ ) fclose( results_files[j] );

			printf("Velocity calculation results files created.\n");

			free(h_vx);
			free(h_vy);
		break;
		case 6:
			printf("\nCreating output for step 6 results: Smoothed Velocity\n");
			float *h_vx_smooth = (float*) malloc(width*height*sizeof(float));
			float *h_vy_smooth = (float*) malloc(width*height*sizeof(float));

			char *vx_sm_result = "results/step6/vx_sm.txt";
			char *vy_sm_result = "results/step6/vy_sm.txt";
			
			results_files[0] = fopen( vx_sm_result, "w" );
			results_files[1] = fopen( vy_sm_result, "w" );

			CUDA_SAFE_CALL( cudaMemcpy2D( h_vx_smooth, width*sizeof(float), Vx_y, d_pitch, width*sizeof(float), height, cudaMemcpyDeviceToHost));				
			CUDA_SAFE_CALL( cudaMemcpy2D( h_vy_smooth, width*sizeof(float), Vy_y, d_pitch, width*sizeof(float), height, cudaMemcpyDeviceToHost));

			//printf("smoothed Vx value: %f\n",h_vx_smooth[34*width+140]);
			//printf("smoothed Vy value: %f\n",h_vy_smooth[34*width+140]);
			
			for( int j=0; j<height; j++) {
				for( int k=0; k<width; k++ ) {
					fprintf( results_files[0], "%f\t", h_vx_smooth[j*width + k] );
					fprintf( results_files[1], "%f\t", h_vy_smooth[j*width + k] );
				}

				fprintf( results_files[0], "\n" );
				fprintf( results_files[1], "\n" );
			}

			for( int j=0; j<2; j++ ) fclose( results_files[j] );

			printf("Velocity calculation results files created.\n");

			free(h_vx_smooth);
			free(h_vy_smooth);
		break;
		default:
			printf("Results not verified - nothing to verify.\n");
	}
}


