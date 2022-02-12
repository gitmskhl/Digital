library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

entity test is end;

architecture rtl of test is
component divisor
generic (N : integer := 8);
port
(
    rst, clk : in std_logic;                            --- rst - сброс, clk - тактовый импульс
    inp_valid : in std_logic;                           -- маркер новых данных
    inp_a, inp_b : in std_logic_vector(N - 1 downto 0); --- новые данные - N-битовые числа без знака a и b
    outp_valid : out std_logic;                         --- маркер готовности результата вычислений
    outp_result : out std_logic_vector(N - 1 downto 0)  --- результат - N - битовое число без знака a // b
);
end component;

signal rst, clk : std_logic;                            --- rst - сброс, clk - тактовый импульс
signal inp_valid : std_logic;                           -- маркер новых данных
signal inp_a, inp_b : std_logic_vector(3 downto 0);     --- новые данные - N-битовые числа без знака a и b
signal outp_valid : std_logic;                          --- маркер готовности результата вычислений
signal outp_result : std_logic_vector(3 downto 0);
signal a_test, b_test : integer range 0 to 15;

begin
    DUT : divisor generic map (4) port map(rst => rst, clk => clk, inp_valid => inp_valid, inp_a => inp_a, inp_b => inp_b, outp_valid => outp_valid, outp_result => outp_result);

process is begin
    clk <= '0';
    wait for 5 ns;
    clk <= '1';
    wait for 5 ns;
end process;

process is
variable var_a, var_b : integer range 0 to 15;
begin
    for var_a in 1 to 15 loop
        for var_b in 1 to 15 loop
            inp_a <= std_logic_vector(conv_unsigned(var_a, 4));
            inp_b <= std_logic_vector(conv_unsigned(var_b, 4));
            inp_valid <= '1';
            wait for 15 ns;
            inp_valid <= '0';
            wait until outp_valid = '1';
            assert outp_result = std_logic_vector(conv_unsigned(var_a / var_b, 4)) report "failed";
        end loop;
    end loop;
end process;

end rtl;