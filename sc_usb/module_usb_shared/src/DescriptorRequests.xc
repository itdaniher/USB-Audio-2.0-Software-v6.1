/**
 * Module:  module_usb_shared
 * Version: 1v2
 * Build:   bb814601fea4422bae7e88cb0fd65289443c217c
 * File:    DescriptorRequests.xc
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
 * @file       DescriptorRequests.xc
 * @brief      DescriptorRequests implementation
 * @author     Ross Owen, XMOS Limited
 * @version    1.0
 */

#include <safestring.h>
#include <print.h>
#include <xs1.h>

#include "xud.h"     /* XUD Functions and defines */
#include "usb.h"     /* Defines related to the USB 2.0 Spec */

#if 0
/** @brief  Returns min of two values 
  * @param  a int
  * @param  b int
  * @return min of the two passed int values 
  */
int min(int a, int b) 
{
    if (a > b) 
        return b; 
    else 
        return a;
}
#endif

extern int min(int a, int b);


/* See DescriptorRequests.h for documentation */
#pragma unsafe arrays
int DescriptorRequests(XUD_ep c, XUD_ep c_in, uint8 devDesc[], int devDescLength, uint8 cfgDesc[], int cfgDescLength,
    uint8 devQualDesc[], int devQualDescLength, uint8 oSpeedCfgDesc[], int oSpeedCfgDescLength, 
    uint8 strDescs[][40], SetupPacket &sp, chanend ?c_usb_test)
{
     /* Return value */
    int datalength;
    int stringID = 0;

    /* Buffer for Setup data */
    uint8 buffer[120]; 
    uint8 sbuffer[120]; 
    /* Wait for Setup data */
    if (XUD_GetSetupBuffer(c, c_in, sbuffer) < 0) 
    {
        return -1;
    } 
#if 1
    else 
    {

		//printintln(1);

    /* Parse data buffer end populate SetupPacket struct */
    XUD_ParseSetupPacket(sbuffer, sp);

    for(int i = 0; i<120; i++)
        sbuffer[i] = 0xff;

    /* Inspect for recipent */
    switch(sp.bmRequestType.Recipient)
    {
        /* Recipient: Device */
        case BM_REQTYPE_RECIP_DEV:
          
            /* Inspect for request type */
            switch(sp.bmRequestType.Type)
            {
                /* Request Type: Standard Request */
                case BM_REQTYPE_TYPE_STANDARD:
        
                    /* Inspect for actual request */
                    switch(sp.bRequest)
                    {
#ifdef TEST_MODE_SUPPORT
                        /* Request: Set Feature */
                        case SET_FEATURE:

                            /* Check we have a test mode channel to XUD.. */
                            if(!isnull(c_usb_test))
                            {
                                if(sp.wValue == TEST_MODE)
                                {
                                    /* Inspect for Test Selector (high byte of wIndex, lower byte must be zero) */
                                    switch(sp.wIndex)
                                    {
                                        case WINDEX_TEST_J:
                                        case WINDEX_TEST_K:
                                        case WINDEX_TEST_SE0_NAK:         
                                        case WINDEX_TEST_PACKET:          
                                        case WINDEX_TEST_FORCE_ENABLE:    
                                            {
                                                int retVal;
                                                retVal = XUD_DoSetRequestStatus(c_in, 0);                                      
                                                if(retVal < 0)
                                                    return retVal;
                                                
                                                //printintln((unsigned)sp.wIndex);
                                                c_usb_test <: (unsigned)sp.wIndex;

                                            }
                                            break;

                                        default:
                                            /* Un-matched will fall through and end up at STALL */
                                            break;
                                    }
                                }
                            } 
                            break;
#endif           
                        /* Request: Get Descriptor */
                        case GET_DESCRIPTOR:
              
                            /* Inspect for which descriptor is required (high byte of wValue) */
                            switch(sp.wValue & 0xff00)
                            {
                                /* Device descriptor */
                                case WVALUE_GETDESC_DEV:              
              
                                    /* Do get request (send descriptor then 0 length status stage) */
                                    return XUD_DoGetRequest(c, c_in, devDesc, devDescLength, sp.wLength); 
                                    break;

                                /* Configuration Descriptor */
                                case WVALUE_GETDESC_CONFIG:
                   
                                    /* Do get request (send descriptor then 0 length status stage) */
				                    return XUD_DoGetRequest(c, c_in,  cfgDesc, cfgDescLength, sp.wLength); 
                                    break;

                                /* Device qualifier descriptor */
                                case WVALUE_GETDESC_DEVQUAL:
                                     
                                    /* Do get request (send descriptor then 0 length status stage) */
                                    return XUD_DoGetRequest(c, c_in, devQualDesc, devQualDescLength, sp.wLength); 
                                    break;

                                /* Other Speed Configiration Descriptor */
                                case WVALUE_GETDESC_OSPEED_CFG:
                                    return  XUD_DoGetRequest(c, c_in,  oSpeedCfgDesc, oSpeedCfgDescLength, sp.wLength);
                                    break;

             
                                /* String Descriptor */ 
                                case WVALUE_GETDESC_STRING:
 
                                    /* Set descriptor type */
                                    buffer[1] = STRING;

                                    /* Send the string that was requested (low byte of wValue) */
                                    /* First, generate valid descriptor from string */
                                    /* TODO Bounds check */
                                    stringID = sp.wValue & 0xff;

                                    /* Microsoft OS String special case, send product ID string */
                                    if ( sp.wValue == 0x03ee)
                                    {
                                        stringID = 2;
                                    }

                                    datalength = safestrlen(strDescs[ stringID ] );
                
                                    /* String 0 (LangIDs) is a special case*/ 
                                    if( stringID == 0 )
                                    {
                                        buffer[0] = datalength + 2;
                                        if( sp.wLength < datalength + 2 )
                                            datalength = sp.wLength - 2; 
                        
                                        for(int i = 0; i < datalength; i += 1 )
                                        {
                                            buffer[i+2] = strDescs[stringID][i];
                                        }
                                    }
                                    else
                                    { 
                                        /* Datalength *= 2 due to unicode */
                                        datalength <<= 1;
                      
                                        /* Set data length in descriptor (+2 due to 2 byte datalength)*/
                                        buffer[0] = datalength + 2;

                                        if(sp.wLength < datalength + 2)
                                            datalength = sp.wLength - 2; 
                        
                                        /* Add zero bytes for unicode.. */
                                        for(int i = 0; i < datalength; i+=2)
                                        {
                                            buffer[i+2] = strDescs[ stringID ][i>>1];
                                            buffer[i+3] = 0;
                                        }
                                       
                                    }
                                    
                                    /* Send back string */

                                    return XUD_DoGetRequest(c, c_in, buffer, datalength + 2, sp.wLength); 
                                    break;                
                                default:
                                    break;

                            }
                            break;

                        default:
                            break;

                    }
                    break;

                default:
                    break;
            }    
            break; 
     
        default:
            break;
    }
    }
#endif
    return 1;
}
