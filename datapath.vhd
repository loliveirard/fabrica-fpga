-- datapath_components_complete.vhd
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity datapath is
    port (
        clk     : in  std_logic;
        reset_n : in  std_logic;            -- ativo em '0'

        -- entradas físicas (switches) - 7 bits
        switches_in : in std_logic_vector(6 downto 0);

        -- controle (loads / clears / mux) - sinais esperados pela controladora
        ld_B  : in std_logic;  clr_B  : in std_logic;  mux_B  : in std_logic;
        ld_Q  : in std_logic;  clr_Q  : in std_logic;  mux_Q  : in std_logic;
        ld_P  : in std_logic;  clr_P  : in std_logic;  mux_P  : in std_logic;
        ld_L  : in std_logic;  clr_L  : in std_logic;  mux_L  : in std_logic;
        ld_C  : in std_logic;  clr_C  : in std_logic;  mux_C  : in std_logic;
        ld_V  : in std_logic;  clr_V  : in std_logic;  mux_V  : in std_logic;

        ld_E1 : in std_logic;  clr_E1 : in std_logic;  mux_E1 : in std_logic;
        ld_E2 : in std_logic;  clr_E2 : in std_logic;  mux_E2 : in std_logic;
        ld_E3 : in std_logic;  clr_E3 : in std_logic;  mux_E3 : in std_logic;
        ld_E4 : in std_logic;  clr_E4 : in std_logic;  mux_E4 : in std_logic;
        ld_E5 : in std_logic;  clr_E5 : in std_logic;  mux_E5 : in std_logic;
        ld_E6 : in std_logic;  clr_E6 : in std_logic;  mux_E6 : in std_logic;

        -- saídas para a controladora / debug
        B_reg_out : out std_logic_vector(3 downto 0);
        Q_reg_out : out std_logic_vector(3 downto 0);
        P_reg_out : out std_logic_vector(5 downto 0);
        L_reg_out : out std_logic_vector(5 downto 0);
        C_reg_out : out std_logic_vector(3 downto 0);
        V_reg_out : out std_logic_vector(6 downto 0);

        E1_out : out std_logic_vector(3 downto 0);
        E2_out : out std_logic_vector(3 downto 0);
        E3_out : out std_logic_vector(3 downto 0);
        E4_out : out std_logic_vector(3 downto 0);
        E5_out : out std_logic_vector(3 downto 0);
        E6_out : out std_logic_vector(3 downto 0);

        -- flags > x
        B_gt_0 : out std_logic;
        Q_gt_0 : out std_logic;
        C_gt_0 : out std_logic;
        P_gt_3 : out std_logic;
        L_gt_3 : out std_logic;
        V_gt_7 : out std_logic;

        -- bcd output
        bcd_in : in std_logic_vector(3 downto 0);
		  bcd_out: out std_logic_vector(6 downto 0)

    );
end entity datapath;


