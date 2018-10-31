//+------------------------------------------------------------------+
//|     
//|                                                      
//|                                             
//+------------------------------------------------------------------+
#property copyright "xiaoxin003"
#property link      "yangjx009@139.com"
#property version   "2.0"
#property strict

#include "inc\CMaCross.mqh";
#include "inc\CStochCross.mqh";

//--------------------MaCross-----------------------

extern bool      isUseMaCross         = false;   
extern int       MaCross_MagicNumber  = 20181026;    
extern double    MaCross_Lots         = 0.1;
extern int       MaCross_intTP        = 6;
extern int       MaCross_intSL        = 6;

extern bool      isUseStochCross         = true;   
extern int       StochCross_MagicNumber  = 20181026;    
extern double    StochCross_Lots         = 0.1;
extern int       StochCross_intTP        = 20;
extern int       StochCross_intSL        = 20;
      

CMaCross* oCMaCross;
CStochCross* oCStochCross;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
//---
   Print("begin");
   if(oCMaCross == NULL){
      oCMaCross = new CMaCross(MaCross_MagicNumber);
      oCStochCross = new CStochCross(StochCross_MagicNumber);
   }
   if(isUseMaCross){
      oCMaCross.Init(MaCross_Lots, MaCross_intTP, MaCross_intSL);
   }else{
      oCMaCross.Stop();
   }
   
   if(isUseStochCross){
      oCStochCross.Init(StochCross_Lots, StochCross_intTP, StochCross_intSL);
   }else{
      oCStochCross.Stop();
   }
   
//---
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   Print("deinit");
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+

void OnTick()
{
   if(isUseMaCross){
      oCMaCross.Tick();
   }
   if(isUseStochCross){
      oCStochCross.Tick();
   }
}


void subPrintDetails()
{
   //
   string sComment   = "";
   string sp         = "----------------------------------------\n";
   string NL         = "\n";

   sComment = sp;
   //sComment = sComment + "TotalItems = " + oCOrder.TotalItems() + NL; 
   sComment = sComment + sp;
   //sComment = sComment + "TotalItemsActive = " + oCOrder.TotalItemsActive() + NL; 
   sComment = sComment + sp;
   //sComment = sComment + "Lots=" + DoubleToStr(Lots,2) + NL;
   Comment(sComment);
}


