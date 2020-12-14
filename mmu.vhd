LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

Entity mmu is
	port(clock, reset, hard_reset, ld, ld_w, stall : in std_logic;
													a0, a1, a2 : in unsigned(7 downto 0);
															wout : in unsigned(23 downto 0);
													y0, y1, y2 : out unsigned(7 downto 0));
End mmu;

Architecture Structure of mmu is

--processing element component
Component pe is
	port(clock, reset, hard_reset, ld, ld_w : in std_logic;
							  a_in, w_in, part_in : in unsigned(7 downto 0);
							   partial_sum, a_out : out unsigned(7 downto 0));
End component;

--states/signals
type i_state is (idle, load_col0, load_col1, load_col2);
signal init_state : i_state;
signal w0, w1, w2, ground : unsigned(23 downto 0);
signal x1, x2, x3, x4, x5, x6, z1, z2, z3, z4, z5, z6 : unsigned(7 downto 0);
signal a0init, a1init, a2init : unsigned(7 downto 0);
signal ld_w1, ld_w2, rdy : std_logic;
begin

--port maps
	pe1 : pe --1,1
	port map(clock => clock, reset => reset, hard_reset => hard_reset, ld => ld, ld_w => ld_w, a_in => a0init, w_in => w0(7 downto 0), part_in => "00000000", partial_sum => z1, a_out => x1);
	
	pe2 : pe --1,2
	port map(clock => clock, reset => reset, hard_reset => hard_reset, ld => ld, ld_w => ld_w1, a_in => x1, w_in => w1(7 downto 0), part_in => "00000000", partial_sum => z2, a_out => x2);
	
	pe3 : pe --1,3
	port map(clock => clock, reset => reset, hard_reset => hard_reset, ld => ld, ld_w => ld_w2, a_in => x2, w_in => w2(7 downto 0), part_in => "00000000", partial_sum => z3, a_out => open);
	
	pe4 : pe --2,1
	port map(clock => clock, reset => reset, hard_reset => hard_reset, ld => ld, ld_w => ld_w, a_in => a1init, w_in => w0(15 downto 8), part_in => z1, partial_sum => z4, a_out => x3);
	
	pe5 : pe --2,2
	port map(clock => clock, reset => reset, hard_reset => hard_reset, ld => ld, ld_w => ld_w1, a_in => x3, w_in => w1(15 downto 8), part_in => z2, partial_sum => z5, a_out => x4);
	
	pe6 : pe --2,3
	port map(clock => clock, reset => reset, hard_reset => hard_reset, ld => ld, ld_w => ld_w2, a_in => x4, w_in => w2(15 downto 8), part_in => z3, partial_sum => z6, a_out => open);
	
	pe7 : pe --3,1
	port map(clock => clock, reset => reset, hard_reset => hard_reset, ld => ld, ld_w => ld_w, a_in => a2init, w_in => w0(23 downto 16), part_in => z4, partial_sum => y0, a_out => x5);
	
	pe8 : pe --3,2
	port map(clock => clock, reset => reset, hard_reset => hard_reset, ld => ld, ld_w => ld_w1, a_in => x5, w_in => w1(23 downto 16), part_in => z5, partial_sum => y1, a_out => x6);
	
	pe9 : pe --3,3
	port map(clock => clock, reset => reset, hard_reset => hard_reset, ld => ld, ld_w => ld_w2, a_in => x6, w_in => w2(23 downto 16), part_in => z6, partial_sum => y2, a_out => open);

--process clock logic
process(clock, reset, hard_reset) is
begin
	
	if hard_reset = '1' then
		--erase all values/factory reset
		w0 <= "000000000000000000000000";
		w1 <= "000000000000000000000000";
		w2 <= "000000000000000000000000";
		a0init <= "00000000";
		a1init <= "00000000";
		a2init <= "00000000";
		init_state <= idle;
		rdy <= '0';
		
	elsif reset = '1' then
		init_state <= idle;
		rdy <= '0';
	
	elsif rising_edge(clock) then
		-- => go to init mode
		
			--default values
			ld_w1 <= '0';
			ld_w2 <= '0';
		
			--init states (idle/load_col0/load_col1/load_col2)
			case init_state is
				when idle =>
					
					if ld_w = '1' then --check if ld_w is asserted, continue on through init
						if stall = '1' then
							init_state <= load_col2;
						else
							init_state <= load_col0;
							rdy <= '0';
						end if;
					end if;
					
				when load_col0 =>
						
					if stall = '1' then --stall
						init_state <= idle;
					else
						w0 <= wout; --latches on next rising edge, w0 inputs will be loaded to first column			
						init_state <= load_col1;
						ld_w1 <= '1';
					end if;
													
				when load_col1 =>
					
					if stall = '1' then --stall
						init_state <= load_col0;
					else
						w1 <= wout;
						init_state <= load_col2;
						ld_w1 <= '0';
						ld_w2 <= '1';
					end if;

				when load_col2 =>
					
					if stall = '1' then --stall
						init_state <= load_col1;
					else	
						w2 <= wout;
						ld_w2 <= '0';
						rdy <= '1';
						init_state <= idle;	
					end if;
				
			end case;
		
		if rdy = '1' then --check if ready is asserted => go to compute mode
			if ld = '1' then--check if ld is asserted
			
				--assigning a_in's for compute logic
				a0init <= a0;
				a1init <= a1;
				a2init <= a2;
			
			end if;
		end if;
		--stay the same//do nothing if not rising_edge(clock)
	end if;
	
End process;
End Structure;








