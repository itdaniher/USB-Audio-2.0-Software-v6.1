/**
 * Module:  module_usb_shared
 * Version: 1v3
 * Build:   da124830ea5119bd45f808f00f72b152ca5a4a24
 * File:    hid.h
 *
 * The copyrights, all other intellectual and industrial 
 * property rights are retained by XMOS and/or its licensors. 
 * Terms and conditions covering the use of this code can
 * be found in the Xmos End User License Agreement.
 *
 * Copyright XMOS Ltd 2010
 *
 * In the case where this code is a modification of existing code
 * under a separate license, the separate license terms are shown
 * below. The modifications to the code are still covered by the 
 * copyright notice above.
 *
 **/                                   

/* hid.h 
 * Defines from USB Device Class Definition for Human Interface Devices Specification 
 */

/* 7. Requests */
/* 7.1 Standard Requests  - Class Descriptor Types - High byte of wValue */
/* The following defines valid types of Class descriptors */
#define HID                   0x21
#define REPORT                0x22
#define PHYSICAL_DESCRIPTOR   0x23
/*0x24 - 0x2F: Reserved */

/* 7.2 Class-Specific Requests - bRequest values */
#define GET_REPORT            0x01           /* Mandatory */
#define GET_IDLE              0x02
#define GET_PROTOCOL          0x03           /* Required only for boot devices */
/* Ox04 - 0x08 reserved */
#define SET_REPORT            0x09
#define SET_IDLE              0x0A
#define SET_PROTOCOL          0x0B           /* Required only for boot devices */
