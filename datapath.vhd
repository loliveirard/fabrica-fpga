library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- Datapath que usa apenas ld_X, clr_X e mux_X para atualizar registradores.
-- Conveção:
--  - Regs nao-En (B,Q,P,L,C,V):  mux = '0' => load external (from switches)
--                              mux = '1' => load (current - 1), saturate a 0
--  - Regs En (E1..E6):           mux = '0' => load (current + 1), saturate a 15
--                              mux = '1' => load (current - 1), saturate a 0
--  - ld_X = '1' habilita carregamento (com a seleção do mux)
--  - clr_X = '1' força zero independente do ld_X
--  - reset_n ativo em '0' zera tudo.

entity datapath is
    port(
        clk      : in  std_logic;
        reset_n  : in  std_logic;               -- ativo em '0'

        -- switches (7 bits) - use para carregar valores externos
        switches_in : in std_logic_vector(6 downto 0);

        ----------------------------------------------------------------
        -- controles (loads / clears) - todos os registradores possuem apenas ld e clr
        ----------------------------------------------------------------
        -- não-En
        ld_B  : in std_logic;  clr_B  : in std_logic;  mux_B  : in std_logic;
        ld_Q  : in std_logic;  clr_Q  : in std_logic;  mux_Q  : in std_logic;
        ld_P  : in std_logic;  clr_P  : in std_logic;  mux_P  : in std_logic;
        ld_L  : in std_logic;  clr_L  : in std_logic;  mux_L  : in std_logic;
        ld_C  : in std_logic;  clr_C  : in std_logic;  mux_C  : in std_logic;
        ld_V  : in std_logic;  clr_V  : in std_logic;  mux_V  : in std_logic;

        -- En (E counters)
        ld_E1 : in std_logic;  clr_E1 : in std_logic;  mux_E1 : in std_logic;
        ld_E2 : in std_logic;  clr_E2 : in std_logic;  mux_E2 : in std_logic;
        ld_E3 : in std_logic;  clr_E3 : in std_logic;  mux_E3 : in std_logic;
        ld_E4 : in std_logic;  clr_E4 : in std_logic;  mux_E4 : in std_logic;
        ld_E5 : in std_logic;  clr_E5 : in std_logic;  mux_E5 : in std_logic;
        ld_E6 : in std_logic;  clr_E6 : in std_logic;  mux_E6 : in std_logic;

        ----------------------------------------------------------------
        -- saídas para a controladora / debug
        ----------------------------------------------------------------
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

        -- flags >0
        B_gt_0 : out std_logic;
        Q_gt_0 : out std_logic;
        P_gt_0 : out std_logic;
        L_gt_0 : out std_logic;
        C_gt_0 : out std_logic;
        V_gt_0 : out std_logic
    );
end datapath;

architecture rtl of datapath is

    -- Registradores internos (unsigned para operações aritméticas simples)
    signal B_reg : unsigned(3 downto 0) := (others => '0');
    signal Q_reg : unsigned(3 downto 0) := (others => '0');
    signal P_reg : unsigned(5 downto 0) := (others => '0');
    signal L_reg : unsigned(5 downto 0) := (others => '0');
    signal C_reg : unsigned(3 downto 0) := (others => '0');
    signal V_reg : unsigned(6 downto 0) := (others => '0');

    signal E1, E2, E3, E4, E5, E6 : unsigned(3 downto 0) := (others => '0');

    -- slices de switches para cada registrador (mapa razoável)
    signal sw_B : unsigned(3 downto 0);
    signal sw_Q : unsigned(3 downto 0);
    signal sw_C : unsigned(3 downto 0);
    signal sw_P : unsigned(5 downto 0);
    signal sw_L : unsigned(5 downto 0);
    signal sw_V : unsigned(6 downto 0);

