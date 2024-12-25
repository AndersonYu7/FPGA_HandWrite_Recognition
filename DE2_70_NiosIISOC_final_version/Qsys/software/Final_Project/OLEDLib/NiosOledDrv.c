/*
 *  NiosOledDrv.c
 *  ���{���D�n�O����Nios�B�z���h�X��SSD1306 OLED��ܾ���ܡC
 *  Created on: 2022/9/15
 *      Author: lishyhan
 */


#include <io.h>
#include <system.h>
#include <stdio.h>
#include "NiosOledDrv.h"


/* drawPixel on screen */
void drawPixel(tAdafruit_GFX *psInst, int16_t x, int16_t y,	uint32_t color){
	int16_t tmp;
  if(psInst->rotation == 1){/*Rotate 90 degrees clockwise */
	  tmp = x;
	  x=y;
	  y=tmp;
	  y = psInst->_height - y;
  }

	// Clip first...
  if ((x >= 0) && (x < psInst->_width) && (y >= 0) && (y < psInst->_height)) {
#ifdef LTM_MM_IF_BASE
	// THEN set up transaction (if needed) and draw...
    psInst->buffer[ y*psInst->WIDTH + x] = color;
  }
#endif
  else{
	  printf("Picture exceeds screen borders.\n");
  }
}

void OLED_Set_Pos(unsigned char x, unsigned char y)
/* x is width pixel */
/* y is page number */
{

}


/* Open OLED Display */
void OLED_Display_On(void)
{

}
/* close OLED Display */
void OLED_Display_Off(void)
{

}
/* �M�ù����, �M���ù�,��ӿù��O�¦⪺!�M�S�I�G�@��!! */
void OLED_Clear(tAdafruit_GFX *psInst)
{
  unsigned int i;
  memset(psInst->buffer, 0, psInst->HEIGHT*psInst->WIDTH*4);
//  for(i=0; i < psInst->HEIGHT*psInst->WIDTH; i++)
//  {
//	  psInst->buffer[i]=0;
//  } // ��s���
  psInst->cursor_x=0;
  psInst->cursor_y=0;
}





