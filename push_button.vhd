library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity push_button is 
port(
	entrada : in std_logic;
	CLK : in std_logic;
	Saida : out std_logic
);
end push_button;

architecture push_button_architecture of push_button is
	signal reg_1,reg_2 :std_logic;
	begin
	process(CLK)
		begin
		if rising_edge(CLK) then
		reg_1 <= entrada;
		reg_2 <= reg_1;
		else
		end if;
		Saida <= '1' and(reg_1 xor reg_2);
	end process;

end architecture push_button_architecture;
