library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_DivisorClock is

end entity;

architecture rtl of tb_DivisorClock is

signal		CLOCK_50MHz : std_logic:='0';
signal		reset	      : std_logic:='0';
signal		CLOCK_1Hz   : std_logic:='0';

   -- Clock period definitions
   constant PERIOD     : time := 20 ns;
   constant DUTY_CYCLE : real := 0.5;
   constant OFFSET     : time := 5 ns;


component DivisorClock 
	port 
	(
		CLOCK_50MHz : in std_logic;
		reset	      : in std_logic;
		CLOCK_1Hz   : out std_logic
	);

end component;
	
begin

DV:DivisorClock 
	port map 
	(
		CLOCK_50MHz => CLOCK_50MHz,
		reset	      => reset,
		CLOCK_1Hz   => CLOCK_1Hz
	);

------------------------------------------------------------------------------------
----------------- proceso generador de la senal de clock 
------------------------------------------------------------------------------------		
        PROCESS    -- clock process for clock
        BEGIN
            WAIT for OFFSET;
            CLOCK_LOOP : LOOP
                CLOCK_50MHz <= '0';
                WAIT FOR (PERIOD - (PERIOD * DUTY_CYCLE));
                CLOCK_50MHz <= '1';
                WAIT FOR (PERIOD * DUTY_CYCLE);
            END LOOP CLOCK_LOOP;
        END PROCESS;
		  
------------------------------------------------------------------------------------
----------------- proceso para introducir el estimulo de reset
------------------------------------------------------------------------------------		
	sreset: process
	begin
		reset <= '1';
		for i in 1 to 2 loop
			wait until rising_edge(CLOCK_50MHz);
		end loop;
		reset <= '0'; 
		wait;	
	end process sreset;		  


end rtl;