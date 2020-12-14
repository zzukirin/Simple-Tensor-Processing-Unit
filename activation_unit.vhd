LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE work.systolic_package.all;

ENTITY activation_unit IS
	PORT(clock, reset, hard_reset, stall : IN STD_LOGIC;
		  
		  y_in0, y_in1, y_in2 : IN UNSIGNED(7 DOWNTO 0);
		  
		  row0, row1, row2 : OUT bus_width;
		  
		  done : OUT STD_LOGIC);
      
END activation_unit;

ARCHITECTURE Behaviour of activation_unit is
type r0 is (y31, y21, y11);
type r1 is (y32, y22, y12);
type r2 is (y33, y23, y13);
signal state1 : r0;
signal state2 : r1;
signal state3 : r2;
BEGIN

PROCESS(clock)
BEGIN

	if hard_reset = '1' then
		--reset product matrix to zero
		row0(0) <= "00000000";
		row0(1) <= "00000000";
		row0(2) <= "00000000";
		row1(0) <= "00000000";
		row1(1) <= "00000000";
		row1(2) <= "00000000";
		row2(0) <= "00000000";
		row2(1) <= "00000000";
		row2(2) <= "00000000";
		state1 <= y31;
		state2 <= y32;
		state3 <= y33;
		done <= '0';
	
	elsif reset = '1' then
		state1 <= y31;
		state2 <= y32;
		state3 <= y33;
		done <= '0';

	elsif rising_edge(clock) then
		
		--row 0
		case state1 is
			when y31 =>
				if stall = '1' then
					state1 <= y11;
				else
					row2(0) <= y_in0;
					state1 <= y21;
					done <= '0';
				end if;
			when y21 =>
				if stall = '1' then
					state1 <= y31;
				else
					row1(0) <= y_in0;
					state1 <= y11;
				end if;
			when y11 =>
				if stall = '1' then
					state1 <= y21;
				else
					row0(0) <= y_in0;
					state1 <= y31;
					done <= '1';
				end if;
		end case;
			
		--row 1
		case state2 is
			when y32 =>
				if stall = '1' then
					state2 <= y12;
				else
					row2(1) <= y_in1;
					state2 <= y22;
					done <= '0';
				end if;
			when y22 =>
				if stall = '1' then
					state2 <= y32;
				else
					row1(1) <= y_in1;
					state2 <= y12;
				end if;
			when y12 =>
				if stall = '1' then
					state2 <= y22;
				else
					row0(1) <= y_in1;
					state2 <= y32;
					done <= '1';
				end if;
		end case;
			
		--row 2
		case state3 is
			when y33 =>
				if stall = '1' then
					state3 <= y13;
				else
					row2(2) <= y_in2;
					state3 <= y23;
					done <= '0';
				end if;
			when y23 =>
				if stall = '1' then
					state3 <= y33;
				else
					row1(2) <= y_in2;
					state3 <= y13;
				end if;
			when y13 =>
				if stall = '1' then
					state3 <= y23;
				else
					row0(2) <= y_in2;
					state3 <= y33;
					done <= '1';
				end if;
		end case;		
	end if;

END PROCESS;
END Behaviour;