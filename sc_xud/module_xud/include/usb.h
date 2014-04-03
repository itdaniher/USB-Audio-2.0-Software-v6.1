/**
 * Module:  module_usb_shared
 * Version: 1v15
 * Build:   ba2d74b0702e5e78a497515f08dfb1ebe601cd36
 * File:    usb.h
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
/** @file      usb.h 
  * @brief     Defines from the Universal Serial Bus Specification Revision 2.0 
  * @author    Ross Owen, XMOS Limited 
  * @version   1.0
  **/

/* USB Class Codes (from usb.org) */
#define USE_CLASS                   0x00     	/* Use class information in the interface descriptors */
#define AUDIO                       0x01
#define COMMUNICATIONS              0x02
#define HID                         0x03
#define PHYSICAL                    0x05
#define IMAGE                       0x06
#define PRINTER                     0x07
#define MASS_STORAGE                0x08
#define HUB                         0x09
#define CDC_DATA                    0x0A
#define SMART_CARD                  0x0B
#define CONTENT_SECURITY            0x0D
#define VIDEO                       0x0E
//...
#define VENDOR_SPECIFIC             0x00


/* Table 8-1. PID Types */
#define OUT                         0x1			/* Tokens */
#define IN                          0x9
#define SOF                         0x5
#define SETUP                       0xD
#define DATA0                       0x3      	/* Data packet PID even */
#define DATA1                       0xB      	/* Data packet PID odd */
#define DATA2						0x7			/* Data packet PID high-speed, high bandwidth isoc transaction in a microframe */
#define MDATA                       0xF      	/* Data packet PID high-speed and high bandwidth isoc transactions */
#define ACK                         0x2      	/* Receiver accepts error-free data packet */
#define NAK                         0xA      	/* Receiving device cannot accept data of transmitting device cannot send data */
#define STALL                       0xE      	/* Endpoint is halted or a control pipe request is not supported */
#define PRE                         0xC
#define ERR                         0xC
#define SPLIT                       0x8
#define PING                        0x4      	/* Hign-speed flow control probe for bulk/control endpoint */


/* 9.3 USB Device Requests: Table 9-2 Format of Setup Data */
/* bmRequestType: */
#define BM_REQTYPE_DIRECTION_OUT    0       	/* Host to device */
#define BM_REQTYPE_DIRECTION_IN     1       	/* Device to host */

#define BM_REQTYPE_TYPE_STANDARD    0x00
#define BM_REQTYPE_TYPE_CLASS       0x01
#define BM_REQTYPE_TYPE_VENDOR      0x02

#define BM_REQTYPE_RECIP_DEV        0x00
#define BM_REQTYPE_RECIP_INTER      0x01
#define BM_REQTYPE_RECIP_EP         0x02
#define BM_REQTYPE_RECIP_OTHER      0x03


/* Table 9-4. Standard Request Codes */
/* bRequest */
#define GET_STATUS                  0x00
#define CLEAR_FEATURE               0x01
#define SET_FEATURE                 0x03
#define SET_ADDRESS                 0x05
#define GET_DESCRIPTOR              0x06
#define SET_DESCRIPTOR              0x07
#define GET_CONFIGURATION           0x08
#define SET_CONFIGURATION           0x09
#define GET_INTERFACE               0x0A
#define SET_INTERFACE               0x0B
#define SYNCH_FRAME                 0x0C


/* Table 9-5. Descriptor Types */
#define DEVICE                      0x01
#define CONFIGURATION               0x02
#define STRING                      0x03
#define INTERFACE                   0x04
#define ENDPOINT                    0x05
#define DEVICE_QUALIFIER            0x06
#define OTHER_SPEED_CONFIGURATION   0x07
#define INTERFACE_POWER             0x08
    

/* Table 9-6. Standard Feature Selectors (wValue) */
#define DEVICE_REMOTE_WAKEUP        0x01     	/* Recipient: Device */
#define ENDPOINT_HALT               0x00     	/* Recipient: Endpoint */
#define TEST_MODE                   0x02     	/* Recipient: Device */

