LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE work.systolic_package.all;

Entity stpu is
	port(clock, reset, hard_reset, setup, GO, stall : in std_logic;
												 weights, a_in : in unsigned(23 downto 0);
													 y0, y1, y2 : out bus_width;
															 done : out std_logic);
End stpu;

Architecture Structure of stpu is

--mmu component
Component mmu is
	port(clock, reset, hard_reset, ld, ld_w, stall : in std_logic;
													a0, a1, a2 : in unsigned(7 downto 0);
															wout : in unsigned(23 downto 0);
													y0, y1, y2 : out unsigned(7 downto 0));
End component;

--wram component
Component WRAM is
port( aclr		: IN STD_LOGIC  := '0';
	address		: IN STD_LOGIC_VECTOR (1 DOWNTO 0);
		clock		: IN STD_LOGIC  := '1';
		data		: IN STD_LOGIC_VECTOR (23 DOWNTO 0);
		rden		: IN STD_LOGIC  := '1';
		wren		: IN STD_LOGIC ;
			q		: OUT STD_LOGIC_VECTOR (23 DOWNTO 0));
End component;

--uram component
Component URAM is
port(	aclr		: IN STD_LOGIC  := '0';
	address		: IN STD_LOGIC_VECTOR (1 DOWNTO 0);
		clock		: IN STD_LOGIC  := '1';
		data		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		rden		: IN STD_LOGIC  := '1';
		wren		: IN STD_LOGIC ;
			q		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0));
End component;

--activation unit component
Component activation_unit is
	PORT(clock, reset, hard_reset, stall : IN STD_LOGIC;	  
						  y_in0, y_in1, y_in2 : IN UNSIGNED(7 DOWNTO 0);	  
							  row0, row1, row2 : OUT bus_width;		  
											  done : OUT STD_LOGIC);
End component;

--signals

signal WRAMaclr, WRAMrden, WRAMwren : std_logic;
signal WRAMaddress : std_logic_vector(1 downto 0);
signal WRAMdata, WRAMq : std_logic_vector(23 downto 0);

signal URAM1aclr, URAM1rden, URAM1wren : std_logic;
signal URAM1address : std_logic_vector(1 downto 0);
signal URAM1data, URAM1q : std_logic_vector(7 downto 0);

signal URAM2aclr, URAM2rden, URAM2wren : std_logic;
signal URAM2address : std_logic_vector(1 downto 0);
signal URAM2data, URAM2q : std_logic_vector(7 downto 0);

signal URAM3aclr, URAM3rden, URAM3wren : std_logic;
signal URAM3address : std_logic_vector(1 downto 0);
signal URAM3data, URAM3q : std_logic_vector(7 downto 0);

signal ldsig, ld_wsig, rdy, dsig : std_logic;
signal ywire0, ywire1, ywire2 : unsigned(7 downto 0);

TYPE state_type is (hard_R, soft_R, resetWrite_a1, resetWrite_a2, resetWrite_a3, resetWrite_a4, readwrite1, readwrite2, readwrite3, load_w0, load_w1, load_w2, la1, la2, la3, la4, la5, la6, idle);
Signal state : state_type; 
begin

--port mapping
	WRAM_unit : WRAM
	port map(aclr => WRAMaclr, address => WRAMaddress, clock => clock, data => WRAMdata, rden => WRAMrden, wren => WRAMwren, q => WRAMq);
	
	URAM_unit1 : URAM
	port map(aclr => URAM1aclr, address => URAM1address, clock => clock, data => URAM1data, rden => URAM1rden, wren => URAM1wren, q => URAM1q);

	URAM_unit2 : URAM
	port map(aclr => URAM2aclr, address => URAM2address, clock => clock, data => URAM2data, rden => URAM2rden, wren => URAM2wren, q => URAM2q);
	
	URAM_unit3 : URAM
	port map(aclr => URAM3aclr, address => URAM3address, clock => clock, data => URAM3data, rden => URAM3rden, wren => URAM3wren, q => URAM3q);
	
	MMU_unit : mmu
	port map(clock => clock, reset => reset, hard_reset => hard_reset, ld => ldsig, ld_w => ld_wsig, stall => stall, 
				a0 => unsigned(URAM1q), a1 => unsigned(URAM2q), a2 => unsigned(URAM3q),
				wout => unsigned(WRAMq), y0 => ywire0, y1 => ywire1 , y2 => ywire2);
	
	AU : activation_unit
	port map(clock => clock, reset => reset, hard_reset => hard_reset, stall => stall, y_in0 => ywire0, y_in1 => ywire1, 
				y_in2 => ywire2, row0 => y0, row1 => y1, row2 => y2, done => dsig);
					
