//+------------------------------------------------------------------+
//|                                                  CustomError.mqh |
//|                                                   Hans Kristanto |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Hans Kristanto"
#property link      "https://www.mql5.com"
#property strict

enum customError
{
   CERR_INVALID_ORDER_TYPE=10001,
   CERR_ORDER_NOT_SELECTED=10002,
   CERR_UNSUPPORTED_BROKER_TYPE=10003
};