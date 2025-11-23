-- fabrica.vhd
-- Top-level integrating controladora and datapath
-- Instancia /mnt/data/controladora.vhd e /mnt/data/datapath.vhd (use those exact files)
--
-- Notes:
--  * report.txt is written using TEXTIO when ld_DATA goes '1' (simulation only).
--  * Timestamp written is simulation time (now) converted to HH:MM:SS relative to sim start.
--  * bcd_in is currently driven by switches_in(3 downto 0). If you want the controladora
--    to drive the bcd selection, provide a controladora variant with an output port (Con_BCD)
--    and I will adapt the top to wire it.

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use std.textio.all;

entity fabrica is
    port (
        clk         : in  std_logic;
        rst_n       : in  std_logic;                 -- active low reset for datapath
        btn_edge    : in  std_logic;
        switches_in : in  std_logic_vector(6 downto 0)  -- 7 physical switches
    );
end entity fabrica;

architecture rtl of fabrica is

    -- signals between controladora and datapath
    -- controladora inputs (from datapath)
    signal Bgt0_sig, Vgt7_sig, Cgt0_sig, Qgt0_sig, Lgt3_sig, Pgt3_sig : std_logic;

    -- controladora outputs -> datapath control
    signal ld_B_sig, clr_B_sig, mux_B_sig : std_logic;
    signal ld_V_sig, clr_V_sig, mux_V_sig : std_logic;
    signal ld_C_sig, clr_C_sig, mux_C_sig : std_logic;
    signal ld_Q_sig, clr_Q_sig, mux_Q_sig : std_logic;
    signal ld_L_sig, clr_L_sig, mux_L_sig : std_logic;
    signal ld_P_sig, clr_P_sig, mux_P_sig : std_logic;

    signal ld_E1_sig, clr_E1_sig, mux_E1_sig : std_logic;
    signal ld_E2_sig, clr_E2_sig, mux_E2_sig : std_logic;
    signal ld_E3_sig, clr_E3_sig, mux_E3_sig : std_logic;
    signal ld_E4_sig, clr_E4_sig, mux_E4_sig : std_logic;
    signal ld_E5_sig, clr_E5_sig, mux_E5_sig : std_logic;
    signal ld_E6_sig, clr_E6_sig, mux_E6_sig : std_logic;

    signal ld_DATA_sig : std_logic;

    -- datapath outputs to be recorded
    signal E1_out_sig, E2_out_sig, E3_out_sig, E4_out_sig, E5_out_sig, E6_out_sig : std_logic_vector(3 downto 0);

    signal B_reg_out_sig : std_logic_vector(3 downto 0);
    signal Q_reg_out_sig : std_logic_vector(3 downto 0);
    signal P_reg_out_sig : std_logic_vector(5 downto 0);
    signal L_reg_out_sig : std_logic_vector(5 downto 0);
    signal C_reg_out_sig : std_logic_vector(3 downto 0);
    signal V_reg_out_sig : std_logic_vector(6 downto 0);

    -- datapath flags back to controller
    signal B_gt_0_sig, Q_gt_0_sig, C_gt_0_sig, P_gt_3_sig, L_gt_3_sig, V_gt_7_sig : std_logic;

    -- bcd interface: datapath expects bcd_in (4 bits) as input
    signal bcd_in_sig  : std_logic_vector(3 downto 0);
    signal bcd_out_sig : std_logic_vector(6 downto 0);

