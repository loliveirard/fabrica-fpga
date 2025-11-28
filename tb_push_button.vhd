-- tb_push_button.vhd
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_push_button is
end entity tb_push_button;

architecture sim of tb_push_button is

    signal CLK    : std_logic := '0';
    signal entrada: std_logic := '0';
    signal Saida  : std_logic;

    constant CLK_PERIOD : time := 20 ns;

begin

    ----------------------------------------------------------------
    -- Instancia o DUT
    ----------------------------------------------------------------
    UUT: entity work.push_button
        port map (
            entrada => entrada,
            CLK     => CLK,
            Saida   => Saida
        );

    ----------------------------------------------------------------
    -- Geração do Clock
    ----------------------------------------------------------------
    clk_proc : process
    begin
        while now < 200 us loop
            CLK <= '0';
            wait for CLK_PERIOD/2;
            CLK <= '1';
            wait for CLK_PERIOD/2;
        end loop;
        wait;
    end process;

    ----------------------------------------------------------------
    -- Geração de Estímulos na Entrada
    ----------------------------------------------------------------
    stim_proc : process
    begin
        -- espera
        entrada <= '0';
        wait for 100 ns;

        -- simula pressionamentos rapidos e estabiliza em '1'
        entrada <= '1'; wait for 6 ns;
        entrada <= '0'; wait for 8 ns;
        entrada <= '1'; wait for 12 ns;
        entrada <= '0'; wait for 5 ns;
        entrada <= '1';                   
        wait for 200 ns;

        -- simula pressionamentos rapidos e estabiliza em '0'
        entrada <= '0'; wait for 7 ns;
        entrada <= '1'; wait for 9 ns;
        entrada <= '0'; wait for 11 ns;
        entrada <= '1'; wait for 6 ns;
        entrada <= '0';
        wait for 200 ns;


        wait for 100 ns;
        wait;
    end process;

end architecture sim;
