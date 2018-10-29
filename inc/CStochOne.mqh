//+------------------------------------------------------------------+
//|                                                   |
//|                                 Copyright 2015, Vasiliy Sokolov. |
//|                                              http://www.yjx.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018."
#property link      "http://www.yjx.com"

class CStochOne
{  
   private:
      
   public:
   
      string crossType; //none up down
      int crossPass;    //after cross number
      int crossOverPass; //cross over buy or sell area cross number
      double crossPrice;
      bool isStochCrossOk;
      double highLow;
      
      
      CStochOne(){
         highLow = 9999;
         crossPass = -1;
         crossPrice = -1;
         crossOverPass = -1;
         crossType = "none"; //up down
         isStochCrossOk = false;
      };
      void AddCol();
      void Reset();
      void SetCross(string ct);
      bool IsCanOpenBuy();
      bool IsCanOpenSell();
      void SetCrossPrice(double cp);
};

void CStochOne::AddCol()
{
   if(crossType != "none"){
      crossPass += 1;
   }
}

void CStochOne::Reset()
{
   highLow = 9999;
   crossType = "none";
   crossPrice = -1;
   crossPass = -1;
   crossPrice = -1;
   crossOverPass = -1;
   isStochCrossOk = false;
}

void CStochOne::SetCross(string ct)
{
   crossType = ct;
   crossPass = 0;
   crossOverPass = 0;
   isStochCrossOk = false;
}

void CStochOne::SetCrossPrice(double cp){
   crossPrice = cp;
}

bool CStochOne::IsCanOpenBuy()
{
    if(crossType == "up" && isStochCrossOk && crossOverPass<11){
      return true;
    }
    return false;
}


bool CStochOne::IsCanOpenSell()
{
   if(crossType == "down" && isStochCrossOk && crossOverPass<11){
      return true;
    }
    return false;
}
