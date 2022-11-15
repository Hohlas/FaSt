#define NAME  "FA$T"  
#define VER   "200.625"
#define MAX_RISK  10
#property version    VER // yym.mdd
#property copyright  "Hohla"
#property link       "hohla.ru"
#property strict // Указание компилятору на применение особого строгого режима проверки ошибок 

extern short   BackTest=0;
extern short   Opt_Trades=5;  // Opt_Trades Влияет только на оптимизацию, остальные параметры и на опт ина бэктест
extern float   RF_=0;         // RF_ При оптимизациях отбрасываем
extern float   PF_=1;         // PF_ резы с худшими показателями
extern float   MO_=0;         // MO_ множитель спреда, т.е. MO=MO_ * Spred
extern float   Risk= 0;       // Risk процент депо в сделке (на реале задается в файле #.csv) Если в настройках выставить Risk>0, то риск, считанный из #.csv будет увеличен в данное количество раз
extern char    MM=1;          // MM 1..4 см. ММ: 
extern bool    Real=false;    // Real
extern char    CustMax=0;      // 0-Bal, 1-RF, 2-iRF, 3-MO/SD - максимизируемый при оптимизации параметр
extern string  SkipPer="";    // пропустить период при оптимизации

extern string z1=" -  S I G N A L S  - ";  
extern char  HL=1;    // HL=1..9  расчет экстремумов HL 
extern char  HLk=1;   // HLk=1..8 переменная для расчета HL
extern char  TR=1;    // TR=-8..8 расчет направления тренда 
extern char  TRk=1;   // TRk=1..9 переменная для расчета тренда
extern char  IN=1;    // IN=-8..8 виды входных фильтров 
extern char  Ik=1;    // Ik=1..9  переменная для фильтра входа 
extern string z2=" -  I N P U T S  - ";  
extern char  Del=1;   // Del=0..2 удаление отложников 0=не трогаем;  1=при появлении нового сигнала удаляем; 2=при появлении нового сигнала удаляем противоположный или если ордер остался один;
extern char  BrkBck=0;// BrkBck=-2..3 откат после пробоя
extern char  Inv=0;   // Rev=0..1 инвертирование тренда Up=!Up Dn=!Dn 
extern char  D=-2;    // D=-5..5  дельта к ценам входа
extern char  Iprice=1;// Iprice=0..3  цена входа 0-LO/HI, 1-Рынок, 2-HI/LO, 3-FIBO
extern char  S=6;     // S=1..8   S=(S+1)^2/10*ATR
extern char  P=5;     // P=1..8   P=(P+1)^2/10*ATR, при Р==0 без таргета
extern string z3=" -  O U T P U T S  - ";  
extern char  PM1=2;   // PM1=0..3  приближение профита при каждом откате
extern char  PM2=3;   // PM2=0..4  если цена провалится от максимальнодостигнутого на xATR, выставляется тейк на максимальнодостигнутый уровень
extern char  Tk=1;    // Tk=1..3    Трейлинг 
extern char  TS=0;    // TS=-1..1   Трейлинг от 0-стопа; 1-входа; -1-без трала   
extern char  Out=0;   // Out1=0..1  появление противоположного сигнала
extern char  OTr=0;   // OTr=-1..1  пропадание сигнала тренда / появление противоположного
extern char  Oprc=1;  // Oprc=1..3  цена выхода 1-ask, 2-MaxFromBuy, 3-HI
extern char  OD=1;    // OD=0..3    OD*ATR/2 прибавка к цене выхода
extern char  Oprf= 2; // Oprf=-1..4 сигнал к закрытию принимается если прибыль больше (Oprf+1)^2/10*ATR. Работает для Основного выхода и выхода по времени
extern string z4=" -  A T R  - ";  
extern char  A=15;    // A=7..28 (7)  кол-во баров  для долгосрочной ATR (49,196,784 баров) 
extern char  a=5;     // a=3..6  (1)  кол-во баров для краткосрочной atr
extern char  AtrLim=0;// AtrLim=0..30 (10) %ATR прибавляемый к уровням стопов
extern string z5=" -  T I M E  - ";  
extern char  tk=0;    // tk=0..3  (1)  (0..6 для 30минуток) 0-без временного фильтра,  >0-разрешена торговля с Tin=(tk-1)*8+T0 до Tin+T1, потом все позы херятся. Каждая единица прибавляет 8 часов к времени Т0  
extern char  T0=7;    // T0=1..8  (1)  при tk=0 определяет GTC: 1,2,3,5,8,13,21 бесконечно. При tk>0 время входа Tin=((8*(tk-1)+T0-1). Все в БАРАХ
extern char  T1=8;    // T1=1..8  (1)  при tk=0 определяет скока баров держать открытую позу: 1,3,5,8,16,24,36,бесконечно. При tk>0 количество баров в течении которых разрешена работа  с момента T0. При T1=0 || T1=8 ограничения по времени не работают  
extern char  tp=6;    // tp=-1..5  (1)  см. Signal 6 и расчет ATR -переменная для подстройки всяких новых идей

