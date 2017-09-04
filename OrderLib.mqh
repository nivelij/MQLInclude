//+------------------------------------------------------------------+
//|                                                     OrderLib.mqh |
//|                                                   Hans Kristanto |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Hans Kristanto"
#property link      "https://www.mql5.com"
#property strict

#include <CommonLib.mqh>
#include <CustomError.mqh>
#include <LogLib.mqh>

const int      SLIPPAGE = 3;
const double   SMALLEST_LOT = 0.01;

/*===========================*
 *     PRIVATE FUNCTION      *
 *===========================*/
int _OpenBuyOrderECN(double lot_size, int magic_number, int stop_loss_pts, int take_profit_pts)
{
   double stop_loss = 0;
   double take_profit = 0;
   string comment = "Buy market order " + Symbol() + " at " + string(Ask) + " for " + string(lot_size) + " with spread " + string(GetSpread());

   int res = OrderSend(Symbol(),OP_BUY,lot_size,Ask,SLIPPAGE,0,0,comment,magic_number,0,Blue);

   if (res <= 0)
   {
      Error("OrderSend Error: " + string(GetLastError()), __FILE__);
   }
   else
   {
      if (stop_loss_pts > 0)
      {
         stop_loss = _GetStopLoss(Buy, stop_loss_pts);
         comment = comment + " with SL at " + string(stop_loss);
      }

      if (take_profit_pts > 0)
      {
         take_profit = _GetTakeProfit(Buy, take_profit_pts);
         comment = comment + " with TP at " + string(take_profit);
      }

      if (ModifyOrder(res, stop_loss, take_profit))
      {
         Info(comment, __FILE__);
      }
   }

   return res;
}

int _OpenSellOrderECN(double lot_size, int magic_number, int stop_loss_pts, int take_profit_pts)
{
   double stop_loss = 0;
   double take_profit = 0;
   string comment = "Sell market order " + Symbol() + " at " + string(Bid) + " for " + string(lot_size) + " with spread " + string(GetSpread());

   int res = OrderSend(Symbol(),OP_SELL,lot_size,Bid,SLIPPAGE,0,0,comment,magic_number,0,Red);

   if (res <= 0)
   {
      Error("OrderSend Error: " + string(GetLastError()), __FILE__);
   }
   else
   {
      if (stop_loss_pts > 0)
      {
         stop_loss = _GetStopLoss(Sell, stop_loss_pts);
         comment = comment + " with SL at " + string(stop_loss);
      }

      if (take_profit_pts > 0)
      {
         take_profit = _GetTakeProfit(Sell, take_profit_pts);
         comment = comment + " with TP at " + string(take_profit);
      }

      if (ModifyOrder(res, stop_loss, take_profit))
      {
         Info(comment, __FILE__);
      }
   }   

   return res;
}

double _GetStopLoss(tradeMode mode, int stop_loss_pts)
{
   if (mode == Sell)
   {
      return NormalizeDouble(Ask + stop_loss_pts * Point, Digits);
   }
   else
   {
      return NormalizeDouble(Bid - stop_loss_pts * Point, Digits);
   }

}

double _GetTakeProfit(tradeMode mode, int take_profit_pts)
{
   if (mode == Sell)
   {
      return NormalizeDouble(Ask - take_profit_pts * Point, Digits);
   }
   else
   {
      return NormalizeDouble(Bid + take_profit_pts * Point, Digits);
   }
}

/*===========================*
 *      PUBLIC FUNCTION      *
 *===========================*/
int PartialCloseOrder(int ticketNumber, double closePrice, double lotSize, double partialPercent)
{
   if (lotSize == SMALLEST_LOT)
   {
      Error("Lot size too small for partial close", __FILE__);
      return CERR_LOT_TOO_SMALL;
   }
   else
   {
      bool selected = OrderSelect(ticketNumber, SELECT_BY_TICKET);

      if (selected)
      {
         int orderType = OrderType();
         string symbol = OrderSymbol();
         int magicNumber = OrderMagicNumber();
         double closeLotSize = NormalizeDouble(partialPercent/100 * lotSize, 2);
         double remainingLotSize = NormalizeDouble(lotSize - closeLotSize, 2);
         bool result = OrderClose(ticketNumber, closeLotSize, closePrice, SLIPPAGE);
   
         if (result)
         {
            for (int i=0;i < OrdersTotal();i++)
            {
               selected = OrderSelect(i, SELECT_BY_POS);

               if (selected)
               {
                  // Get new ticket number here
                  if (OrderType() == orderType
                        && OrderLots() == remainingLotSize
                        && OrderSymbol() == symbol
                        && OrderMagicNumber() == magicNumber)
                  {
                     return OrderTicket();
                  }
               }
               else
               {
                  return CERR_ORDER_NOT_SELECTED;
               }
            }

            return CERR_ORDER_NOT_FOUND;            
         }
         else
         {
            return CERR_PARTIAL_CLOSE_FAILED;
         }
      }
      else
      {
         return CERR_ORDER_NOT_SELECTED;
      }
   }
}

int OpenOrder(tradeMode mode, bool is_ecn, double lot_size, int magic_number, int stop_loss_pts, int take_profit_pts)
{
   if (is_ecn)
   {
      int response;

      if (mode == Buy)
      {
         response = _OpenBuyOrderECN(lot_size, magic_number, stop_loss_pts, take_profit_pts);
      }
      else {
         response = _OpenSellOrderECN(lot_size, magic_number, stop_loss_pts, take_profit_pts);
      }

      return response;
   }
   else {
      Warn("Support for other broker type will be added soon!", __FILE__);
      return CERR_UNSUPPORTED_BROKER_TYPE;
   }
}

bool ModifyOrder(int ticket, double stop_loss, double take_profit)
{
   bool modRes = OrderModify(ticket, 0, stop_loss, take_profit, 0);

   if (!modRes)
   {
      Error("OrderModify Error: " + string(GetLastError()) + " SL " + string(stop_loss) + " TP " + string(take_profit), __FILE__);
   }

   return modRes;
}

int GetSpread()
{
   return int(NormalizeDouble(MathPow(10, DIGIT) * MathAbs(Ask - Bid), 0));
}

int GetTotalOrderCount(string symbol, int magicNumber)
{
   int counter = 0;
   
   for (int i=0;i < OrdersTotal();i++)
   {
      bool selected = OrderSelect(i, SELECT_BY_POS);

      if (selected)
      {
         if (OrderSymbol() == symbol && OrderMagicNumber() == magicNumber)
         {
            counter += 1;
         }
      }
   }

   return counter;
}