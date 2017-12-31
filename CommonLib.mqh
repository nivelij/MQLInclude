//+------------------------------------------------------------------+
//|                                                    KrishaLib.mqh |
//|                                                   Hans Kristanto |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Hans Kristanto"
#property link      "https://www.mql5.com"
#property strict

#include <CustomError.mqh>
#include <LogLib.mqh>


enum tradeHour
{
   HOUR_0=0,
   HOUR_1=1,
   HOUR_2=2,
   HOUR_3=3,
   HOUR_4=4,
   HOUR_5=5,
   HOUR_6=6,
   HOUR_7=7,
   HOUR_8=8,
   HOUR_9=9,
   HOUR_10=10,
   HOUR_11=11,
   HOUR_12=12,
   HOUR_13=13,
   HOUR_14=14,
   HOUR_15=15,
   HOUR_16=16,
   HOUR_17=17,
   HOUR_18=18,
   HOUR_19=19,
   HOUR_20=20,
   HOUR_21=21,
   HOUR_22=22,
   HOUR_23=23,
};

enum tradeMode
{
   Buy,
   Sell
};

enum instrumentClass
{
   All=0,
   Major=1,
   Minor=2,
   Exotic=3,
   Metals=4,
   Indices=5,
   Commodities=6
};

const int      DIGIT = int(MarketInfo(Symbol(), MODE_DIGITS));
const string   MAJOR[19] = {"AUDJPY", "AUDUSD", "CHFJPY", "EURAUD", "EURCAD", "EURCHF", "EURGBP", "EURJPY", "EURUSD", "GBPAUD", "GBPCAD", "GBPCHF", "GBPJPY", "GBPUSD", "NZDJPY", "NZDUSD", "USDCAD", "USDCHF", "USDJPY"};
const string   MINOR[17] = {"AUDCAD", "AUDCHF", "AUDNZD", "CADCHF", "CADJPY", "EURDKK", "EURNOK", "EURNZD", "EURSEK", "GBPNZD", "NZDCAD", "NZDCHF", "USDDKK", "USDHKD", "USDNOK", "USDSEK", "USDSGD"};
const string   EXOTIC[12] = {"EURHKD", "EURPLN", "EURTRY", "GBPDKK", "GBPPLN", "GBPSEK", "USDCZK", "USDHUF", "USDMXN", "USDPLN", "USDTRY", "USDZAR"};
const string   METALS[2] = {"XAGUSD", "XAUUSD"};
const string   INDICES[11] = {"AUS200", "FCHI40", "GDAXIm", "HSI50", "Jap225", "ND100m", "SP500m", "SPN35", "STOX50", "UK100", "WSt30m"};
const string   COMMODITIES[3] = {"Crude", "Brent", "NatGas"};


bool isElementMemberOf(string key, const string& array[])
{
   for (int i=0;i < ArraySize(array);i++)
   {
      if (StringFind(array[i], key) != -1)
      {
         return true;
      }
   }

   return false;
}

bool IsPartOfInstrumentClass(string instrument, int instClass)
{
   if (instClass == All)
   {
      return true;
   }
   else
   {
      bool result = false;
      switch(instClass)
      {
         case Major:
            result = isElementMemberOf(instrument, MAJOR);
            break;
         case Minor:
            result = isElementMemberOf(instrument, MINOR);
            break;
         case Exotic:
            result = isElementMemberOf(instrument, EXOTIC);
            break;
         case Metals:
            result = isElementMemberOf(instrument, METALS);
            break;
         case Indices:
            result = isElementMemberOf(instrument, INDICES);
            break;
         case Commodities:
            result = isElementMemberOf(instrument, COMMODITIES);
            break;
         
      }

      return result;
   }
}

int GetDistanceInPoints(double fromPrice, double toPrice, bool useAbsolute=false)
{
   if (useAbsolute)
   {
      return int(NormalizeDouble(MathPow(10, DIGIT) * MathAbs((fromPrice - toPrice)), 0));
   }
   else
   {
      return int(NormalizeDouble(MathPow(10, DIGIT) * (fromPrice - toPrice), 0));
   }
}

int GetDistanceInPoints(int ticket)
{
   bool orderSelected = OrderSelect(ticket, SELECT_BY_TICKET);
   
   if (orderSelected)
   {
      int orderType = OrderType();

      if (orderType == OP_BUY)
      {
         return GetDistanceInPoints(Bid, OrderOpenPrice());
      }
      else if (orderType == OP_SELL)
      {
         return GetDistanceInPoints(OrderOpenPrice(), Ask);
      }
      else
      {
         Error("Only BUY and SELL order allowed for calling this function.", __FILE__);
         return CERR_INVALID_ORDER_TYPE;
      }
   }
   else
   {
      Error("Order " + string(ticket) + " cannot be selected. Reason " + string(GetLastError()), __FILE__);
      return CERR_ORDER_NOT_SELECTED;
   }
}
