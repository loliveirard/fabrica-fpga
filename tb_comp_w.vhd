    library IEEE;
use IEEE.std_logic_1164.all;

entity tb_comp_w is
end entity tb_comp_w;

architecture teste of tb_comp_w is
    constant W : natural := 8;

    signal A, B : std_logic_vector(W-1 downto 0);
    signal GT   : std_logic;

begin
    U_COMP : entity work.comp_w
        generic map (
            W => W
        )
        port map (
            A  => A,
            B  => B,
            GT => GT
        );

    stim_proc : process
    begin
        A <= "00000000"; B <= "00000000"; wait for 10 ns;
        A <= "00000001"; B <= "00000000"; wait for 10 ns;
        A <= "00000000"; B <= "00000001"; wait for 10 ns;
        A <= "11110000"; B <= "01110000"; wait for 10 ns;
        A <= "01111111"; B <= "11111111"; wait for 10 ns;
        A <= "10101010"; B <= "10101010"; wait for 10 ns;
        wait;
    end process stim_proc;
end architecture teste;