# Add source files here
EXECUTABLE	:= flow08
# CUDA source files (compiled with cudacc)
CUFILES		:= flow08.cu
# CUDA dependency files
CU_DEPS		:= \
	flow08.cu \

# C/C++ source files (compiled with gcc / c++)
CCFILES		:= \


################################################################################
# Rules and targets

rel: ../../bin/linux/release/$(EXECUTABLE)
	cp ../../bin/linux/release/$(EXECUTABLE) /home/CHREC/hawk/release/OpticalFlow2008/$(EXECUTABLE)

include ../../common/common.mk
