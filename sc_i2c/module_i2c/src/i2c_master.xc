///////////////////////////////////////////////////////////////////////////////
//
// I2C master

#include <xs1.h>
#include <platform.h>
#include <stdio.h>
#include "i2c.h"

#ifdef __i2c_conf_h_exists__
#include "i2c_conf.h"
#endif

#ifdef I2C_SINGLE_MASTER
#define OUTPUT_HIGH(p)  { p <: 1; }
#define OUTPUT_LOW(p)   { p <: 0; }
#else
#define OUTPUT_HIGH(p)  { int x; p :> x; }
#define OUTPUT_LOW(p)   { p <: 0; }
#endif

/**
 *  \fn      i2c_slave_init
 *  \brief   initialise an I2C 2-wire slave device
 *  \param   i2c_slave  the port control structure
 */
void i2c_master_init(struct r_i2c &i2c_master)
{
	// Set the ports into idle
	i2c_master.scl <: 1;
	i2c_master.sda <: 1;
}

 /**
 * \fn       i2c_master_rx
 * \brief    The function is called whenever required to read from a I2C Slave device.
 *           The data received and the length of the data is stored in i2c_data structure.
 * \param    device address, sub address, data length and data in a structure, sda and scl port in a structure
 * \return   0 if transaction is not scuccesfull
 * 			 1 if transaction is scuccesfull
 */
int i2c_master_rx(int device, int sub_addr, struct i2c_data_info &i2c_data, struct r_i2c &i2c_master)
{
  //   int result;
   int Temp, CtlAdrsData, i,j;
   int deviceAddr;
   int ack;
   int data_rx;
   int sda_high;
   unsigned int scl_high;
   unsigned int clock_mul;

   clock_mul = i2c_data.clock_mul;
   i2c_master.scl :> scl_high;
   i2c_master.sda :> sda_high;
   sync(i2c_master.sda);

   wait_func(2,1,i2c_master.sda,1);

   i2c_master.scl :> scl_high;
   i2c_master.sda  <: 0;  //Generating START Bit

   wait_func(2,1,i2c_master.sda,1);

   i2c_master.scl <: 0;

   for (i = 0; i < 8; ++i) // To Send 7-Bit Device ID and 1-Bit R/W Bit(Fixed to write).
   {
      Temp = (device >> (7 - i)) & 0x1;
      if(Temp ==0) i2c_master.sda <: Temp;
      else i2c_master.sda :> sda_high;

      wait_func(2,clock_mul,i2c_master.scl,0);
      i2c_master.scl :> scl_high;
      i2c_master.scl when pinseq(1) :> void;

      if(Temp){            //Checks the sda for arbitration
    	  i2c_master.sda :> sda_high;
    	  if(!sda_high) {
    		  return(0);
    	  }
      }

      wait_func(2,clock_mul,i2c_master.scl,1);
      i2c_master.scl <: 0;
   }

   i2c_master.sda :> Temp; // Turn the data to input

   wait_func(2,clock_mul,i2c_master.scl,0);
   i2c_master.scl :> scl_high;
   i2c_master.scl when pinseq(1) :> void;

   i2c_master.sda :> ack; // Sample Acknowledge.
   if(ack) return (0);

   wait_func(2,clock_mul,i2c_master.scl,1);
   i2c_master.scl <: 0;

   CtlAdrsData = (sub_addr & 0xFF);

   for (i = 0; i < 8; i += 1) // To Send 8-Bit Sub address.
   {
      Temp = (CtlAdrsData >> (7 - i)) & 0x1;
      if(Temp ==0) i2c_master.sda <: Temp;
      else i2c_master.sda :> sda_high;

      wait_func(2,clock_mul,i2c_master.scl,0);
      i2c_master.scl :> scl_high;
      i2c_master.scl when pinseq(1) :> void;

      //Checks the sda for arbitration
      if(Temp){
    	  i2c_master.sda :> sda_high;
    	  if(!sda_high) return(0);
      }

      wait_func(2,clock_mul,i2c_master.scl,1);
      i2c_master.scl <: 0;
   }

   i2c_master.sda :> Temp;// turn the data to input
   wait_func(2,clock_mul,i2c_master.scl,0);
   i2c_master.scl :> scl_high;
   i2c_master.scl when pinseq(1) :> void;

   i2c_master.sda :> ack; // Samples ACK.
   if(ack) return (0);

   wait_func(2,clock_mul,i2c_master.scl,1);
   i2c_master.scl <: 0;
   i2c_master.sda :> sda_high;

   wait_func(2,clock_mul,i2c_master.scl,0);
   i2c_master.scl :> scl_high;
   i2c_master.scl when pinseq(1) :> void;

   wait_func(4,clock_mul,i2c_master.scl,1);

   i2c_master.sda <:0;// Generating Repeated Start bit on SDI

   wait_func(4,clock_mul,i2c_master.scl,1);
   i2c_master.scl <: 0;

   deviceAddr = device | 1;
   for (i = 0; i < 8; i += 1) // To Send 7-Bit Device ID and 1-Bit R/W Bit(Fixed to Read).
   {
      Temp = (deviceAddr >> (7 - i)) & 0x1;
      i2c_master.sda <: Temp;
      wait_func(2,clock_mul,i2c_master.scl,0);
      i2c_master.scl :> scl_high;
      i2c_master.scl when pinseq(1) :> void;
      ///////////

      if(Temp){
    	  i2c_master.sda :> sda_high;
    	  if(!sda_high) return(0);
      }

      wait_func(2,clock_mul,i2c_master.scl,1);
      i2c_master.scl <: 0;
   }

   i2c_master.sda :> Temp; //Turn the data to input
   wait_func(2,clock_mul,i2c_master.scl,0);
   i2c_master.scl :> scl_high;
   i2c_master.scl when pinseq(1) :> void;

   i2c_master.sda :> ack; // Samples ACK.
   if(ack) return (0);

   for(i=0; i < i2c_data.data_len;++i){ //To Check for number of 8-Bit data.
	   data_rx = 0;
	   wait_func(2,clock_mul,i2c_master.scl,1);
	   i2c_master.scl <: 0;
	   i2c_master.sda :> sda_high;

	   wait_func(2,clock_mul,i2c_master.scl,0);
	   i2c_master.scl :> scl_high;
	   i2c_master.scl when pinseq(1) :> void;

	   for(j=7; j >= 0;--j){ //To Receive 8-Bit data
		   i2c_master.sda :> Temp;
		   data_rx = ((Temp << j) | data_rx);

		   wait_func(2,clock_mul,i2c_master.scl,1);
		   i2c_master.scl <: 0;

		   if(j ==0)
			   i2c_master.sda <: 0;

			wait_func(2,clock_mul,i2c_master.scl,0);
			i2c_master.scl :> scl_high;
			i2c_master.scl when pinseq(1) :> void;
	   }
	   i2c_data.data[i] = data_rx;

   }

   wait_func(4,clock_mul,i2c_master.scl,1);
   i2c_master.sda <: 1;                     //Sending Stop.
   wait_func(2,clock_mul,i2c_master.scl,1);
   return (1);
}

