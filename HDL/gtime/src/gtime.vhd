----------------------------------------------------------------------------------
-- Company:        www.mlab.cz
-- Based on code written by MIHO.
-- 
-- HW Design Name: S3AN01A
-- Project Name:   gtime
-- Target Devices: XC3S50AN-4
-- Tool versions:  ISE 13.3
-- Description:    Time and frequency synchronisation for RDMS01A.
--
-- Dependencies:   CLKGEN01B, GPS01A, STM32F10xRxT01A
--
-- Version:  $Id: gtime.vhd 3223 2013-07-25 22:41:43Z kakl $
--
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

library UNISIM;
use UNISIM.vcomponents.all;

entity gtime is
	generic (
		--	Top Value for 100MHz Clock Counter
		MAXCOUNT:	integer	:=	10_000;				-- Maximum for the first counter
		MUXCOUNT:	integer	:=	100_000				--	LED Display Multiplex Clock Divider
	);
	port (
		-- Clock on PCB
		CLK100MHz:	in		std_logic;
		
		-- Mode Signals (usualy not used)
		M:				in		std_logic_vector(2 downto 0);
		VS:			in		std_logic_vector(2 downto 0);

		-- Dipswitch Inputs
		DIPSW:		in		std_logic_vector(7 downto 0);

		-- Push Buttons
		PB:			in		std_logic_vector(3 downto 0);

		-- LED Bar Outputs
		LED:			out	std_logic_vector(7 downto 0);

		--	LED Display (8 digit with 7 segments and ddecimal point)
		LD_A_n:		out	std_logic;
		LD_B_n:		out	std_logic;
		LD_C_n:		out	std_logic;
		LD_D_n:		out	std_logic;
		LD_E_n:		out	std_logic;
		LD_F_n:		out	std_logic;
		LD_G_n:		out	std_logic;
		LD_DP_n:		out	std_logic;
		LD_0_n:		out	std_logic;
		LD_1_n:		out	std_logic;
		LD_2_n:		out	std_logic;
		LD_3_n:		out	std_logic;
		LD_4_n:		out	std_logic;
		LD_5_n:		out	std_logic;
		LD_6_n:		out	std_logic;
		LD_7_n:		out	std_logic;

		--	VGA Video Out Port
		VGA_R:		out	std_logic_vector(1 downto 0);
		VGA_G:		out	std_logic_vector(1 downto 0);
		VGA_B:		out	std_logic_vector(1 downto 0);
		VGA_VS:		out	std_logic;
		VGA_HS:		out	std_logic;

		-- Bank 1 Pins - Inputs for this Test
		B:				inout		std_logic_vector(24 downto 0);
		
		-- PS/2 Bidirectional Port (open collector, J31 and J32)
		PS2_CLK1:	inout	std_logic;
		PS2_DATA1:	inout	std_logic;
		PS2_CLK2:	inout	std_logic;
		PS2_DATA2:	inout	std_logic;

		--	Diferencial Signals on 4 pin header (J7)
		DIF1P:		inout	std_logic;
		DIF1N:		inout	std_logic;
		DIF2P:		inout	std_logic;
		DIF2N:		inout	std_logic;
		

		--	I2C Signals (on connector J30)
		I2C_SCL:		inout	std_logic;
		I2C_SDA:		inout	std_logic;

		--	Diferencial Signals on SATA like connectors (not SATA capable, J28 and J29)
		SD1AP:		inout	std_logic;
		SD1AN:		inout	std_logic;
		SD1BP:		inout	std_logic;
		SD1BN:		inout	std_logic;
		SD2AP:		inout	std_logic;
		SD2AN:		inout	std_logic;
		SD2BP:		inout	std_logic;
		SD2BN:		inout	std_logic;

		--	Analog In Out
	   ANA_OUTD:	out	std_logic;
		ANA_REFD:	out	std_logic;
		ANA_IND:		in		std_logic;

		--	SPI Memory Interface
		SPI_CS_n:	inout	std_logic;
		SPI_DO:		inout	std_logic;
		SPI_DI:		inout	std_logic;
		SPI_CLK:		inout	std_logic;
		SPI_WP_n:	inout	std_logic
	);
end entity gtime;


