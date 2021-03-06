package ADL_Config is
   Vendor                         : constant String  := "STMicro";           -- From board definition
   Max_Mount_Points               : constant         := 2;                   -- From default value
   Max_Mount_Name_Length          : constant         := 128;                 -- From default value
   Runtime_Profile                : constant String  := "ravenscar-full";    -- From command line
   Device_Name                    : constant String  := "STM32F405RGTx";     -- From board definition
   Device_Family                  : constant String  := "STM32F4";           -- From board definition
   Has_Ravenscar_SFP_Runtime      : constant String  := "True";              -- From board definition
   Runtime_Name                   : constant String  := "ravenscar-full-stm32f4"; -- From default value
   Has_Ravenscar_Full_Runtime     : constant String  := "True";              -- From board definition
   CPU_Core                       : constant String  := "ARM Cortex-M4F";    -- From mcu definition
   Board                          : constant String  := "Cc3df4revo";         -- From command line
   Has_ZFP_Runtime                : constant String  := "False";             -- From board definition
   Number_Of_Interrupts           : constant         := 91;                   -- From default value
   High_Speed_External_Clock      : constant         := 8000000;             -- From board definition
   Max_Path_Length                : constant         := 1024;                -- From default value
   Runtime_Name_Suffix            : constant String  := "stm32f4";           -- From board definition
   Architecture                   : constant String  := "ARM";               -- From board definition
   Use_Startup_Gen                : constant Boolean  := False;               -- From command line
end ADL_Config;
