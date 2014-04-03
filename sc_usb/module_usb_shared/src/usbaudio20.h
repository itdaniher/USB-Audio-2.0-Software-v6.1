/**
 * Module:  module_usb_shared
 * Version: 1v15
 * Build:   5f54bab9944b48e1ccf265e572562e2be9746401
 * File:    usbaudio20.h
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
 * @file       usbaudio20.h
 * @brief      Defines from the USB Audio 2.0 Specifications 
 * @author     Ross Owen, XMOS Limited
 * @version    0.9
 */ 

#include "usb.h"

/***********************************************************************/
/* USB Audio 2.0 Class Specification */

/* A.1 Audio Function Class Code */
#define AUDIO_FUNCTION              AUDIO

/* A.2 Audio Function Subclass Codes */
#define FUNCTION_SUBCLASS_UNDEFINED 0x00

/* A.3 Audio Function Protocol Codes */
#define FUNCTION_PROTOCOL_UNDEFINED 0x00
#define AF_VERSION_02_00            IP_VERSION_02_00

/* A.4 Audio Interface Class Code */
#define AUDIO                       0x01

/* A.5 Audio Interface Subclass Codes */
#define AUDIOCONTROL                0x01
#define AUDIOSTREAMING              0x02
#define MIDISTREAMING               0x03

/* A.6 Audo Interface Protocol Codes */
#define IP_VERSION_02_00            0x20

/* A.7 Audio Function Category Codes */
#define FUNCTION_SUBCLASS_UNDEFINED 0x00
#define DESKTOP_SPEAKER             0x01
#define HOME_THEATER                0x02
#define MICROPHONE                  0x03
#define HEADSET                     0x04
#define TELEPHONE                   0x05
#define CONVERTER                   0x06
#define VOICE_SOUND_RECORDER        0x07
#define IO_BOX                      0x08
#define MUSICAL_INTRUMENT           0x09
#define PRO_AUDIO                   0x0A
#define AUDIO_VIDEO                 0x0B
#define CONTROL_PANEL               0x0C
#define OTHER                       0xFF

/* A.8 Audio Class-Specific Descriptor Types */
#define CS_UNDEFINED                0x20
#define CS_DEVICE                   0x21
#define CS_CONFIGURATION            0x22
#define CS_STRING                   0x23
#define CS_INTERFACE                0x24
#define CS_ENDPOINT                 0x25

/* A.9 Audio Class-Specific AC Interface Descriptor Subtypes */
#define AC_DESCRIPTOR_UNDEFINED     0x00
#define HEADER                      0x01
#define INPUT_TERMINAL              0x02
#define OUTPUT_TERMINAL             0x03
#define MIXER_UNIT                  0x04
#define SELECTOR_UNIT               0x05
#define FEATURE_UNIT                0x06
#define EFFECT_UNIT                 0x07
#define PROCESSING_UNIT             0x08
#define EXTENSION_UNIT              0x09
#define CLOCK_SOURCE                0x0A
#define CLOCK_SELECTOR              0x0B
#define CLOCK_MULTIPLIER            0x0C
#define SAMPLE_RATE_CONVERTER       0x0D

/* A.10 Audio Class Specific AS Interface Descriptor Subtypes */
#define AS_DESCRIPTOR_UNDEFINED     0x00
#define AS_GENERAL                  0x01
#define FORMAT_TYPE                 0x02
#define ENCODER                     0x03
#define DECODER                     0x04

/* A.11 Effect Unit Effect Types */
#define EFFECT_UNDEFINED            0x00
#define PARAM_EQ_SECTION_EFFECT     0x01
#define REVERBERATION_EFFECT        0x02
#define MOD_DELAY_EFFECT            0x03
#define DYN_RANGE_COMP_EFFECT       0x04

/* A.12 Processing Unit Process Types */
#define PROCESS_UNDEFINED           0x00
#define UP_DOWNMIX_PROCESS          0x01
#define DOLBY_PROLOGIC_PROCESS      0x02
#define STEREO_EXTENDER_PROCESS     0x03

/* A.13 Audio Class-Specific Endpoint Descriptor Subtypes */
#define DESCRIPTOR_UNDEFINED        0x00
#define EP_GENERAL                  0x01