architecture gtime_a of gtime is


	-- Counter
	--	----------------

	signal Counter:			unsigned(31 downto 0)	:= X"00000000";		--	Main Counter 2 Hz (binary)


	--	LED Display
	--	-----------

	signal Number:			std_logic_vector(31 downto 0) :=	X"00000000";				--	LED Display Input
	signal Freq:			std_logic_vector(31 downto 0) :=	X"00000000";				--	Measured Frequency
	signal MuxCounter:	unsigned(31 downto 0)	:=	(others => '0');	--	LED Multiplex - Multiplex Clock Divider
	signal Enable:			std_logic;
	signal Digits:			std_logic_vector(7 downto 0)	:=	X"01";	--	LED Multiplex - Digit Counter - LED Digit Output
	signal Segments:		std_logic_vector(0 to 7);						--	LED Segment Output
	signal Code:			std_logic_vector(3 downto 0);					--	BCD to 7 Segment Decoder Output

	
--	signal LO_CLOCK:	std_logic;		-- Frequency divided by 2
	signal EXT_CLOCK:	std_logic;		-- Input Frequency

	signal Decko:	std_logic;												-- D flip-flop
	signal State:	unsigned(2 downto 0)	:=	(others => '0');		-- Inner states of automata
 	
	signal SCLK:	std_logic;
	signal SCLK2:	std_logic;


begin

	-- Counter
	process (EXT_CLOCK)
	begin
	
		if rising_edge(EXT_CLOCK) then
		
			if (State = 2) or (State = 0) then
				Counter <= Counter + 1;
			end if;
			if (State = 1) then
				Freq(31  downto 0) <= std_logic_vector(Counter);
				Counter <= (others => '0');
			end if;
		end if;

	end process;	


	-- Sampling 1PPS signal
	process (EXT_CLOCK)
	begin
		if rising_edge(EXT_CLOCK) then
			Decko <= B(22);
		end if;
	end process;

	-- Automata for controlling the Counter
	process (EXT_CLOCK)
	begin
		if rising_edge(EXT_CLOCK) then
			if (Decko = '1') then
				if (State < 2) then
					State <= State + 1;
				end if;
			else
				State <= (others => '0');
			end if;
		end if;
	end process;

	process (Decko)
   begin
		if Decko = '0' then
			LED(6) <= '1';
		else
			LED(6) <= '0';
		end if;
	end process;
	
	SCLK <= B(0);
	
	-- Output Shift Register
	process (Decko,SCLK)
   begin
		if (Decko = '0') then
			Number(31 downto 0) <= Freq(31 downto 0);	
		else
			if rising_edge(SCLK) then
				Number(30 downto 0) <= Number(31 downto 1);	
			end if;
		end if;
	end process;

	B(1) <= Number(0);
	B(2) <= Decko;

	LED(7) <= Decko; -- Display 1PPS pulse on LEDbar
	LED(5 downto 0) <= (others => '0');

	--	LED Display (multiplexed)
	--	=========================

	--	Connect LED Display Output Ports (negative outputs)
	LD_A_n	<=	not (Segments(0) and Enable);
	LD_B_n	<=	not (Segments(1) and Enable);
	LD_C_n	<=	not (Segments(2) and Enable);
	LD_D_n	<=	not (Segments(3) and Enable);
	LD_E_n	<=	not (Segments(4) and Enable);
	LD_F_n	<=	not (Segments(5) and Enable);
	LD_G_n	<=	not (Segments(6) and Enable);
	LD_DP_n	<=	not (Segments(7) and Enable);

	LD_0_n	<=	not Digits(0);
	LD_1_n	<=	not Digits(1);
	LD_2_n	<=	not Digits(2);
	LD_3_n	<=	not Digits(3);
	LD_4_n	<=	not Digits(4);
	LD_5_n	<=	not Digits(5);
	LD_6_n	<=	not Digits(6);
	LD_7_n	<=	not Digits(7);

	--	Time Multiplex
	process (CLK100MHz)
	begin
		if rising_edge(CLK100MHz) then
			if MuxCounter < MUXCOUNT-1 then
				MuxCounter <= MuxCounter + 1;
			else
				MuxCounter <= (others => '0');
				Digits(7 downto 0) <= Digits(6 downto 0) & Digits(7);	--	Rotate Left
				Enable <= '0';
			end if;
			if MuxCounter > (MUXCOUNT-4) then
				Enable <= '1';
			end if;
		end if;
	end process;

	--	HEX to 7 Segmet Decoder
	--	 --     A
	--	|  |  F   B
	--	 --     G
	--	|  |  E   C
	--	 --     D   H
	--              ABCDEFGH
	Segments		<=	"11111100"	when	Code="0000"	else	--	Digit 0
						"01100000"	when	Code="0001"	else	--	Digit 1
						"11011010"	when	Code="0010"	else	--	Digit 2
						"11110010"	when	Code="0011"	else	--	Digit 3
						"01100110"	when	Code="0100"	else	--	Digit 4
						"10110110"	when	Code="0101"	else	--	Digit 5
						"10111110"	when	Code="0110"	else	--	Digit 6
						"11100000"	when	Code="0111"	else	--	Digit 7
						"11111110"	when	Code="1000"	else	--	Digit 8
						"11110110"	when	Code="1001"	else	--	Digit 9
						"11101110"	when	Code="1010"	else	--	Digit A
						"00111110"	when	Code="1011"	else	--	Digit b
						"10011100"	when	Code="1100"	else	--	Digit C
						"01111010"	when	Code="1101"	else	--	Digit d
						"10011110"	when	Code="1110"	else	--	Digit E
						"10001110"	when	Code="1111"	else	--	Digit F
						"00000000";

	Code 			<=	Number( 3 downto  0)	when	Digits="00000001"	else
						Number( 7 downto  4)	when	Digits="00000010"	else
						Number(11 downto  8)	when	Digits="00000100"	else
						Number(15 downto 12)	when	Digits="00001000"	else
						Number(19 downto 16)	when	Digits="00010000"	else
						Number(23 downto 20)	when	Digits="00100000"	else
						Number(27 downto 24)	when	Digits="01000000"	else
						Number(31 downto 28)	when	Digits="10000000"	else
						"0000";


	-- Diferencial In/Outs
	-- ========================
   DIFbuffer1 : IBUFGDS
   generic map (
      DIFF_TERM => FALSE, -- Differential Termination 
      IBUF_DELAY_VALUE => "0", -- Specify the amount of added input delay for buffer, 
                               -- "0"-"16" 
      IOSTANDARD => "LVPECL_33")
   port map (
      I => SD1AP,  -- Diff_p buffer input (connect directly to top-level port)
      IB => SD1AN, -- Diff_n buffer input (connect directly to top-level port)
      O => EXT_CLOCK  -- Buffer output - Counter INPUT
   );

	OBUFDS_inst : OBUFDS
   generic map (
      IOSTANDARD => "LVDS_33")
   port map (
      O => SD2AP,     -- Diff_p output (connect directly to top-level port)
      OB => SD2AN,   -- Diff_n output (connect directly to top-level port)
      I => EXT_CLOCK      -- Buffer input are connected directly to IBUFGDS
   );
	
	--	Output Signal on SATA Connector