datetime BarTime,  ExpMemory, TestEndTime;
bool     InUp, InDn, TrUp, TrDn;
short    ExpirBars, Per, Tout, Tin, Tper,  LotDigits, DIGITS, Exp, ExpTotal, FastAtrPer, SlowAtrPer, HistDD,  LastTestDD, SkipFrom=0, SkipTo=0;
int      bar=1, Magic, Today, TesterFile;
float    PS[20], ch[6], Present, MaxSpred, Lot, Aggress, Lim,  MaxFromBuy, MinFromBuy, MaxFromSell, MinFromSell, CurDD,
         ATR, atr, ASK, BID, StopLevel, Spred, MaxRisk,  MaxMargin=float(0.7),  // максимальный суммарный риск всех позиций в одну сторону (все лонги или все шорты), максимальная загрузка маржи    
         InitDeposit, DayMinEquity, DrawDown, MaxEquity, MinEquity, Equity;  
string   history="", SYMBOL, Hist, filename, ID, Company,
         Prm1,Prm2,Prm3,Prm4,Prm5,Prm6,Prm7,Prm8,Prm9,Prm10,Prm11,Prm12,Prm13, OptPeriod,
         Str1,Str2,Str3,Str4,Str5,Str6,Str7,Str8,Str9,Str10,Str11,Str12,Str13; 
ulong    MagicLong;

#include <stdlib.mqh> 
#include <stderror.mqh> 
#include <StdLibErr.mqh> 
#include <iGRAPH.mqh>
#include <SERVICE.mqh>       // сохранение/восстановление параметров, отчеты и др. заморочки
#include <ERRORS.mqh>    // проверка исполнения
#include <MM.mqh> 

#include <ORDERS.mqh>
#include <INPUT.mqh>
#include <OUTPUT.mqh>
#include <SIGNAL.mqh>
#include <INDICATORS.mqh>
#include <COUNT.mqh>


 
double HH,LL;
void OnTick(){
   //if (TimeYear(Time[bar])<StartYear) return;
   if (Real && float(Ask-Bid)>MaxSpred) MaxSpred=float(Ask-Bid);
   if (Time[0]==BarTime) {CHECK_OUT(); return;}  // Сравниваем время открытия текущего(0) бара 
   
   DAY_STATISTIC(); // расчет параметров DD, Trades, массив с резами сделок
   if (TimeYear(Time[bar])>=SkipFrom && TimeYear(Time[bar])<SkipTo){ORDER_CHECK(); STANDBY(); return;}
   for (Exp=0; Exp<ExpTotal; Exp++){// осуществление перебора всех строк с входными параметрами за один тик (только для реала) 
      if (!EXPERT_SET()) continue; // выбор параметров эксперта из строки Exp массива CSV, сформированного из файла #.csv
      ORDER_CHECK();  // подробности открытых и отложенных поз  Print("SELLSTOP=",SELLSTOP," BUYSTOP=",BUYSTOP);
      if (!FINE_TIME()) STANDBY();  // не торгуем и закрываем все позы в период запрета торговли
      else{
         if (Tper>0) TIMER(); // может пора закрыть открытые позы?
         if (COUNT()){     // Print(DoubleToStr(Magic,0),": S T A R T, BackTest=",BackTest," ExpBUY=",BUY.Val+BUYSTOP+BUYLIMIT," ExpSELL=",SEL.Val+SELLSTOP+SELLLIMIT," memBUY.Val=",memBUY.Val," ExpMemory=",ExpMemory); // Расчет основных параметров, должен стоять после OrderCheck!   
            PENDING_ORDERS_DEL(); // удаление отложника, если остался один (при Del=2)
            if (BUY.Val>0 || SEL.Val>0){
               TRAILING_STOP();
               TRAILING_PROFIT();
               OUTPUT();   
               }
            INPUT();    
            VIRTUAL_ORDERS();  // виртуальные ордера для отрaботки откатов 
            //WEEKEND(); // закрываемся в конце сессии, чтоб не платить своп за овернайт
            MODIFY();  
            if (setBUY.Val!=0 || setSEL.Val!=0){ 
               if (Real)   ORDERS_COLLECT();
               else{   
                  if (Risk==0)   Lot=float(0.1);
                  else           Lot=MM(MathMax(setBUY.Val-setBUY.Stp, setSEL.Stp-setSEL.Val), Risk, SYMBOL); 
                  ORDERS_SET();
         }  }  }  }
      AFTER();
      }  
   END(); // Print("After BarTime=",BarTime);  // отчет о проведенных операциях, сохранение текущих параметров       
   BarTime=Time[0];   //Print("New BarTime=",BarTime); 
   }  
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ    
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
void FOMC(){   // 
   if (TimeDayOfWeek(Time[1])==5 && TimeDay(Time[1])>22){  // && TimeMinute(Time[0])>=60-Period()
      BUY.Val=0; SEL.Val=0; setBUY.Val=0; setSEL.Val=0; setBUY.Val=0; setSEL.Val=0;
   }  }
