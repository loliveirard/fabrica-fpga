-----------------------------------------------------------------
-- Comparador de W bits
-- Saída = '1' se A > B, caso contrário '0'
-----------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity comp_w is
    generic (
        W : natural := 8   -- largura padrão dos operandos
    );
    port (
        A, B  : in  std_logic_vector(W-1 downto 0);
        GT    : out std_logic                    -- '1' se A > B
    );
end entity comp_w;

architecture rtl of comp_w is
begin
    process (A, B)
    begin
        if unsigned(A) > unsigned(B) then
            GT <= '1';
        else
            GT <= '0';
        end if;
    end process;
end architecture rtl;