#include <xs1.h>
#include <stdio.h>
#include <stdlib.h>
#include <syscall.h>
#include "i2c.h"

#undef __XS1_G__
/**
 *  \fn      i2c_slave_init
 *  \brief   initialise an I2C 2-wire slave device
 *  \param   i2c_slave  the port control structure
 */
void i2c_slave_init(struct r_i2c &i2c_slave)
{
}

/**
 * \fn       i2c_slave_rx
 * \brief    The function receives the data whenever master address it in write mode.
 * 			 The first byte received will be the address and second byte onwards will be data.
 * \param    device address , data length and data in a structure in which number of data bytes received and
 *           the bytes are stored, sda and scl port in a structure.
 * \return   0 if transaction is not scuccesfull
 * 			 1 if transaction is scuccesfull
 */
int i2c_slave_rx(int dev_addr, struct i2c_data_info &i2c_slave_data, struct r_i2c &i2c_slave)
{
	unsigned int clk;
	unsigned int rx_addr;
	unsigned int rx_data;
	unsigned int stop_det;
	unsigned int temp;
	unsigned int time;
	timer t;
	int x,i;
	unsigned int while_break;
	unsigned int rpt_start_det;
	#ifdef __XS1_G__
	set_port_pull_up(i2c_slave.scl);
	set_port_pull_up(i2c_slave.sda);
	#endif
	temp=0;
	i2c_slave_data.data_len = 0;  // Initialise the data length
	i2c_slave.sda :> temp;
	while(1){
		while(1){                                 // To Wait for start bit
			i2c_slave.sda when pinseq(0) :> void;
			i2c_slave.scl :> clk;
			if(clk == 1){
				break;
			}
			else
				i2c_slave.sda when pinseq(1) :> void;
		}
		i2c_slave.scl when pinseq(0) :> void;
		rx_addr =0;
		for(i=7; i >= 0; --i){  // To read the address.
			i2c_slave.scl when pinseq(1) :> void;
			i2c_slave.sda :> temp;
			rx_addr = rx_addr | (temp << i);
			i2c_slave.scl when pinseq(0) :> void;
		}

		if(!(rx_addr & 0x01)&&(rx_addr>>1) != dev_addr){  // Compare the received address and R/W bit
			break;
		}
		i2c_slave.scl <: 0;
		t:> time;
		time = time + (3*I2C_BIT_TIME);
		t when timerafter (time) :> void;

		i2c_slave.sda <: 0;  //Sending ACK signal to the Master.
		t:> time;
		time = time + (3*I2C_BIT_TIME);
		t when timerafter (time) :> void;

		i2c_slave.scl :> temp;
		i2c_slave.scl when pinseq(1) :> void;
		i2c_slave.scl when pinseq(0) :> void;
		i2c_slave.sda :> temp;
		stop_det = 0;
		while_break = 0;
		rpt_start_det = 0;
		x=0;
		//For data Read
		while(!stop_det){   // Read the data till STOP signal
			rx_data=0;
			for(i=7; i >= 0; --i){
				i2c_slave.scl when pinseq(1) :> void;
				i2c_slave.sda :> temp;
				rx_data = rx_data | (temp << i);
				if(i == 7) while_break = 0;
				while(!while_break && i == 7){  // Checks at only MSB.
				if(x > 0){  // Checking for STOP bit after 1st byte reception
					select {
						case i2c_slave.scl when pinseq(0) :> void:
							while_break = 1;
							break;
						case i2c_slave.sda when pinseq(1) :> void:
							if(temp == 0) {
								stop_det = 1;
								while_break = 1;
							}
							break;
						}
				}
				else
					if(temp) // Checks for START bit if MSB is 1
					{
						select {  // To Check for repeat START.
							case i2c_slave.scl when pinseq(0) :> void:
								while_break = 1;
								break;
							case i2c_slave.sda when pinseq(0) :> void:
								if(temp) {
									rpt_start_det = 1;
									while_break = 1;
								}
								break;
							}
						}
					else
						while_break = 1;
				}

				if(stop_det == 0) i2c_slave.scl when pinseq(0) :> void;
				else break;
			}
			if(!stop_det) {
				i2c_slave.scl <: 0;
				t:> time;
				time = time + (3*I2C_BIT_TIME);
				t when timerafter (time) :> void;

				i2c_slave.sda <: 0;  // Sending ACK.
				t:> time;
				time = time + (3*I2C_BIT_TIME);
				t when timerafter (time) :> void;

				i2c_slave.scl :> temp;
				i2c_slave.scl when pinseq(1) :> void;
				i2c_slave_data.data_len++;  // Updates the data length
				i2c_slave_data.data[x] = rx_data; //Stores the Data Received in the array.
				x++;
				i2c_slave.scl when pinseq(0) :> void;
				i2c_slave.sda :> temp;
			}
			else {
				return 1;
			}
		}
		//return;
	}
	return 0;
}

