/*
 * NiosOledDrv.h
 *
 *  Created on: 2022/10/20
 *      Author: lishyhan
 */

#ifndef NIOSOLEDDRV_H_
#define NIOSOLEDDRV_H_
/*
 * ssd1306 SPI 的drawpixel程式。
 *
 * */
#include "./Adafruit-GFX-Library/Adafruit_GFX.h" /* define tAdafruit_GFX */

// Color definitions
#define	BLACK           0
#define	BLUE            0xFF0000
#define	RED             0x0000FF
#define	GREEN           0x00FF00
#define CYAN            (255<<16)|(221<<8)|155
#define MAGENTA         (233<<16)|(0<<8)|255
#define YELLOW          (255<<16)|(255<<8)|0
#define WHITE           0xFFFFFF

extern void NiosSPI_init(void);
extern void OLED_WR_Byte(unsigned char cTxData, unsigned int cMode);
extern void OLED_Set_Pos(unsigned char x, unsigned char y);
extern void drawPixel(tAdafruit_GFX *psInst, int16_t x, int16_t y,	uint32_t color);

/* Open OLED Display */
extern void OLED_Display_On(void);
/* close OLED Display */
extern void OLED_Display_Off(void);
/* 清螢幕函數, 清完螢幕,整個螢幕是黑色的!和沒點亮一樣!! */
extern void OLED_Clear(tAdafruit_GFX *psInst);
extern void ssd1306_init( tAdafruit_GFX *psInst );



#endif /* NIOSOLEDDRV_H_ */