#define STANDARD_DEVICE_REQUEST     0x00
#define STANDARD_INTERFACE_REQUEST  0x01
#define STANDARD_ENDPOINT_REQUEST   0x02
#define VENDOR_DEVICE_REQUEST       0x40
#define VENDOR_ENDPOINT_REQUEST     0x42
#define CLASS_INTERFACE_REQUEST     0x21
#define CLASS_ENDPOINT_REQUEST      0x22



#define WVAL_EP_HALT                0



// Audio
#define B_REQ_SET_CUR               0x01
#define B_REQ_GET_CUR               0x81
#define B_REQ_GET_MIN           	0x82
#define B_REQ_GET_MAX               0x83
#define B_REQ_GET_RES               0x84

/* wValue for Get Descriptor (indicates required descriptor)
 * Note: top byte used only
 */
#define WVALUE_GETDESC_DEV       	(DEVICE << 8)
#define WVALUE_GETDESC_CONFIG    	(CONFIGURATION << 8)
#define WVALUE_GETDESC_STRING    	(STRING << 8)
#define WVALUE_GETDESC_INTER     	(INTERFACE << 8)
#define WVALUE_GETDESC_DEVQUAL   	(DEVICE_QUALIFIER << 8)
#define WVALUE_GETDESC_OSPEED_CFG 	(OTHER_SPEED_CONFIGURATION << 8)

// Low byte values:
#define WVALUE_GETDESC_STRING_LANGIDS 0x0
#define WVALUE_GETDESC_STRING_IPRODUCT  0x2

//bDeviceClass
#define XUD_DESC_DEV_B_DEVCLASS_INTER     0x0   // Interface descriptor speicifies class
#define XUD_DESC_DEV_B_DEVCLASS_COMMS     0x2   // Communications

// Test selector defines for Test mode
#define WINDEX_TEST_J               (0x1<<8)
#define WINDEX_TEST_K               (0x2<<8)
#define WINDEX_TEST_SE0_NAK         (0x3<<8)
#define WINDEX_TEST_PACKET          (0x4<<8)
#define WINDEX_TEST_FORCE_ENABLE    (0x5<<8)

// Raw PIDs
#define PID_OUT   0x01
#define PID_ACK   0x02
#define PID_DATA0 0x03
#define PID_PING  0x04
#define PID_SOF   0x05
#define PID_IN    0x09
#define PID_DATA1 0x0B
#define PID_SETUP 0x0D

// PIDs with error check
// Token
#define PIDn_OUT   0xe1
#define PIDn_IN    0x69
#define PIDn_SOF   0xa5
#define PIDn_SETUP 0x2d

// Data PIDs
#define PIDn_DATA0  0xc3
#define PIDn_DATA1  0x4b
#define PID_DATA0   0x3
#define PID_DATA1   0xb

#define PIDn_ACK 0xd2
#define PIDn_NAK 0x5a
#define PIDn_STALL 0x1e

#if 0
//bRequest
#define B_REQ_GETSTATUS             0x00
#define B_REQ_SETFEATURE            0x03
#define B_REQ_CLEARFEATURE          0x01
#define B_REQ_GETDESC               0x06
#define B_REQ_SETADDR               0x05
#define B_REQ_GETCONFIG             0x08
#define B_REQ_SETCONFIG             0x09
#define B_REQ_GETINTER              0x0a
#define B_REQ_SETINTER              0x0b
#endif

#if 0
//////////
// Descriptor types:
#define XUD_DESC_DEV_B_DESCTYPE_DEVICE     0x1
#define XUD_DESC_DEV_B_DESCTYPE_CONFIG     0x2
#define XUD_DESC_DEV_B_DESCTYPE_STRING     0x3
#define XUD_DESC_DEV_B_DESCTYPE_INTER      0x4
#define XUD_DESC_DEV_B_DESCTYPE_EP         0x5
#define XUD_DESC_DEV_B_DESCTYPE_DEVQUAL    0x6
#define XUD_DESC_DEV_B_DESCTYPE_OSPEED_CFG 0x7

#define XUD_DESC_DEV_B_DESCTYPE_HID   0x21
#endif
