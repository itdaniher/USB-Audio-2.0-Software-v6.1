#include "i2c.h"

/**
 *  This supports the standalone CODEC in the XDK board.  It has a slightly
 *  different configuration of address and data bits, and is wired so that
 *  multiple masters cannot coexist on the same I2C interface. As a consequence
 *  it needs the core to drive the wires high as well as low.
 */
int i2c_tlv320_tx(struct r_i2c &r, int addr, int regn, int data);
