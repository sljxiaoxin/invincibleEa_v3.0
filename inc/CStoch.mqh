//+------------------------------------------------------------------+
//|                                                   |
//|                                 Copyright 2015, Vasiliy Sokolov. |
//|                                              http://www.yjx.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018."
#property link      "http://www.yjx.com"

#include "CStochBase.mqh";
#include "CTrade.mqh";

class CStoch : public CStochBase
{  
   private:
      datetime CheckTimeM1;
      CTrade* oCTrade;
      
   public:
   
      CStoch(CTrade* _oCTrade) : CStochBase(_oCTrade){
         oCTrade = _oCTrade;
      };
      
      
};

void CStoch::Tick()
{
    if(CheckTimeM1 == iTime(NULL,PERIOD_M1,0)){
      
    }else{
         CheckTimeM1 = iTime(NULL,PERIOD_M1,0);
         this.TickBase();
    }
}