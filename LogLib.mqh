//+------------------------------------------------------------------+
//|                                                       LogLib.mqh |
//|                                                   Hans Kristanto |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Hans Kristanto"
#property link      "https://www.mql5.com"
#property strict

void Info(string message, string source)
{
   Print("[INFO][", source, "] ", message);
}

void Warn(string message, string source)
{
   Print("[WARN][", source, "] ", message);
}

void Error(string message, string source)
{
   Print("[ERROR][", source, "] ", message);
}
