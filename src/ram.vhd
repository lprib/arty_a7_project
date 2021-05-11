library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ram is
    generic (
        ITEM_WIDTH: natural;
        SIZE: natural
    );
    port (
        clk: in std_logic;
        write_enable: in std_logic;
        write_addr: in natural range 0 to SIZE - 1;
        read_addr: in natural range 0 to SIZE - 1;
        in_data: in std_logic_vector(ITEM_WIDTH - 1 downto 0);
        out_data: out std_logic_vector(ITEM_WIDTH - 1 downto 0)
    );
end entity ram;

architecture behav of ram is
    type ram_t is array(SIZE - 1 downto 0) of std_logic_vector(ITEM_WIDTH - 1 downto 0);
    signal ram_array: ram_t := (others => std_logic_vector(to_unsigned(2#10101110#, ITEM_WIDTH)));
begin
    main: process(clk)
    begin
        if rising_edge(clk) then
            if write_enable = '1' then
                ram_array(write_addr) <= in_data;
            end if;
            out_data <= ram_array(read_addr);
        end if;
    end process main;
end architecture behav;
