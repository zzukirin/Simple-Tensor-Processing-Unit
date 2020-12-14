LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

Entity mac is
	port(weight, a_in, part_in : in unsigned(7 downto 0);
							 mac_out : out unsigned(7 downto 0));
End mac;

Architecture Behaviour of mac is
signal result : unsigned(15 downto 0);
signal msig : unsigned(7 downto 0);
begin

process(weight, a_in, part_in, result) is
begin
	
	result <= to_unsigned(to_integer(weight) * to_integer(a_in) + to_integer(part_in), 16);
	
	--Rounding unit
	if to_integer(result) > 255 then msig <= "11111111";
	else msig <= result(7 downto 0);
	end if;
	
End process;

mac_out <= msig;

End Behaviour;