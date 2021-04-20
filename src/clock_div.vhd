library ieee;
use ieee.std_logic_1164.all;

entity clock_div is
    generic (
        divisor: natural
    );
    port (
        clk: in std_logic;
        div: out std_logic
    );
end clock_div;

architecture Behavioral of clock_div is
    subtype cnt_t is natural range 0 to (divisor/2)-1;
    signal cnt: cnt_t := 0;
    signal div_internal: std_logic := '0';
begin
    div <= div_internal;
    process(clk) is begin
        if rising_edge(clk) then
            if cnt = cnt_t'high then
                cnt <= 0;
                div_internal <= not div_internal;
            else
                cnt <= cnt + 1;
            end if;
        end if;
    end process;

end Behavioral;
