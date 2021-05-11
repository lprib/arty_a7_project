library ieee;
use ieee.std_logic_1164.all;

entity pulse_clock_div is
    generic (
        divisor: natural
    );
    port (
        clk: in std_logic;
        div: out std_logic
    );
end pulse_clock_div;

architecture Behavioral of pulse_clock_div is
    subtype cnt_t is natural range 0 to divisor - 1;
    signal cnt: cnt_t := 0;
begin
    div <= '1' when cnt = 0 else '0';

    process(clk) is begin
        if rising_edge(clk) then
            if cnt = cnt_t'high then
                cnt <= 0;
            else
                cnt <= cnt + 1;
            end if;
        end if;
    end process;
end Behavioral;
