with HAL.SPI; use HAL.SPI;
with HAL.GPIO; use HAL.GPIO;

package mpu6000_spi is

   type Six_Axis_Accelerometer
     (Port        : not null Any_SPI_Port;
      Chip_Select : not null Any_GPIO_Point) is limited private;

   type Acc_Data is
      record
         Xacc, Yacc, Zacc : Short_Integer;
         Xang, Yang, Zang : Short_Integer;
      end record;

   procedure Configure (this : in out Six_Axis_Accelerometer);

   function Read (this : in out Six_Axis_Accelerometer) return Acc_Data;

private
   type Six_Axis_Accelerometer
     (Port        : not null Any_SPI_Port;
      Chip_Select : not null Any_GPIO_Point) is limited
   record
      Device_Configured : Boolean := False;
   end record;

end mpu6000_spi;
