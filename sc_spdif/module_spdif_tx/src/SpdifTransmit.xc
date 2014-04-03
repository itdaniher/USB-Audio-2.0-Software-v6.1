// Copyright (c) 2011, XMOS Ltd, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/** 
 * @file    SpditTransmit.xc
 * @brief   S/PDIF line transmitter 
 * @author  XMOS Semiconductor 
 *
 * Uses a master clock to output S/PDIF encoded samples.
 * This implementation uses a lookup table to generate S/PDIF encoded data stream from raw audio samples.
 */

#include <xs1.h>
#include <xclib.h>
#include <print.h>

#define	VALIDITY 		0x00000000		/* Validity bit (x<<28) */

void SpdifTransmitPortConfig(out buffered port:32 p, clock clk, in port p_mclk)
{
    /* Clock clock block from master-clock */
    configure_clock_src(clk, p_mclk);
    
    /* Clock S/PDIF tx port from MClk */
    configure_out_port_no_ready(p, clk, 0);
  
    /* Set delay to align SPDIF output to the clock at the external flop */
    set_clock_fall_delay(clk, 7);
   
    /* Start the clockblock ticking */ 
    start_clock(clk);  
}



/* Returns parity for a given word */
static int inline parity32(unsigned x)
{
    crc32(x, 0, 1);
    return (x & 1);
}

unsigned dataWords_1_Nibble[16] = {
    0x33,
    0xCD,
    0xCB,
    0x35,
    0xD3,
    0x2D,
    0x2B,
    0xD5,
    0xB3,
    0x4D,
    0x4B,
    0xB5,
    0x53,
    0xAD,
    0xAB,
    0x55
};    
      
