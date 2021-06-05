library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.components.all;

library unisim;
use unisim.vcomponents.all;

architecture artix7 of pll is
    signal feedback: std_logic;
begin
    plle2_base_inst : plle2_base
    generic map (
        bandwidth => "OPTIMIZED",
        clkfbout_mult => mult_amount,
        clkin1_period => clk_in_period_ns,
        clkout0_divide => div_amount,
        clkout0_duty_cycle => 0.5,
        clkout0_phase => 0.0
    )
    port map (
        clkout0 => clk_out,
        clkfbout => feedback,
        clkin1 => clk_in,
        pwrdwn => '0',
        rst => '0',
        clkfbin => feedback
    );
end architecture artix7;