--	SD1AP			<=	'Z';	-- Counter INPUT
--	SD1AN			<=	'Z';
	SD1BP			<=	'Z';
	SD1BN			<=	'Z';

	--	Input Here via SATA Cable
--	SD2AP			<=	'Z';	-- Counter OUTPUT
--	SD2AN			<=	'Z';
	SD2BP			<=	'Z';
	SD2BN			<=	'Z';


	--	Unused Signals
	--	==============

	-- Differential inputs onn header
	DIF1N <= 'Z';
	DIF1P <= 'Z';
	DIF2N <= 'Z';
	DIF2P <= 'Z';

	--	I2C Signals (on connector J30)
	I2C_SCL		<=	'Z';
	I2C_SDA		<=	'Z';

	--	SPI Memory Interface
	SPI_CS_n		<=	'Z';
	SPI_DO		<=	'Z';
	SPI_DI		<=	'Z';
	SPI_CLK		<=	'Z';
	SPI_WP_n		<=	'Z';

	-- A/D
   ANA_OUTD	<= 'Z';
	ANA_REFD <= 'Z';

	-- VGA
	VGA_R	<= "ZZ";
	VGA_G	<= "ZZ";
	VGA_B	<= "ZZ";
	VGA_VS	<= 'Z';
	VGA_HS	<= 'Z';

	-- PS2
	PS2_DATA2 <= 'Z';
	PS2_CLK2 <='Z';

end architecture gtime_a;
