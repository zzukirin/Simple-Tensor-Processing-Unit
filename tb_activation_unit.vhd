library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
USE work.systolic_package.all;

ENTITY tb_activation_unit IS
END tb_activation_unit;

ARCHITECTURE test of tb_activation_unit IS

COMPONENT activation_unit IS 

PORT(clock, reset, hard_reset, stall : IN STD_LOGIC;
		  
		  y_in0, y_in1, y_in2 : IN UNSIGNED(7 DOWNTO 0);
		  
		  row0, row1, row2 : OUT bus_width;
		  
		  done : OUT STD_LOGIC);
		
END COMPONENT;



CONSTANT PERIOD : time := 10 ns;

SIGNAL clocksig, resetsig, hard_resetsig, stallsig : std_logic := '1';
SIGNAL y_in0sig, y_in1sig, y_in2sig : unsigned(7 downto 0);
SIGNAL row0sig, row1sig, row2sig : bus_width;
SIGNAL donesig : std_logic;
 
BEGIN

    DUT:	activation_unit
	 
    PORT MAP (clock => clocksig, reset => resetsig, hard_reset => hard_resetsig, stall => stallsig, 
				  y_in0 => y_in0sig, y_in1 => y_in1sig, y_in2 => y_in2sig,
				  row0 => row0sig, row1 => row1sig, row2 => row2sig,
				  done => donesig);
	 
	 clocksig <= NOT clocksig after PERIOD;

PROCESS IS
BEGIN 
	 
--initialization
	 resetsig <= '1';
	 hard_resetsig <= '1';
	 stallsig <= '0';
	 y_in0sig <= "00000000";
	 y_in1sig <= "00000000";
	 y_in2sig <= "00000000";
	 wait for 20 ns;
	
--stall
	 resetsig <= '0';
	 hard_resetsig <= '0';
	 stallsig <= '1';
	 wait for 20 ns;

--test 1 
	 resetsig <= '0';
	 hard_resetsig <= '0';
	 stallsig <= '0';
	 y_in0sig <= "11111111";
	 y_in1sig <= "11111111";
	 y_in2sig <= "11111111";
	 wait for 20 ns;
	 
	 resetsig <= '0';
	 hard_resetsig <= '0';
	 stallsig <= '0';
	 y_in0sig <= "11111111";
	 y_in1sig <= "11111111";
	 y_in2sig <= "11111111";
	 wait for 20 ns;
	 
	 resetsig <= '0';
	 hard_resetsig <= '0';
	 stallsig <= '0';
	 y_in0sig <= "11111111";
	 y_in1sig <= "11111111";
	 y_in2sig <= "11111111";
	 wait for 20 ns;
	 
--test 2
	 resetsig <= '0';
	 hard_resetsig <= '0';
	 stallsig <= '0';
	 y_in0sig <= "00000001";
	 y_in1sig <= "00000001";
	 y_in2sig <= "00000001";
	 wait for 20 ns;
	 
	 resetsig <= '1'; --(soft reset)
	 hard_resetsig <= '0'; 
	 stallsig <= '0';
	 y_in0sig <= "00000010";
	 y_in1sig <= "00000010";
	 y_in2sig <= "00000010";
	 wait for 20 ns;

	 resetsig <= '0';
	 hard_resetsig <= '0';
	 stallsig <= '0';
	 y_in0sig <= "00000011";
	 y_in1sig <= "00000011";
	 y_in2sig <= "00000011";
	 wait for 20 ns;

--(hard reset)
	 resetsig <= '0';
	 hard_resetsig <= '1';
	 stallsig <= '0';
	 y_in0sig <= "00000000";
	 y_in1sig <= "00000000";
	 y_in2sig <= "00000000";
	 wait for 20 ns;
	 
	 resetsig <= '0';
	 hard_resetsig <= '1';
	 stallsig <= '0';
	 wait for 20 ns;
	 
	 resetsig <= '0';
	 hard_resetsig <= '1';
	 stallsig <= '0';
	 wait for 20 ns;
	 
--test3 (hard reset)
	 resetsig <= '0';
	 hard_resetsig <= '0';
	 stallsig <= '0';
	 y_in0sig <= to_unsigned(7, 8);
	 y_in1sig <= to_unsigned(8, 8);
	 y_in2sig <= to_unsigned(9, 8);
	 wait for 20 ns;
	 
	 resetsig <= '0';
	 hard_resetsig <= '0';
	 stallsig <= '0';
	 y_in0sig <= to_unsigned(4, 8);
	 y_in1sig <= to_unsigned(5, 8);
	 y_in2sig <= to_unsigned(6, 8);
	 wait for 20 ns;
	 
	 resetsig <= '0';
	 hard_resetsig <= '0';
	 stallsig <= '0';
	 y_in0sig <= to_unsigned(1, 8);
	 y_in1sig <= to_unsigned(2, 8);
	 y_in2sig <= to_unsigned(3, 8);
	 wait for 20 ns;
	 
--stall x3
	 resetsig <= '0';
	 hard_resetsig <= '0';
	 stallsig <= '1';
	 wait for 20 ns;
	 
	 resetsig <= '0';
	 hard_resetsig <= '0';
	 stallsig <= '1';
	 wait for 20 ns;
	 
	 resetsig <= '0';
	 hard_resetsig <= '0';
	 stallsig <= '1';
	 wait for 20 ns;
	
END PROCESS;
END test;