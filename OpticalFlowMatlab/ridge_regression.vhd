------------------------------------------------------------------------------
--
-- FILE:                ridge_regression.vhd
-- AUTHOR:              Zhaoyi Wei
-- CREATED:             3.16.2008
-- REVISED:	   7.20.2008 for incorport 1D LPF generics into the code
-- ORGINIZATION:        Brigham Young University
--                      Dept. Electrical and Computer Engineering
--                      Robot Vision Lab
-- Description:		This file contains the logic for ridge_regression calculation.
--				Ridge regression uses the velocity of right above pixel and 6 
--				tensor components to calculate the offset added onto the tensor
--				componenets. To align the velocity, a fifo is used to buffer up
--				the velocity. 
--				In plb_ofc_1.00 b, we incorporate the 1D low pass filter which 
--				will introduce new latency to the velocity. Therefore, this module
--				also needs to know whether the 1D low pass filter is applied or not
--				in order to apply the correct latency in the alignment.
-----------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library proc_common_v1_00_b;
use proc_common_v1_00_b.proc_common_pkg.all;

entity ridge_regression is
  generic
  (
    C_COL_NUM  				: integer	:= 630; --626; 
    C_ROW_NUM  				: integer	:= 470; --470; 
  	C_K_SHIFT_BITS			: integer	:= 3;
	C_1D_LPF_SCALE			: integer	:= 4
  );
  port
  (
  	la						: out	std_logic_vector(15 downto 0);
  	cs_trig					: out	std_logic;
  	cs_data1				: out	std_logic_vector(199 downto 0);
  	cs_data2				: out	std_logic_vector(199 downto 0);
  	
  	clk						: in	std_logic;
  	rst						: in	std_logic;
  		
  	dxdx					: in	std_logic_vector(15 downto 0);
  	dydy					: in	std_logic_vector(15 downto 0);
  	dtdt					: in	std_logic_vector(15 downto 0);
  	dxdy					: in	std_logic_vector(15 downto 0);
  	dxdt					: in	std_logic_vector(15 downto 0);
  	dydt					: in	std_logic_vector(15 downto 0);
  	d_valid					: in	std_logic;
  	
  	vx						: in	std_logic_vector(15 downto 0);  --4.12 format
  	vy						: in	std_logic_vector(15 downto 0);
  	v_done					: in	std_logic;
  	v_valid					: in	std_logic;
  		
  	k						: out	std_logic_vector(15 downto 0);
  	dxdx_new				: out	std_logic_vector(15 downto 0);
  	dydy_new				: out	std_logic_vector(15 downto 0);
  	dtdt_new				: out	std_logic_vector(15 downto 0);
  	dxdy_new				: out	std_logic_vector(15 downto 0);
  	dxdt_new				: out	std_logic_vector(15 downto 0);
  	dydt_new				: out	std_logic_vector(15 downto 0);
  	out_valid				: out	std_logic
  );
end entity ridge_regression;

