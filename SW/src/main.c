// Atomic counter with I2C and RS232 output

// Usage conditions:
// 1. The first I2C or RS232 readout can be performed minimally 20 s after power up.
// 2. The I2C internal address 0 has to be read first.
// 3. An I2C readout can be performed at 15-th, 35-th and 55-th second of UTC. 
//
// Counter gives 32 bit value:
// I2C register address 0 = LSB
// I2C register address 3 = MSB

#define ID "$Id: main.c 3741 2014-10-25 22:30:12Z kakl $"
#include "main.h"
#use i2c(SLAVE, Fast, sda=PIN_C4, scl=PIN_C3, force_hw, address=0xA2) 

#include <string.h>

#define LED    PIN_B3   // heartbeat indicator
#define SEL0   PIN_E0   // external counter division ratio
#define SEL1   PIN_E1   // external counter division ratio
#define MR     PIN_E2   // external counter master reset
#define CLKI   PIN_C0   // internal counter input

unsigned int32 count;   // count per second

int1 fire_setup;        // flag for sending setup to GPS

#define BUF_LEN 4
int8 buffer[BUF_LEN];   // I2C buffer     
int8 address=0;

unsigned int16 of=0; // count of overflow

// 1x 100 us per 10 s UTC synchronised; 40 configuration bytes
char cmd[50]={40, 0xB5, 0x62, 0x06, 0x31, 0x20, 0x00, 0x00, 0x00, 0x00, 0x00, 0x32, 0x00, 0x00, 0x00, 0x80, 0x96, 0x98, 0x00, 0xE0, 0xC8, 0x10, 0x00, 0x64, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x73, 0x00, 0x00, 0x00, 0xC6, 0x51};

// configure GPS
void setup_GPS()
{ 
   int n;
   int len;
   len=cmd[0];
   for (n=1;n<=len;n++) putc(cmd[n]); 
}

#INT_SSP
void ssp_interupt ()
{
   int8 incoming, state;

   state = i2c_isr_state();

   if(state < 0x80)                    //Master is sending data
   {     
      incoming = i2c_read();           // Read byte

      if(state == 1)                   //Second received byte is address of register
      {
         address = incoming;         
      }

      if(state == 2)                   //Thid received byte are configuration data
      {             
         if ((address==0)&&(incoming==0)) 
         {
            fire_setup = 1; // Write configuration to the GPS if configuration data length is 0
         }
         else
         {
            cmd[address] = incoming; // Store byte to configuration sentence
         }
      }
   }
   if(state == 0x80)                     //Master is requesting data
   {
      //i2c_read();    // Dummy read of I2C device address
      
      if(address == 0)  // Change buffer atomically at reading of the first byte
      {
         buffer[0]=make8(count,0);
         buffer[1]=make8(count,1);
         buffer[2]=make8(count,2);
         buffer[3]=make8(count,3);
      }
      if(address <= BUF_LEN) 
      {
         i2c_write(buffer[address]); // Prepare one byte to SSP buffer
      }
      else
      {
         i2c_write(0x00); // There is nothing to prepare, so zero
      }
   }

   if(state == 0x81)                     //Master is requesting data
   {
      i2c_write(buffer[1]); // Prepare next byte to SSP buffer
   }
   if(state == 0x82)                     //Master is requesting data
   {
      i2c_write(buffer[2]); // Prepare next byte to SSP buffer
   }
   if(state == 0x83)                     //Master is requesting data
   {
      i2c_write(buffer[3]); // Prepare next byte to SSP buffer         
   }

   if(state > 0x83)                     //Master is requesting data
   {
      i2c_write(0x00); // There is nothing to prepare, so zero
   }
}



#int_EXT  // Interrupt from 1PPS (RB0)
void  EXT_isr(void) 
{
   unsigned int16 countH;
   unsigned int8  countL;
   int16 of2;
   
   of2=of;                 // read overflow counter   
   countH=get_timer1();    // read internal counter
   countL=0;
   output_low(SEL0);
   output_low(SEL1);
   countL=input(CLKI);     // read bit 0 of external counter
   output_high(SEL0);
//   output_low(SEL1);
   countL|=input(CLKI)<<1; // read bit 1 of external counter
   output_low(SEL0);
   output_high(SEL1);
   countL|=input(CLKI)<<2; // read bit 2 of external counter
   output_high(SEL0);
//   output_high(SEL1);
   countL|=input(CLKI)<<3; // read bit 3 of external counter

   output_toggle(LED); // heartbeat
   output_low(MR);   // External counter Master Reset
   output_high(MR);
   set_timer1(0);    // Internal counter reset
   of=0;             // Overflow counter reset
   
   count=((unsigned int32)of2<<20)+((unsigned int32)countH<<4)+(unsigned int32)countL; // concatenate 

//   printf("%010Lu\r\n", count);    
}

#int_TIMER1  // Interrupf from overflow
void  TIMER1_isr(void) 
{
   of++;
}

void main()
{
   setup_adc_ports(NO_ANALOGS|VSS_VDD);
   setup_adc(ADC_OFF);
//   setup_spi(SPI_SS_DISABLED);  //must not be set if I2C are in use! 
   setup_timer_0(RTCC_INTERNAL|RTCC_DIV_1);
   setup_wdt(WDT_2304MS);
   setup_timer_1(T1_EXTERNAL|T1_DIV_BY_1);
   setup_timer_2(T2_DISABLED,0,1);
   setup_comparator(NC_NC_NC_NC);
   setup_vref(FALSE);

   restart_wdt();
   delay_ms(1000);
   restart_wdt();
   
   // setup GPS
   setup_GPS();

   ext_int_edge( L_TO_H );       // set 1PPS active edge
   enable_interrupts(INT_TIMER1);
   enable_interrupts(INT_EXT);
   enable_interrupts(INT_SSP); 
   enable_interrupts(GLOBAL);    
   
   buffer[0]=0x0; // Clear I2C output buffer
   buffer[1]=0x0;
   buffer[2]=0x0;
   buffer[3]=0x0;

   //printf("\r\ncvak...\r\n");
   
   fire_setup = 0;

   while(true)
   {      
      restart_wdt();
      delay_ms(1000);
      if (fire_setup) 
      {
         setup_GPS(); // Write configuration to the GPS
         fire_setup = 0;
      }
      output_toggle(LED); // heartbeat
      //printf("%X %X %X %X\r\n", buffer[0],buffer[1],buffer[2],buffer[3]);
      //printf("%010Lu\r\n", count);    
   }
}
