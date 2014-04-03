#include "Crc.h"

uint GenPid(uint pid)
{
	return ((~pid & 0xF) << 4) | (pid & 0xF);
}

uint GenCrc5_11(uint elevenBits)
{	
  static const uint intSize = 32;
  
  uint poly5 = 0x05 << (intSize - 5);
  uint crc5 = 0x1Fu << (intSize - 5);
  uint udata = elevenBits << (intSize - 11);    // crc over 11 bits
  int iBitcnt = 11;

  while (iBitcnt--)
  {
    if ((udata ^ crc5) & (0x1 << (intSize - 1)))   // bit4 != bit4?
    {
      crc5 <<= 1;
      crc5 ^= poly5;
    }
    else
    {
      crc5 <<= 1;
    }
    udata <<= 1;
  }

  // Shift back into position
  crc5 >>= intSize - 5;

  // Invert contents to generate crc field
  crc5 ^= 0x1f;

  return crc5;
}

uint bitrev(uint x)
{
  int y = 0;
  for (int i = 0; i < 32; i++)
  {
    y <<= 1;
    y |= (x & 1);
    x >>= 1;
  }
  return y;
}

uint GenCrc16(const unsigned char *data, int bytesNum)
{
  uint topBit;
  uint crc = 0xffff;
  uint poly = 0x8005;
  uint d;  

  //printf("crc gen data: ");
  for (int i = 0; i < bytesNum; i++)
  {
    d = data[i];
	//printf("%02x ", d);
	topBit = 1 << 15;
    crc ^= reflect(d & 0xFF, 8) << 8;  // REFIN
    for (uint k = 0; k < 8; k++)
    {
      if (crc & topBit)
        crc = (crc << 1) ^ poly;
      else
        crc <<= 1;
    }
  }
  //printf("\n");

  //crc = crc ^0xffff;
  crc = reflect(crc,16);
  crc = ~crc;
  crc = crc & 0xffff;
  //printf("crc: %04x\n", crc);
  return crc;
}

uint reflect(uint val, int numBits)
{
	uint valRef = 0;
	for (int i = 0; i < numBits; i++)
	{
		valRef <<= 1;
		
		if (val & 1)
			valRef |= 1;
		
		val >>= 1;
	}
	return valRef;
}
