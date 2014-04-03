/**
 * Module:  module_usb_shared
 * Version: 1v14
 * Build:   2653f22a66739162bd368f5c7d50da8bd7417fd7
 * File:    DescriptorRequests.h
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
/** 
 * @file       DescriptorRequests.h
 * @brief      DescriptorRequestsi() prototype
 * @author     Ross Owen, XMOS Limited
 * @version    1.0
 */


/** DescriptorRequests()
  * @brief     This function performs some of the common USB standard descriptor requests.
  *
  * @param     c_out Channel to XUD (ep 0)
  * @param     c_in Channel from XUD (ep 0) 
  * @param     devDesc Device descriptor
  * @param     devDescLength Length of device descriptor in bytes
  * @param     cfgDesc Configuration descriptor
  * @param     cfgDescLength Length of config descriptor in bytes
  * @param     devQualDesc Device Qualification Descriptor
  * @param     sp SetupPacket (passed by ref) in which the setup data is returned
  * @param     c_usb_test Optional channel param for USB test mode support
  * @return    1 if dealt with else 
  *
  * This function handles the following standard requests appropriately using values passed to it:
  *
  *   - Get Device Descriptor (Using devDesc argument)
  *   - Get Configuration Descriptor (Using cfgDesc argument)
  *   - String requests (using strDesc argument)
  *   - Get Micro$oft OS String Descriptor (Usings product ID string) 
  *   - Get Device_Qualifier Descriptor 
  *   - Get Other-Speed Configuration Descriptor (using oSpeedCfgDesc argument)
  *   
  *  This function returns 1 if the request has been dealt with successfully, 0 if not.  The SetupPacket
  *  structure should then be examined for device specific requests.

  */
int DescriptorRequests(XUD_ep c, XUD_ep c_in, uint8 devDesc[], int devDescLength, uint8 cfgDesc[], int cfgDescLength,
    uint8 devQualDesc[], int devQualDescLength, uint8 oSpeedCfgDesc[], int oSpeedCfgDescLength, 
    uint8 strDescs[][40], SetupPacket &sp, chanend ?c_usb_test);
