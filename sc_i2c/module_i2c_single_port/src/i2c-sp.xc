// Copyright (c) 2011, XMOS Ltd, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

// I2C master

#include <xs1.h>
#include <xclib.h>
#include <stdio.h>
#include "i2c.h"

#define SDA_LOW     0
#define SCL_LOW     0

void i2c_master_init(port i2c) {
    i2c :> void;    // Drive all high
}

static void waitQuarter(void) {
    timer gt;
    int time;

    gt :> time;
    time += (I2C_BIT_TIME + 3) / 4;
    gt when timerafter(time) :> int _;
}

static void waitHalf(void) {
    waitQuarter();
    waitQuarter();
}

static int highPulse(port i2c, int sdaValue) {
    if (sdaValue) {
        int temp;
         i2c <: SDA_HIGH | SCL_LOW | S_REST; // Orig
        //i2c <: SDA_LOW | SCL_LOW | S_REST; // JEG
        waitQuarter();
        i2c :> void;
        waitQuarter();
        temp = (peek(i2c) & SDA_HIGH) != 0;
        waitQuarter();
         i2c <: SDA_HIGH | SCL_LOW | S_REST; // Orig
        //i2c <: SDA_LOW | SCL_LOW | S_REST; // JEG
        waitQuarter();
        return temp;
    } else {
        i2c <: SDA_LOW | SCL_LOW | S_REST;
        waitQuarter();
        i2c <: SDA_LOW | SCL_HIGH | S_REST;
        waitQuarter();
        waitQuarter();
        i2c <: SDA_LOW | SCL_LOW | S_REST;
        waitQuarter();
        return 0;
    }
}

static int highPulseSample(port i2c) {
    return highPulse(i2c, 1);
}

static void startBit(port i2c) {
    waitQuarter();
    i2c <: SDA_LOW | SCL_HIGH | S_REST;
    waitHalf();
    i2c <: SDA_LOW | SCL_LOW | S_REST;
    waitQuarter();
}

static void stopBit(port i2c) {
    i2c <: SDA_LOW | SCL_LOW | S_REST;
    waitQuarter();
    i2c <: SDA_LOW | SCL_HIGH | S_REST;
    waitHalf();
    i2c :> void;
    waitQuarter();
}

static int tx8(port i2c, unsigned data) {
    int ack;
    int temp;
    unsigned CtlAdrsData = ((unsigned) bitrev(data)) >> 24;
    for (int i = 8; i != 0; i--) {
        highPulse(i2c, CtlAdrsData & 1);
        CtlAdrsData >>= 1;
    }
    //ack = highPulseSample(i2c); // Orig
    /* JEG ... */
            
         //i2c <: SDA_HIGH | SCL_LOW | S_REST; // Orig
        i2c <: SDA_LOW | SCL_LOW | S_REST; // JEG
        waitQuarter();
        i2c :> void;
        waitQuarter();
        temp = (peek(i2c) & SDA_HIGH) != 0;
        waitQuarter();
        // i2c <: SDA_HIGH | SCL_LOW | S_REST; // Orig
        i2c <: SDA_LOW | SCL_LOW | S_REST; // JEG
        waitQuarter();
     /* end JEG */
//    printf("Ack: %d\n", ack);
    return ack;
}

#ifndef I2C_TI_COMPATIBILITY
int i2c_master_rx(int device, unsigned char data[], int nbytes, port i2c) {
   int i;
   int rdData = 0;

   startBit(i2c);
   tx8(i2c, device | 1);
   for (i = 8; i != 0; i--) {
       int temp = highPulseSample(i2c);
       rdData = (rdData << 1) | temp;
   }
   (void) highPulseSample(i2c);
   stopBit(i2c);
   data[0] = rdData;
   return 1;
}

int i2c_master_read_reg(int device, int addr, unsigned char data[], int nbytes, port i2c) {
   startBit(i2c);
   tx8(i2c, device);
   tx8(i2c, addr);
   stopBit(i2c);
   return i2c_master_rx(device, data, nbytes, i2c);
}
#endif

int i2c_master_write_reg(int device, int addr, unsigned char s_data[], int nbytes, port i2c) {
   int data = s_data[0];
   int ack;

   startBit(i2c);
   ack = tx8(i2c, device);
#ifdef I2C_TI_COMPATIBILITY
   ack |= tx8(i2c, addr << 1 | (data >> 8) & 1);
#else
   ack |= tx8(i2c, addr);
#endif
   ack |= tx8(i2c, data);
   stopBit(i2c);
   return ack == 0;
}