begin

    -- mapear fatias de entrada (ajuste se quiser outro mapeamento)
    sw_V <= unsigned(switches_in);                       -- 7 bits -> V
    sw_P <= unsigned('0' & switches_in(4 downto 0));     -- 6 bits -> P, L (pad)
    sw_L <= unsigned('0' & switches_in(4 downto 0));
    sw_B <= unsigned(switches_in(3 downto 0));           -- 4 bits -> B, Q, C
    sw_Q <= unsigned(switches_in(3 downto 0));
    sw_C <= unsigned(switches_in(3 downto 0));

    ----------------------------------------------------------------
    -- Processo principal: atualiza registradores no clk
    ----------------------------------------------------------------
    process(clk)
    begin
        if rising_edge(clk) then
            if reset_n = '0' then
                -- reset sincrono/assíncrono (ativo em 0)
                B_reg <= (others => '0');
                Q_reg <= (others => '0');
                P_reg <= (others => '0');
                L_reg <= (others => '0');
                C_reg <= (others => '0');
                V_reg <= (others => '0');

                E1 <= (others => '0');
                E2 <= (others => '0');
                E3 <= (others => '0');
                E4 <= (others => '0');
                E5 <= (others => '0');
                E6 <= (others => '0');

            else
                -- -------------------
                -- B register (4 bits)
                -- -------------------
                if clr_B = '1' then
                    B_reg <= (others => '0');
                elsif ld_B = '1' then
                    if mux_B = '0' then
                        -- carregar valor externo (fatia)
                        B_reg <= sw_B;
                    else
                        -- carregar (current - 1) saturado em 0
                        if B_reg > 0 then
                            B_reg <= B_reg - 1;
                        else
                            B_reg <= (others => '0');
                        end if;
                    end if;
                end if;

                -- -------------------
                -- Q register (4 bits)
                -- -------------------
                if clr_Q = '1' then
                    Q_reg <= (others => '0');
                elsif ld_Q = '1' then
                    if mux_Q = '0' then
                        Q_reg <= sw_Q;
                    else
                        if Q_reg > 0 then
                            Q_reg <= Q_reg - 1;
                        else
                            Q_reg <= (others => '0');
                        end if;
                    end if;
                end if;

                -- -------------------
                -- P register (6 bits)
                -- -------------------
                if clr_P = '1' then
                    P_reg <= (others => '0');
                elsif ld_P = '1' then
                    if mux_P = '0' then
                        P_reg <= sw_P;
                    else
                        -- current - 1 saturado
                        if P_reg > 0 then
                            P_reg <= P_reg - 1;
                        else
                            P_reg <= (others => '0');
                        end if;
                    end if;
                end if;

                -- -------------------
                -- L register (6 bits)
                -- -------------------
                if clr_L = '1' then
                    L_reg <= (others => '0');
                elsif ld_L = '1' then
                    if mux_L = '0' then
                        L_reg <= sw_L;
                    else
                        if L_reg > 0 then
                            L_reg <= L_reg - 1;
                        else
                            L_reg <= (others => '0');
                        end if;
                    end if;
                end if;

                -- -------------------
                -- C register (4 bits)
                -- -------------------
                if clr_C = '1' then
                    C_reg <= (others => '0');
                elsif ld_C = '1' then
                    if mux_C = '0' then
                        C_reg <= sw_C;
                    else
                        if C_reg > 0 then
                            C_reg <= C_reg - 1;
                        else
                            C_reg <= (others => '0');
                        end if;
                    end if;
                end if;

                -- -------------------
                -- V register (7 bits)
                -- -------------------
                if clr_V = '1' then
                    V_reg <= (others => '0');
                elsif ld_V = '1' then
                    if mux_V = '0' then
                        V_reg <= sw_V;
                    else
                        if V_reg > 0 then
                            V_reg <= V_reg - 1;
                        else
                            V_reg <= (others => '0');
                        end if;
                    end if;
                end if;

                -- -------------------
                -- E counters (4 bits) : E1..E6
                -- mux_E = '0' -> incrementa (saturando a 15)
                -- mux_E = '1' -> decrementa (saturando em 0)
                -- -------------------
                if clr_E1 = '1' then
                    E1 <= (others => '0');
                elsif ld_E1 = '1' then
                    if mux_E1 = '0' then
                        if E1 /= "1111" then
                            E1 <= E1 + 1;
                        else
                            E1 <= E1;
                        end if;
                    else
                        if E1 > 0 then
                            E1 <= E1 - 1;
                        else
                            E1 <= (others => '0');
                        end if;
                    end if;
                end if;

                if clr_E2 = '1' then
                    E2 <= (others => '0');
                elsif ld_E2 = '1' then
                    if mux_E2 = '0' then
                        if E2 /= "1111" then
                            E2 <= E2 + 1;
                        else
                            E2 <= E2;
                        end if;
                    else
                        if E2 > 0 then
                            E2 <= E2 - 1;
                        else
                            E2 <= (others => '0');
                        end if;
                    end if;
                end if;

                if clr_E3 = '1' then
                    E3 <= (others => '0');
                elsif ld_E3 = '1' then
                    if mux_E3 = '0' then
                        if E3 /= "1111" then
                            E3 <= E3 + 1;
                        else
                            E3 <= E3;
                        end if;
                    else
                        if E3 > 0 then
                            E3 <= E3 - 1;
                        else
                            E3 <= (others => '0');
                        end if;
                    end if;
                end if;

                if clr_E4 = '1' then
                    E4 <= (others => '0');
                elsif ld_E4 = '1' then
                    if mux_E4 = '0' then
                        if E4 /= "1111" then
                            E4 <= E4 + 1;
                        else
                            E4 <= E4;
                        end if;
                    else
                        if E4 > 0 then
                            E4 <= E4 - 1;
                        else
                            E4 <= (others => '0');
                        end if;
                    end if;
                end if;

                if clr_E5 = '1' then
                    E5 <= (others => '0');
                elsif ld_E5 = '1' then
                    if mux_E5 = '0' then
                        if E5 /= "1111" then
                            E5 <= E5 + 1;
                        else
                            E5 <= E5;
                        end if;
                    else
                        if E5 > 0 then
                            E5 <= E5 - 1;
                        else
                            E5 <= (others => '0');
                        end if;
                    end if;
                end if;

                if clr_E6 = '1' then
                    E6 <= (others => '0');
                elsif ld_E6 = '1' then
                    if mux_E6 = '0' then
                        if E6 /= "1111" then
                            E6 <= E6 + 1;
                        else
                            E6 <= E6;
                        end if;
                    else
                        if E6 > 0 then
                            E6 <= E6 - 1;
                        else
                            E6 <= (others => '0');
                        end if;
                    end if;
                end if;

            end if;
        end if;
    end process;

    ----------------------------------------------------------------
    -- Saídas e flags
    ----------------------------------------------------------------
    B_reg_out <= std_logic_vector(B_reg);
    Q_reg_out <= std_logic_vector(Q_reg);
    P_reg_out <= std_logic_vector(P_reg);
    L_reg_out <= std_logic_vector(L_reg);
    C_reg_out <= std_logic_vector(C_reg);
    V_reg_out <= std_logic_vector(V_reg);

    E1_out <= std_logic_vector(E1);
    E2_out <= std_logic_vector(E2);
    E3_out <= std_logic_vector(E3);
    E4_out <= std_logic_vector(E4);
    E5_out <= std_logic_vector(E5);
    E6_out <= std_logic_vector(E6);

    B_gt_0 <= '1' when B_reg > 0 else '0';
    Q_gt_0 <= '1' when Q_reg > 0 else '0';
    P_gt_0 <= '1' when P_reg > 0 else '0';
    L_gt_0 <= '1' when L_reg > 0 else '0';
    C_gt_0 <= '1' when C_reg > 0 else '0';
    V_gt_0 <= '1' when V_reg > 0 else '0';

end architecture rtl;