architecture IMP of ridge_regression is
	component v_fifo1 IS
	port (
		din: IN std_logic_VECTOR(31 downto 0);
		rd_clk: IN std_logic;
		rd_en: IN std_logic;
		rst: IN std_logic;
		wr_clk: IN std_logic;
		wr_en: IN std_logic;
		dout: OUT std_logic_VECTOR(31 downto 0);
		empty: OUT std_logic;
		full: OUT std_logic);
	end component;

	component rr_fifo1
	port (
		din: IN std_logic_VECTOR(95 downto 0);
		rd_clk: IN std_logic;
		rd_en: IN std_logic;
		rst: IN std_logic;
		wr_clk: IN std_logic;
		wr_en: IN std_logic;
		dout: OUT std_logic_VECTOR(95 downto 0);
		empty: OUT std_logic;
		full: OUT std_logic);
	end component;
	component division_8_8 is
	port
	(
		clk                            : in std_logic;
		rst                            : in std_logic;
		-- input data
		dividend                       : in std_logic_vector(31 downto 0);
		divisor                        : in std_logic_vector(31 downto 0);
		-- out put data
		quot                           : out std_logic_vector(15 downto 0);
		frac                           : out std_logic_vector(15 downto 0);
		-- inverse table entity
		num_to_inv                     : out std_logic_vector(7 downto 0);
		num_fr_inv                     : in  std_logic_vector(16 downto 0);
		div_en                         : out std_logic;
		-- ce
		in_valid                       : in  std_logic;
		out_valid                      : out std_logic
	);
	end component;
	component inv_table is
	port (
		clk 		 : in std_logic;
		we			 : in std_logic;
		addr_a       : in std_logic_vector(7 downto 0);
		addr_b       : in std_logic_vector(7 downto 0);
		din			 : in std_logic_vector(16 downto 0);
		doa		     : out std_logic_vector(16 downto 0);
		dob		     : out std_logic_vector(16 downto 0)
	);
	end component;
	
	--constant FIFO1_LATENCY								: unsigned := TO_UNSIGNED(C_COL_NUM-22, 16);
	constant FIFO1_LATENCY								: unsigned := TO_UNSIGNED(C_COL_NUM-10, 16);
	signal fifo1_cnt									: unsigned(15 downto 0);
	signal fifo1_rd, fifo1_wr, fifo1_empty, fifo1_full	: std_logic;
	signal der_cat, der_out2							: std_logic_vector(95 downto 0);
	signal v_out1										: std_logic_vector(31 downto 0);
	signal vx_d, vy_d									: std_logic_vector(15 downto 0);
	signal vx_d1, vy_d1									: std_logic_vector(15 downto 0);
	--signal fifo1_cnt_incr								: std_logic;
	--constant FIFO2_LATENCY								: unsigned := TO_UNSIGNED(11, 8);
	--signal fifo2_cnt									: unsigned(7 downto 0);
	
	--signal dxdx_d1, dydy_d1, dtdt_d1, dxdy_d1, dxdt_d1, dydt_d1: signed(15 downto 0);
	signal dxdx_d2, dydy_d2, dtdt_d2, dxdy_d2, dxdt_d2, dydt_d2: std_logic_vector(15 downto 0);
	signal dxdx_new_sg, dydy_new_sg, dtdt_new_sg, dxdy_new_sg, dxdt_new_sg, dydt_new_sg : std_logic_vector(15 downto 0);
	
	signal i1_1													: signed(31 downto 0);  --intermediate variables
	signal i2_1, i3_1											: signed(31 downto 0);
	signal i4_1, i5_1, i6_1										: signed(31 downto 0);
	signal i7_1, i8_1											: signed(31 downto 0);
	signal i1_2													: signed(31 downto 0);
	signal i2_2, i3_2											: signed(47 downto 0);  --intermediate variables
	signal i4_2, i5_2, i6_2										: signed(47 downto 0);
	signal i7_2, i8_2											: signed(31 downto 0);
	signal i_valid1, i_valid2									: std_logic;
	signal sum0_lv0, sum1_lv0, sum2_lv0							: signed(32 downto 0);
	signal sum0_lv1, sum1_lv1									: signed(33 downto 0);
	signal sum0_lv2												: signed(34 downto 0);
	signal sum3_lv0												: signed(32 downto 0);
	signal sum2_lv1												: signed(33 downto 0);
	signal sum1_lv2												: signed(34 downto 0);
	signal sum_lv0_valid, sum_lv1_valid, sum_lv2_valid, divide_valid: std_logic;
	signal fifo2_rd, fifo2_empty								: std_logic;	
	signal divisor, dividend									: std_logic_vector(31 downto 0);
	signal vx_rg, vy_rg											: std_logic_vector(15 downto 0);
	--signal sum0_lv2											
	
	signal v_cat												: std_logic_vector(31 downto 0);
	signal quot, remd											: std_logic_vector(15 downto 0);
	signal num_to_inv_a, num_to_inv_b							: std_logic_vector(7 downto 0);
	signal num_fr_inv_a, num_fr_inv_b							: std_logic_vector(16 downto 0);
	signal div_valid											: std_logic;	
	