unsigned dataWords_1[256] = {
    0x3333,
    0xCCCD,
    0xCCCB,
    0x3335,
    0xCCD3,
    0x332D,
    0x332B,
    0xCCD5,
    0xCCB3,
    0x334D,
    0x334B,
    0xCCB5,
    0x3353,
    0xCCAD,
    0xCCAB,
    0x3355,
    0xCD33,
    0x32CD,
    0x32CB,
    0xCD35,
    0x32D3,
    0xCD2D,
    0xCD2B,
    0x32D5,
    0x32B3,
    0xCD4D,
    0xCD4B,
    0x32B5,
    0xCD53,
    0x32AD,
    0x32AB,
    0xCD55,
    0xCB33,
    0x34CD,
    0x34CB,
    0xCB35,
    0x34D3,
    0xCB2D,
    0xCB2B,
    0x34D5,
    0x34B3,
    0xCB4D,
    0xCB4B,
    0x34B5,
    0xCB53,
    0x34AD,
    0x34AB,
    0xCB55,
    0x3533,
    0xCACD,
    0xCACB,
    0x3535,
    0xCAD3,
    0x352D,
    0x352B,
    0xCAD5,
    0xCAB3,
    0x354D,
    0x354B,
    0xCAB5,
    0x3553,
    0xCAAD,
    0xCAAB,
    0x3555,
    0xD333,
    0x2CCD,
    0x2CCB,
    0xD335,
    0x2CD3,
    0xD32D,
    0xD32B,
    0x2CD5,
    0x2CB3,
    0xD34D,
    0xD34B,
    0x2CB5,
    0xD353,
    0x2CAD,
    0x2CAB,
    0xD355,
    0x2D33,
    0xD2CD,
    0xD2CB,
    0x2D35,
    0xD2D3,
    0x2D2D,
    0x2D2B,
    0xD2D5,
    0xD2B3,
    0x2D4D,
    0x2D4B,
    0xD2B5,
    0x2D53,
    0xD2AD,
    0xD2AB,
    0x2D55,
    0x2B33,
    0xD4CD,
    0xD4CB,
    0x2B35,
    0xD4D3,
    0x2B2D,
    0x2B2B,
    0xD4D5,
    0xD4B3,
    0x2B4D,
    0x2B4B,
    0xD4B5,
    0x2B53,
    0xD4AD,
    0xD4AB,
    0x2B55,
    0xD533,
    0x2ACD,
    0x2ACB,
    0xD535,
    0x2AD3,
    0xD52D,
    0xD52B,
    0x2AD5,
    0x2AB3,
    0xD54D,
    0xD54B,
    0x2AB5,
    0xD553,
    0x2AAD,
    0x2AAB,
    0xD555,
    0xB333,
    0x4CCD,
    0x4CCB,
    0xB335,
    0x4CD3,
    0xB32D,
    0xB32B,
    0x4CD5,
    0x4CB3,
    0xB34D,
    0xB34B,
    0x4CB5,
    0xB353,
    0x4CAD,
    0x4CAB,
    0xB355,
    0x4D33,
    0xB2CD,
    0xB2CB,
    0x4D35,
    0xB2D3,
    0x4D2D,
    0x4D2B,
    0xB2D5,
    0xB2B3,
    0x4D4D,
    0x4D4B,
    0xB2B5,
    0x4D53,
    0xB2AD,
    0xB2AB,
    0x4D55,
    0x4B33,
    0xB4CD,
    0xB4CB,
    0x4B35,
    0xB4D3,
    0x4B2D,
    0x4B2B,
    0xB4D5,
    0xB4B3,
    0x4B4D,
    0x4B4B,
    0xB4B5,
    0x4B53,
    0xB4AD,
    0xB4AB,
    0x4B55,
    0xB533,
    0x4ACD,
    0x4ACB,
    0xB535,
    0x4AD3,
    0xB52D,
    0xB52B,
    0x4AD5,
    0x4AB3,
    0xB54D,
    0xB54B,
    0x4AB5,
    0xB553,
    0x4AAD,
    0x4AAB,
    0xB555,
    0x5333,
    0xACCD,
    0xACCB,
    0x5335,
    0xACD3,
    0x532D,
    0x532B,
    0xACD5,
    0xACB3,
    0x534D,
    0x534B,
    0xACB5,
    0x5353,
    0xACAD,
    0xACAB,
    0x5355,
    0xAD33,
    0x52CD,
    0x52CB,
    0xAD35,
    0x52D3,
    0xAD2D,
    0xAD2B,
    0x52D5,
    0x52B3,
    0xAD4D,
    0xAD4B,
    0x52B5,
    0xAD53,
    0x52AD,
    0x52AB,
    0xAD55,
    0xAB33,
    0x54CD,
    0x54CB,
    0xAB35,
    0x54D3,
    0xAB2D,
    0xAB2B,
    0x54D5,
    0x54B3,
    0xAB4D,
    0xAB4B,
    0x54B5,
    0xAB53,
    0x54AD,
    0x54AB,
    0xAB55,
    0x5533,
    0xAACD,
    0xAACB,
    0x5535,
    0xAAD3,
    0x552D,
    0x552B,
    0xAAD5,
    0xAAB3,
    0x554D,
    0x554B,
    0xAAB5,
    0x5553,
    0xAAAD,
    0xAAAB,
    0x5555,
};

unsigned preableWords_1[3] = {
    0x47, 0x27, 0x17
};


unsigned dataWords_2[16] = {
  0x0F0F,           
  0xF0F3,           
  0xF0CF,           
  0x0F33,           
  0xF30F,           
  0x0CF3,           
  0x0CCF,           
  0xF333,           
  0xCF0F,           
  0x30F3,           
  0x30CF,           
  0xCF33,           
  0x330F,           
  0xCCF3,           
  0xCCCF,           
  0x3333            
};

unsigned preableWords_2[3] = {
    0x303F, 0x0C3F, 0x033F
};


unsigned dataWords_4[32] = {
    0x00FF, 0x00FF,
    0xFF00, 0xFF0F,
    0xFF00, 0xF0FF,
    0x00FF, 0x0F0F,
    0xFF0F, 0x00FF,
    0x00F0, 0xFF0F,
    0x00F0, 0xF0FF,
    0xFF0F, 0x0F0F,
    0xF0FF, 0x00FF,
    0x0F00, 0xFF0F,
    0x0F00, 0xF0FF,
    0xF0FF, 0x0F0F,
    0x0F0F, 0x00FF,
    0xF0F0, 0xFF0F,
    0xF0F0, 0xF0FF,
    0x0F0F, 0x0F0F
};

unsigned preambleWords_4[6] = {
    0x0F00, 0x0FFF,
    0x00F0, 0x0FFF,
    0x000F, 0x0FFF
};




