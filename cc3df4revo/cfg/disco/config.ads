with STM32.GPIO; use STM32.GPIO;
with STM32.Device; use STM32.Device;
with STM32.SPI; use STM32.SPI;

package Config is
   SIGNAL_LED : GPIO_Point renames PD13; --  red led

   SPI_Accel_Port : SPI_Port renames STM32.Device.SPI_1;
   SCLK : GPIO_Point renames STM32.Device.PA5;
   MISO : GPIO_Point renames STM32.Device.PA6;
   MOSI : GPIO_Point renames STM32.Device.PA7;
   CS_ACCEL : GPIO_Point renames STM32.Device.PE3;

   Disco : Boolean := True;
end Config;
