library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity controladora is
    port(
        clk      : in  std_logic;
        rst      : in  std_logic;
        btn_edge : in  std_logic;

        -- comparadores do datapath
        Bgt0 : in std_logic;
        Vgt7 : in std_logic;
        Cgt0 : in std_logic;
        Qgt0 : in std_logic;
        Lgt3 : in std_logic;
        Pgt3 : in std_logic;

        -- sinais de controle dos registradores
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
end entity;

architecture fsm_arch of controladora is

    type state_type is (
        INICIO, SALVA_B, SALVA_V, SALVA_C, SALVA_Q, SALVA_L, SALVA_P,
        PROC_0, PROC_B, PROC_V, PROC_C, PROC_Q, PROC_L, PROC_P,
        STORE_DATA
    );

    signal state, next_state : state_type;

begin

    -------------------------------------------------------------------
    -- REGISTRADOR DE ESTADO
    -------------------------------------------------------------------
    process(clk, rst)
    begin
        if rst = '1' then
            state <= INICIO;
        elsif rising_edge(clk) then
            state <= next_state;
        end if;
    end process;


    -------------------------------------------------------------------
    -- LÓGICA DE PRÓXIMO ESTADO
    -------------------------------------------------------------------
    process(state, btn_edge, Bgt0, Vgt7, Cgt0, Qgt0, Lgt3, Pgt3)
    begin
        next_state <= state;

        case state is

            -----------------------------------------------------------
            -- ETAPA DE LEITURA (avança só com btn_edge)
            -----------------------------------------------------------
            when INICIO =>
                if btn_edge = '1' then next_state <= SALVA_B; end if;

            when SALVA_B =>
                if btn_edge = '1' then next_state <= SALVA_V; end if;

            when SALVA_V =>
                if btn_edge = '1' then next_state <= SALVA_C; end if;

            when SALVA_C =>
                if btn_edge = '1' then next_state <= SALVA_Q; end if;

            when SALVA_Q =>
                if btn_edge = '1' then next_state <= SALVA_L; end if;

            when SALVA_L =>
                if btn_edge = '1' then next_state <= SALVA_P; end if;

            when SALVA_P =>
                if btn_edge = '1' then next_state <= PROC_0; end if;


            -----------------------------------------------------------
            -- ETAPA DE PROCESSAMENTO
            -----------------------------------------------------------
				when PROC_0 =>
                if Bgt0 = '1' then
                    next_state <= PROC_B;
                else
                    next_state <= STORE_DATA;
                end if;

            when PROC_B =>
                if Vgt7 = '1' then  -- disponibilidade de 8 válvulas
                    next_state <= PROC_V;
                else
                    next_state <= PROC_0;
                end if;

            when PROC_V =>
                if Cgt0 = '1' then  -- disponibilidade de 1 cabeçote
                    next_state <= PROC_C;
                else
                    next_state <= PROC_0;
                end if;

            when PROC_C =>
                if Qgt0 = '1' then  -- disponibilidade de 1 conjunto de parafusos
                    next_state <= PROC_Q;
                else
                    next_state <= PROC_0;
                end if;

            when PROC_Q =>
                if Lgt3 = '1' then  -- pelo menos 4 lâminas disponíveis
                    next_state <= PROC_L;
                else
                    next_state <= PROC_0;
                end if;

            when PROC_L =>
                if Pgt3 = '1' then  -- pelo menos 4 pinos disponíveis
                    next_state <= PROC_P;
                else
                    next_state <= PROC_0;
                end if;

            when PROC_P =>
                -- sempre retorna ao início do ciclo
                next_state <= PROC_0;

            when STORE_DATA =>
                next_state <= INICIO;

        end case;
    end process;


    -------------------------------------------------------------------
    -- TABELA DE SAÍDAS (Moore)
    -------------------------------------------------------------------
    process(state)
    begin
        -- padrões
        ld_B <= '0'; clr_B <= '0'; mux_B <= '0';
        ld_V <= '0'; clr_V <= '0'; mux_V <= '0';
        ld_C <= '0'; clr_C <= '0'; mux_C <= '0';
        ld_Q <= '0'; clr_Q <= '0'; mux_Q <= '0';
        ld_L <= '0'; clr_L <= '0'; mux_L <= '0';
        ld_P <= '0'; clr_P <= '0'; mux_P <= '0';
        ld_DATA <= '0';

        case state is

            -----------------------------------------------------------
            -- ETAPA DE LEITURA — gravação simples
            -----------------------------------------------------------
            when SALVA_B => ld_B <= '1';
            when SALVA_V => ld_V <= '1';
            when SALVA_C => ld_C <= '1';
            when SALVA_Q => ld_Q <= '1';
            when SALVA_L => ld_L <= '1';
            when SALVA_P => ld_P <= '1';

				-----------------------------------------------------------
				-- PROCESSAMENTO: incremento e decremento via mux
				-----------------------------------------------------------

				-- PROC_B
				when PROC_B =>
					 mux_B <= '1';      -- decrementa
					 ld_B  <= '1';
					 
					 mux_E1 <= '1';
					 ld_E1 <= '1';

				-- PROC_V: incrementa V e decrementa B
				when PROC_V =>
					 mux_V <= '1';      -- decrementa
					 ld_V  <= '1';
					 
					 mux_E1 <= '0';
					 ld_E1 <= '1';
					 
					 mux_E2 <= '1';
					 ld_E2 <= '1';


				-- PROC_C: incrementa C e decrementa V
				when PROC_C =>
					 mux_C <= '1';      
					 ld_C  <= '1';

					 mux_E2 <= '0';
					 ld_E2 <= '1';
					 
					 mux_E3 <= '1';
					 ld_E3 <= '1';

				-- PROC_Q: incrementa Q e decrementa C
				when PROC_Q =>
					 mux_Q <= '1';
					 ld_Q  <= '1';

					 mux_E3 <= '0';
					 ld_E3 <= '1';
					 
					 mux_E4 <= '1';
					 ld_E4 <= '1';

				-- PROC_L: incrementa L e decrementa Q
				when PROC_L =>
					 mux_L <= '1';
					 ld_L  <= '1';

					 mux_E4 <= '0';
					 ld_E4 <= '1';
					 
					 mux_E5 <= '1';
					 ld_E5 <= '1';

				-- PROC_P: incrementa P e decrementa L
				when PROC_P =>
					 mux_P <= '1';
					 ld_P  <= '1';

					 mux_E5 <= '0';
					 ld_E5 <= '1';
					 
					 mux_E6 <= '1';
					 ld_E6 <= '1';

				-----------------------------------------------------------
				when STORE_DATA =>
					 ld_DATA <= '1';

				when others =>
					 null;


        end case;
    end process;

end architecture;