/* E.g. 24MHz -> 192kHz */
void SpdifTransmit_1(out buffered port:32 p, chanend c_tx0, const int ctrl_left[2], const int ctrl_right[2])
{
    unsigned word;
    unsigned xor = 0;
    unsigned encoded_preamble, encoded_word;

    unsigned sample, sample2, control, preamble, parity;
  
    /* Check for new frequency */
    if (testct(c_tx0)) 
    {    
        chkct(c_tx0, XS1_CT_END);
        return;
    }
  
    /* Get L/R samples */
    sample = inuint(c_tx0) >> 4 & 0x0FFFFFF0 ;
    sample2 = inuint(c_tx0);

#pragma unsafe arrays
    while (1) 
    {
        int controlLeft  = ctrl_left[0];
        int controlRight = ctrl_right[0];
        int newblock = 2;
        
        for (int i = 0 ; i < 192; i++) 
        {
        
            /* Left sample */
            control = (controlLeft & 1) << 30;
            preamble = newblock ;
            parity = parity32(sample | control | VALIDITY) << 31;
            word = preamble | sample | control | parity | VALIDITY;

            /* Preamble */
            encoded_preamble = preableWords_1[word & 0xF];
            encoded_preamble ^= xor;
            partout(p, 8, encoded_preamble);
            xor = __builtin_sext(encoded_preamble, 8) >> 8;     /* xor = 0xFFFFFFFF * ((encoded_preamble & 0x8000) == 0x8000); */
                                                                /* Replace with sext(encoded_word,1) */
            word = word >> 4;

            /* Lookup remaining 28 bits, 8/4 bits at a time */
            encoded_word = dataWords_1[word & 0xFF];
            encoded_word ^= xor;                                /* Xor to invert data if lsab of last data was a 1 */
            partout(p, 16, encoded_word);
            xor = __builtin_sext(encoded_word, 16) >> 16;       /* xor = 0xFFFFFFFF * (encoded_word < 0);  */
                                                                /* Replace with sext(encoded_word,1) */
            word = word >> 8;

            newblock = 0;
            controlLeft >>=1;

            encoded_word = dataWords_1[word & 0xFF];
            encoded_word ^= xor;                                /* Xor to invert data if lsab of last data was a 1 */
            partout(p, 16, encoded_word);
            xor = __builtin_sext(encoded_word, 16) >> 16;       /* xor = 0xFFFFFFFF * (encoded_word < 0);  */
                                                                /* Replace with sext(encoded_word,1) */
            word = word >> 8;

            encoded_word = dataWords_1_Nibble[word & 0xF];
            encoded_word ^= xor;                                /* Xor to invert data if lsab of last data was a 1 */
            partout(p, 8, encoded_word);
            xor = __builtin_sext(encoded_word, 8) >> 8;         /* xor = 0xFFFFFFFF * ((encoded_word & 0x8000) != 0);  */
                                                                /* Replace with sext(encoded_word,1) */
            word = word >> 4;

            sample = sample2 >> 4 & 0x0FFFFFF0 ;
          
            encoded_word = dataWords_1[word & 0xFF];
            encoded_word ^= xor;                                /* Xor to invert data if lsab of last data was a 1 */
            partout(p, 16, encoded_word);
            xor = __builtin_sext(encoded_word, 16) >> 16;       /* xor = 0xFFFFFFFF * (encoded_word < 0);  */
                                                                /* Replace with sext(encoded_word,1) */

            /* Right sample */
          
            control = (controlRight & 1)<<30;
            preamble = (1);
            parity = parity32(sample | control | VALIDITY) << 31;
            word = preamble | sample | control | parity | VALIDITY;


            /* Preamble */
            encoded_preamble = preableWords_1[word & 0xF];
            encoded_preamble ^= xor;
            partout(p, 8, encoded_preamble);
            xor = __builtin_sext(encoded_preamble, 8) >> 8;     /* xor = 0xFFFFFFFF * ((encoded_preamble & 0x8000) == 0x8000);  */
                                                                /* Replace with sext(encoded_word,1) */
            word = word >> 4;

            /* Lookup remaining 28 bits, 8/4 bits at a time */
            encoded_word = dataWords_1[word & 0xFF];
            encoded_word ^= xor;                                /* Xor to invert data if lsab of last data was a 1 */
            partout(p, 16, encoded_word);
            xor = __builtin_sext(encoded_word, 16) >> 16;       /* xor = 0xFFFFFFFF * (encoded_word < 0);  */
                                                                /* Replace with sext(encoded_word,1) */
            word = word >> 8;

            encoded_word = dataWords_1[word & 0xFF];
            encoded_word ^= xor;                                /* Xor to invert data if lsab of last data was a 1 */
            partout(p, 16, encoded_word);
            xor = __builtin_sext(encoded_word, 16) >> 16;       /* xor = 0xFFFFFFFF * (encoded_word < 0); */ 
                                                                /* Replace with sext(encoded_word,1) */
            word = word >> 8;

            controlRight >>=1;
          
            encoded_word = dataWords_1_Nibble[word & 0xF];
            encoded_word ^= xor;                                /* Xor to invert data if lsab of last data was a 1 */
            partout(p, 8, encoded_word);
            xor = __builtin_sext(encoded_word, 8) >> 8;         /* xor = 0xFFFFFFFF * ((encoded_word & 0x8000) != 0); */ 
                                                                /* Replace with sext(encoded_word,1) */
            word = word >> 4;

            /* Test for new frequency */
            if (testct(c_tx0)) 
            {
                chkct(c_tx0, XS1_CT_END);
                return;
            }
            
            /* Get new samples... */
            sample = inuint(c_tx0) >> 4 & 0x0FFFFFF0 ;
            sample2 = inuint(c_tx0);
          
            encoded_word = dataWords_1[word & 0xFF];
            encoded_word ^= xor;                                /* Xor to invert data if lsab of last data was a 1 */
            partout(p, 16, encoded_word);
            xor = __builtin_sext(encoded_word, 16) >> 16;       /* xor = 0xFFFFFFFF * (encoded_word < 0);  */
                                                                /* Replace with sext(encoded_word,1) */
            if (i == 31) {
                controlLeft = ctrl_left[1];
                controlRight = ctrl_right[1];
            }
        }
    }
}

/* Divide by 2, e.g 24 -> 96khz */
void SpdifTransmit_2(out buffered port:32 p, chanend c_tx0, const int ctrl_left[2], const int ctrl_right[2])
{
    unsigned word;
    unsigned xor = 0;
    unsigned encoded_preamble, encoded_byte;

    unsigned sample, sample2, control, preamble, parity;
  
    clearbuf(p);
  
#pragma unsafe arrays
    while (1) 
    {
        int controlLeft  = ctrl_left[0];
        int controlRight = ctrl_right[0];
        int newblock = 2;
        
        for (int i = 0; i < 192; i++) 
        {
            /* Check for new frequency */
            if (testct(c_tx0))
            {
                chkct(c_tx0, XS1_CT_END);
                return;
            }

            /* Input samples */
            sample = inuint(c_tx0) >> 4 & 0x0FFFFFF0 ;
            sample2 = inuint(c_tx0);
          
            control = (controlLeft & 1)<<30;
            preamble = newblock ;
            parity = parity32(sample | control | VALIDITY) << 31;
            word = preamble | sample | control | parity | VALIDITY;

            /* Output left sample */
          
            /* Preamble */
            encoded_preamble = preableWords_2[word & 0xF];
            encoded_preamble ^= xor;
            partout(p, 16, encoded_preamble);
            xor = __builtin_sext(encoded_preamble, 16) >> 16;         
            word = word >> 4;

            newblock = 0;
            controlLeft >>=1;
          
            /* Lookup remaining 28 bits, 4 bits at a time */
#pragma unsafe arrays
#pragma loop unroll(7)
            for (int i = 0; i < 7; i++)
            {
                encoded_byte = dataWords_2[word & 0xF];
                encoded_byte ^= xor;  /* Xor to invert data if lsab of last data was a 1 */
                partout(p, 16, encoded_byte);
                xor = __builtin_sext(encoded_byte, 16) >> 16;         
                word = word >> 4;
            }       
           
            sample = sample2 >> 4 & 0x0FFFFFF0 ;
          
            control = (controlRight & 1)<<30;
            preamble = (1);
            parity = parity32(sample | control | VALIDITY) << 31;
            word = preamble | sample | control | parity | VALIDITY;

            /* Output right sample */

            /* Preamble */
            encoded_preamble = preableWords_2[word & 0xF];
            encoded_preamble ^= xor;
            partout(p, 16, encoded_preamble);
            xor = __builtin_sext(encoded_preamble, 16) >> 16;         
            word = word >> 4;

            controlRight >>=1;
          
            /* Lookup remaining 28 bits, 4 bits at a time */
#pragma unsafe arrays
#pragma loop unroll(7)
            for (int i = 0; i < 7; i++)
            {
                encoded_byte = dataWords_2[word & 0xF];
                encoded_byte ^= xor;  // Xor to invert data if lsab of last data was a 1
                partout(p, 16, encoded_byte);
                xor = __builtin_sext(encoded_byte, 16) >> 16;         
                word = word >> 4;
            }          

            if (i == 31) {
                controlLeft = ctrl_left[1];
                controlRight = ctrl_right[1];
            }
        }
    }
}



