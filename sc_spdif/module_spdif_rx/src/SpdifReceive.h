// Copyright (c) 2011, XMOS Ltd, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

#ifndef _SpdifReceive_h_
#define _SpdifReceive_h_
#include <xs1.h>

/** This constant defines the four least-significant bits of the first
 * sample of a frame (typically a sample from the left channel)
 */
#define FRAME_X 9

/** This constant defines the four least-significant bits of the second or
 * later sample of a frame (typically a sample from the right channel,
 * unless there are more than two channels)
 */
#define FRAME_Y 5

/** This constant defines the four least-significant bits of the first
 * sample of the first frame of a block (typically a sample from the left
 * channel)
 */
#define FRAME_Z 3


/** S/PDIF receive function. 
 *
 * This function needs 1 thread and no memory other
 * than ~2800 bytes of program code. It can do 11025, 12000, 22050, 24000,
 * 44100, 48000, 88200, 96000, and 192000 Hz.
 * When the decoder
 * encounters a long series of zeros it will lower the divider; when it
 * encounters a short series of 0-1 transitions it will increase the divider.
 *
 * Output: the received 24-bit sample values are output as a word on the
 * streaming channel end. Each value is shifted up by 4-bits with the
 * bottom four bits being one of FRAME_X, FRAME_Y, or FRAME_Z. The bottom
 * four bits should be removed whereupon the sample value should be sign
 * extended.
 *
 * The function does not return unless compiled with TEST defined in which case it returns any
 * time that it loses synchronisation.
 *
 * \param p               S/PDIF input port. This port must be 4-bit buffered,
 *                        declared as ``in buffered port:4``
 *
 * \param c               channel to output samples to
 *
 * \param initial_divider initial divide for initial estimate of sample rate
 *                        For a 100Mhz reference clock, use an initial divider
 *                        of 1 for 192000, 2 for 96000/88200, and 4 for 48000/44100.
 *
 * \param clk             clock block sourced from the 100 MHz reference clock.
 *
 **/
void SpdifReceive(in buffered port:4 p, streaming chanend c, int initial_divider, clock clk);

#endif // _SpdifReceive_h_
