library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_controladora is
end entity;

architecture sim of tb_controladora is

    --------------------------------------------------------------------
    -- DUT declaration
    --------------------------------------------------------------------
    component controladora is
        port(
            clk      : in  std_logic;
            rst      : in  std_logic;
            btn_edge : in  std_logic;

            Bgt0 : in std_logic;
            Vgt7 : in std_logic;
            Cgt0 : in std_logic;
            Qgt0 : in std_logic;
            Lgt3 : in std_logic;
            Pgt3 : in std_logic;

            ld_B, clr_B, mux_B : out std_logic;
            ld_V, clr_V, mux_V : out std_logic;
            ld_C, clr_C, mux_C : out std_logic;
            ld_Q, clr_Q, mux_Q : out std_logic;
            ld_L, clr_L, mux_L : out std_logic;
            ld_P, clr_P, mux_P : out std_logic;

            ld_E1, clr_E1, mux_E1 : out std_logic;
            ld_E2, clr_E2, mux_E2 : out std_logic;
            ld_E3, clr_E3, mux_E3 : out std_logic;
            ld_E4, clr_E4, mux_E4 : out std_logic;
            ld_E5, clr_E5, mux_E5 : out std_logic;
            ld_E6, clr_E6, mux_E6 : out std_logic;

            ld_DATA : out std_logic
        );
    end component;

    --------------------------------------------------------------------
    -- DUT Signals
    --------------------------------------------------------------------
    signal clk      : std_logic := '0';
    signal rst      : std_logic := '1';
    signal btn_edge : std_logic := '0';

    signal Bgt0 : std_logic := '0';
    signal Vgt7 : std_logic := '0';
    signal Cgt0 : std_logic := '0';
    signal Qgt0 : std_logic := '0';
    signal Lgt3 : std_logic := '0';
    signal Pgt3 : std_logic := '0';

    signal ld_B, clr_B, mux_B : std_logic;
    signal ld_V, clr_V, mux_V : std_logic;
    signal ld_C, clr_C, mux_C : std_logic;
    signal ld_Q, clr_Q, mux_Q : std_logic;
    signal ld_L, clr_L, mux_L : std_logic;
    signal ld_P, clr_P, mux_P : std_logic;

    signal ld_E1, clr_E1, mux_E1 : std_logic;
    signal ld_E2, clr_E2, mux_E2 : std_logic;
    signal ld_E3, clr_E3, mux_E3 : std_logic;
    signal ld_E4, clr_E4, mux_E4 : std_logic;
    signal ld_E5, clr_E5, mux_E5 : std_logic;
    signal ld_E6, clr_E6, mux_E6 : std_logic;

    signal ld_DATA : std_logic;

begin

    --------------------------------------------------------------------
    -- CLOCK (20 ns)
    --------------------------------------------------------------------
    clk <= not clk after 10 ns;

    --------------------------------------------------------------------
    -- DUT Instance
    --------------------------------------------------------------------
    DUT : controladora
        port map(
            clk => clk,
            rst => rst,
            btn_edge => btn_edge,

            Bgt0 => Bgt0,
            Vgt7 => Vgt7,
            Cgt0 => Cgt0,
            Qgt0 => Qgt0,
            Lgt3 => Lgt3,
            Pgt3 => Pgt3,

            ld_B => ld_B, clr_B => clr_B, mux_B => mux_B,
            ld_V => ld_V, clr_V => clr_V, mux_V => mux_V,
            ld_C => ld_C, clr_C => clr_C, mux_C => mux_C,
            ld_Q => ld_Q, clr_Q => clr_Q, mux_Q => mux_Q,
            ld_L => ld_L, clr_L => clr_L, mux_L => mux_L,
            ld_P => ld_P, clr_P => clr_P, mux_P => mux_P,

            ld_E1 => ld_E1, clr_E1 => clr_E1, mux_E1 => mux_E1,
            ld_E2 => ld_E2, clr_E2 => clr_E2, mux_E2 => mux_E2,
            ld_E3 => ld_E3, clr_E3 => clr_E3, mux_E3 => mux_E3,
            ld_E4 => ld_E4, clr_E4 => clr_E4, mux_E4 => mux_E4,
            ld_E5 => ld_E5, clr_E5 => clr_E5, mux_E5 => mux_E5,
            ld_E6 => ld_E6, clr_E6 => clr_E6, mux_E6 => mux_E6,

            ld_DATA => ld_DATA
        );

    --------------------------------------------------------------------
    -- TEST SEQUENCE
    --------------------------------------------------------------------
    stim : process
    begin

        ----------------------------------------------------------------
        -- RESET
        ----------------------------------------------------------------
        rst <= '1';
        wait for 50 ns;
        rst <= '0';

        ----------------------------------------------------------------
        -- ETAPA DE LEITURA (7 apertos do botão)
        ----------------------------------------------------------------
        for i in 0 to 6 loop
            btn_edge <= '1';
            wait for 20 ns;
            btn_edge <= '0';
            wait for 60 ns;
        end loop;

        ----------------------------------------------------------------
        -- PROCESSAMENTO COMPLETO
        ----------------------------------------------------------------

        -- PROC_0 → PROC_B
        Bgt0 <= '1';
        wait for 40 ns;
        Bgt0 <= '0';

        -- PROC_B → PROC_V
        Vgt7 <= '1';
        wait for 40 ns;
        Vgt7 <= '0';

        -- PROC_V → PROC_C
        Cgt0 <= '1';
        wait for 40 ns;
        Cgt0 <= '0';

        -- PROC_C → PROC_Q
        Qgt0 <= '1';
        wait for 40 ns;
        Qgt0 <= '0';

        -- PROC_Q → PROC_L
        Lgt3 <= '1';
        wait for 40 ns;
        Lgt3 <= '0';

        -- PROC_L → PROC_P
        Pgt3 <= '1';
        wait for 40 ns;
        Pgt3 <= '0';

        ----------------------------------------------------------------
        -- PROC_P → WRITE → INICIO
        ----------------------------------------------------------------
        wait for 100 ns;

        ----------------------------------------------------------------
        wait;
    end process;

end architecture;
