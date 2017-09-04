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

const int      DIGIT = int(MarketInfo(Symbol(), MODE_DIGITS));

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
