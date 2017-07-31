#include "main.h"

#define LED1         PIN_E0   // RMC
#define LED2         PIN_E1   // 10s
#define LED3         PIN_E2   // PPS
#define LED4         PIN_A5   // Fix

#define SYNC_OUTPUT  PIN_A0  

int1 sync;
int8 sec;

// Interrupt from B0
#int_EXT
void  EXT_isr(void) 
{
   if (sync==1) 
   {
      output_low(SYNC_OUTPUT);
      output_toggle(LED2);
      delay_us(5);  // na svvakove staci 5us v Upici bylo potreba energii zvednout
      output_high(SYNC_OUTPUT);
      sync=0;
   }
   output_toggle(LED3);  
}


void main()
{

   setup_adc_ports(NO_ANALOGS|VSS_VDD);
   setup_adc(ADC_CLOCK_DIV_2);
   setup_spi(SPI_SS_DISABLED);
   setup_timer_0(RTCC_INTERNAL|RTCC_DIV_1);
   setup_wdt(WDT_2304MS|WDT_DIV_16);
   setup_timer_1(T1_DISABLED);
   setup_timer_2(T2_DISABLED,0,1);
   setup_ccp1(CCP_OFF);
   setup_comparator(NC_NC_NC_NC);// This device COMP currently not supported by the PICWizard


   output_high(SYNC_OUTPUT);
   output_high(LED1);
   output_high(LED2);
   output_high(LED3);

   sync=0;

   enable_interrupts(INT_EXT);
   enable_interrupts(GLOBAL);

   while(true)
   {
      while (getch()!='$');
      if (getch()!='G') continue;
      if (getch()!='P') continue;
      if (getch()!='R') continue;
      if (getch()!='M') continue;
      if (getch()!='C') continue;
      if (getch()!=',') continue;
      getch();
      getch();
      getch();
      getch();
      getch();
      output_toggle(LED1);
      sec=getch();
      if ((sec=='9')) {sync=1; continue;}
      getch();
      getch();
      getch();
      getch();
//      getch();      GPS01A ma A na 18. znaku, ne na 19.
      if ('A'!=getch())
      {
         output_high(LED4);         // Neni FIX
         if (sec=='0') {sync=1;}   // Extra click hlasi chybu
      }
      else
      {
         output_low(LED4);
      }
   }

}