begin

    ----------------------------------------------------------------
    -- Instantiate controladora (DUT)
    -- The controladora entity file must be in the project (you already provided it)
    ----------------------------------------------------------------
    u_controladora : entity work.controladora
        port map (
            clk      => clk,
            rst      => rst_n,      -- controladora used rst active '1' in its code; keep mapping as your file expects
            btn_edge => btn_edge,

            Bgt0 => Bgt0_sig,
            Vgt7 => Vgt7_sig,
            Cgt0 => Cgt0_sig,
            Qgt0 => Qgt0_sig,
            Lgt3 => Lgt3_sig,
            Pgt3 => Pgt3_sig,

            ld_B => ld_B_sig, clr_B => clr_B_sig, mux_B => mux_B_sig,
            ld_V => ld_V_sig, clr_V => clr_V_sig, mux_V => mux_V_sig,
            ld_C => ld_C_sig, clr_C => clr_C_sig, mux_C => mux_C_sig,
            ld_Q => ld_Q_sig, clr_Q => clr_Q_sig, mux_Q => mux_Q_sig,
            ld_L => ld_L_sig, clr_L => clr_L_sig, mux_L => mux_L_sig,
            ld_P => ld_P_sig, clr_P => clr_P_sig, mux_P => mux_P_sig,

            ld_E1 => ld_E1_sig, clr_E1 => clr_E1_sig, mux_E1 => mux_E1_sig,
            ld_E2 => ld_E2_sig, clr_E2 => clr_E2_sig, mux_E2 => mux_E2_sig,
            ld_E3 => ld_E3_sig, clr_E3 => clr_E3_sig, mux_E3 => mux_E3_sig,
            ld_E4 => ld_E4_sig, clr_E4 => clr_E4_sig, mux_E4 => mux_E4_sig,
            ld_E5 => ld_E5_sig, clr_E5 => clr_E5_sig, mux_E5 => mux_E5_sig,
            ld_E6 => ld_E6_sig, clr_E6 => clr_E6_sig, mux_E6 => mux_E6_sig,

				bcd_ctrl => bcd_in_sig,
				
            ld_DATA => ld_DATA_sig
        );

    -- (The mapping above intentionally uses the exact port names from your controladora file.)

    ----------------------------------------------------------------
    -- Instantiate datapath
    ----------------------------------------------------------------
    u_datapath : entity work.datapath
        port map (
            clk => clk,
            reset_n => rst_n,
            switches_in => switches_in,

            -- control from controller
            ld_B => ld_B_sig, clr_B => clr_B_sig, mux_B => mux_B_sig,
            ld_Q => ld_Q_sig, clr_Q => clr_Q_sig, mux_Q => mux_Q_sig,
            ld_P => ld_P_sig, clr_P => clr_P_sig, mux_P => mux_P_sig,
            ld_L => ld_L_sig, clr_L => clr_L_sig, mux_L => mux_L_sig,
            ld_C => ld_C_sig, clr_C => clr_C_sig, mux_C => mux_C_sig,
            ld_V => ld_V_sig, clr_V => clr_V_sig, mux_V => mux_V_sig,

            ld_E1 => ld_E1_sig, clr_E1 => clr_E1_sig, mux_E1 => mux_E1_sig,
            ld_E2 => ld_E2_sig, clr_E2 => clr_E2_sig, mux_E2 => mux_E2_sig,
            ld_E3 => ld_E3_sig, clr_E3 => clr_E3_sig, mux_E3 => mux_E3_sig,
            ld_E4 => ld_E4_sig, clr_E4 => clr_E4_sig, mux_E4 => mux_E4_sig,
            ld_E5 => ld_E5_sig, clr_E5 => clr_E5_sig, mux_E5 => mux_E5_sig,
            ld_E6 => ld_E6_sig, clr_E6 => clr_E6_sig, mux_E6 => mux_E6_sig,

            -- datapath outputs
            B_reg_out => B_reg_out_sig,
            Q_reg_out => Q_reg_out_sig,
            P_reg_out => P_reg_out_sig,
            L_reg_out => L_reg_out_sig,
            C_reg_out => C_reg_out_sig,
            V_reg_out => V_reg_out_sig,

            E1_out => E1_out_sig,
            E2_out => E2_out_sig,
            E3_out => E3_out_sig,
            E4_out => E4_out_sig,
            E5_out => E5_out_sig,
            E6_out => E6_out_sig,

            -- flags back to controller
            B_gt_0 => Bgt0_sig,
            Q_gt_0 => Qgt0_sig,
            P_gt_3 => Pgt3_sig,
            L_gt_3 => Lgt3_sig,
            C_gt_0 => Cgt0_sig,
            V_gt_7 => Vgt7_sig,   

            -- BCD wiring: datapath expects a 4-bit bcd_in input which is selected by the controller
            bcd_in => bcd_in_sig,   -- default: drive BCD from switches (change if controller supplies selection)
            bcd_out => bcd_out_sig
        );

    ----------------------------------------------------------------
    -- REPORT: append to "report.txt" every time ld_DATA_sig is asserted
    -- This uses TEXTIO and simulation time. Note: simulators differ in support for 'append' mode.
    ----------------------------------------------------------------
    process
        file report_file : text open append_mode is "report.txt";  -- try write_mode first (will overwrite on each run)
        -- If your simulator supports "append" use: file report_file : text open append_mode is "report.txt";
        variable L : line;
        variable secs   : integer;
        variable hours  : integer;
        variable mins   : integer;
        variable ssecs  : integer;
        variable e1_i, e2_i, e3_i, e4_i, e5_i, e6_i : integer;
    begin
        wait until rising_edge(clk);

        if ld_DATA_sig = '1' then
            -- compute simulation-time based timestamp (seconds since sim start)
            secs := integer(now / 1 sec);
            hours := secs / 3600;
            mins  := (secs rem 3600) / 60;
            ssecs := secs rem 60;

            -- convert E regs to integers
            e1_i := to_integer(unsigned(E1_out_sig));
            e2_i := to_integer(unsigned(E2_out_sig));
            e3_i := to_integer(unsigned(E3_out_sig));
            e4_i := to_integer(unsigned(E4_out_sig));
            e5_i := to_integer(unsigned(E5_out_sig));
            e6_i := to_integer(unsigned(E6_out_sig));

            -- write header timestamp
            write(L, string'("TIME "));
            write(L, integer'image(hours)); write(L, string'(":"));
            write(L, integer'image(mins));  write(L, string'(":"));
            write(L, integer'image(ssecs));
            writeline(report_file, L);

            -- write values E1..E6
            L := null;
            write(L, string'("E1="));
            write(L, integer'image(e1_i));
            write(L, string'(" E2="));
            write(L, integer'image(e2_i));
            write(L, string'(" E3="));
            write(L, integer'image(e3_i));
            write(L, string'(" E4="));
            write(L, integer'image(e4_i));
            write(L, string'(" E5="));
            write(L, integer'image(e5_i));
            write(L, string'(" E6="));
            write(L, integer'image(e6_i));
            writeline(report_file, L);

            -- blank line
            L := null;
            writeline(report_file, L);
        end if;

    end process;

end architecture rtl;
