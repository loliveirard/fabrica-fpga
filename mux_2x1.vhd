-----------------------------------------------------------------
-- Multiplexador 2:1 de W bits implementado com uso de generic map
-- Baseado no codigo de exemplo da pagina 41 do livro "Free Range VHDL"
-----------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity mux_2x1 is
    generic (
        W : natural := 4   -- largura padrao do barramento
    );
    port (
        D0, D1 : in  std_logic_vector(W-1 downto 0);
        SEL    : in  std_logic;
        MX_OUT : out std_logic_vector(W-1 downto 0)
    );
end entity mux_2x1;

architecture behavioral of mux_2x1 is
begin
    -- Atribuição condicional: escolhe entre D0 e D1 com base em SEL
    MX_OUT <= D1 when SEL = '1' else
              D0;
end architecture behavioral;