--  This package will provide declarations for devices
--  and configuration routines on the Flip32cc3df4revo board
with System;
with STM32; use STM32;
with STM32.Device; use STM32.Device;
with STM32.GPIO; use STM32.GPIO;
--  with STM32.USARTs; use STM32.USARTs;
--  with STM32.Timers; use STM32.Timers;
--  with STM32.PWM; use STM32.PWM;
with Interfaces; use Interfaces;
with Interfaces.C;
with Ada.Strings.Bounded;

--  with Ravenscar_Time;
package cc3df4revo.Board is
   package ASB32 is new Ada.Strings.Bounded.Generic_Bounded_Length (Max => 32);
   --
   --  Devices
   --
   --  mpu
   --  usart (for s.bus)
   --  type SBUS_RXTX (USART_Ptr : not null access USART) is limited null record;

   --  SBUS1 : SBUS_RXTX (USART_Ptr => USART_1'Access);
   --  SBUS1 : USART renames USART_1;
   --  SBUS_TX        : GPIO_Point renames PA9;
   --  SBUS_RX        : GPIO_Point renames PA10;
   --  SBUS_AF  : GPIO_Alternate_Function renames GPIO_AF_USART1_7;
   --  M1 : PWM_Modulator;

   --
   --  Board initialization
   --
   procedure Initialize;

   --  Doing receive
   procedure usb_receive (message : out ASB32.Bounded_String);

   --  Doing transmission
   procedure usb_transmit (message : String);

private

   function ada_usbapi_rx (buffer : out Interfaces.C.char_array) return Interfaces.C.unsigned_short
     with
       Import        => True,
       Convention    => C,
       External_Name => "usbapi_rx";

   procedure ada_usbapi_tx (buffer : System.Address; len : Interfaces.C.unsigned_short)
     with
       Import        => True,
       Convention    => C,
       External_Name => "usbapi_tx";

   --
   --  USB util
   --
   function ada_usbapi_setup return Interfaces.C.int
     with
       Import        => True,
       Convention    => C,
       External_Name => "usbapi_setup";

   --
   --  Motor pins
   --
   --  MOTOR_123_Timer : Timer renames Timer_2;
   --  MOTOR_4_Timer   : Timer renames Timer_4;
   --  MOTOR_1         : GPIO_Point renames PB0;
   --  MOTOR_1_AF      : GPIO_Alternate_Function renames GPIO_AF_TIM2_1;
   --  MOTOR_1_Channel : Timer_Channel renames Channel_2;
   --  MOTOR_2         : GPIO_Point renames PB1;
   --  MOTOR_2_AF      : GPIO_Alternate_Function renames GPIO_AF_TIM2_1;
   --  MOTOR_2_Channel : Timer_Channel renames Channel_4;
   --  MOTOR_3         : GPIO_Point renames PA3;
   --  MOTOR_3_AF      : GPIO_Alternate_Function renames GPIO_AF_TIM2_1;
   --  MOTOR_3_Channel : Timer_Channel renames Channel_1;
   --  MOTOR_4         : GPIO_Point renames PA2;
   --  MOTOR_4_AF      : GPIO_Alternate_Function renames GPIO_AF_TIM4_2;
   --  MOTOR_4_Channel : Timer_Channel renames Channel_4;

end cc3df4revo.Board;
