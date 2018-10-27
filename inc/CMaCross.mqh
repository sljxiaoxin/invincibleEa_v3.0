//+------------------------------------------------------------------+
//|                                                   |
//|                                 Copyright 2015, Vasiliy Sokolov. |
//|                                              http://www.yjx.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018."
#property link      "http://www.yjx.com"

//#include "structs.mqh";
#include "CMaOne.mqh";
#include "CTrade.mqh";
class CMaCross
{  
   private:
      
      CTrade* oCTrade;
      CMaOne* oCMaOne;
      
      bool    m_isUse;
      double  m_lots;
      int     m_tp;
      int     m_sl;
      
      //int     m_ticket_fast;
      int     m_ticket_slow;
      double  m_fast_profit_pips;
      
      double m_Ma10[30];
      double m_Ma30[30];
      double m_Stoch14[30];
      double m_Stoch100[30];
      
      datetime CheckTimeM1;
      int OrderOpenPass;
      bool isCurrCrossOpen;
      
      void FillData();
      double StochDistance(int counts);
      
      
   public:
   
      CMaCross(int Magic){
         oCTrade = new CTrade(Magic);
         oCMaOne = new CMaOne();
         //m_ticket_fast = 0;
         m_ticket_slow = 0;
         m_fast_profit_pips = 0;
         OrderOpenPass  = 0;
         isCurrCrossOpen = false;
      };
      
      void Init(double _lots, int _tp, int _sl);
      void Stop();
      void Tick();
      bool Entry();
      bool Exit();
      void Protect();
      int EntrySignal();
      string ExitSignal();
      double GetCrossPriceDistanceHigh(int counts);
      double GetCrossPriceDistanceLow(int counts);
      
};

void CMaCross::FillData()
{
   for(int i=0;i<30;i++){ 
      m_Ma10[i] = iMA(NULL,PERIOD_M1,10,0,MODE_SMA,PRICE_CLOSE,i);
      m_Ma30[i] = iMA(NULL,PERIOD_M1,30,0,MODE_SMA,PRICE_CLOSE,i);
      m_Stoch14[i] = iStochastic(NULL, PERIOD_M1, 14, 3, 3, MODE_SMA, 0, MODE_MAIN, i);
      m_Stoch100[i] = iStochastic(NULL, PERIOD_M1, 100, 3, 3, MODE_SMA, 0, MODE_MAIN, i);
   }
   OrderOpenPass += 1;
   oCMaOne.AddCol();
   if(m_ticket_slow != 0 && oCTrade.isOrderClosed(m_ticket_slow)){
      m_ticket_slow = 0;
   }
   if(m_ticket_slow == 0){
      OrderOpenPass  = 0;
   }
   Print("m_ticket_slow=",m_ticket_slow);
}

void CMaCross::Init(double _lots, int _tp, int _sl)
{
   m_lots = _lots;
   m_tp   = _tp;
   m_sl   = _sl;
   m_isUse = true;
}

void CMaCross::Stop()
{
   m_isUse = false;
}

void CMaCross::Tick()
{
    if(CheckTimeM1 == iTime(NULL,PERIOD_M1,0)){
      
    }else{
         CheckTimeM1 = iTime(NULL,PERIOD_M1,0);
         this.FillData();
         this.Protect();
         this.Exit();
         this.Entry();
    }
}

bool CMaCross::Entry()
{
   int sig = this.EntrySignal();
   Print("Entry sig is:",sig);
   if(!m_isUse){
      return false;
   }
   if( m_ticket_slow != 0){
      return false;
   }
   if(isCurrCrossOpen){
      return false;
   }
   
   int t = 0;
   if(sig == OP_BUY){
      t = oCTrade.Buy(m_lots, m_sl, m_tp, "CMaM1_slow");
      if(t > 0){
         m_ticket_slow = t;
      }
      isCurrCrossOpen = true;
      
   }
   if(sig == OP_SELL){
      t = oCTrade.Sell(m_lots, m_sl, m_tp, "CMaM1_slow");
      if(t > 0){
         m_ticket_slow = t;
      }
      isCurrCrossOpen = true;
   }
   return true;
}

bool CMaCross::Exit()
{
   if(m_ticket_slow == 0){
      return false;
   }
   string sig = this.ExitSignal();
   
   if(m_ticket_slow != 0){
      if(oCTrade.GetOrderType(m_ticket_slow) == OP_BUY){
            if(sig == "exit_buy_all"){
               oCTrade.Close(m_ticket_slow);
               m_ticket_slow = 0;
            }
      }
      if(oCTrade.GetOrderType(m_ticket_slow) == OP_SELL){
            if(sig == "exit_sell_all"){
               oCTrade.Close(m_ticket_slow);
               m_ticket_slow = 0;
            }
      }
   }
   return true;
   
}