begin
	cs_trig					 <= d_valid;
	
	cs_data1(199)			 <= d_valid;
	cs_data1(198 downto 183) <= dxdx;
	cs_data1(182 downto 167) <= dydy;
	cs_data1(166 downto 151) <= dtdt;
	cs_data1(150 downto 135) <= dxdy;
	cs_data1(134 downto 119) <= dxdt;
	cs_data1(118 downto 103) <= dydt;
	cs_data1(102)			 <= v_valid;
	cs_data1(101 downto 86)	 <= vx;
	cs_data1(85  downto 70)  <= vy;
	--cs_data1(69  downto 62)  <= std_logic_vector(fifo1_cnt);
	cs_data1(61  downto 30)  <= dividend;
	cs_data1(29	 downto 0)	 <= divisor(29 downto 0);
	
	cs_data2(199)			 <= sum_lv2_valid;
	cs_data2(198 downto 167) <= dividend;
	cs_data2(166 downto 135) <= divisor;
	cs_data2(134 downto 119) <= quot;
	cs_data2(118 downto 103) <= remd;
	cs_data2(102 downto 87)  <= dxdx_new_sg;
	cs_data2(86  downto 71)  <= dydy_new_sg;
	cs_data2(70  downto 55)  <= dtdt_new_sg;
	cs_data2(54  downto 39)  <= dxdy_new_sg;
	cs_data2(38  downto 23)  <= dxdt_new_sg;
	cs_data2(22  downto 7)   <= dydt_new_sg;
	cs_data2(6)				 <= div_valid;
	
	FIFO_CNT_SM: process(clk, rst)
	begin
		if clk'event and clk = '1' then
			if rst = '1' then
				fifo1_cnt <= (others => '0');
			else
				if v_valid = '1' and fifo1_cnt < FIFO1_LATENCY-1 then
					fifo1_cnt <= fifo1_cnt + 1;
				elsif v_done = '1' then
					fifo1_cnt <= (others => '0');
				end if;
				
				--if fifo1_rd = '1' and fifo2_cnt < FIFO2_LATENCY - 1 then
				--	fifo2_cnt <= fifo2_cnt + 1;
				--elsif fifo2_empty = '1' then
				--	fifo2_cnt <= (others => '0');
				--end if;
			end if;
		end if;
	end process FIFO_CNT_SM;
	
	fifo1_rd <= d_valid when fifo1_cnt = FIFO1_LATENCY-1 else '0';  --fifo1_rd is v_valid when data in fifo1 have enough delay
	fifo1_wr <= v_valid;
	fifo2_rd <= div_valid;
	
	v_cat	<= vx & vy;
	--vx_d1	<= v_out1(31 downto 16) when fifo1_cnt = FIFO1_LATENCY-1 else X"1000";
	--vy_d1	<= v_out1(15 downto 0)	when fifo1_cnt = FIFO1_LATENCY-1 else X"1000";
	der_cat	<= std_logic_vector(dxdx & dydy & dtdt & dxdy & dxdt & dydt);
	--dxdx_d1	<= signed(der_out1(95 downto 80));
	--dydy_d1	<= signed(der_out1(79 downto 64));
	--dtdt_d1	<= signed(der_out1(63 downto 48));
	--dxdy_d1	<= signed(der_out1(47 downto 32));
	--dxdt_d1	<= signed(der_out1(31 downto 16));
	--dydt_d1	<= signed(der_out1(15 downto 0));
	
	I_RG: process(clk, rst)
	begin
		if clk'event and clk = '1' then
			if fifo1_cnt = FIFO1_LATENCY-1 then
				vx_d1 <= v_out1(31 downto 16);
				vy_d1 <= v_out1(15 downto 0);
			else
				vx_d1 <= X"1000";
				vy_d1 <= X"1000";
			end if;
		
			vx_d <= vx_d1;
			vy_d <= vy_d1;
			
			i_valid1<= d_valid;
			i1_1<= signed(dtdt) * 4096;
			i2_1<= -2 * signed(dxdt);
			i3_1<= -2 * signed(dydt);
			i4_1<= signed(dxdx) * signed(vx_d);
			i5_1<= shift_left(signed(dxdy) * signed(vx_d), 1);
			i6_1<= signed(dydy) * signed(vy_d);
			i7_1<= signed(vx_d) * signed(vx_d);
			i8_1<= signed(vy_d) * signed(vy_d);
			
			vx_rg <= vx_d;
			vy_rg <= vy_d;
			i_valid2<= i_valid1;
			i1_2<= i1_1;
			i2_2<= i2_1 * signed(vx_rg);
			i3_2<= i3_1 * signed(vy_rg);
			i4_2<= i4_1 * signed(vx_rg);
			i5_2<= i5_1 * signed(vy_rg);
			i6_2<= i6_1 * signed(vy_rg);
			i7_2<= i7_1;
			i8_2<= i8_1;
		end if;
	end process;

	
	DIV_SUM: process(clk, rst)
	begin
		if clk'event and clk = '1' then
			sum_lv0_valid <= '0';
			if i_valid2 = '1' then
				sum_lv0_valid <= '1';
				sum0_lv0 <= resize(i1_2, 33) + resize(i2_2, 33);
				sum1_lv0 <= resize(i3_2, 33) + resize(i4_2(43 downto 12), 33);
				sum2_lv0 <= resize(i5_2(43 downto 12), 33) + resize(i6_2(43 downto 12), 33);
				
				sum3_lv0 <= resize(i7_2, 33) + resize(i8_2, 33);
			end if;
			sum0_lv1 <= resize(sum0_lv0, 34) + resize(sum1_lv0, 34);
			sum1_lv1 <= resize(sum2_lv0, 34);
			
			sum2_lv1 <= resize(sum3_lv0, 34);
			sum_lv1_valid <= sum_lv0_valid;
			
			sum0_lv2 <= resize(sum0_lv1, 35) + resize(sum1_lv1, 35);
			sum1_lv2 <= resize(sum2_lv1, 35);
			sum_lv2_valid <= sum_lv1_valid;
		end if;
	end process DIV_SUM;
	dividend<= std_logic_vector(sum0_lv2(31 downto 0));
	divisor	<= std_logic_vector(sum1_lv2(31 downto 0));
	
	FIFO1: v_fifo1
	port map(
		din		=>  v_cat,
		rd_clk	=>	clk,
		rd_en	=>	fifo1_rd,
		rst		=>	v_done,
		wr_clk	=>	clk,
		wr_en	=>	fifo1_wr,
		dout	=>	v_out1,
		empty	=>	fifo1_empty,
		full	=>	fifo1_full
	);
	
	dxdx_d2	<= der_out2(95 downto 80);
	dydy_d2	<= der_out2(79 downto 64);
	dtdt_d2	<= der_out2(63 downto 48);
	dxdy_d2	<= der_out2(47 downto 32);
	dxdt_d2	<= der_out2(31 downto 16);
	dydt_d2	<= der_out2(15 downto 0);
	
	SUM_PROC: process(clk, rst)
	begin
		if clk'event and clk = '1' then
			k		 <= quot;
			out_valid<= div_valid;			
			
			dxdx_new_sg <= std_logic_vector(signed(dxdx_d2) + signed(quot));
			dydy_new_sg	<= std_logic_vector(signed(dydy_d2) + signed(quot));
			dtdt_new_sg	<= dtdt_d2;
			dxdy_new_sg	<= dxdy_d2;
			dxdt_new_sg	<= dxdt_d2;
			dydt_new_sg	<= dydt_d2;	
		end if;
	end process SUM_PROC;
	
	dxdx_new <= dxdx_new_sg;
	dydy_new <=	dydy_new_sg;
	dtdt_new <=	dtdt_new_sg;
	dxdy_new <=	dxdy_new_sg;
	dxdt_new <=	dxdt_new_sg;
	dydt_new <=	dydt_new_sg;
			
	FIFO2: rr_fifo1
	port map(
		din		=>  der_cat,
		rd_clk	=>	clk,
		rd_en	=>	fifo2_rd,
		rst		=>	rst,
		wr_clk	=>	clk,
		wr_en	=>	d_valid,
		dout	=>	der_out2,
		empty	=>	fifo2_empty,
		full	=>	open
	);
	
	K_CALC : division_8_8
	port map
	(
		clk                            => clk,
		rst                            => rst,
		-- input data
		dividend                       => dividend,
		divisor                        => divisor,
		-- out put data
		quot                           => quot,
		frac                           => remd,
		-- inverse table entity
		num_to_inv                     => num_to_inv_a,
		num_fr_inv                     => num_fr_inv_a,
		div_en                         => open,
		-- ce
		in_valid                       => sum_lv2_valid,
		out_valid                      => div_valid
	);
	INV_TABLE_0 : inv_table
	port map (
		clk 		 => clk,
		we			 => '0',
		addr_a       => num_to_inv_a,
		addr_b       => num_to_inv_b,
		din			 => "00000000000000000",
		doa		     => num_fr_inv_a,
		dob		     => num_fr_inv_b
	);
end IMP;