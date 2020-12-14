LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY tb_mmu is
END tb_mmu;

ARCHITECTURE test of tb_mmu is

Component mmu is
	port(clock, reset, hard_reset, ld, ld_w, stall : in std_logic;
													a0, a1, a2 : in unsigned(7 downto 0);
															wout : in unsigned(23 downto 0);
													y0, y1, y2 : out unsigned(7 downto 0));
End component;

constant period : time := 10 ns;

signal tbclk : std_logic := '1';
signal y0sig, y1sig, y2sig, a0s, a1s, a2s : unsigned(7 downto 0);
signal rst, hrst, lds, ldw, s : std_logic;
signal woutsig : unsigned(23 downto 0);
begin

	DUT : mmu
	port map(clock => tbclk, reset => rst, hard_reset => hrst, ld => lds, ld_w => ldw, stall => s, a0 => a0s, a1 => a1s, a2 => a2s, wout => woutsig, y0 => y0sig, y1 => y1sig, y2 => y2sig);
	
	tbclk <= NOT tbclk after period;
	
process is
begin

--zero everything
	rst <= '1';
	hrst <= '1';
	s <= '0';
	lds <= '0';
	ldw <= '0';
	a0s <= "00000001";
	a1s <= "00000001";
	a2s <= "00000001";
	woutsig <= "000000000000000000000000";
	wait for 20 ns;
	
	ldw <= '1';
	woutsig <= "000000000000000000000000";
	wait for 20 ns;
	
	ldw <= '1';
	woutsig <= "000000000000000000000000";
	wait for 20 ns;
	
	ldw <= '1';
	woutsig <= "000000000000000000000000";
	wait for 20 ns;
	
	ldw <= '1';
	woutsig <= "000000000000000000000000";
	wait for 20 ns;
	
	ldw <= '1';
	woutsig <= "000000000000000000000000";
	wait for 20 ns;

	

--weight loading cc
	rst <= '0';
	hrst <= '0';
	ldw <= '1';
	woutsig <= "000001110000010000000001"; --w0 (7,4,1)
	wait for 20 ns;
	
	ldw <= '1';
	woutsig <= "000010000000010100000010"; --w1 (8,5,2)
	wait for 20 ns;
	
	ldw <= '1';
	woutsig <= "000010010000011000000011"; --w2 (9,6,3)
	wait for 20 ns;
	
	ldw <= '1';
	woutsig <= "000000000000000000000000";
	wait for 20 ns;


--a values
	ldw <= '0';
	lds <= '1';
	wait for 20 ns; --a computing
	
--a values repeating
	lds <= '1';
	wait for 20 ns; --a computing
	
	lds <= '1';
	wait for 20 ns; --a computing
	
	lds <= '1';
	wait for 20 ns; --a computing
	
--a values repeating
	lds <= '1';
	wait for 20 ns; --a computing
	
	lds <= '1';
	wait for 20 ns; --a computing
	
	lds <= '1';
	wait for 20 ns; --a computing
	
--a values repeating
	lds <= '1';
	wait for 20 ns; --a computing
	
	lds <= '1';
	wait for 20 ns; --a computing
	
	lds <= '1';
	wait for 20 ns; --a computing
	
	hrst <= '1';
	lds <= '0';
	wait for 20 ns;

--zero everything
	rst <= '1';
	hrst <= '1';
	s <= '0';
	lds <= '0';
	ldw <= '0';
	a0s <= "00000001";
	a1s <= "00000001";
	a2s <= "00000001";
	woutsig <= "000000000000000000000000";
	wait for 20 ns;
	
	ldw <= '1';
	woutsig <= "000000000000000000000000";
	wait for 20 ns;
	
	ldw <= '1';
	woutsig <= "000000000000000000000000";
	wait for 20 ns;
	
	ldw <= '1';
	woutsig <= "000000000000000000000000";
	wait for 20 ns;
	
	ldw <= '1';
	woutsig <= "000000000000000000000000";
	wait for 20 ns;
	
	ldw <= '1';
	woutsig <= "000000000000000000000000";
	wait for 20 ns;
	
--weight loading cc
	rst <= '0';
	hrst <= '0';
	ldw <= '1';
	woutsig <= "111111111111111111111111"; --w0 (255,255,255)
	wait for 20 ns;
	
	ldw <= '1';
	woutsig <= "111111111111111111111111"; --w1 (255,255,255)
	wait for 20 ns;
	
	ldw <= '1';
	woutsig <= "111111111111111111111111"; --w2 (255,255,255)
	wait for 20 ns;
	
	ldw <= '1';
	woutsig <= "000000000000000000000000";
	wait for 20 ns;
	
--a values
	ldw <= '0';
	lds <= '1';
	wait for 20 ns; --a computing
	
--a values repeating
	lds <= '1';
	wait for 20 ns; --a computing
	
	lds <= '1';
	wait for 20 ns; --a computing
	
	lds <= '1';
	wait for 20 ns; --a computing
	
--a values repeating
	lds <= '1';
	wait for 20 ns; --a computing
	
	lds <= '1';
	wait for 20 ns; --a computing
	
	lds <= '1';
	wait for 20 ns; --a computing
	
--a values repeating
	lds <= '1';
	wait for 20 ns; --a computing
	
	lds <= '1';
	wait for 20 ns; --a computing
	
	lds <= '1';
	wait for 20 ns; --a computing
	
	hrst <= '1';
	lds <= '0';
	wait for 20 ns;


End process;
End test;