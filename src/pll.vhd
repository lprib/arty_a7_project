library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.components.all;

entity pll is
    generic (
        div_amount: natural range 1 to 128;
        mult_amount: natural range 2 to 64;
        -- default: 100MHz
        clk_in_period_ns: real := 10.0
    );
    port (
        clk_in: in std_logic;
        clk_out: out std_logic
    );
end entity pll;
