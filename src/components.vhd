library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package components is
    attribute dont_touch: string;

    component clock_div is
        generic (
            divisor: natural
        );
        port (
            clk: in std_logic;
            div: out std_logic
        );
    end component;

    component pwm is
        port (
            clk: in std_logic;
            duty: in unsigned(10 downto 0);
            pwm_out: out std_logic
        );
    end component;

    component vga is
        port (
            clk: in std_logic;
            hsync_out: out std_logic;
            vsync_out: out std_logic;
            r_out: out std_logic_vector(3 downto 0);
            g_out: out std_logic_vector(3 downto 0);
            b_out: out std_logic_vector(3 downto 0)
        );
    end component;
    
    component ram is
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
    end component;

    component buffered_vga is
        port (
            clk: in std_logic;
            write_enable: in std_logic;
            write_addr: in natural range 0 to (80 * 60 - 1);
            data: in std_logic_vector(7 downto 0);
            frame_flip_strobe: out std_logic;
            h_sync: out std_logic;
            v_sync: out std_logic;
            screen_bit: out std_logic
        );
    end component;
    attribute dont_touch of buffered_vga: component is "yes";

    component pll is
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
    end component;
    attribute dont_touch of pll: component is "yes";

end package components;