LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE work.systolic_package.all;

Entity tb_stpu is
End tb_stpu;

Architecture test of tb_stpu is

--stpu component (THE BIG BOY)
Component stpu is
	port(clock, reset, hard_reset, setup, GO, stall : in std_logic;
												 weights, a_in : in unsigned(23 downto 0);
													 y0, y1, y2 : out bus_width;
															 done : out std_logic);
End component;

constant period : time := 10 ns;

signal tbclk : std_logic := '1';
signal wsig, asig : unsigned(23 downto 0);
signal rst, hrst, setupsig, g, s, dsig : std_logic;
signal y0sig, y1sig, y2sig : bus_width;
begin

	DUT : stpu
	port map(clock => tbclk, reset => rst, hard_reset => hrst, setup => setupsig, GO => g, stall => s, weights => wsig, a_in => asig, y0 => y0sig, y1 => y1sig, y2 => y2sig, done => dsig);
	
	tbclk <= NOT tbclk after period;
	
process is
begin

--initialization
	rst <= '0';
	hrst <= '1';
	setupsig <= '0';
	g <= '0';
	s <= '0';
	dsig <= '0';
	wsig <= "000000000000000000000000";
	asig <= "000000000000000000000000";
	wait for 120 ns;

--load stuff
	rst <= '0';
	hrst <= '0';
	setupsig <= '1';
	g <= '0';
	s <= '0';
	wsig <= "000000010000001000000011";
	asig <= "000000010000000100000001";
	wait for 20 ns;
	
	wsig <= "000001000000010100000110";
	asig <= "000000010000000100000001";
	wait for 20 ns;
	
	wsig <= "000001110000100000001001";
	asig <= "000000010000000100000001";
	wait for 20 ns;

--load stuff again
	rst <= '0';
	hrst <= '0';
	setupsig <= '1';
	g <= '0';
	s <= '0';
	wsig <= "000000010000001000000011";
	asig <= "000000010000000100000001";
	wait for 20 ns;
	
	wsig <= "000001000000010100000110";
	asig <= "000000010000000100000001";
	wait for 20 ns;
	
	wsig <= "000001110000100000001001";
	asig <= "000000010000000100000001";
	wait for 20 ns;
	
--go compute
	g <= '1';
	s <= '0';
	wait for 20 ns;
	
	g <= '0';
	s <= '0';
	wait for 200 ns;
	
--reset
	rst <= '0';
	hrst <= '1';
	setupsig <= '0';
	g <= '0';
	s <= '0';
	wsig <= "000000000000000000000000";
	asig <= "000000000000000000000000";
	wait for 120 ns;

End process;
End test;