--process logic
process(clock, reset, hard_reset, setup, GO, stall)
begin
	
	--resetting the system
	if(hard_reset = '1' or reset = '1') then 
		state <= hard_R;
		
	--happens on rising edge of clock:
	elsif rising_edge(clock) then
	
		if setup = '1' then
			state <= readwrite1;
		elsif GO = '1' then
			if rdy = '1' then
				state <= load_w0;
			end if;
		end if;
		
		case state is
		
			when hard_R =>
				
				if(reset = '1') then state <= soft_R;
				else state <= resetWrite_a1; --start resetting/clearing all buffer stuff
				end if;
				
			when soft_R =>
				
				rdy <= '0';
				WRAMwren <= '0';
				URAM1wren <= '0';
				URAM2wren <= '0';
				URAM3wren <= '0';
				state <= idle; --return everything to idle state
				
			when resetWrite_a1 => --wram reset mem cell 1
				
				if stall = '1' then
					state <= hard_R;
				else
				
					--wram clear
					WRAMaddress <= "00";
					WRAMaclr <= '1';
					WRAMdata <= "000000000000000000000000";
					WRAMwren <= '1';
					
					--uram clear
					URAM1address <= "00";
					URAM2address <= "00";
					URAM3address <= "00";
					URAM1aclr <= '1';
					URAM2aclr <= '1';
					URAM3aclr <= '1';
					URAM1data <= "00000000";
					URAM2data <= "00000000";
					URAM3data <= "00000000";
					URAM1wren <= '1';
					URAM2wren <= '1';
					URAM3wren <= '1';
					
					state <= resetWrite_a2;
				end if;
				
			when resetWrite_a2 => --wram reset mem cell 2
				
				if stall = '1' then
					state <= resetWrite_a1;
				else
				
					--wram clear
					WRAMaddress <= "01";
					WRAMaclr <= '1';
					WRAMdata <= "000000000000000000000000";
					WRAMwren <= '1';
					
					--uram clear
					URAM1address <= "01";
					URAM2address <= "01";
					URAM3address <= "01";
					URAM1aclr <= '1';
					URAM2aclr <= '1';
					URAM3aclr <= '1';
					URAM1data <= "00000000";
					URAM2data <= "00000000";
					URAM3data <= "00000000";
					URAM1wren <= '1';
					URAM2wren <= '1';
					URAM3wren <= '1';
					
					state <= resetWrite_a3;
				end if;
				
			when resetWrite_a3 => --wram reset mem cell 3
				
				if stall = '1' then
					state <= resetWrite_a2;
				else
				
					--wram clear
					WRAMaddress <= "10";
					WRAMaclr <= '1';
					WRAMdata <= "000000000000000000000000";
					WRAMwren <= '1';
					
					--uram clear
					URAM1address <= "10";
					URAM2address <= "10";
					URAM3address <= "10";
					URAM1aclr <= '1';
					URAM2aclr <= '1';
					URAM3aclr <= '1';
					URAM1data <= "00000000";
					URAM2data <= "00000000";
					URAM3data <= "00000000";
					URAM1wren <= '1';
					URAM2wren <= '1';
					URAM3wren <= '1';
					
					state <= resetWrite_a4;
				end if;
				
			when resetWrite_a4 => --wram reset mem cell 3
				
				if stall = '1' then
					state <= resetWrite_a2;
				else
				
					--wram clear
					WRAMaddress <= "11";
					WRAMaclr <= '1';
					WRAMdata <= "000000000000000000000000";
					WRAMwren <= '1';
					
					--uram clear
					URAM1address <= "11";
					URAM2address <= "11";
					URAM3address <= "11";
					URAM1aclr <= '1';
					URAM2aclr <= '1';
					URAM3aclr <= '1';
					URAM1data <= "00000000";
					URAM2data <= "00000000";
					URAM3data <= "00000000";
					URAM1wren <= '1';
					URAM2wren <= '1';
					URAM3wren <= '1';
					
					state <= soft_R;
				end if;
				
			when readwrite1 => --read/write1 (three 24bit a_in inputs, for three cycles)
			
				if stall = '1' then
					state <= idle;
				else
					rdy <= '0';
				
					--wram
					WRAMaddress <= "00";
					WRAMrden <= '1'; --enable read, stpu -> wram
					WRAMwren <= '0'; --disable write
					WRAMdata <= std_logic_vector(weights);
					
					--uram
					URAM1address <= "00";
					URAM2address <= "00";
					URAM3address <= "00";
					URAM1data <= std_logic_vector(a_in(23 downto 16));
					URAM2data <= std_logic_vector(a_in(15 downto 8));
					URAM3data <= std_logic_vector(a_in(7 downto 0));
					
					state <= readwrite2;
				end if;
				
			when readwrite2 => --read/write2
			
				if stall = '1' then
					state <= readwrite1;
				else
					--wram
					WRAMaddress <= "01";
					WRAMrden <= '1'; --enable read, stpu -> wram
					WRAMwren <= '0'; --disable write
					WRAMdata <= std_logic_vector(weights);
					
					--uram
					URAM1address <= "01";
					URAM2address <= "01";
					URAM3address <= "01";
					URAM1data <= std_logic_vector(a_in(23 downto 16));
					URAM2data <= std_logic_vector(a_in(15 downto 8));
					URAM3data <= std_logic_vector(a_in(7 downto 0));
					
					state <= readwrite3;
				end if;
				
			when readwrite3 => --read/write3
			
				if stall = '1' then
					state <= readwrite2;
				else
					--wram
					WRAMaddress <= "10";
					WRAMrden <= '1'; --enable read, stpu -> wram
					WRAMwren <= '0'; --disable write
					WRAMdata <= std_logic_vector(weights);
					
					--uram
					URAM1address <= "10";
					URAM2address <= "10";
					URAM3address <= "10";
					URAM1data <= std_logic_vector(a_in(23 downto 16));
					URAM2data <= std_logic_vector(a_in(15 downto 8));
					URAM3data <= std_logic_vector(a_in(7 downto 0));
					rdy <= '1';
					
					state <= idle;
				end if;
			
			when load_w0 =>
				
				if stall = '1' then
					state <= idle;
				else
					ld_wsig <= '1';
					WRAMaddress <= "00";

					state <= load_w1;
				end if;
			
			when load_w1 =>
				
				if stall = '1' then
					state <= load_w0;
				else
					ld_wsig <= '1';
					WRAMaddress <= "01";

					state <= load_w2;
				end if;
			
			when load_w2 =>
				
				if stall = '1' then
					state <= load_w1;
				else
					ld_wsig <= '1';
					WRAMaddress <= "10";
					ld_wsig <= '0';
					WRAMrden <= '0';
			
					URAM1rden <= '1';
					URAM2rden <= '1';
					URAM3rden <= '1';

					state <= la1;
				end if;
			
			when la1 =>
			
				if stall = '1' then
					state <= load_w2;
				else
					ldsig <= '1';
					
					--loading a's
					URAM1address <= "00";
					URAM2address <= "11";
					URAM3address <= "11";
				
					state <= la2;
				end if;
				
			when la2 =>
			
				if stall = '1' then
					state <= la1;
				else
					ldsig <= '1';
					
					--loading a's
					URAM1address <= "01";
					URAM2address <= "00";
					URAM3address <= "11";
					
					state <= la3;
				end if;
			
			when la3 =>
			
				if stall = '1' then
					state <= la2;
				else
					ldsig <= '1';
					
					--loading a's
					URAM1address <= "10";
					URAM2address <= "01";
					URAM3address <= "00";
					
					state <= la4;
				end if;
			
			when la4 =>
			
				if stall = '1' then
					state <= la3;
				else
					ldsig <= '1';
					
					--loading a's
					URAM1address <= "11";
					URAM2address <= "10";
					URAM3address <= "01";
					
					state <= la5;
				end if;
			
			when la5 =>
			
				if stall = '1' then
					state <= la4;
				else
					ldsig <= '1';
					
					--loading a's
					URAM1address <= "11";
					URAM2address <= "11";
					URAM3address <= "10";
					
					state <= la6;
				end if;
				
			when la6 =>
			
				if stall = '1' then
					state <= la5;
				else
					ldsig <= '1';
					
					--loading a's
					URAM1address <= "11";
					URAM2address <= "11";
					URAM3address <= "11";
				
					if dsig = '1' then
						state <= idle;
					end if;
				end if;
				
			when idle =>
			
				--change everything to idle
				URAM1aclr <= '0';
				URAM2aclr <= '0';
				URAM3aclr <= '0';
				ldsig <= '0';
				ld_wsig <= '0';
				
				URAM1rden <= '0';
				URAM2rden <= '0';
				URAM3rden <= '0';
			
		end case;
	end if;

End process;
End Structure;