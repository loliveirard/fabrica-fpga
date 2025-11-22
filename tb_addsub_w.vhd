library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity tb_addsub_w is
end tb_addsub_w;

architecture behavior of tb_addsub_w is

    -- Component declaration for the addsub_w
    component addsub_w is
        generic (
            w : integer := 4  -- tamanho das entradas em bits (padrão 4)
        );
        port (
            A    : in  std_logic_vector(w-1 downto 0);
            B    : in  std_logic_vector(w-1 downto 0);
            SUB  : in  std_logic;
            S    : out std_logic_vector(w downto 0)
        );
    end component;

    -- Test signals
    signal A    : std_logic_vector(3 downto 0);
    signal B    : std_logic_vector(3 downto 0);
    signal SUB  : std_logic;
    signal S    : std_logic_vector(4 downto 0);

begin

    -- Instantiate the Unit Under Test (UUT)
    uut: addsub_w
        port map (
            A => A,
            B => B,
            SUB => SUB,
            S => S
        );

    -- Stimulus process
    stim_proc: process
    begin
        -- Test case 1: Soma A + B quando SUB = 0
        A <= "0101"; B <= "0011"; SUB <= '0';  -- 5 + 3 = 8
        wait for 10 ns;

        -- Test case 2: Subtração A - B quando SUB = 1
        A <= "0101"; B <= "0011"; SUB <= '1';  -- 5 - 3 = 2
        wait for 10 ns;

        -- Test case 3: Soma A + B quando SUB = 0
        A <= "1111"; B <= "0001"; SUB <= '0';  -- 15 + 1 = 16
        wait for 10 ns;

        -- Test case 4: Subtração A - B quando SUB = 1
        A <= "1111"; B <= "0001"; SUB <= '1';  -- 15 - 1 = 14
        wait for 10 ns;

        -- Test case 5: Soma A + B quando SUB = 0
        A <= "0000"; B <= "0000"; SUB <= '0';  -- 0 + 0 = 0
        wait for 10 ns;

        -- Test case 6: Subtração A - B quando SUB = 1
        A <= "0000"; B <= "0000"; SUB <= '1';  -- 0 - 0 = 0
        wait for 10 ns;

        -- Test case 7: Subtração A - B quando SUB = 1
        A <= "1000"; B <= "0100"; SUB <= '1';  -- 8 - 4 = 4
        wait for 10 ns;

        -- Test case 8: Soma A + B quando SUB = 0
        A <= "1010"; B <= "1100"; SUB <= '0';  -- 10 + 12 = 22
        wait for 10 ns;

        -- Test case 9: Subtração A - B quando SUB = 1
        A <= "1010"; B <= "1100"; SUB <= '1';  -- 10 - 12 = -2
        wait for 10 ns;

        -- End the simulation
        wait;
    end process;

end behavior;