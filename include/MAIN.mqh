 
class EXPERT : public EXPERT_PARENT_CLASS { // дочерний класс: индивидуальные функции данного эксперта
   protected:
      bool InUp, InDn, TrUp, TrDn;   
   
   public: 
      void MAIN();
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
      void ATR_DOUBLE(int B);
      void LAYERS(int Layer);
      void iLAYERS(int B, int Layer);
      void TIMER();
      void ORDERS_CLOSE(uchar Position);
      void CLOSE_BUY(float ClosePrice, float MinProfit, string Reason);
      void CLOSE_SEL(float ClosePrice, float MinProfit, string Reason);
      void SET_BUY_STOP();
      void SET_SEL_STOP();
      void INPUT();    
      void VIRTUAL_ORDERS();  // виртуальные ордера для отрaботки откатов 
   }EXP[1]; // по умолчанию, создается один экземпляр класса, потом ресайзится в зависимости от кол-ва экспертов в файле #.csv
   
void EXPERT::MAIN(){
   if (!EXPERT_SET(ExpNum)) return; // выбор параметров эксперта из строки Exp массива CSV, сформированного из файла #.csv
   //CONSTANT_COUNTER();
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
   if (set.BUY.Val!=0 || set.SEL.Val!=0){ 
      if (Real)   ORDERS_COLLECT();
      else{   
         if (Risk==0)   Lot=float(0.1);
         else           Lot=MM(MathMax(set.BUY.Val-set.BUY.Stp, set.SEL.Stp-set.SEL.Val), Risk, SYMBOL); 
         Lot=float(0.1); ORDERS_SET();
      }  }   
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
   


         
