library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_bcd is
end tb_bcd;

architecture sim of tb_bcd is

    -- DUT inputs/outputs
    signal entrada : std_logic_vector(3 downto 0) := (others => '0');
    signal saida   : std_logic_vector(6 downto 0);

begin

    --------------------------------------------------------------------
    -- Instancia o DUT
    --------------------------------------------------------------------
    uut : entity work.bcd
        port map (
            entrada => entrada,
            saida   => saida
        );

    --------------------------------------------------------------------
    -- Processo de testes
    --------------------------------------------------------------------
    stim_proc : process
    begin

        ---------------------------------------------------------------
        -- Testa todas as entradas de 0 a 15 (0000 a 1111)
        ---------------------------------------------------------------
        for i in 0 to 15 loop
            entrada <= std_logic_vector(to_unsigned(i, 4));
            wait for 50 ns;
        end loop;

        wait;
    end process;

end sim;