int CMaCross::EntrySignal()
{
   
   if(m_Ma10[1] > m_Ma30[1] && m_Ma10[2] < m_Ma30[2]){
      oCMaOne.SetCross("up", m_Ma30[1], this.GetCrossPriceDistanceLow(12));
      isCurrCrossOpen = false;
   }
   if(m_Ma10[1] < m_Ma30[1] && m_Ma10[2] > m_Ma30[2]){
      oCMaOne.SetCross("down", m_Ma30[1], this.GetCrossPriceDistanceHigh(12));
      isCurrCrossOpen = false;
   }
   if(!oCMaOne.isStochCrossOk && oCMaOne.crossPass <10){
      double hPrice14=0,lPrice14=100;
      double hPrice100=0,lPrice100=100;
      for(int i=1;i<=15;i++){
         if(m_Stoch100[i]>hPrice100){
            hPrice100 = m_Stoch100[i];
         }
         if(m_Stoch100[i]<lPrice100){
            lPrice100 = m_Stoch100[i];
         }
         
         if(m_Stoch14[i]>hPrice14){
            hPrice14 = m_Stoch14[i];
         }
         if(m_Stoch14[i]<lPrice14){
            lPrice14 = m_Stoch14[i];
         }
      }
      Print("hPrice14 is:",hPrice14);
      Print("lPrice14 is:",lPrice14);
      Print("hPrice100 is:",hPrice100);
      Print("lPrice100 is:",lPrice100);
      Print("crossType is:",oCMaOne.crossType);
      if(oCMaOne.crossType == "up"){
         if(lPrice14<18 && lPrice100<18){
            oCMaOne.isStochCrossOk = true;
         }
      }
      if(oCMaOne.crossType == "down"){
         if(hPrice14 > 82 && hPrice100>82){
            oCMaOne.isStochCrossOk = true;
         }
      }
   }
   
   bool isOk;
   if(oCMaOne.IsCanOpenBuy()){
      Print("IsCanOpenBuy pip:",oCTrade.GetPip());
      Print("IsCanOpenBuy crossPass:",oCMaOne.crossPass);
      Print("IsCanOpenBuy crossPrice:",oCMaOne.crossPrice);
      
      isOk = false;
      if(oCMaOne.crossPass <15 && Ask - m_Ma30[1]<2*oCTrade.GetPip()){
         double hl = oCMaOne.highLow;
         double pips = (Ask - hl)/oCTrade.GetPip();
         if(pips < 20){
            isOk = true;
         }
      }
      if(isOk){
         //oCMaOne.Reset();
         return OP_BUY;
      }
   }
   
   if(oCMaOne.IsCanOpenSell() ){
      Print("IsCanOpenSell pip:",oCTrade.GetPip());
      Print("IsCanOpenSell crossPass:",oCMaOne.crossPass);
      Print("IsCanOpenSell crossPrice:",oCMaOne.crossPrice);
      isOk = false;
      if(oCMaOne.crossPass <15 && m_Ma30[1] -Bid<2*oCTrade.GetPip()){
         double hl = oCMaOne.highLow;
         double pips = (hl - Bid)/oCTrade.GetPip();
         if(pips < 20){
            isOk = true;
         }
      }
      if(isOk){
         //oCMaOne.Reset();
         return OP_SELL;
      }
   }
   return -1;
}

string CMaCross::ExitSignal()
{
   /*
   if( (this.StochDistance(6)>18 && m_Stoch100[1] < m_Stoch100[2] && m_Stoch100[2]<50 && m_Ma10[1]<m_Ma30[1] && Close[1]<Open[1] && Close[1] <m_Ma30[1])){
      return "exit_buy_all";
   }
   
   if((this.StochDistance(6)>18 && m_Stoch100[1] > m_Stoch100[2] && m_Stoch100[2]>50 && m_Ma10[1]>m_Ma30[1]  && Close[1]>Open[1] && Close[1] >m_Ma30[1])){
      return "exit_sell_all";
   }
   */
   return "none";
}

double CMaCross::StochDistance(int counts)
{
   double h=0,l=100;
   for(int i=1;i<=counts;i++){
      if(m_Stoch100[i]>h){
         h = m_Stoch100[i]; 
      }
      if(m_Stoch100[i]<l){
         l = m_Stoch100[i]; 
      }
   }
   return h-l;
}

void CMaCross::Protect()
{
   double stoploss;
   int ordertype;
   double oop,otp;
   if(m_ticket_slow != 0){
      stoploss = oCTrade.GetOrderStopLoss(m_ticket_slow);
      ordertype = oCTrade.GetOrderType(m_ticket_slow);
      oop = oCTrade.GetOrderOpenPrice(m_ticket_slow);
      otp = oCTrade.GetOrderTakeProfit(m_ticket_slow);
      if(stoploss != -1){
         if(ordertype == OP_BUY){
            if((stoploss == 0 || stoploss - oop <-3*oCTrade.GetPip()) && Close[1] - oop > 5*oCTrade.GetPip() && Ask - oop > 5*oCTrade.GetPip()){
               //oCTrade.Modify(m_ticket_slow, oop, NormalizeDouble(oop + 1*oCTrade.GetPip(), Digits));
               oCTrade.ModifySl(m_ticket_slow,NormalizeDouble(oop - 2*oCTrade.GetPip(), Digits));
            }
            if((stoploss == 0 || stoploss - oop <2*oCTrade.GetPip()) && Close[1] - oop > 10*oCTrade.GetPip() && Ask - oop > 10*oCTrade.GetPip()){
               //oCTrade.Modify(m_ticket_slow, oop, NormalizeDouble(oop + 5*oCTrade.GetPip(), Digits));
               oCTrade.ModifySl(m_ticket_slow,NormalizeDouble(oop +5*oCTrade.GetPip(), Digits));
               if(otp >0 && (otp - oop)<13*oCTrade.GetPip()){
                  oCTrade.ModifyTp(m_ticket_slow,NormalizeDouble(oop +18*oCTrade.GetPip(), Digits));
               }
            }
            if((stoploss == 0 || stoploss - oop <6*oCTrade.GetPip()) && Close[1] - oop > 15*oCTrade.GetPip() && Ask - oop > 15*oCTrade.GetPip()){
               //oCTrade.Modify(m_ticket_slow, oop, NormalizeDouble(oop + 5*oCTrade.GetPip(), Digits));
               oCTrade.ModifySl(m_ticket_slow,NormalizeDouble(oop +10*oCTrade.GetPip(), Digits));
               if(otp >0 && (otp - oop)<19*oCTrade.GetPip()){
                  oCTrade.ModifyTp(m_ticket_slow,NormalizeDouble(oop +26*oCTrade.GetPip(), Digits));
               }
            }
         }
         if(ordertype == OP_SELL){
            if((stoploss == 0 || oop - stoploss <-3*oCTrade.GetPip()) &&  oop - Close[1] > 5*oCTrade.GetPip() && oop - Bid > 5*oCTrade.GetPip()){
               //oCTrade.Modify(m_ticket_slow, oop, NormalizeDouble(oop - 1*oCTrade.GetPip(), Digits));
               oCTrade.ModifySl(m_ticket_slow,NormalizeDouble(oop + 2*oCTrade.GetPip(), Digits));
            }
            if((stoploss == 0 || oop - stoploss <2*oCTrade.GetPip()) &&  oop - Close[1] > 10*oCTrade.GetPip() && oop - Bid > 10*oCTrade.GetPip()){
               //oCTrade.Modify(m_ticket_slow, oop, NormalizeDouble(oop - 5*oCTrade.GetPip(), Digits));
               oCTrade.ModifySl(m_ticket_slow,NormalizeDouble(oop -5*oCTrade.GetPip(), Digits));
               if(otp >0 && (oop - otp)<13*oCTrade.GetPip()){
                  oCTrade.ModifyTp(m_ticket_slow,NormalizeDouble(oop -18*oCTrade.GetPip(), Digits));
               }
            }
            if((stoploss == 0 || oop - stoploss <7*oCTrade.GetPip()) &&  oop - Close[1] > 15*oCTrade.GetPip() && oop - Bid > 15*oCTrade.GetPip()){
               //oCTrade.Modify(m_ticket_slow, oop, NormalizeDouble(oop - 10*oCTrade.GetPip(), Digits));
               oCTrade.ModifySl(m_ticket_slow,NormalizeDouble(oop -10*oCTrade.GetPip(), Digits));
               if(otp >0 && (oop - otp)<19*oCTrade.GetPip()){
                  oCTrade.ModifyTp(m_ticket_slow,NormalizeDouble(oop -26*oCTrade.GetPip(), Digits));
               }
            }
         }
      }
   }
}

double CMaCross::GetCrossPriceDistanceHigh(int counts)
{  
   double high=0;
   for(int i=1;i<counts;i++){
      if(High[i]>high){
         high = High[i];
      }
   }
   return high;
}

double CMaCross::GetCrossPriceDistanceLow(int counts)
{  
   double low=99999999;
   for(int i=1;i<counts;i++){
      if(Low[i]<low){
         low = Low[i];
      }
   }
   return low;
}