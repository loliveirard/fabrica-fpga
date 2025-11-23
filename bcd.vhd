LIBRARY IEEE;
use ieee.std_logic_1164.all;

Entity bcd is
port (
    entrada: in std_logic_vector (3 downto 0);
    saida  : out std_logic_vector (6 downto 0)
);
end bcd;

architecture bcd_architecture of bcd is
begin
    with entrada select
        saida <= 
            "1000000" when "0000", -- 0
            "1111001" when "0001", -- 1
            "0100100" when "0010", -- 2
            "0110000" when "0011", -- 3
            "0011001" when "0100", -- 4
            "0010010" when "0101", -- 5
            "0000010" when "0110", -- 6
            "1111000" when "0111", -- 7
            "0000000" when "1000", -- 8
            "0010000" when "1001", -- 9
            "1100000" when "1010", -- B
            "1000001" when "1011", -- V
            "1000110" when "1100", -- C
            "0011000" when "1101", -- Q
            "1110001" when "1110", -- L
            "0001100" when "1111", -- P
            "1111111" when others; -- apagado
end bcd_architecture;
