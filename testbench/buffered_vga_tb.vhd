library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.components.all;
use work.testbench_utils.all;

entity buffered_vga_tb is end;

architecture test of buffered_vga_tb is
    signal clk: std_logic;
begin
    uut: buffered_vga port map (
        clk, '0', 0, "00000000"
    );

    testmain: process is
    begin
        for i in 1 to 10000 loop
            do_clk(clk);
            report integer'image(i);
        end loop;
        wait;
    end process testmain;
end architecture test;