/* Divide by 4, e.g 24 -> 48khz */
void SpdifTransmit_4(buffered out port:32 p, chanend c_tx0, const int ctrl_left[2], const int ctrl_right[2])
{
    unsigned word;
    unsigned xor = 0;
    unsigned encoded_preamble, encoded_byte;

    unsigned sample, control, preamble, parity, sample2;
  
    clearbuf(p);
  
#pragma unsafe arrays
    while (1) 
    {
        int controlLeft  = ctrl_left[0];
        int controlRight = ctrl_right[0];
        int newblock = 2;
      
        for (int i = 0 ; i<192; i++) 
        {
            /* Check for new sample frequency */ 
            if (testct(c_tx0)) 
            {
                /* Swallow control token and return */   
                chkct(c_tx0, XS1_CT_END);
                return;
            }

            /* Input left and right samples */
            sample = inuint(c_tx0) >> 4 & 0x0FFFFFF0 ;
            sample2 = inuint(c_tx0);
          
            /* Create status bit */
            control = (controlLeft & 1) << 30;
            preamble = newblock ;

            /* Generate parity bit */
            parity = parity32(sample | control | VALIDITY) << 31;
            
            /* Generate complete 32bit word */ 
            word = preamble | sample | control | parity | VALIDITY;
          
            /* Output left sample */

            /* Look up preamble and output */
            encoded_preamble = preambleWords_4[(word & 0xF)*2+1];
            encoded_preamble ^= xor;
            partout(p, 16, encoded_preamble);
            
            encoded_preamble = preambleWords_4[(word & 0xF)*2];
            encoded_preamble ^= xor;
            partout(p, 16, encoded_preamble);
            xor = __builtin_sext(encoded_preamble, 16) >> 16;         
            word = word >> 4;

            newblock = 0;
            controlLeft >>=1;
          
            /* Lookup remaining 28 bits, 4 bits at a time */
#pragma unsafe arrays
#pragma loop unroll(7)    
            for (int i = 0; i < 7; i++)
            {
                encoded_byte = dataWords_4[(word & 0xF)*2+1];
                encoded_byte ^= xor;  /* Xor to invert data if lsab of last data was a 1 */
                partout(p, 16, encoded_byte);
                encoded_byte = dataWords_4[(word & 0xF) * 2];  
                encoded_byte ^= xor;  /* Xor to invert data if lsab of last data was a 1 */
                partout(p, 16, encoded_byte);
                xor = __builtin_sext(encoded_byte, 16) >> 16;         
                word = word >> 4;
            }

            sample = sample2 >> 4 & 0x0FFFFFF0 ;

            /*  Output right sample */
          
            control = (controlRight & 1)<<30;
            preamble = (1);
            parity = parity32(sample | control | VALIDITY) << 31;
            word = preamble | sample | control | parity | VALIDITY;
          
            /* Look up and output pre-amble, 2 bytes at a time */
            encoded_preamble = preambleWords_4[(word & 0xF)*2+1];
            encoded_preamble ^= xor;
            partout(p, 16, encoded_preamble);

            encoded_preamble = preambleWords_4[(word & 0xF)*2];
            encoded_preamble ^= xor;
            partout(p, 16, encoded_preamble);
            xor = __builtin_sext(encoded_preamble, 16) >> 16;        
            word = word >> 4;

            controlRight >>=1;
          
          
            /* Lookup remaining 28 bits, 4 bits at a time */
#pragma unsafe arrays
#pragma loop unroll(7)    
            for (int i = 0; i < 7; i++)
            {
                encoded_byte = dataWords_4[(word & 0xF)*2+1];
                encoded_byte ^= xor;  /* Xor to invert data if lsab of last data was a 1 */
                partout(p, 16, encoded_byte);
                encoded_byte = dataWords_4[(word & 0xF) * 2];
                encoded_byte ^= xor;  /* Xor to invert data if lsab of last data was a 1 */
                xor = __builtin_sext(encoded_byte, 16) >> 16;        
                word = word >> 4;
                partout(p, 16, encoded_byte);
            }

            if (i == 31) {
                controlLeft = ctrl_left[1];
                controlRight = ctrl_right[1];
            }
        }
    }
}


