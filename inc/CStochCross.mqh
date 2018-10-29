//+------------------------------------------------------------------+
//|                                                   |
//|                                 Copyright 2015, Vasiliy Sokolov. |
//|                                              http://www.yjx.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018."
#property link      "http://www.yjx.com"

#include "CStochOne.mqh";
#include "CTrade.mqh";
class CStochCross
{  
   private:
      
      CTrade* oCTrade;
      CStochOne* oCStochOne;
      
      bool    m_isUse;
      double  m_lots;
      int     m_tp;
      int     m_sl;
     
      int     m_ticket;
      
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
   
      CStochCross(int Magic){
         oCTrade = new CTrade(Magic);
         oCStochOne = new CStochOne();
         m_ticket = 0;
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
      double GetStoch14Lowest(int counts);
      double GetStoch14Highest(int counts);
      double GetStoch100Lowest(int counts);
      double GetStoch100Highest(int counts);
      double GetPriceDistance(int counts);
      
};

void CStochCross::FillData()
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

void CStochCross::Init(double _lots, int _tp, int _sl)
{
   m_lots = _lots;
   m_tp   = _tp;
   m_sl   = _sl;
   m_isUse = true;
}

void CStochCross::Stop()
{
   m_isUse = false;
}

void CStochCross::Tick()
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



/////////////////////////////////////////////////////////////////

bool CStochCross::Entry()
{
   int sig = this.EntrySignal();
   Print("Entry sig is:",sig);
   if(!m_isUse){
      return false;
   }
   if( m_ticket != 0){
      return false;
   }
   if(isCurrCrossOpen){
      return false;
   }
   
   int t = 0;
   if(sig == OP_BUY){
      t = oCTrade.Buy(m_lots, m_sl, m_tp, "CStochM1");
      if(t > 0){
         m_ticket = t;
      }
      isCurrCrossOpen = true;
      
   }
   if(sig == OP_SELL){
      t = oCTrade.Sell(m_lots, m_sl, m_tp, "CStochM1");
      if(t > 0){
         m_ticket = t;
      }
      isCurrCrossOpen = true;
   }
   return true;
}

bool CStochCross::Exit()
{
   if(m_ticket == 0){
      return false;
   }
   string sig = this.ExitSignal();
   
   if(m_ticket != 0){
      if(oCTrade.GetOrderType(m_ticket) == OP_BUY){
            if(sig == "exit_buy_all"){
               oCTrade.Close(m_ticket);
               m_ticket = 0;
            }
      }
      if(oCTrade.GetOrderType(m_ticket) == OP_SELL){
            if(sig == "exit_sell_all"){
               oCTrade.Close(m_ticket);
               m_ticket = 0;
            }
      }
   }
   return true;
   
}

int CStochCross::EntrySignal()
{
   if(m_Stoch14[3]<m_Stoch100[3] && m_Stoch14[2]<m_Stoch100[2] && m_Stoch14[1]>m_Stoch100[1]){
      if(m_Stoch100[2]<40 && this.GetStoch14Lowest(12)<11){
         oCStochOne.SetCross("up");
         isCurrCrossOpen = false;
      }
   }
   
   if(m_Stoch14[3]>m_Stoch100[3] && m_Stoch14[2]>m_Stoch100[2] && m_Stoch14[1]<m_Stoch100[1]){
      if(m_Stoch100[2]>60 && this.GetStoch14Highest(12)>89){
         oCStochOne.SetCross("down");
         isCurrCrossOpen = false;
      }
   }
   
   if(!oCStochOne.isStochCrossOk && oCStochOne.crossPass <10){
      oCStochOne.crossOverPass = 0;
      if(oCStochOne.crossType == "up" && m_Stoch14[1] > 21){
         oCStochOne.isStochCrossOk = true;
      }
      if(oCStochOne.crossType == "down" && m_Stoch14[1] < 79){
         oCStochOne.isStochCrossOk = true;
      }
   }
   
   if(oCStochOne.isStochCrossOk){
      oCStochOne.crossOverPass += 1;
   }
   
   //check ma
   bool isOk;
   if(oCStochOne.IsCanOpenBuy()){
      Print("IsCanOpenBuy crossPass:",oCStochOne.crossPass);
      
      isOk = false;
      
      if(m_Ma10[1] > m_Ma10[2] && Close[2]>m_Ma10[2] && Close[1]>Open[1] && Close[1]>m_Ma10[1] && Ask - m_Ma30[1]<1.5*oCTrade.GetPip()){
         double pips = GetPriceDistance(20)/oCTrade.GetPip();
         Print("IsCanOpenBuy pips:", pips);
         if(pips > 2){
            isOk = true;
         }
      }
      if(isOk){
         //oCMaOne.Reset();
         return OP_BUY;
      }
   }
   
   if(oCStochOne.IsCanOpenSell() ){
      Print("IsCanOpenSell crossPass:",oCStochOne.crossPass);
      isOk = false;
      if(m_Ma10[1] < m_Ma10[2] && Close[2]<m_Ma10[2] && Close[1]<Open[1] && Close[1]<m_Ma10[1] && m_Ma30[1] - Bid<1.5*oCTrade.GetPip()){
         double pips = GetPriceDistance(20)/oCTrade.GetPip();
         Print("IsCanOpenSell pips:", pips);
         if(pips > 2){
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

string CStochCross::ExitSignal()
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

double CStochCross::StochDistance(int counts)
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

void CStochCross::Protect()
{

   if(m_ticket == 0){
      return;
   }
   /*
   if(OrderOpenPass == 10){
      double oop = oCTrade.GetOrderOpenPrice(m_ticket);
      double high = this.GetCrossPriceDistanceHigh(10);
      double low = this.GetCrossPriceDistanceLow(10);
      double close = Close[1];
      double stochHigh = GetStoch100Highest(10);
      double stochLow = GetStoch100Lowest(10);
      double stochNow = m_Stoch100[1];
      
      
   }
*/



   double stoploss;
   int ordertype;
   double oop,otp;
   if(m_ticket != 0){
      stoploss = oCTrade.GetOrderStopLoss(m_ticket);
      ordertype = oCTrade.GetOrderType(m_ticket);
      oop = oCTrade.GetOrderOpenPrice(m_ticket);
      otp = oCTrade.GetOrderTakeProfit(m_ticket);
      if(stoploss != -1){
         if(ordertype == OP_BUY){
            if((stoploss == 0 || stoploss - oop <-3*oCTrade.GetPip()) && Close[1] - oop > 3*oCTrade.GetPip() && Ask - oop > 3*oCTrade.GetPip()){
               
               oCTrade.ModifySl(m_ticket,NormalizeDouble(oop - 2*oCTrade.GetPip(), Digits));
            }
            if((stoploss == 0 || stoploss - oop <2*oCTrade.GetPip()) && Close[1] - oop > 5*oCTrade.GetPip() && Ask - oop > 5*oCTrade.GetPip()){
               
               oCTrade.ModifySl(m_ticket,NormalizeDouble(oop +1*oCTrade.GetPip(), Digits));
            }
            
         }
         if(ordertype == OP_SELL){
            if((stoploss == 0 || oop - stoploss <-3*oCTrade.GetPip()) &&  oop - Close[1] > 3*oCTrade.GetPip() && oop - Bid > 3*oCTrade.GetPip()){
              
               oCTrade.ModifySl(m_ticket,NormalizeDouble(oop + 2*oCTrade.GetPip(), Digits));
            }
            if((stoploss == 0 || oop - stoploss <2*oCTrade.GetPip()) &&  oop - Close[1] > 5*oCTrade.GetPip() && oop - Bid > 5*oCTrade.GetPip()){
               
               oCTrade.ModifySl(m_ticket,NormalizeDouble(oop -1*oCTrade.GetPip(), Digits));
             
            }
            
         }
      }
   }
}

double CStochCross::GetCrossPriceDistanceHigh(int counts)
{  
   double high=0;
   for(int i=1;i<counts;i++){
      if(High[i]>high){
         high = High[i];
      }
   }
   return high;
}

double CStochCross::GetCrossPriceDistanceLow(int counts)
{  
   double low=99999999;
   for(int i=1;i<counts;i++){
      if(Low[i]<low){
         low = Low[i];
      }
   }
   return low;
}

double CStochCross::GetStoch14Lowest(int counts){
   double low = 9999;
   for(int i=1;i<counts;i++){
      if(m_Stoch14[i]<low){
         low = m_Stoch14[i];
      }
   }
   return low;
}

double CStochCross::GetStoch14Highest(int counts){
   double high = -1;
   for(int i=1;i<counts;i++){
      if(m_Stoch14[i]>high){
         high = m_Stoch14[i];
      }
   }
   return high;
}

double CStochCross::GetStoch100Lowest(int counts){
   double low = 9999;
   for(int i=1;i<counts;i++){
      if(m_Stoch100[i]<low){
         low = m_Stoch100[i];
      }
   }
   return low;
}

double CStochCross::GetStoch100Highest(int counts){
   double high = -1;
   for(int i=1;i<counts;i++){
      if(m_Stoch100[i]>high){
         high = m_Stoch100[i];
      }
   }
   return high;
}

double CStochCross::GetPriceDistance(int counts)
{
   double low = Close[1],high = Close[1];
   for(int i=2;i<counts;i++){
      if(Close[i]>high){
         high = Close[i];
      }
      if(Close[i]<low){
         low = Close[i];
      }
   }
   return NormalizeDouble(high - low,Digits);
}