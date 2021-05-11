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

    signal fast_clk: std_logic;
    signal vga_screen_bit: std_logic;
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

    VGA_R <= "1111" when vga_screen_bit = '1' else "0000";
    VGA_G <= "1111" when vga_screen_bit = '1' else "0000";
    VGA_B <= "1111" when vga_screen_bit = '1' else "0000";

    myvga: buffered_vga port map (
        clk => fast_clk,
        write_enable => '0',
        write_addr => 0,
        data => "00000000",
        h_sync => VGA_HS_O,
        v_sync => VGA_VS_O,
        screen_bit => vga_screen_bit
    );


    led0_b <= b;
    led0_g <= g;
    led0_r <= r;

    dr(9 downto 0) <= dutyr;
    dg(9 downto 0) <= dutyg;
    db(9 downto 0) <= dutyb;

    -- v: vga port map (
        -- clk => CLK100MHZ,
        -- hsync_out => VGA_HS_O,
        -- vsync_out => VGA_VS_O,
        -- r_out => VGA_R,
        -- g_out => VGA_G,
        -- b_out => VGA_B
    -- );


    dd: clock_div
    generic map (
        divisor => 180000
    )
    port map (
        clk => fast_clk,
        div => change_pwm
    );

    pp: pwm port map (
        clk => fast_clk,
        duty => dr,
        pwm_out => r
    );
    pp1: pwm port map (
        clk => fast_clk,
        duty => dg,
        pwm_out => g
    );
    pp2: pwm port map (
        clk => fast_clk,
        duty => db,
        pwm_out => b
    );

    mypll: pll
    generic map (
        div_amount => 5,
        mult_amount => 9
    )
    port map (
        clk_in => CLK100MHZ,
        clk_out => fast_clk
    );

    do_pwm: process(fast_clk)
    begin
        if rising_edge(fast_clk) then
            if prev_change_pwm = '0' and change_pwm = '1' then
                dutyr <= dutyr + 1;
                dutyg <= dutyg + 1;
                dutyb <= dutyb + 1;
            end if;
            prev_change_pwm <= change_pwm;
        end if;
    end process do_pwm;

end Behavioral;
