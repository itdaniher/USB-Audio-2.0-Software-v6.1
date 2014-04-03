#include <xs1.h>
#include <platform.h>
#include "xud.h"

#ifdef ARCH_S





#else
#ifdef UIFM_USB_CLK_PORT
// Port defines already made (probably in XN file)
in port  p_usb_clk       = UIFM_USB_CLK_PORT;
out port reg_write_port  = UIFM_REG_WRITE_PORT;
in  port reg_read_port   = UIFM_REG_READ_PORT;
in  port flag0_port      = UIFM_FLAG_0_PORT;
in  port flag1_port      = UIFM_FLAG_1_PORT;
in  port flag2_port      = UIFM_FLAG_2_PORT;
out port p_usb_txd       = UIFM_TX_DATA_PORT;
    port p_usb_rxd       = UIFM_RX_DATA_PORT;
#else

// We need to know what core the USB ports are on
#ifndef USB_CORE
//#error "Must define USB_CORE to core number with USB interface"
#else
#define UIFM_USB_CLK_PORT        XS1_PORT_1H

#define UIFM_REG_WRITE_PORT      XS1_PORT_8C
#define UIFM_REG_READ_PORT       XS1_PORT_8D
#define UIFM_FLAG_0_PORT         XS1_PORT_1N
#define UIFM_FLAG_1_PORT         XS1_PORT_1O
#define UIFM_FLAG_2_PORT         XS1_PORT_1P
#define UIFM_TX_DATA_PORT        XS1_PORT_8A
#define UIFM_RX_DATA_PORT        XS1_PORT_8B
#define UIFM_STP_SUS_PORT        XS1_PORT_1E
#define UIFM_LS_PORT             XS1_PORT_4D

on stdcore[USB_CORE]:in port  p_usb_clk       = UIFM_USB_CLK_PORT;
on stdcore[USB_CORE]:out port reg_write_port  = UIFM_REG_WRITE_PORT;
on stdcore[USB_CORE]:in  port reg_read_port   = UIFM_REG_READ_PORT;
on stdcore[USB_CORE]:in  port flag0_port      = UIFM_FLAG_0_PORT;
on stdcore[USB_CORE]:in  port flag1_port      = UIFM_FLAG_1_PORT;
on stdcore[USB_CORE]:in  port flag2_port      = UIFM_FLAG_2_PORT;
on stdcore[USB_CORE]:out port p_usb_txd       = UIFM_TX_DATA_PORT;
on stdcore[USB_CORE]:    port p_usb_rxd       = UIFM_RX_DATA_PORT;
#endif
#endif
#endif
