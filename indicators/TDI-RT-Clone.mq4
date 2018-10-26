/*------------------------------------------------------------------------------------
   Name: TDI-RT-Clone.mq4
   
   Description: A clone of the TDI indicator. 
                The volatility bands and the market base line are not exactly the same 
                but they are close enough. 
                	          
-------------------------------------------------------------------------------------*/
// Indicator properties
#property copyright "www.xaphod.com"
#property link      "www.xaphod.com"
#property strict
#property version "1.600"
#property description "A clone of the TDI-RT indicator"
#property description "RT indicating that it updates in Real Time, ie on every tick."
#property description "The volatility bands and the market base line are not exactly the same but they are close enough."
#property indicator_separate_window
#property indicator_buffers 6
#property indicator_color1 clrYellow
#property indicator_width1 1
#property indicator_color2 clrRed
#property indicator_width2 2
#property indicator_color3 clrGreen
#property indicator_width3 2
#property indicator_color4 clrBlue
#property indicator_width4 1
#property indicator_color5 clrBlue
#property indicator_width5 1
#property indicator_color6 CLR_NONE
#property indicator_width6 1
#property indicator_level1 32
#property indicator_level2 50
#property indicator_level3 68
#property indicator_levelstyle STYLE_DOT
#property indicator_levelcolor DimGray

#define INDICATOR_NAME "TDI-RT-Clone"

// Indicator parameters
extern int                RSI_Period=13;            
extern ENUM_APPLIED_PRICE RSI_Price=PRICE_CLOSE; 
extern int                Volatility_Band=34;
extern int                RSISignal_Period=2;   
extern ENUM_MA_METHOD     RSISignal_Mode=MODE_SMA;
extern int                TradeSignal_Period=7;      
extern ENUM_MA_METHOD     TradeSignal_Mode=MODE_SMA; 


// Global module varables
double gdaRSI[];
double gdaRSISig[];
double gdaTradeSig[];
double gdaMktBase[];
double gdaVolaTop[];
double gdaVolaBtm[];


//-----------------------------------------------------------------------------
// function: init()
// Description: Custom indicator initialization function.
//-----------------------------------------------------------------------------
int init() {
  SetIndexStyle(0, DRAW_LINE);
  SetIndexBuffer(0, gdaMktBase);
  SetIndexLabel(0,"Market Base");
  SetIndexStyle(1, DRAW_LINE);
  SetIndexBuffer(1, gdaTradeSig);
  SetIndexLabel(1,"Trade Signal");
  SetIndexStyle(2, DRAW_LINE);
  SetIndexBuffer(2, gdaRSISig);
  SetIndexLabel(2,"RSI Signal");   
  SetIndexStyle(3, DRAW_LINE);
  SetIndexBuffer(3, gdaVolaTop);
  SetIndexLabel(3,"Volatility Top");   
  SetIndexStyle(4, DRAW_LINE);
  SetIndexBuffer(4, gdaVolaBtm);
  SetIndexLabel(4,"Volatility Bottom");   
  SetIndexStyle(5, DRAW_NONE);
  SetIndexBuffer(5, gdaRSI);
  SetIndexLabel(5,NULL);
  IndicatorDigits(1);
  IndicatorShortName(INDICATOR_NAME);
  return(0);
}

//-----------------------------------------------------------------------------
// function: deinit()
// Description: Custom indicator deinitialization function.
//-----------------------------------------------------------------------------
int deinit() {
   return (0);
}


///-----------------------------------------------------------------------------
// function: start()
// Description: Custom indicator iteration function.
//-----------------------------------------------------------------------------
int start() {
  int iNewBars, iCountedBars, i;  
  
  // Get unprocessed bars
  iCountedBars=IndicatorCounted();
  if(iCountedBars < 0) return (-1); 
  if(iCountedBars>0) iCountedBars--;
  iNewBars=Bars-iCountedBars;

  // Calc TDI data
  for(i=iNewBars-1; i>=0; i--) {
    gdaRSI[i] = iRSI(NULL,0,RSI_Period,RSI_Price,i); 
  }
  for(i=iNewBars-1; i>=0; i--) {  
    gdaRSISig[i]=iMAOnArray(gdaRSI,0,RSISignal_Period,0,RSISignal_Mode,i);
    gdaTradeSig[i]=iMAOnArray(gdaRSI,0,TradeSignal_Period,0,TradeSignal_Mode,i);
    gdaMktBase[i]=iMAOnArray(gdaRSI,0,Volatility_Band,0,MODE_SMA,i);    
    gdaVolaTop[i]=gdaMktBase[i]+1.6185 * iStdDevOnArray(gdaRSI,0,Volatility_Band,0,MODE_SMA,i);
    gdaVolaBtm[i]=gdaMktBase[i]-1.6185 * iStdDevOnArray(gdaRSI,0,Volatility_Band,0,MODE_SMA,i);
  } 
  return(0);
}
//+------------------------------------------------------------------+


