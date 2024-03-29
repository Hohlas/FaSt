#define OscN  30 // количество диапазонов HL для усреднения
 
class ATR_CLASS{  //  C Т Р У К Т У Р А   A T R
   public:
   float Fst;   // 
   float Slw;   //
   float Lim;    // точность совпадения уровней
   float Max;
   float Min;
   };   
class EXPERT : public EXPERT_PARENT_CLASS { // дочерний класс: индивидуальные функции данного эксперта
   protected:
      bool InUp, InDn, TrUp, TrDn;  
      float LayH4,LayH3,LayH2,LayH1,LayL4,LayL3,LayL2,LayL1, _HLC, _H, _L, _C, hl[OscN+1],Osc0, Osc1, Osc2;
      int BarLayers; // счетчик посчитанных бар
      short daybar;
      int   BarHL, LimitBars; // счетчик посчитанных бар
      char HLtrend;
      bool UpTrend, DnTrend; // запоминаемое значение тренда
      
      float DM, DM1, DMmax,DMmin, DMmax1, DMmin1;
      int BarDM;
      ATR_CLASS Atr;
   public: 
      float H, L, C, H1, L1, C1; //    
      void EXPERT(){ // конструктор по умолчанию,   
         Osc0=0; Osc1=0; Osc2=0;
         BarLayers=1; BarHL=1; BarDM=1;
         //Print("EXPERT constructor: CurExp=",CurExp," Name=",Name," VER=",VER);
         }
      // expert functions   
      void MAIN();
      int  INIT(); 
      bool FINE_TIME();
      void PENDING_ORDERS_DEL();
      bool COUNT();
      void CONSTANT_COUNTER();
      bool CAN_TRADE();
      void TRAILING_STOP();
      void TRAILING_PROFIT();
      void OUTPUT();
      void SIGNAL(bool TREND, char SigType, char SigParam, bool& Up, bool& Dn);
      void iHILO();
      void iHL(int B);
      float PIC_HI(int B, int width, float CompareLev);
      float PIC_LO(int B, int width, float CompareLev);
      bool FIND_HI(int B, int b, int width, float& NewHI, bool Condition);
      bool FIND_LO(int B, int b, int width, float& NewLO, bool Condition);
      float ATH(float LastHi);
      float ATL(float LastLo);
      void ATR_DOUBLE(int B);
      void LAYERS(int Layer);
      void iLAYERS(int B, int Layer);
      void iOSC();
      void iDM(int DmMode, int per);
      
      void TIMER();
      void ORDERS_CLOSE(uchar Position);
      void CLOSE_BUY(float ClosePrice, float MinProfit, string Reason);
      void CLOSE_SEL(float ClosePrice, float MinProfit, string Reason);
      void SET_BUY_STOP();
      void SET_SEL_STOP();
      void INPUT();    
      void VIRTUAL_ORDERS();  // виртуальные ордера для отрaботки откатов 
      void COUNT_200900();
      void SET_BUY_200900();
      void SET_SEL_200900();
      void TRAILING_200900(float& TrlBuy, float& TrlSel); 
      void TRAILING_200833(float& TrlBuy, float& TrlSel);
   }EXP[1]; // по умолчанию, создается один экземпляр класса, потом ресайзится в зависимости от кол-ва экспертов в файле #.csv
   
void EXPERT::MAIN(){
   if (!EXPERT_SET(ExpNum)) return; // выбор параметров эксперта из строки ExpNum массива CSV, сформированного из файла #.csv
   ORDER_CHECK();  // подробности открытых и отложенных поз  Print("SELLSTOP=",SELLSTOP," BUYSTOP=",BUYSTOP);
   TIMER(); // может пора закрыть открытые позы?
   PENDING_ORDERS_DEL(); // удаление отложника, если остался один (при Del=2)
   if (!COUNT() || !CAN_TRADE()){// не торгуем и закрываем все позы в период запрета торговли
      AFTER(ExpNum); 
      return;}
   if (BUY.Typ==MARKET || SEL.Typ==MARKET){
      TRAILING_STOP();
      TRAILING_PROFIT();
      OUTPUT();   
      }
   INPUT();    
   VIRTUAL_ORDERS();  // виртуальные ордера для отрaботки откатов 
   MODIFY();  
   if (set.BUY.Val || set.SEL.Val) ORDERS_SET(); 
   AFTER(ExpNum); // сохранение на каждом баре переменных HI,LO,DM,DayBar... и значений индикаторов Real/Test    
   }  
        
      

// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ    
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
bool EXPERT::CAN_TRADE(){// удаление всех поз в период запрета торговли
   if (!FINE_TIME()                                                  // временной фильтр
   || (Wknd==1 && TimeDayOfWeek(TimeCurrent())==5 && TimeDay(TimeCurrent())>22)  // FOMC
   || (Wknd==2 && TimeDayOfWeek(TimeCurrent())==5 && TimeHour(TimeCurrent())>21)){// Weekend
      ORDERS_CLOSE(0); // все закрываем и удаляем
      MODIFY();   
      return (false);
      }
   return (true);
   }   
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ 
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ  
void EXPERT::PENDING_ORDERS_DEL(){// УДАЛЕНИЕ ОТЛОЖНИКА, ЕСЛИ ОСТАЛСЯ ОДИН  
   if (Del!=2)  return;
   if (BUY.Typ==MARKET){ 
      if (SEL.Typ==STOP && SEL.Val!=mem.SEL.Val)  SEL.Val=0;   
      if (SEL.Typ==LIMIT)                         SEL.Val=0;  
      }
   if (SEL.Typ==MARKET){
      if (BUY.Typ==STOP && BUY.Val!=mem.BUY.Val)  BUY.Val=0;    
      if (BUY.Typ==LIMIT)                         BUY.Val=0;   
   }  }
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ    
//+------------------------------------------------------------------+
//| функция родительского класса по соднанию и обработке 
//| списка внешних переменных             
//+------------------------------------------------------------------+
void EXPERT_PARENT_CLASS::EXTERN_VARS(){// функция родительского класса 
   DATA("Mod", Mod);
   DATA(" - S I G N A L  - "); //////
   DATA("HL",  HL);
   DATA("HLk", HLk);
   DATA("TR",  TR);
   DATA("TRk", TRk);
   DATA("IN",  IN);
   DATA("Ik",  Ik);
   DATA(" - I N P U T  - ");////////
   DATA("Del", Del);
   DATA("BrkBck",BrkBck);
   DATA("Inv", Inv);
   DATA("D",   D);
   DATA("Iprice",Iprice);
   DATA("S",   S);
   DATA("P",   P);
   DATA(" - O U T P U T  - ");////// 
   DATA("PM1", PM1);
   DATA("PM2", PM2);
   DATA("Tk",  Tk);
   DATA("TS",  TS);
   DATA("Out", Out);
   DATA("OTr", OTr);
   DATA("Oprc",Oprc);
   DATA("OD",  OD);
   DATA("Oprf",Oprf);
   DATA("Wknd",Wknd);
   DATA(" - A T R  - ");/////////// 
   DATA("A",   A);
   DATA("a",   a);
   DATA("AtrLim",AtrLim);
   DATA(" - T I M E  - "); ///////
   DATA("tk",  tk);
   DATA("T0",  T0);
   DATA("T1",  T1);
   DATA("tp",  tp);
   }       


         
