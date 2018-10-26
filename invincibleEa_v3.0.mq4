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

//--------------------MaCross-----------------------

extern bool      isUseMaCross         = true;   
extern int       MaCross_MagicNumber  = 20181026;    
extern double    MaCross_Lots         = 0.1;
extern int       MaCross_intTP        = 24;
extern int       MaCross_intSL        = 9;
      

CMaCross* oCMaCross;


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
//---
   Print("begin");
   if(oCMaCross == NULL){
      oCMaCross = new CMaCross(MaCross_MagicNumber);
   }
   if(isUseMaCross){
      oCMaCross.Init(MaCross_Lots, MaCross_intTP, MaCross_intSL);
   }else{
      oCMaCross.Stop();
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


