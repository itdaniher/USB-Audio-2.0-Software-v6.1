// Copyright (c) 2011, XMOS Ltd, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

// I2C master

#include <xs1.h>
#include <xclib.h>
#include "i2c.h"

void i2c_master_init(struct r_i2c &i2c_master) {
	i2c_master.scl :> void;
    i2c_master.sda :> void;
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

static int highPulseSample(port i2c_scl, port ?i2c_sda) {
    int temp;
    if (!isnull(i2c_sda)) {
        i2c_sda :> int _;
    }
    waitQuarter();
    i2c_scl :> void;
    waitQuarter();
    if (!isnull(i2c_sda)) {
        i2c_sda :> temp;
    }
    waitQuarter();
    i2c_scl <: 0;
    waitQuarter();
    return temp;
}

static void highPulse(port i2c_scl) {
    highPulseSample(i2c_scl, null);
}

static void startBit(port i2c_scl, port i2c_sda) {
    waitQuarter();
    i2c_sda  <: 0;
    waitHalf();
    i2c_scl  <: 0;
    waitQuarter();
}

static void stopBit(port i2c_scl, port i2c_sda) {
    i2c_sda <: 0;
    waitQuarter();
    i2c_scl :> void;
    waitHalf();
    i2c_sda :> void;
    waitQuarter();
}

static int tx8(port i2c_scl, port i2c_sda, unsigned data) {
    unsigned CtlAdrsData = ((unsigned) bitrev(data)) >> 24;
    for (int i = 8; i != 0; i--) {
        i2c_sda <: >> CtlAdrsData;
        highPulse(i2c_scl);
    }
    return highPulseSample(i2c_scl, i2c_sda);
}

#ifndef I2C_TI_COMPATIBILITY
int i2c_master_rx(int device, unsigned char data[], int nbytes, struct r_i2c &i2c) {
   int i;
   int rdData = 0;

   startBit(i2c.scl, i2c.sda);
   tx8(i2c.scl, i2c.sda, (device<<1) | 1);
   for (i = 8; i != 0; i--) {
       int temp = highPulseSample(i2c.scl, i2c.sda);
       rdData = (rdData << 1) | temp;
   }
   (void) highPulseSample(i2c.scl, i2c.sda);
   stopBit(i2c.scl, i2c.sda);
   data[0] = rdData;
   return 1;
}

int i2c_master_read_reg(int device, int addr, unsigned char data[], int nbytes, struct r_i2c &i2c) {
   startBit(i2c.scl, i2c.sda);
   tx8(i2c.scl, i2c.sda, device<<1);
   tx8(i2c.scl, i2c.sda, addr);
   stopBit(i2c.scl, i2c.sda);
   return i2c_master_rx(device, data, nbytes, i2c);
}
#endif

int i2c_master_write_reg(int device, int addr, unsigned char s_data[], int nbytes, struct r_i2c &i2c) {
   int data = s_data[0];
   int ack;

   startBit(i2c.scl, i2c.sda);
   ack = tx8(i2c.scl, i2c.sda, device<<1);
#ifdef I2C_TI_COMPATIBILITY
   ack |= tx8(i2c.scl, i2c.sda, addr << 1 | (data >> 8) & 1);
#else
   ack |= tx8(i2c.scl, i2c.sda, addr);
#endif
   ack |= tx8(i2c.scl, i2c.sda, data);
   stopBit(i2c.scl, i2c.sda);
   return ack == 0;
}
