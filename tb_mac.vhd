LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY tb_mac is
END tb_mac;

ARCHITECTURE test of tb_mac is

Component mac is
	port(weight, a_in, part_in : in unsigned(7 downto 0);
							 mac_out : out unsigned(7 downto 0));
End component;

signal wsig, asig, psig : unsigned(7 downto 0);
signal msig : unsigned(7 downto 0);
BEGIN

	DUT : mac
	port map(wsig, asig, psig, msig);

PROCESS is
BEGIN

	wsig <= "00010100";
	asig <= "00000010";
	psig <= "00001010"; --50 msig
	wait for 20 ns;
	
	wsig <= "00010100";
	asig <= "00001111"; -- 300 asig*wsig
	psig <= "00001010"; -- 300+10 = 310 but overflow, so 255
	wait for 20 ns;

END PROCESS;
END test;