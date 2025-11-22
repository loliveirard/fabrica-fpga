-----------------------------------------------------------------
-- Somador/Subtrator de W bits
-- Quando SUB = '0' → realiza A + B
-- Quando SUB = '1' → realiza A - B
-----------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.numeric_std;

entity addsub_w is
    generic (
        w : integer := 4  -- tamanho das entradas em bits (padrão 4)
    );
    port (
        A    : in  std_logic_vector(w-1 downto 0);  -- entrada A
        B    : in  std_logic_vector(w-1 downto 0);  -- entrada B
        SUB  : in  std_logic;  -- controle de operação (0 = soma, 1 = subtração)
        S    : out std_logic_vector(w downto 0)   -- resultado
    );
end addsub_w;

architecture behavior of addsub_w is
begin
    process(A, B, SUB)
    begin
        if SUB = '0' then
            -- Realiza a soma de A e B
            S <= ('0' & A) + ('0' & B);
        else
            -- Realiza a subtração de A e B
            S <= ('0' & A) + not('0' & B) + '1';
        end if;
    end process;
end behavior;