architecture rtl of datapath is

    -- Internal vectors backed by reg_w components
    signal B_reg_vec : std_logic_vector(3 downto 0) := (others => '0');
    signal Q_reg_vec : std_logic_vector(3 downto 0) := (others => '0');
    signal C_reg_vec : std_logic_vector(3 downto 0) := (others => '0');
    signal P_reg_vec : std_logic_vector(5 downto 0) := (others => '0');
    signal L_reg_vec : std_logic_vector(5 downto 0) := (others => '0');
    signal V_reg_vec : std_logic_vector(6 downto 0) := (others => '0');

    signal E1_vec, E2_vec, E3_vec, E4_vec, E5_vec, E6_vec : std_logic_vector(3 downto 0)
        := (others => '0');

    -- slices of switches
    signal sw_B : std_logic_vector(3 downto 0);
    signal sw_Q : std_logic_vector(3 downto 0);
    signal sw_C : std_logic_vector(3 downto 0);
    signal sw_P : std_logic_vector(5 downto 0);
    signal sw_L : std_logic_vector(5 downto 0);
    signal sw_V : std_logic_vector(6 downto 0);

    -- mux outputs (to regs)
    signal B_mux_out  : std_logic_vector(3 downto 0);
    signal Q_mux_out  : std_logic_vector(3 downto 0);
    signal C_mux_out  : std_logic_vector(3 downto 0);
    signal P_mux_out  : std_logic_vector(5 downto 0);
    signal L_mux_out  : std_logic_vector(5 downto 0);
    signal V_mux_out  : std_logic_vector(6 downto 0);

    -- E mux outputs (4 bits)
    signal E1_mux_out, E2_mux_out, E3_mux_out, E4_mux_out, E5_mux_out, E6_mux_out : std_logic_vector(3 downto 0);

    -- addsub results for decrement / increment
    signal B_sub_s : std_logic_vector(4 downto 0);
    signal Q_sub_s : std_logic_vector(4 downto 0);
    signal C_sub_s : std_logic_vector(4 downto 0);
    signal P_sub_s : std_logic_vector(6 downto 0);
    signal L_sub_s : std_logic_vector(6 downto 0);
    signal V_sub_s : std_logic_vector(7 downto 0);

    signal E1_sub_s, E2_sub_s, E3_sub_s, E4_sub_s, E5_sub_s, E6_sub_s : std_logic_vector(4 downto 0);
    signal E1_add_s, E2_add_s, E3_add_s, E4_add_s, E5_add_s, E6_add_s : std_logic_vector(4 downto 0);

    -- derived +1 / -1 vectors (final)
    signal B_minus1  : std_logic_vector(3 downto 0);
    signal Q_minus1  : std_logic_vector(3 downto 0);
    signal C_minus1  : std_logic_vector(3 downto 0);
    signal P_minus1  : std_logic_vector(5 downto 0);
    signal L_minus1  : std_logic_vector(5 downto 0);
    signal V_minus1  : std_logic_vector(6 downto 0);

    signal E1_minus1, E2_minus1, E3_minus1, E4_minus1, E5_minus1, E6_minus1 : std_logic_vector(3 downto 0);
    signal E1_plus1,  E2_plus1,  E3_plus1,  E4_plus1,  E5_plus1,  E6_plus1  : std_logic_vector(3 downto 0);

    -- comparator outputs (use local comparisons)
    -- helper constants
    constant ZERO4 : std_logic_vector(3 downto 0) := "0000";
    constant ZERO6 : std_logic_vector(5 downto 0) := "000000";
    constant ZERO7 : std_logic_vector(6 downto 0) := "0000000";

    -- component declarations
    component reg_w is
         generic ( W : natural := 4 );
         port (
              REG_IN  : in  std_logic_vector(W-1 downto 0);
              CLK     : in  std_logic;
              LD      : in  std_logic;
              CLR     : in  std_logic;
              REG_OUT : out std_logic_vector(W-1 downto 0)
         );
    end component reg_w;

    component mux_2x1 is
         generic ( W : natural := 4 );
         port (
              D0, D1 : in  std_logic_vector(W-1 downto 0);
              SEL    : in  std_logic;
              MX_OUT : out std_logic_vector(W-1 downto 0)
         );
    end component mux_2x1;

    component addsub_w is
         generic ( w : integer := 4 );
         port (
              A    : in  std_logic_vector(w-1 downto 0);
              B    : in  std_logic_vector(w-1 downto 0);
              SUB  : in  std_logic;
              S    : out std_logic_vector(w downto 0)
         );
    end component addsub_w;

    component comp_w is
         generic ( W : natural := 8 );
         port (
              A, B  : in  std_logic_vector(W-1 downto 0);
              GT    : out std_logic
         );
    end component comp_w;

    component bcd is
         port (
              entrada: in std_logic_vector (3 downto 0);
              saida  : out std_logic_vector (6 downto 0)
         );
    end component bcd;

