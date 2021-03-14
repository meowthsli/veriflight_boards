pragma Ada_2012;
package body sbus_commander is

   ----------
   -- init --
   ----------

   procedure init is
   begin
      null;
   end init;

   -----------------------
   -- get_channels_data --
   -----------------------

   function get_channels_data return sbus_data is
   begin
      return frame.data;
   end get_channels_data;

end sbus_commander;
