library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.components.all;

entity main is
    port (
        CLK100MHZ: in std_logic;
        led0_r: out std_logic;
        led0_g: out std_logic;
        led0_b: out std_logic;
        VGA_R: out std_logic_vector(3 downto 0);
        VGA_G: out std_logic_vector(3 downto 0);
        VGA_B: out std_logic_vector(3 downto 0);
        VGA_HS_O: out std_logic;
        VGA_VS_O: out std_logic
    );
end main;

architecture Behavioral of main is
    signal dutyr: unsigned(9 downto 0) := to_unsigned(0, 10);
    signal dutyg: unsigned(9 downto 0) := to_unsigned(350, 10);
    signal dutyb: unsigned(9 downto 0) := to_unsigned(700, 10);
    signal dr: unsigned(10 downto 0) := to_unsigned(0, 11);
    signal dg: unsigned(10 downto 0) := to_unsigned(0, 11);
    signal db: unsigned(10 downto 0) := to_unsigned(0, 11);
    signal change_pwm: std_logic;
    signal prev_change_pwm: std_logic;
    signal r: std_logic;
    signal g: std_logic;
    signal b: std_logic;
begin
    myram: ram
    generic map (
        ITEM_WIDTH => 32,
        SIZE => 128
    )
    port map (
        CLK100MHZ,
        '0',
        0,
        0,
        (others => '0')
    );

    led0_b <= b;
    led0_g <= g;
    led0_r <= r;

    dr(9 downto 0) <= dutyr;
    dg(9 downto 0) <= dutyg;
    db(9 downto 0) <= dutyb;

    v: vga port map (
        clk => CLK100MHZ,
        hsync_out => VGA_HS_O,
        vsync_out => VGA_VS_O,
        r_out => VGA_R,
        g_out => VGA_G,
        b_out => VGA_B
    );


    dd: clock_div
    generic map (
        divisor => 180000
    )
    port map (
        clk => CLK100MHZ,
        div => change_pwm
    );

    pp: pwm port map (
        clk => CLK100MHZ,
        duty => dr,
        pwm_out => r
    );
    pp1: pwm port map (
        clk => CLK100MHZ,
        duty => dg,
        pwm_out => g
    );
    pp2: pwm port map (
        clk => CLK100MHZ,
        duty => db,
        pwm_out => b
    );

    do_pwm: process(CLK100MHZ)
    begin
        if rising_edge(CLK100MHZ) then
            if prev_change_pwm = '0' and change_pwm = '1' then
                dutyr <= dutyr + 1;
                dutyg <= dutyg + 1;
                dutyb <= dutyb + 1;
            end if;
            prev_change_pwm <= change_pwm;
        end if;
    end process do_pwm;

end Behavioral;
