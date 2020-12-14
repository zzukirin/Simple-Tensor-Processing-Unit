LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

--goal of systolic array:
--fixes imbalanced data and computation. so rather than one operation and accessing memory (one PE),
--you can just access it once and have pipelined PEs so you dont have to keep accessing the memory
--save on memory bandwidth this way.

Entity pe is
	port(clock, reset, hard_reset, ld, ld_w : in std_logic;
							  a_in, w_in, part_in : in unsigned(7 downto 0);
							   partial_sum, a_out : out unsigned(7 downto 0));
End pe;

Architecture Structure of pe is

--reg component
Component reg is
	port(clk, rst, ld_r : in std_logic;
				  rin : in unsigned(7 downto 0);
				 rout : out unsigned(7 downto 0));
End component;

--mac component
Component mac is
	port(weight, a_in, part_in : in unsigned(7 downto 0);
							 mac_out : out unsigned(7 downto 0));
End component;

--signals
signal weightsig, macoutsig, a_outsig, partial_sumsig : unsigned(7 downto 0);
begin

--port maps
	W : reg port map(clk => clock, rst => reset, ld_r => ld_w, rin => w_in, rout => weightsig);
	A : reg port map(clk => clock, rst => reset, ld_r => ld, rin => a_in, rout => a_outsig);
	Y : reg port map(clk => clock, rst => reset, ld_r => ld, rin => macoutsig, rout => partial_sumsig);
	mac_unit : mac port map(weight => weightsig, a_in => a_in, part_in => part_in, mac_out => macoutsig);
	
	a_out <= a_outsig;
	partial_sum <= partial_sumsig;
	
End Structure;