void WEEKEND(){   // 
   if (TimeDayOfWeek(Time[1])==5 && TimeHour(Time[0])>21){  // && TimeMinute(Time[0])>=60-Period()
      BUY.Val=0; SEL.Val=0; setBUY.Val=0; setSEL.Val=0; setBUY.Val=0; setSEL.Val=0;
   }  }
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ 
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ  
void PENDING_ORDERS_DEL(){// УДАЛЕНИЕ ОТЛОЖНИКА, ЕСЛИ ОСТАЛСЯ ОДИН  
   if (Del!=2)  return;
   if (BUY.Val>0){ 
      if (SELSTP!=0 && SELSTP!=memSEL.Val)   SELSTP=0;   
      if (SELLIM!=0)                      SELLIM=0;  
      }
   if (SEL.Val>0){
      if (BUYSTP!=0 && BUYSTP!=memBUY.Val)    BUYSTP=0;    
      if (BUYLIM!=0)                      BUYLIM=0;   
   }  }

// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ 
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
void TIMER(){   // ВРЕМЯ УДЕРЖАНИ ОТКРЫТЫХ ПОЗ (В Барах)  
   float TimeProfit; 
   if (tp<0)  TimeProfit=-20*ATR; // при отрицательных значениях tp поХ c каким кушем выходить
   else       TimeProfit=float((tp)*(tp)*0.1*ATR); // пороговая прибыль, без которой не закрываемся 0.1  0.4  0.9  1.6  2.5  3.6
   if (BUY.Val>0 && (Time[0]-BUY.T)/60/Period()>=Tper){ 
      if (Bid-BUY.Val>TimeProfit)  BUY.Val=0;  // достаточно профита, чтоб сразу закрыться
      else  if (BUY.Prf==0 || BUY.Prf>BUY.Val+TimeProfit)  BUY.Prf=BUY.Val+TimeProfit; // Перетащим профит на уровень жадности
      LINE("BuyPositionTimer", bar,BUY.Prf, bar+1,BUY.Prf, clrGreenYellow,0);    //Print("BuyPositionTimer=",(Time[0]-BuyTime)/60/Period()," CurProfit=",Bid-BUY.Val," TimeProfit=",TimeProfit); 
      } 
   if (SEL.Val>0 && (Time[0]-SEL.T)/60/Period()>=Tper){ 
      if (SEL.Val-Ask>TimeProfit) SEL.Val=0;  
      else  if (SEL.Prf==0 || SEL.Prf<SEL.Val-TimeProfit)  SEL.Prf=SEL.Val-TimeProfit;
      LINE("SellPositionTimer", bar,SEL.Prf, bar+1,SEL.Prf, clrGreenYellow,0);   //Print("SellPositionTimer=",(Time[0]-SellTime)/60/Period()," CurProfit=",SEL.Val-Ask," TimeProfit=",TimeProfit); 
   }  }
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
void STANDBY(){ // Закрытие всех поз в период запрета торговли 
   float TimeProfit;
   if (tp<0)  TimeProfit=-20*ATR; // при отрицательных значениях tp поХ c каким кушем выходить
   else       TimeProfit=float((tp)*(tp)*0.1*ATR); // пороговая прибыль, без которой не закрываемся 0.1  0.4  0.9  1.6  2.5  3.6
   if (BUY.Val>0){//Print("setBUY=",BUY.Val);
      if (Bid-BUY.Val>TimeProfit)  BUY.Val=0;  // достаточно профита, чтоб сразу закрыться
      else  if (BUY.Prf==0 || BUY.Prf>BUY.Val+TimeProfit)  BUY.Prf=BUY.Val+TimeProfit; // Перетащим профит на уровень жадности
      }
   if (SEL.Val>0){// Print("STANDBY: Sell=",SEL.Val," SEL.Val-Ask=",SEL.Val-Ask, " TimeProfit=",TimeProfit," ATR=",ATR);
      if (SEL.Val-Ask>TimeProfit) SEL.Val=0;  
      else  if (SEL.Prf==0 || SEL.Prf<SEL.Val-TimeProfit)  SEL.Prf=SEL.Val-TimeProfit;
      }
   BUYSTP=0; BUYLIM=0; SELSTP=0; SELLIM=0; // Если остались отложники, херим все
   MODIFY();// все закрываем, удаляем, модифицируем
   }
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ   
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ

