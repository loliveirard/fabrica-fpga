library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity datapath_tb is
end entity datapath_tb;

architecture tb_rtl of datapath_tb is
    signal clk_s, reset_n_s : std_logic := '0';
    signal switches_in_s : std_logic_vector(6 downto 0) := (others => '0');
    signal ld_B_s, clr_B_s, mux_B_s : std_logic := '0';
    signal ld_Q_s, clr_Q_s, mux_Q_s : std_logic := '0';
    signal ld_P_s, clr_P_s, mux_P_s : std_logic := '0';
    signal ld_L_s, clr_L_s, mux_L_s : std_logic := '0';
    signal ld_C_s, clr_C_s, mux_C_s : std_logic := '0';
    signal ld_V_s, clr_V_s, mux_V_s : std_logic := '0';
    signal ld_E1_s, clr_E1_s, mux_E1_s : std_logic := '0';
    signal ld_E2_s, clr_E2_s, mux_E2_s : std_logic := '0';
    signal ld_E3_s, clr_E3_s, mux_E3_s : std_logic := '0';
    signal ld_E4_s, clr_E4_s, mux_E4_s : std_logic := '0';
    signal ld_E5_s, clr_E5_s, mux_E5_s : std_logic := '0';
    signal ld_E6_s, clr_E6_s, mux_E6_s : std_logic := '0';
    signal B_reg_out_s, Q_reg_out_s, C_reg_out_s : std_logic_vector(3 downto 0);
    signal P_reg_out_s, L_reg_out_s : std_logic_vector(5 downto 0);
    signal V_reg_out_s : std_logic_vector(6 downto 0);
    signal E1_out_s, E2_out_s, E3_out_s, E4_out_s, E5_out_s, E6_out_s : std_logic_vector(3 downto 0);
    signal B_gt_0_s, Q_gt_0_s, C_gt_0_s, P_gt_3_s, L_gt_3_s, V_gt_7_s : std_logic;
    signal bcd1_out_s, bcd2_out_s, bcd3_out_s, bcd4_out_s, bcd5_out_s, bcd6_out_s : std_logic_vector(6 downto 0);

    constant CLK_PERIOD : time := 10 ns;
begin
    UUT: entity work.datapath port map (
        clk => clk_s, switches_in => switches_in_s,
        ld_B => ld_B_s, clr_B => clr_B_s, mux_B => mux_B_s,
        ld_Q => ld_Q_s, clr_Q => clr_Q_s, mux_Q => mux_Q_s,
        ld_P => ld_P_s, clr_P => clr_P_s, mux_P => mux_P_s,
        ld_L => ld_L_s, clr_L => clr_L_s, mux_L => mux_L_s,
        ld_C => ld_C_s, clr_C => clr_C_s, mux_C => mux_C_s,
        ld_V => ld_V_s, clr_V => clr_V_s, mux_V => mux_V_s,
        ld_E1 => ld_E1_s, clr_E1 => clr_E1_s, mux_E1 => mux_E1_s,
        ld_E2 => ld_E2_s, clr_E2 => clr_E2_s, mux_E2 => mux_E2_s,
        ld_E3 => ld_E3_s, clr_E3 => clr_E3_s, mux_E3 => mux_E3_s,
        ld_E4 => ld_E4_s, clr_E4 => clr_E4_s, mux_E4 => mux_E4_s,
        ld_E5 => ld_E5_s, clr_E5 => clr_E5_s, mux_E5 => mux_E5_s,
        ld_E6 => ld_E6_s, clr_E6 => clr_E6_s, mux_E6 => mux_E6_s,
        B_reg_out => B_reg_out_s, Q_reg_out => Q_reg_out_s, P_reg_out => P_reg_out_s,
        L_reg_out => L_reg_out_s, C_reg_out => C_reg_out_s, V_reg_out => V_reg_out_s,
        E1_out => E1_out_s, E2_out => E2_out_s, E3_out => E3_out_s,
        E4_out => E4_out_s, E5_out => E5_out_s, E6_out => E6_out_s,
        B_gt_0 => B_gt_0_s, Q_gt_0 => Q_gt_0_s, C_gt_0 => C_gt_0_s,
        P_gt_3 => P_gt_3_s, L_gt_3 => L_gt_3_s, V_gt_7 => V_gt_7_s,
        bcd1_out => bcd1_out_s, bcd2_out => bcd2_out_s, bcd3_out => bcd3_out_s,
        bcd4_out => bcd4_out_s, bcd5_out => bcd5_out_s, bcd6_out => bcd6_out_s
    );

    clk_process : process
    begin
        loop
            clk_s <= '0'; wait for CLK_PERIOD/2;
            clk_s <= '1'; wait for CLK_PERIOD/2;
        end loop;
    end process;

    stimulus_process : process
    begin
        reset_n_s <= '0';
        wait for CLK_PERIOD;
        reset_n_s <= '1';
        wait for CLK_PERIOD;

        switches_in_s <= "1001010";
        ld_B_s <= '1'; mux_B_s <= '0';
        ld_V_s <= '1'; mux_V_s <= '0';
        wait for CLK_PERIOD;
        ld_B_s <= '0'; ld_V_s <= '0';

        ld_B_s <= '1'; mux_B_s <= '1';
        wait for CLK_PERIOD * 10;
        wait for CLK_PERIOD;
        ld_B_s <= '0';

        switches_in_s <= "0010100";
        ld_P_s <= '1'; mux_P_s <= '0';
        wait for CLK_PERIOD;
        ld_P_s <= '0';
        clr_P_s <= '1';
        wait for CLK_PERIOD;
        clr_P_s <= '0';

        switches_in_s <= "0000100";
        ld_P_s <= '1'; mux_P_s <= '0'; wait for CLK_PERIOD; ld_P_s <= '0';
        ld_P_s <= '1'; mux_P_s <= '1'; wait for CLK_PERIOD; ld_P_s <= '0';

        ld_E1_s <= '1'; mux_E1_s <= '0';
        ld_E2_s <= '1'; mux_E2_s <= '1';
        wait for CLK_PERIOD * 5;
        ld_E1_s <= '0'; ld_E2_s <= '0';

        wait;
    end process;

end architecture;