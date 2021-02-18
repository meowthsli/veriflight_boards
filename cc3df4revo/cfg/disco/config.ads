with STM32.GPIO; use STM32.GPIO;
with STM32.Device; use STM32.Device;

package Config is
   SIGNAL_LED : GPIO_Point renames PD5; --  red led
end Config;
