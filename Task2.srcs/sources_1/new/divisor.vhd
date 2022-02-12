library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;


entity divisor is
generic (N : integer := 8);
port
(
    rst, clk : in std_logic;                            --- rst - сброс, clk - тактовый импульс
    inp_valid : in std_logic;                           -- маркер новых данных
    inp_a, inp_b : in std_logic_vector(N - 1 downto 0); --- новые данные - N-битовые числа без знака a и b
    outp_valid : out std_logic;                         --- маркер готовности результата вычислений
    outp_result : out std_logic_vector(N - 1 downto 0)  --- результат - N - битовое число без знака a // b
);
end divisor;

architecture Behavioral of divisor is
signal a0, b0, D0 : std_logic_vector(N - 1 downto 0);
signal sw0 : std_logic;

signal a1, b1, D1 : std_logic_vector(N - 1 downto 0);
signal sw1 : std_logic;
signal outp_valid1 : std_logic;

begin

---- Block 0
process (clk) is begin
    if rising_edge(clk) then
        if rst = '1' then
            outp_valid <= '0';
            outp_result <= (others => '0');             ---- можно удалить
            
            a0 <= (others => '0');
            b0 <= (others => '0');
            D0 <= (others => '0');
            sw0 <= '0';
        elsif inp_valid = '1' then
            outp_valid <= '0';
            outp_result <= (others => '0');             ---- можно удалить
            
            a0 <= inp_a;
            b0 <= inp_b;
            D0 <= (others => '0');
            sw0 <= '0';
        else
            outp_valid <= outp_valid1;
            outp_result <= D1;
            
            a0 <= a1;
            b0 <= b1;
            D0 <= D1;
            sw0 <= not sw1;
        end if;
    end if;
end process;

----- Block 1
process (a0, b0, D0, sw0) is 
variable subtraction : unsigned(N downto 0);
variable s1, s2 : unsigned(N downto 0);
begin
    if sw0 = '0' then
          s1 := unsigned('0' & a0(N - 1 downto 0));
          s2 := unsigned('0' & b0(N - 1 downto 0));
    else
        s1 := unsigned('0' & D0(N - 1 downto 0));
        s2 := unsigned(conv_std_logic_vector(-1, N + 1));
    end if;
   subtraction := s1 - s2;
   if sw0 = '0' then
        D1 <= D0;
        if subtraction(N) = '1' then            --- проверка на то, что a0 < b0
            outp_valid1 <= '1';
            a1 <= a0;
        else
            a1 <= std_logic_vector(subtraction(N - 1 downto 0));
            outp_valid1 <= '0';
        end if;
   else
        if outp_valid1 = '0' then
            D1 <= std_logic_vector(subtraction(N - 1 downto 0));
        else
            D1 <= D0;
        end if;
        a1 <= a0;
   end if;
   
    b1 <= b0;
    sw1 <= sw0;
end process;

end Behavioral;
