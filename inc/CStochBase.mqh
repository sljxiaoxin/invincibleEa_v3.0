//+------------------------------------------------------------------+
//|                                                   |
//|                                 Copyright 2015, Vasiliy Sokolov. |
//|                                              http://www.yjx.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018."
#property link      "http://www.yjx.com"
#include "CTrade.mqh";

class CStochBase
{  
   private:
      
      int fixedTp;
      int fixedSl;
      
      double dynamicTpPrice;
      double dynamicSlPrice;
      
      double orderOpenPrice;
      double orderOpenPass;
      
      int deadlinePassNumber;
      
      int m_ticket;
      
      double m_Ma10[30];
      double m_Ma30[30];
      double m_Stoch14[30];
      double m_Stoch100[30];
      
      
   public:
      CTrade* oCTrade;
      
      CStochBase(int Magic){
        oCTrade = new CTrade(Magic);
      };
      
      void FillData();
      void AddCol();
      void reset();
};

void CStochBase::FillData()
{
   for(int i=0;i<30;i++){ 
      m_Ma10[i] = iMA(NULL,PERIOD_M1,10,0,MODE_SMA,PRICE_CLOSE,i);
      m_Ma30[i] = iMA(NULL,PERIOD_M1,30,0,MODE_SMA,PRICE_CLOSE,i);
      m_Stoch14[i] = iStochastic(NULL, PERIOD_M1, 14, 3, 3, MODE_SMA, 0, MODE_MAIN, i);
      m_Stoch100[i] = iStochastic(NULL, PERIOD_M1, 100, 3, 3, MODE_SMA, 0, MODE_MAIN, i);
   }
   OrderOpenPass += 1;
   oCStochOne.AddCol();
   if(m_ticket != 0 && oCTrade.isOrderClosed(m_ticket)){
      m_ticket = 0;
   }
   if(m_ticket == 0){
      OrderOpenPass  = 0;
   }
   Print("m_ticket=",m_ticket);
}

void CStochBase::AddCol()
{
   
}

void CStochBase::UpdateTicket()
{
   if(m_ticket != 0 && this.isTicketClosed()){
      m_ticket = 0;
   }
}

void CStochBase::isTicketClosed()
{
     return oCTrade.isOrderClosed(m_ticket);
}