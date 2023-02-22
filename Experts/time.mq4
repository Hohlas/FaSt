//+------------------------------------------------------------------+
//|                                                         time.mq4 |
//|                                                            Hohla |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Hohla"
#property link      "http://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetTimer(60);
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer
   EventKillTimer();
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
datetime BarTime;
void OnTick(){
   if (Time[0]==BarTime) return;
   uint sec=uint(Time[0]+32);
   Print("Time[0]=",datetime(sec)," / ",sec-datetime(sec%(Period()*60)) ," %=" ,uint(sec%(Period()*60)), " datetime=",int(Period()*60)); //datetime(ExpirBars*Period()
   BarTime=Time[0];
   }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
   
  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//---
   
  }
//+------------------------------------------------------------------+
