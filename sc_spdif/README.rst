S/PDIF 
...........

:Version: 1.3.0rc2
:Vendor: XMOS
:Description: S/PDIF Component


The two modules in this library are used to transmit and receive
S/PDIF streams, http://en.wikipedia.org/wiki/Spdif. The rx_generator directory contains the programs that are used
to generate the state machine used
by the receiver.

Key Features
============

* RX and TX in separate threads
* Rates of 44,100 up to 192,000 Samples/sec

Firmware Overview
=================

RX and TX are defined as functions which each run forever.

Known Issues
============

none

Required software (dependencies)
================================

  * xcommon (if using development tools earlier than 11.11.0)
  * sc_i2c

Documentation
=============

You can find the documentation for this software in the doc/ directory of the package.

Support
=======

  This package is support by XMOS Ltd. Issues can be raised against the software
  at:

      http://www.xmos.com/support

