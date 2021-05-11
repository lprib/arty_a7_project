library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package testbench_utils is
    procedure do_clk(signal clk: out std_logic);
end package testbench_utils;

package body testbench_utils is
    procedure do_clk(signal clk: out std_logic) is
    begin
        clk <= '0';
        wait for 10 ns;
        clk <= '1';
        wait for 10 ns;
    end procedure do_clk;
end package body testbench_utils;