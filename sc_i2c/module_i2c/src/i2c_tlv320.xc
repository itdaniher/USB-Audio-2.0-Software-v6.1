#include "i2c.h"
#include "i2c_tlv320.h"

#define CTL_SCLK_PERIOD_LOW_TICKS      (1000)
#define CTL_SCLK_PERIOD_HIGH_TICKS     (1000)

// Valid register address.
#define LIVCTL_REG                     (0x00)
#define RIVCTL_REG                     (0x01)
#define LHPVCTL_REG                    (0x02)
#define RHPVCTL_REG                    (0x03)
#define AAPCTL_REG                     (0x04)
#define DAPCTL_REG                     (0x05)
#define PDCTL_REG                      (0x06)
#define DAIF_REG                       (0x07)
#define SRC_REG                        (0x08)
#define DIA_REG                        (0x09)
#define RESET_REG                      (0x0F)

int i2c_tlv320_tx(struct r_i2c &r, int addr, int regn, int data)
{
   int Result;
   timer gt;
   unsigned time;
   int Temp, CtlAdrsData, i;
   // three device ACK
   int DeviceACK[3]; 
   
   // sanity checking
   // only 9bits of data.
   if ((data & 0xFFFFFE00) != 0)
   {
      return(0);
   }
   // only valid address.
   switch (regn)
   {
      case LIVCTL_REG: case RIVCTL_REG: case LHPVCTL_REG: case RHPVCTL_REG:
      case AAPCTL_REG: case DAPCTL_REG: case PDCTL_REG: case DAIF_REG:
      case SRC_REG: case DIA_REG: case RESET_REG:
         break;
      default:
         return(0);      
         break;
   }   
   // initial values.
   r.scl <: 1;
   r.sda  <: 1;
   sync(r.sda);
   gt :> time;
   time += CTL_SCLK_PERIOD_HIGH_TICKS + CTL_SCLK_PERIOD_LOW_TICKS;
   gt when timerafter(time) :> time;
   // start bit on SDI
   r.scl <: 1;
   r.sda  <: 0;
   gt :> time;
   time += CTL_SCLK_PERIOD_HIGH_TICKS;
   gt when timerafter(time) :> time;
   r.scl <: 0;   
   // shift 7bits of address and 1bit R/W (fixed to write).
   // WARNING: Assume MSB first.
   for (i = 0; i < 8; i += 1)
   {
      Temp = (addr >> (7 - i)) & 0x1;
      r.sda <: Temp;
      gt :> time;
      time += CTL_SCLK_PERIOD_HIGH_TICKS;
      gt when timerafter(time) :> time;
      r.scl <: 1;
      gt :> time;
      time += CTL_SCLK_PERIOD_HIGH_TICKS;
      gt when timerafter(time) :> time;
      r.scl <: 0;      
   }
   // turn the data to input
   r.sda :> Temp;
   gt :> time;
   time += CTL_SCLK_PERIOD_HIGH_TICKS;
   gt when timerafter(time) :> time;
   r.scl <: 1;
   // sample first ACK.
   r.sda :> DeviceACK[0];
   gt :> time;
   time += CTL_SCLK_PERIOD_HIGH_TICKS;
   gt when timerafter(time) :> time;
   r.scl <: 0;      
   // this build funny TI data format
   CtlAdrsData = ((regn & 0x7F) << 9) | (data & 0x1FF);
   // shift first 8 bits.
   for (i = 0; i < 8; i += 1)
   {
      Temp = (CtlAdrsData >> (15 - i)) & 0x1;
      r.sda <: Temp;
      gt :> time;
      time += CTL_SCLK_PERIOD_HIGH_TICKS;
      gt when timerafter(time) :> time;
      r.scl <: 1;
      gt :> time;
      time += CTL_SCLK_PERIOD_HIGH_TICKS;
      gt when timerafter(time) :> time;
      r.scl <: 0;      
   }   
   // turn the data to input
   r.sda :> Temp;
   gt :> time;
   time += CTL_SCLK_PERIOD_HIGH_TICKS;
   gt when timerafter(time) :> time;
   r.scl <: 1;
   // sample second ACK.
   r.sda :> DeviceACK[1];
   gt :> time;
   time += CTL_SCLK_PERIOD_HIGH_TICKS;
   gt when timerafter(time) :> time;
   r.scl <: 0;      
   


   // shift second 8 bits.
   for (i = 0; i < 8; i += 1)
   {
      Temp = (CtlAdrsData >> (7 - i)) & 0x1;
      r.sda <: Temp;
      gt :> time;
      time += CTL_SCLK_PERIOD_HIGH_TICKS;
      gt when timerafter(time) :> time;
      r.scl <: 1;
      gt :> time;
      time += CTL_SCLK_PERIOD_HIGH_TICKS;
      gt when timerafter(time) :> time;
      r.scl <: 0;      
   }    
   // turn the data to input
   r.sda :> Temp;
   gt :> time;
   time += CTL_SCLK_PERIOD_HIGH_TICKS;
   gt when timerafter(time) :> time;
   r.scl <: 1;
   // sample second ACK.
   r.sda :> DeviceACK[2];
   gt :> time;
   time += CTL_SCLK_PERIOD_HIGH_TICKS;
   gt when timerafter(time) :> time;
   r.scl <: 0;  
   gt :> time;
   time += CTL_SCLK_PERIOD_HIGH_TICKS;
   gt when timerafter(time) :> time;
   r.scl <: 1;
   // put the data to a good value for next round.
   r.sda  <: 1;
   // validate all items are ACK properly.
   Result = 1;
   for (i = 0; i < 3; i += 1)
   {
      if (DeviceACK[i] != 0)
      {
         Result = 0;
      }
   }   
   
   return(Result);        
}