/**
* \fn       _i2c_master_tx
* \brief    The function is called whenever required to write a I2C Slave device. The data and the length of data
*           is obtained from i2c_data structure.
* \param    device address, sub address, data length and data in a structure, sda and scl port in a structure
* \return   0 if transaction is not successful
* 			1 if transaction is successful
*/
int i2c_master_tx(int device, int sub_addr, struct i2c_data_info &i2c_data, struct r_i2c &i2c_master)
{
   int Temp, CtlAdrsData, i;
   int ack;
   unsigned int data;
   unsigned int j;
   unsigned int sda_high;
   unsigned int clock_mul;

   clock_mul = i2c_data.clock_mul;

   // Initial state is both high
   OUTPUT_HIGH(i2c_master.scl);
   OUTPUT_HIGH(i2c_master.sda);

   sync(i2c_master.sda);

   OUTPUT_HIGH(i2c_master.scl);
   wait_func(2,clock_mul,i2c_master.scl,1);

   // Clock high, data low for start bit
   OUTPUT_HIGH(i2c_master.scl);
   OUTPUT_LOW(i2c_master.sda);
   wait_func(2,clock_mul,i2c_master.scl,1);

   // Clock low at start of first address bit
   OUTPUT_LOW(i2c_master.scl);

   for (i = 0; i < 8; ++i) // To Send 7-Bit Device ID and 1-Bit R/W Bit(Fixed to write).
   {
	  // Drive for 0, pull-up for 1
      Temp = (device >> (7 - i)) & 0x1;
      if(!Temp) OUTPUT_LOW(i2c_master.sda)
      else OUTPUT_HIGH(i2c_master.sda);

      wait_func(2,clock_mul,i2c_master.scl,0);

      // Raise clock and wait to make sure it raises
      OUTPUT_HIGH(i2c_master.scl);
      i2c_master.scl when pinseq(1) :> void;

      // Checking for bit (Arbitration - bit may be low if 2 masters are conflicting)
      if(Temp){
    	  i2c_master.sda :> sda_high;
    	  if(!sda_high){
    		  return(0);
    	  }
      }

      // Second half cycle of bit
      wait_func(2,clock_mul,i2c_master.scl,1);

      // Clock low at start of next bit
      OUTPUT_LOW(i2c_master.scl);
   }

   i2c_master.sda :> Temp;   // turn the data to input
   wait_func(2,clock_mul,i2c_master.scl,0);
   //i2c_master.scl <: 1;
   OUTPUT_HIGH(i2c_master.scl);
   i2c_master.scl when pinseq(1) :> void;

   i2c_master.sda :> ack; // Sample Acknowledge.
   if(ack) return (0);

   wait_func(2,clock_mul,i2c_master.scl,1);
   OUTPUT_LOW(i2c_master.scl);
   OUTPUT_LOW(i2c_master.sda);

   CtlAdrsData = (sub_addr & 0xFF);

   for (i = 0; i < 8; i += 1) // To Send 8-Bit Sub address.
   {
      Temp = (CtlAdrsData >> (7 - i)) & 0x1;
      if(!Temp) OUTPUT_LOW(i2c_master.sda)
      else OUTPUT_HIGH(i2c_master.sda);

      wait_func(2,clock_mul,i2c_master.scl,0);

      OUTPUT_HIGH(i2c_master.scl);
      i2c_master.scl when pinseq(1) :> void;

      // Checking for bit(Arbitration)
      if(Temp){
    	  i2c_master.sda :> sda_high;
    	  if(!sda_high){
    		  return(0);
    	  }
      }
      wait_func(2,clock_mul,i2c_master.scl,1);
      OUTPUT_LOW(i2c_master.scl);
   }

   i2c_master.sda :> Temp; // turn the data to input
   wait_func(2,clock_mul,i2c_master.scl,0);

   OUTPUT_HIGH(i2c_master.scl);
   i2c_master.scl when pinseq(1) :> void;

   i2c_master.sda :> ack;  // Sample Acknowledge.
   if(ack) return(0);

   wait_func(2,clock_mul,i2c_master.scl,1);
   i2c_master.scl <: 0;
   i2c_master.sda <: 0;

   CtlAdrsData = (data & 0xFF);

   // shift second 8 bits.
   //Sending Data
   for(j=0; j < i2c_data.data_len; j++){           //Check for data length
	   CtlAdrsData = (i2c_data.data[j] & 0xFF);
	   for (i = 0; i < 8; ++i)                     //To Send 8-Bit data
	   {
		   Temp = (CtlAdrsData >> (7 - i)) & 0x1;
		   if(!Temp) OUTPUT_LOW(i2c_master.sda)
		   else OUTPUT_HIGH(i2c_master.sda);

		   wait_func(2,clock_mul,i2c_master.scl,0);

		   OUTPUT_HIGH(i2c_master.scl);
		   i2c_master.scl when pinseq(1) :> void;

		   // Checking for bit(Arbitration)
		   if(Temp){
			   i2c_master.sda :> sda_high;
			   if(!sda_high){
				   return(0);
			   }
		   }
		   wait_func(2,clock_mul,i2c_master.scl,1);
		   OUTPUT_LOW(i2c_master.scl);
	   }

	   i2c_master.sda :> Temp;// turn the data to input
	   wait_func(2,clock_mul,i2c_master.scl,0);

	   OUTPUT_HIGH(i2c_master.scl);
	   i2c_master.scl when pinseq(1) :> void;

	   i2c_master.sda :> ack; // Sample Acknowledge.
	   if(ack) return(0);

	   wait_func(2,clock_mul,i2c_master.scl,1);
	   OUTPUT_LOW(i2c_master.scl);
   }

   OUTPUT_LOW(i2c_master.sda);
   wait_func(2,clock_mul,i2c_master.scl,0);

   // Send stop
   OUTPUT_HIGH(i2c_master.scl);
   i2c_master.scl when pinseq(1) :> void;

   wait_func(4,clock_mul,i2c_master.scl,1);
   OUTPUT_HIGH(i2c_master.sda);
   return (1);
}

/**
* \fn       _wait_func
* \brief    The function is called to insert wait state between scl high and low, and low to high.
*           During clock syncronization, scl is pulled low before the wait time is elapsed if another
*           master pulls scl low.
* \param    div_factor,clock_mul,scl,edge
*           clock_mul : to change the frequency of SCL.
*           edge : If scl transition is from 1 to 0 and if any other master pulls the clock low before
*           this master pulls low, there is no point in waiting for the wait-period to pull the clock low
*           by this master. This is used in clock syncronization.
*           if edge =1 if required clock transition is from 1 to 0.
*           edge = 0 if required clock transition is from 0 to 1.
* \return   none
*/

void wait_func(int div_factor, unsigned int clock_mul,port scl,int edge){
	unsigned int time;
	timer gt;
	int i;
	gt :> time;
	time += ((I2C_BIT_TIME / div_factor)* clock_mul);
	if(edge){
		select {
		case scl when pinseq(0) :> void :
			i=0;
			break;
		case gt when timerafter(time) :> void :
			i=1;
			break;
		}
	} else gt when timerafter(time) :> void;
}