/**
* \fn       _i2c_slave_tx
* \brief    The function transmits the data stored whenever master address it in read mode.
* \param    device address , sub address, data length and data in a structure in which number of data bytes
*           are stored for transmitting , sda and scl port in a structure.
* \return   0 if transaction is not scuccesfull
* 			 1 if transaction is scuccesfull
*/

int i2c_slave_tx(int dev_addr, int sub_addr, struct i2c_data_info &i2c_slave_data, struct r_i2c &i2c_slave)
{
	unsigned int clk;
	unsigned int rx_addr;
	unsigned int rx_data;
	unsigned int Temp;
	unsigned int sda_high;
	int i,j;
	unsigned int nack,start_det;
	#ifdef __XS1_G__
	set_port_pull_up(i2c_slave.scl);
	set_port_pull_up(i2c_slave.sda);
	#endif
	Temp=0;
	i2c_slave.sda :> Temp;
	while(1){        // To Wait for start bit
		i2c_slave.sda when pinseq(0) :> void;
		i2c_slave.scl :> clk;
		if(clk == 1){
			break;
		}
		else
			i2c_slave.sda when pinseq(1) :> void;
	}
	i2c_slave.scl when pinseq(0) :> void;
	//address read
	rx_addr =0;
	for(i=7; i >= 0; --i){  // Reading address
		i2c_slave.scl when pinseq(1) :> void;
		i2c_slave.sda :> Temp;
		rx_addr = (rx_addr | (Temp << i));
		i2c_slave.scl when pinseq(0) :> void;
	}
	if((rx_addr & 0x01)&&(rx_addr>>1) != dev_addr){  // Compare the received address and R/W bit
		return 0;
	}
	i2c_slave.sda <: 0; // Sending ACK
	i2c_slave.scl when pinseq(1) :> void;
	i2c_slave.scl when pinseq(0) :> void;
	rx_addr = 0;
	for(i=7; i >= 0; --i){  //Reading Sub-address
		i2c_slave.scl when pinseq(1) :> void;
		i2c_slave.sda :> Temp;
		rx_addr = rx_addr | (Temp << i);
		i2c_slave.scl when pinseq(0) :> void;
	}

	if((rx_addr) != sub_addr){ //To Compare sub-address.
		return 0;
	}
	i2c_slave.sda <: 0;  //To send ACK.
	i2c_slave.scl when pinseq(1) :> void;
	i2c_slave.scl when pinseq(0) :> void;
	i2c_slave.sda :> sda_high;
	i2c_slave.scl when pinseq(1) :> void;

	i2c_slave.sda :> Temp;
	start_det = 0;

	select {  // To Check for repeat START.
	case i2c_slave.sda when pinseq(0) :> void:
		{
			if(Temp == 1)
				start_det =1;
			break;
		}
	case i2c_slave.scl when pinseq(0) :> void:
		{
			start_det = 0;
			break;
		}
	}
	if(!start_det) return 0;
	i2c_slave.scl when pinseq(0) :> void;

	rx_addr=0;

	for(i=7; i >= 0; --i){  //To receive Dev-address.
		i2c_slave.scl when pinseq(1) :> void;
		i2c_slave.sda :> Temp;
		rx_addr = ((Temp << i) | rx_addr);
		i2c_slave.scl when pinseq(0) :> void;
	}
	if((rx_addr>>1 == dev_addr) && (rx_addr & 0x1)){ // To check for device address and
		i2c_slave.sda <: 0;                                       // read/write bit for read.
	}
	else return 0;

	i2c_slave.scl when pinseq(1) :> void;
	i2c_slave.scl when pinseq(0) :> void;
	nack = 0;
	j=0;
	while(!nack){
		rx_data = i2c_slave_data.data[j];
		j++;
		for(i=7; i >=0 ;--i){ //To transmit data from slave.
			Temp = (rx_data >> i) & 0x01;
			i2c_slave.sda <: Temp;
			i2c_slave.scl when pinseq(1) :> void ;
			i2c_slave.scl when pinseq(0) :> void ;
		}
		i2c_slave.sda :> void;
		i2c_slave.scl when pinseq(1) :> void ;
		i2c_slave.sda :> nack;
		i2c_slave.scl when pinseq(0) :> void ;
	}

	return 0;
}