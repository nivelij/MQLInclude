//+------------------------------------------------------------------+
//|                                                     MoneyLib.mqh |
//|                                                   Hans Kristanto |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Hans Kristanto"
#property link      "https://www.mql5.com"
#property strict

#include <CommonLib.mqh>

double GetRiskedLotSize(double riskPercent, int stopPoints)
{
   double margin = AccountBalance() * (riskPercent/100);
   double tickSize = MarketInfo(Symbol(), MODE_TICKVALUE);
   double lotSize = (margin / stopPoints) / tickSize;

   if (lotSize < MarketInfo(Symbol(), MODE_MINLOT))
      lotSize = MarketInfo(Symbol(), MODE_MINLOT);
   else if (lotSize > MarketInfo(Symbol(), MODE_MAXLOT))
      lotSize = MarketInfo(Symbol(), MODE_MAXLOT);
   else if (MarketInfo(Symbol(), MODE_LOTSTEP) == 0.1)
      lotSize = NormalizeDouble(lotSize, 1);
   else
      lotSize = NormalizeDouble(lotSize, 2);
   
   return lotSize;
}