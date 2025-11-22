-----------------------------------------------------------------
-- Registrador de W bits com sinais de LOAD e CLEAR
-- Baseado no código de exemplo da página 217 do livro "Free Range VHDL"
-----------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity reg_w is
    generic (
        W : natural := 4   -- largura padrão do registrador
    );
    port (
        REG_IN  : in  std_logic_vector(W-1 downto 0);
        CLK     : in  std_logic;
        LD      : in  std_logic;
        CLR     : in  std_logic;
        REG_OUT : out std_logic_vector(W-1 downto 0)
    );
end entity reg_w;

architecture reg of reg_w is
    signal reg_data : std_logic_vector(W-1 downto 0);
begin
    load_process : process (CLK)
    begin
        if rising_edge(CLK) then
            if CLR = '1' then
                reg_data <= (others => '0');        -- limpa o registrador
            elsif LD = '1' then
                reg_data <= REG_IN;                 -- carrega novo valor
            end if;
        end if;
    end process load_process;

    REG_OUT <= reg_data;
end architecture reg;