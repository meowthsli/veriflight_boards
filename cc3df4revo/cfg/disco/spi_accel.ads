with Config; use Config;
with LIS3DSH.SPI; use LIS3DSH.SPI;

package spi_accel is

   procedure init;

   type accel_data is
      record
         X, Y, Z : Short_Integer;
      end record;

   function read return accel_data;

private

   gyro : Three_Axis_Accelerometer_SPI
     (Port => SPI_Accel_Port'Access,
      Chip_Select => CS_ACCEL'Access);

end spi_accel;