begin

    -- mapear fatias de entrada (switches_in é 6 downto 0)
    sw_V <= switches_in;                         -- 7 bits
    sw_P <= '0' & switches_in(4 downto 0);       -- 6 bits (pad MSB)
    sw_L <= '0' & switches_in(4 downto 0);
    sw_B <= switches_in(3 downto 0);
    sw_Q <= switches_in(3 downto 0);
    sw_C <= switches_in(3 downto 0);

    ----------------------------------------------------------------
    -- ADD/SUB instâncias (gera S signals); para subtrair 1 usamos SUB='1'
    ----------------------------------------------------------------

    -- B - 1 (w=4) -> S(4 downto 0)
    U_B_SUB : addsub_w generic map ( w => 4 ) port map (
        A   => B_reg_vec,
        B   => "0001",
        SUB => '1',
        S   => B_sub_s
    );

    -- Q - 1
    U_Q_SUB : addsub_w generic map ( w => 4 ) port map (
        A   => Q_reg_vec,
        B   => "0001",
        SUB => '1',
        S   => Q_sub_s
    );

    -- C - 1
    U_C_SUB : addsub_w generic map ( w => 4 ) port map (
        A   => C_reg_vec,
        B   => "0001",
        SUB => '1',
        S   => C_sub_s
    );

    -- P - 1 (w=6)
    U_P_SUB : addsub_w generic map ( w => 6 ) port map (
        A   => P_reg_vec,
        B   => "000100",
        SUB => '1',
        S   => P_sub_s
    );

    -- L - 1 (w=6)
    U_L_SUB : addsub_w generic map ( w => 6 ) port map (
        A   => L_reg_vec,
        B   => "000100",
        SUB => '1',
        S   => L_sub_s
    );

    -- V - 1 (w=7)
    U_V_SUB : addsub_w generic map ( w => 7 ) port map (
        A   => V_reg_vec,
        B   => "0001000",
        SUB => '1',
        S   => V_sub_s
    );

    -- E counters: produce plus1 and minus1 (w=4)
    U_E1_ADD : addsub_w generic map ( w => 4 ) port map ( A => E1_vec, B => "0001", SUB => '0', S => E1_add_s );
    U_E1_SUB : addsub_w generic map ( w => 4 ) port map ( A => E1_vec, B => "0001", SUB => '1', S => E1_sub_s );

    U_E2_ADD : addsub_w generic map ( w => 4 ) port map ( A => E2_vec, B => "0001", SUB => '0', S => E2_add_s );
    U_E2_SUB : addsub_w generic map ( w => 4 ) port map ( A => E2_vec, B => "0001", SUB => '1', S => E2_sub_s );

    U_E3_ADD : addsub_w generic map ( w => 4 ) port map ( A => E3_vec, B => "0001", SUB => '0', S => E3_add_s );
    U_E3_SUB : addsub_w generic map ( w => 4 ) port map ( A => E3_vec, B => "0001", SUB => '1', S => E3_sub_s );

    U_E4_ADD : addsub_w generic map ( w => 4 ) port map ( A => E4_vec, B => "0001", SUB => '0', S => E4_add_s );
    U_E4_SUB : addsub_w generic map ( w => 4 ) port map ( A => E4_vec, B => "0001", SUB => '1', S => E4_sub_s );

    U_E5_ADD : addsub_w generic map ( w => 4 ) port map ( A => E5_vec, B => "0001", SUB => '0', S => E5_add_s );
    U_E5_SUB : addsub_w generic map ( w => 4 ) port map ( A => E5_vec, B => "0001", SUB => '1', S => E5_sub_s );

    U_E6_ADD : addsub_w generic map ( w => 4 ) port map ( A => E6_vec, B => "0001", SUB => '0', S => E6_add_s );
    U_E6_SUB : addsub_w generic map ( w => 4 ) port map ( A => E6_vec, B => "0001", SUB => '1', S => E6_sub_s );

    ----------------------------------------------------------------
    -- derive minus1 / plus1 vectors (saturate min 0)
    ----------------------------------------------------------------
    B_minus1 <= B_sub_s(3 downto 0) when B_reg_vec /= "0000" else "0000";
    Q_minus1 <= Q_sub_s(3 downto 0) when Q_reg_vec /= "0000" else "0000";
    C_minus1 <= C_sub_s(3 downto 0) when C_reg_vec /= "0000" else "0000";
    P_minus1 <= P_sub_s(5 downto 0) when P_reg_vec /= "000000" else "000000";
    L_minus1 <= L_sub_s(5 downto 0) when L_reg_vec /= "000000" else "000000";
    V_minus1 <= V_sub_s(6 downto 0) when V_reg_vec /= "0000000" else "0000000";

    E1_plus1  <= E1_add_s(3 downto 0);
    E1_minus1 <= E1_sub_s(3 downto 0);
    E2_plus1  <= E2_add_s(3 downto 0);
    E2_minus1 <= E2_sub_s(3 downto 0);
    E3_plus1  <= E3_add_s(3 downto 0);
    E3_minus1 <= E3_sub_s(3 downto 0);
    E4_plus1  <= E4_add_s(3 downto 0);
    E4_minus1 <= E4_sub_s(3 downto 0);
    E5_plus1  <= E5_add_s(3 downto 0);
    E5_minus1 <= E5_sub_s(3 downto 0);
    E6_plus1  <= E6_add_s(3 downto 0);
    E6_minus1 <= E6_sub_s(3 downto 0);

    ----------------------------------------------------------------
    -- MUXes: choose between external switches (D0) and minus_n (D1) for regs
    -- for E counters: D0=minus1 (mux=0->decrement), D1=plus1 (mux=1->increment)
    ----------------------------------------------------------------

    -- B: W=4
    U_MUX_B : mux_2x1 generic map ( W => 4 ) port map (
        D0 => sw_B,
        D1 => B_minus1,
        SEL => mux_B,
        MX_OUT => B_mux_out
    );

    -- Q
    U_MUX_Q : mux_2x1 generic map ( W => 4 ) port map (
        D0 => sw_Q,
        D1 => Q_minus1,
        SEL => mux_Q,
        MX_OUT => Q_mux_out
    );

    -- C
    U_MUX_C : mux_2x1 generic map ( W => 4 ) port map (
        D0 => sw_C,
        D1 => C_minus1,
        SEL => mux_C,
        MX_OUT => C_mux_out
    );

    -- P (W=6)
    U_MUX_P : mux_2x1 generic map ( W => 6 ) port map (
        D0 => sw_P,
        D1 => P_minus1,
        SEL => mux_P,
        MX_OUT => P_mux_out
    );

    -- L (W=6)
    U_MUX_L : mux_2x1 generic map ( W => 6 ) port map (
        D0 => sw_L,
        D1 => L_minus1,
        SEL => mux_L,
        MX_OUT => L_mux_out
    );

    -- V (W=7)
    U_MUX_V : mux_2x1 generic map ( W => 7 ) port map (
        D0 => sw_V,
        D1 => V_minus1,
        SEL => mux_V,
        MX_OUT => V_mux_out
    );

    -- E1..E6 (W=4) : D0 = minus1, D1 = plus1
    U_MUX_E1 : mux_2x1 generic map ( W => 4 ) port map (
        D0 => E1_minus1, D1 => E1_plus1, SEL => mux_E1, MX_OUT => E1_mux_out
    );
    U_MUX_E2 : mux_2x1 generic map ( W => 4 ) port map (
        D0 => E2_minus1, D1 => E2_plus1, SEL => mux_E2, MX_OUT => E2_mux_out
    );
    U_MUX_E3 : mux_2x1 generic map ( W => 4 ) port map (
        D0 => E3_minus1, D1 => E3_plus1, SEL => mux_E3, MX_OUT => E3_mux_out
    );
    U_MUX_E4 : mux_2x1 generic map ( W => 4 ) port map (
        D0 => E4_minus1, D1 => E4_plus1, SEL => mux_E4, MX_OUT => E4_mux_out
    );
    U_MUX_E5 : mux_2x1 generic map ( W => 4 ) port map (
        D0 => E5_minus1, D1 => E5_plus1, SEL => mux_E5, MX_OUT => E5_mux_out
    );
    U_MUX_E6 : mux_2x1 generic map ( W => 4 ) port map (
        D0 => E6_minus1, D1 => E6_plus1, SEL => mux_E6, MX_OUT => E6_mux_out
    );

    ----------------------------------------------------------------
    -- REGISTERS: reg_w instances for each register size
    ----------------------------------------------------------------

    U_REG_B : reg_w generic map ( W => 4 ) port map (
        REG_IN  => B_mux_out,
        CLK     => clk,
        LD      => ld_B,
        CLR     => clr_B,
        REG_OUT => B_reg_vec
    );

    U_REG_Q : reg_w generic map ( W => 4 ) port map (
        REG_IN  => Q_mux_out, CLK => clk, LD => ld_Q, CLR => clr_Q, REG_OUT => Q_reg_vec
    );

    U_REG_C : reg_w generic map ( W => 4 ) port map (
        REG_IN  => C_mux_out, CLK => clk, LD => ld_C, CLR => clr_C, REG_OUT => C_reg_vec
    );

    U_REG_P : reg_w generic map ( W => 6 ) port map (
        REG_IN  => P_mux_out, CLK => clk, LD => ld_P, CLR => clr_P, REG_OUT => P_reg_vec
    );

    U_REG_L : reg_w generic map ( W => 6 ) port map (
        REG_IN  => L_mux_out, CLK => clk, LD => ld_L, CLR => clr_L, REG_OUT => L_reg_vec
    );

    U_REG_V : reg_w generic map ( W => 7 ) port map (
        REG_IN  => V_mux_out, CLK => clk, LD => ld_V, CLR => clr_V, REG_OUT => V_reg_vec
    );

    -- E regs (w=4)
    U_REG_E1 : reg_w generic map ( W => 4 ) port map ( REG_IN => E1_mux_out, CLK => clk, LD => ld_E1, CLR => clr_E1, REG_OUT => E1_vec );
    U_REG_E2 : reg_w generic map ( W => 4 ) port map ( REG_IN => E2_mux_out, CLK => clk, LD => ld_E2, CLR => clr_E2, REG_OUT => E2_vec );
    U_REG_E3 : reg_w generic map ( W => 4 ) port map ( REG_IN => E3_mux_out, CLK => clk, LD => ld_E3, CLR => clr_E3, REG_OUT => E3_vec );
    U_REG_E4 : reg_w generic map ( W => 4 ) port map ( REG_IN => E4_mux_out, CLK => clk, LD => ld_E4, CLR => clr_E4, REG_OUT => E4_vec );
    U_REG_E5 : reg_w generic map ( W => 4 ) port map ( REG_IN => E5_mux_out, CLK => clk, LD => ld_E5, CLR => clr_E5, REG_OUT => E5_vec );
    U_REG_E6 : reg_w generic map ( W => 4 ) port map ( REG_IN => E6_mux_out, CLK => clk, LD => ld_E6, CLR => clr_E6, REG_OUT => E6_vec );

    ----------------------------------------------------------------
    -- FLAGS / THRESHOLDS (com unsigned comparisons)
    ----------------------------------------------------------------
    B_gt_0 <= '1' when unsigned(B_reg_vec) > 0 else '0';
    Q_gt_0 <= '1' when unsigned(Q_reg_vec) > 0 else '0';
    C_gt_0 <= '1' when unsigned(C_reg_vec) > 0 else '0';
    P_gt_3 <= '1' when unsigned(P_reg_vec) > 3 else '0';
    L_gt_3 <= '1' when unsigned(L_reg_vec) > 3 else '0';
    V_gt_7 <= '1' when unsigned(V_reg_vec) > 7 else '0';
	 
	 ----------------------------------------------------------------
	 -- BCD
	 ----------------------------------------------------------------
	 U_BCD : bcd
    port map (
        entrada => bcd_in,
        saida   => bcd_out
    );

    ----------------------------------------------------------------
    -- Outputs & helpers
    ----------------------------------------------------------------
    B_reg_out <= B_reg_vec;
    Q_reg_out <= Q_reg_vec;
    C_reg_out <= C_reg_vec;
    P_reg_out <= P_reg_vec;
    L_reg_out <= L_reg_vec;
    V_reg_out <= V_reg_vec;

    E1_out <= E1_vec;
    E2_out <= E2_vec;
    E3_out <= E3_vec;
    E4_out <= E4_vec;
    E5_out <= E5_vec;
    E6_out <= E6_vec;

end architecture rtl;