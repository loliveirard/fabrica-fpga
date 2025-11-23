library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use std.textio.all;

entity tb_fabrica is
end entity tb_fabrica;

architecture sim of tb_fabrica is

    -- DUT ports
    signal clk_tb         : std_logic := '0';
    signal rst_n_tb       : std_logic := '0';
    signal btn_edge_tb    : std_logic := '0';
    signal switches_tb    : std_logic_vector(6 downto 0) := (others => '0');

    -- Clock period
    constant CLK_PERIOD : time := 20 ns;

begin
    --------------------------------------------------------------------
    -- DUT instantiation
    --------------------------------------------------------------------
    dut : entity work.fabrica
        port map (
            clk         => clk_tb,
            rst_n       => rst_n_tb,
            btn_edge    => btn_edge_tb,
            switches_in => switches_tb
        );

    --------------------------------------------------------------------
    -- CLOCK GENERATION
    --------------------------------------------------------------------
    clk_process : process
    begin
        clk_tb <= '0';
        wait for CLK_PERIOD/2;
        clk_tb <= '1';
        wait for CLK_PERIOD/2;
    end process;

    --------------------------------------------------------------------
    -- RESET SEQUENCE
    --------------------------------------------------------------------
    reset_process : process
    begin
        rst_n_tb <= '0';
        wait for 200 ns;        -- reset asserted
        rst_n_tb <= '1';        -- release reset
        wait;
    end process;

    --------------------------------------------------------------------
    -- BUTTON EDGE PULSE GENERATOR
    --------------------------------------------------------------------
    stim_btn : process
    begin
        wait for 350 ns;        
        btn_edge_tb <= '1';
        wait for CLK_PERIOD;
        btn_edge_tb <= '0';

        wait for 2 us;

        -- segundo cálculo (opcional)
        btn_edge_tb <= '1';
        wait for CLK_PERIOD;
        btn_edge_tb <= '0';

        wait;
    end process;

    --------------------------------------------------------------------
    -- SWITCHES STIMULUS (INPUT DATA)
    --------------------------------------------------------------------
    stim_switches : process
    begin
        wait for 500 ns;

        -- Exemplo: definir switches para um valor útil
        -- switches_tb(3 downto 0) = BCD
        -- switches_tb(6 downto 4) = outras entradas para o datapath
        switches_tb <= "1011011";  -- altere conforme necessário

        wait for 5 us;

        switches_tb <= "0100010";

        wait;
    end process;

    --------------------------------------------------------------------
    -- SIMULATION END TIME
    --------------------------------------------------------------------
    end_simulation : process
    begin
        wait for 20 us;
        report "Simulation finished." severity note;
        wait;
    end process;

end architecture sim;