/* A.14 Audio Class-Specific Request Codes */
#define REQUEST_CODE_UNDEFINED      0x00
#define CUR                         0x01
#define RANGE                       0x02
#define MEM                         0x03

/* A.15 Encoder Type Codes */
#define ENCODER_UNDEFINED           0x00
#define OTHER_ENCODER               0x01
#define MPEG_ENCODER                0x02
#define AC_3_ENCODER                0x03
#define WMA_ENCODER                 0x04
#define DTS_ENCODER                 0x05

/* A.17 Control Selector Codes */
/* A.17.1 Clock Source Control Selectors */
#define CS_CONTROL_UNDEFINED        0x00
#define CS_SAM_FREQ_CONTROL         0x01
#define CS_CLOCK_VALID_CONTROL      0x02

/* A.17.2 Clock Selector Control Selectors */
#define CX_CONTROL_UNDEFINED        0x00
#define CX_CLOCK_SELECTOR_CONTROL   0x01

/* A.17.7 Feature Unit Control Selectors */
#define FU_CONTROL_UNDEFINED        0x00
#define FU_MUTE_CONTROL             0x01
#define FU_VOLUME_CONTROL           0x02

/* A.17.11 Audio Streaming Interface Control Selectors */
#define AS_CONTROL_UNDEFINED        0x00
#define AS_ACT_ALT_SETTING_CONTROL  0x01
#define AS_VAL_ALT_SETTINGS_CONTROL 0x02
#define AS_AUDIO_DATA_FORMAT_CONTROL 0x03

/* Audio Class-Specific Descriptor Types */
#define CS_INTERFACE                0x24
#define CS_ENDPOINT                 0x25


/* Audio Class-Specific AS Interface Descriptor Subtypes */
#define FORMAT_TYPE                 0x02


/***********************************************************************/
/* Universal Serial Bus Device Class Definition for Audio Data Formats */

/* A.1 Format Type Codes */
#define FORMAT_TYPE_UNDEFINED       0x00
#define FORMAT_TYPE_I               0x01
#define FORMAT_TYPE_II              0x02
#define FORMAT_TYPE_III             0x03
#define FORMAT_TYPE_IV              0x04
#define EXT_FORMAT_TYPE_I           0x81
#define EXT_FORMAT_TYPE_II          0x82
#define EXT_FORMAT_TYPE_III         0x83

/* A.3 Side Band Protocol Codes */
#define PROTOCOL_UNDEFINED          0x00
#define PRESS_TIMESTAMP_PROTOCOL    0x01


/***********************************************************************/
/* Univeral Serial Bus  Device Class Definition for Terminal Types */

/* 2.1 USB Terminal Types */
/* Terminal Types that describe Terminals that handle signals carried over USB */
#define USB_UNDEFINED				0x0100
#define USB_STREAMING               0x0101
#define USB_VENDOR_SPECIFIC         0x01FF

/* 2.2 Input Terminal Types */
/* Terminal Types that describe Terminals that are designed to record sounds */
#define INPUT_UDEFINED				0x0200
#define MICROPHONE_					0x0201
#define DESKTOP_MICROPHONE			0x0202
#define PERSONAL_MICROPHONE			0x0203
#define OMNIDIRECTIONAL_MICROPHONE	0x0204
#define MICROPHONE_ARRAY			0x0205
#define PROCESSING_MICROPHONE_ARRAY 0x0206

/* 2.3 Output Terminal Types */
/* These Terminal Types describe Terminals that produce audible signals that are intended to 
 * be heard by the user of the audio function */
#define SPEAKER						0x0301
#define HEADPHONES					0x0302
#define HEAD_MOUNTED_DISPLAY		0x0303
#define DESKTOPSPEAKER				0x0304
#define ROOM_SPEAKER				0x0305
#define COMMUNICATION_SPEAKER		0x0306
#define LOW_FREQ_EFFECTS_SPEAKER	0x0307


#define FORMAT_TYPE_I               0x01

/* A.2 AudioData Format Bit Allocation in the bmFormats field */
/* A.2.1 Audio Data Format Type I Bit Allocations */
#define PCM                         0x01
#define PCM8                        0x02
#define IEEE_FLOAT                  0x04
