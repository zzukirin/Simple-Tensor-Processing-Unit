library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

ENTITY tb_WRAM IS
END tb_WRAM;

ARCHITECTURE test of tb_WRAM IS

COMPONENT WRAM IS 

PORT
	(
		aclr		: IN STD_LOGIC  := '0';
		address		: IN STD_LOGIC_VECTOR (1 DOWNTO 0);
		clock		: IN STD_LOGIC  := '1';
		data		: IN STD_LOGIC_VECTOR (23 DOWNTO 0);
		rden		: IN STD_LOGIC  := '1';
		wren		: IN STD_LOGIC ;
		q		: OUT STD_LOGIC_VECTOR (23 DOWNTO 0)
	);
		
END COMPONENT;



CONSTANT PERIOD : time := 15 ns;

SIGNAL aclrsig : std_logic := '0';
SIGNAL addresssig : std_logic_vector(1 downto 0);
SIGNAL clocksig : std_logic := '1';
SIGNAL datasig : std_logic_vector(23 downto 0);
SIGNAL rdensig : std_logic := '1';
SIGNAL wrensig : std_logic;

SIGNAL qsig : std_logic_vector(23 downto 0);
 
BEGIN

    DUT:	WRAM
	 
    PORT MAP (aclr => aclrsig, address => addresssig, clock => clocksig, data => datasig, rden => rdensig, wren => wrensig, q => qsig);
	 
	 clocksig <= NOT clocksig after PERIOD;

PROCESS IS

    BEGIN 
	 
	 aclrsig <= '0';
	 addresssig <= "11";
	 datasig <= "111111111111111111111111";
	 rdensig <= '1';
	 wrensig <= '0';
	 wait for 150 ns;
	 
	 aclrsig <= '0';
	 addresssig <= "11";
	 datasig <= "111111111111111111111111";
	 rdensig <= '1';
	 wrensig <= '0';
	 wait for 150 ns;
	 
	 aclrsig <= '0';
	 addresssig <= "11";
	 datasig <= "111111111111111111111111";
	 rdensig <= '0';
	 wrensig <= '1';
	 wait for 150 ns;
	 
	 aclrsig <= '1';
	 wait for 150 ns;
	 
    
END PROCESS;
END test;