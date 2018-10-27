//+------------------------------------------------------------------+
//|                                                   |
//|                                 Copyright 2015, Vasiliy Sokolov. |
//|                                              http://www.yjx.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018."
#property link      "http://www.yjx.com"

class CMaOne
{  
   private:
      
   public:
   
      string crossType; //none up down
      int crossPass;    //after cross number
      double crossPrice;
      bool isStochCrossOk;
      double highLow;
      
      
      CMaOne(){
         highLow = 9999;
         crossPass = -1;
         crossPrice = -1;
         crossType = "none"; //up down
         isStochCrossOk = false;
      };
      void AddCol();
      void Reset();
      void SetCross(string ct, double cp, double hl);
      bool IsCanOpenBuy();
      bool IsCanOpenSell();
};

void CMaOne::AddCol()
{
   if(crossType != "none"){
      crossPass += 1;
   }
}

void CMaOne::Reset()
{
   highLow = 9999;
   crossType = "none";
   crossPrice = -1;
   crossPass = -1;
   crossPrice = -1;
   isStochCrossOk = false;
}

void CMaOne::SetCross(string ct, double cp, double hl)
{
   crossType = ct;
   crossPrice = cp;
   highLow = hl;
   crossPass = 0;
   //crossPrice = -1;
   isStochCrossOk = false;
}

bool CMaOne::IsCanOpenBuy()
{
    if(crossType == "up" && isStochCrossOk){
      return true;
    }
    return false;
}


bool CMaOne::IsCanOpenSell()
{
   if(crossType == "down" && isStochCrossOk){
      return true;
    }
    return false;
}
