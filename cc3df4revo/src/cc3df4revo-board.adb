package body cc3df4revo.Board is
   procedure Initialize_SPI is
   begin
      null;
   end Initialize_SPI;

   procedure Initialize_SBUS is
   begin
      null;
   end Initialize_SBUS;

   procedure Send (sbus : in out SBUS_RXTX) is
   begin
      null;
   end Send;
begin
   Send (SBUS1);
   SBUS1.Send;
end cc3df4revo.Board;
