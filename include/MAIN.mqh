   
 
   
class MAIN_PARENT_CLASS { // parent class
   protected:
      bool     InUp, InDn, TrUp, TrDn;   
      short    FastAtrPer, SlowAtrPer, Tout, Tin, Tper,  ExpirBars;
      
      
   public:
      void ORDERS_CLOSE(uchar Position);
      void CLOSE_BUY(float ClosePrice, float MinProfit, string Reason);
      void CLOSE_SEL(float ClosePrice, float MinProfit, string Reason);
   }FAST[MAX_EXPERTS_AMOUNT]; 
     
class FAST20 : public MAIN_PARENT_CLASS { // дочерний класс печати внешних переменных на график
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
      void iHILO();
      void iHL(int B);
      void ATR_DOUBLE(int B);
      void TIMER();
      
      void SET_BUY_STOP();
      void SET_SEL_STOP();
      void INPUT();    
      void VIRTUAL_ORDERS();  // виртуальные ордера для отрaботки откатов 
   
      
   }FAST_20[MAX_EXPERTS_AMOUNT];
   
void FAST20::MAIN(){
   if (!EXPERT_SET()) return; // выбор параметров эксперта из строки Exp массива CSV, сформированного из файла #.csv
   CONSTANT_COUNTER();
   ORDER_CHECK();  // подробности открытых и отложенных поз  Print("SELLSTOP=",SELLSTOP," BUYSTOP=",BUYSTOP);
   TIMER(); // может пора закрыть открытые позы?
   PENDING_ORDERS_DEL(); // удаление отложника, если остался один (при Del=2)
   if (!COUNT() || !CAN_TRADE()){// не торгуем и закрываем все позы в период запрета торговли
      AFTER(); 
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
         else           Lot=MM(MathMax(set.BUY.Val-set.BUY.Stp, set.SEL.Stp-set.SEL.Val), Risk, SYMBOL); Print("Lot=",Lot);
         Lot=float(0.1); ORDERS_SET();
      }  }   
      AFTER(); // сохранение на каждом баре переменных HI,LO,DM,DayBar... и значений индикаторов Real/Test    
   }  
        
      

// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ    
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
bool FAST20::CAN_TRADE(){// удаление всех поз в период запрета торговли
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
void FAST20::PENDING_ORDERS_DEL(){// УДАЛЕНИЕ ОТЛОЖНИКА, ЕСЛИ ОСТАЛСЯ ОДИН  
   if (Del!=2)  return;
   if (BUY.Typ==MARKET){ 
      if (SEL.Typ==STOP && SEL.Val!=mem.SEL.Val)  SEL.Val=0;   
      if (SEL.Typ==LIMIT)                         SEL.Val=0;  
      }
   if (SEL.Typ==MARKET){
      if (BUY.Typ==STOP && BUY.Val!=mem.BUY.Val)  BUY.Val=0;    
      if (BUY.Typ==LIMIT)                         BUY.Val=0;   
   }  }
   
