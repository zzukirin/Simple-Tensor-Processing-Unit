LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

Entity reg is
	port(clk, rst, ld_r : in std_logic;
				  rin : in unsigned(7 downto 0);
				 rout : out unsigned(7 downto 0));
End reg;

Architecture Behaviour of reg is

signal routsig : unsigned(7 downto 0);
begin

process(clk) is
begin
		
		if rst = '1' then
			routsig <= "00000000";
		
		elsif rising_edge(clk) then
				if ld_r = '1' then 
					routsig <= rin;
				else 
					routsig <= routsig;
				end if;
		else 
			routsig <= routsig;
		end if;
		
End process;

rout <= routsig;

End Behaviour;