void SpdifTransmitError(chanend c_in)
{

#if 0
    printstr("Sample Frequency and Master Clock Frequency combination not supported\n");
#endif
    
    while(1)
    {
        /* Keep swallowing samples until we get a sample frequency change */
        if (testct(c_in)) 
        {    
            chkct(c_in, XS1_CT_END);
            return;
        }
        
        inuint(c_in);
        inuint(c_in);
    }
}

/* Defines for building channel status words */
#define CHAN_STAT_L        0x00107A04
#define CHAN_STAT_R        0x00207A04

#define CHAN_STAT_44100    0x00000000
#define CHAN_STAT_48000    0x02000000
#define CHAN_STAT_88200    0x08000000
#define CHAN_STAT_96000    0x0A000000
#define CHAN_STAT_176400   0x0C000000
#define CHAN_STAT_192000   0x0E000000

#define CHAN_STAT_WORD_2   0x0000000B


/* S/PDIF transmit thread */
void SpdifTransmit(buffered out port:32 p, chanend c_in)
{
    int chanStat_L[2], chanStat_R[2];
    unsigned divide;

    /* Receive sample frequency over channel (in Hz) */
    unsigned  samFreq = inuint(c_in);

    /* Receive master clock frequency over channel (in Hz) */
    unsigned  mclkFreq = inuint(c_in);

    /* Create channel status words based on sample freq */
    switch(samFreq)
    {
        case 44100:
            chanStat_L[0] = CHAN_STAT_L | CHAN_STAT_44100;
            chanStat_R[0] = CHAN_STAT_R | CHAN_STAT_44100;
            break;

        case 48000:
            chanStat_L[0] = CHAN_STAT_L | CHAN_STAT_48000;
            chanStat_R[0] = CHAN_STAT_R | CHAN_STAT_48000;
            break;

        case 88200:
            chanStat_L[0] = CHAN_STAT_L | CHAN_STAT_88200;
            chanStat_R[0] = CHAN_STAT_R | CHAN_STAT_88200;
            break;
            
        case 96000:
            chanStat_L[0] = CHAN_STAT_L | CHAN_STAT_96000;
            chanStat_R[0] = CHAN_STAT_R | CHAN_STAT_96000;
            break;

        case 176400:
            chanStat_L[0] = CHAN_STAT_L | CHAN_STAT_176400;
            chanStat_R[0] = CHAN_STAT_R | CHAN_STAT_176400;
            break;

        case 192000:
            chanStat_L[0] = CHAN_STAT_L | CHAN_STAT_192000;
            chanStat_R[0] = CHAN_STAT_R | CHAN_STAT_192000;
            break;

        default:
            /* Sample frequency not recognised.. carry on for now... */
            chanStat_L[0] = CHAN_STAT_L;
            chanStat_R[0] = CHAN_STAT_R;
            break;
             
    }
    chanStat_L[1] = CHAN_STAT_WORD_2;
    chanStat_R[1] = CHAN_STAT_WORD_2;

    /* Calculate required divide */
    divide = mclkFreq / (samFreq * 2 * 32 * 2);

    switch(divide)
    {
        case 1:
            /* Highest sample freq supported by mclk freq, eg: 24 -> 192 */
            SpdifTransmit_1(p,  c_in, chanStat_L, chanStat_R);
            break;

        case 2:
            /* E.g. 24 -> 96 */
           SpdifTransmit_2(p, c_in, chanStat_L, chanStat_R);
           break;

        case 4:
            /* E.g. 24MHz -> 48kHz */
            SpdifTransmit_4(p, c_in, chanStat_L, chanStat_R);
            break;

        default:
            /* Mclk does not support required sample freq */
            SpdifTransmitError(c_in);
            break;
    }
}


