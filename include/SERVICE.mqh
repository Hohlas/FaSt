#define MAGIC_GEN    1  // виды  
#define LABEL_WRITE  2  // обработки
#define READ_FILE    3  // входных 
#define READ_ARR     4  // данных 
#define WRITE_HEAD   5  // 
#define WRITE_PARAM  6
#define PARAMS 50 // максимальное количество входных параметров эксперта
#define MAX_EXPERTS_AMOUNT 255
struct EXPERTS_DATA{// данные эксперта
   short    Per, HistDD, LastTestDD, Back;
   datetime Bar, TestEndTime, ExpMemory,BuyExp,SelExp; 
   char     PRM[PARAMS];
   string   ID, Sym, Name, Hist, OptPeriod;
   float    Risk, Buy, Sel, BuyStp, BuyPrf, SelStp, SelPrf, Lot;
   int      Magic; 
   };
EXPERTS_DATA CSV[MAX_EXPERTS_AMOUNT]; 
struct PICS {float PssP;}; // структура  PICS для совместимости с $o$imple в файле ORDERS.mqh 
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ 
int OnInit(){// функции сохранения и восстановления параметров на случай отключения терминала в течении часа // ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
   if (!IsTesting() && !IsOptimization()) {Real=true;} // на реале формирование файла проверки обязательно  
   InitDeposit=float(AccountBalance());
   DayMinEquity=InitDeposit;
   SYMBOL=Symbol();
   Per=short(Period());
   MaxRisk=MAX_RISK;
   if (IsTesting())     Company="Test";
   else if (IsDemo())   Company="Demo"; 
   else                 Company=StringSubstr(AccountCompany(),0,StringFind(AccountCompany()," ",0)); // Первое слово до пробела
   if (MarketInfo(Symbol(),MODE_LOTSTEP)<0.1) LotDigits=2; else LotDigits=1;
   Print("\n\n\n\nInit():  Time[",Bars,"]=",TimeToStr(Time[Bars-1],TIME_DATE)," Time[1]=",TimeToStr(Time[1],TIME_DATE));   
   CHART_SETTINGS();
   if (Real){
      for (int i=ObjectsTotal()-1; i>=0; i--) ObjectDelete(ObjectName(i)); // удаляются все объекты (обязательно в обратном порядке)
      if (Bars<10000) Alert("History too short: Time["+S0(Bars)+"]="+BTIME(Bars-1)+" Bars should be more 10000"); // история слишком короткая, индикаторы могут посчитаться неверно
      if (Risk==0) Aggress=1; // Если в настройках выставить риск>0, то риск, считанный из #.csv будет увеличен в данное количество раз. 
      else{
         Aggress=Risk; 
         MaxRisk=MAX_RISK*Aggress; 
         Alert(" WARNING, Risk x ",Aggress,"  MaxRisk=",MaxRisk, " !!!");
         } 
      LABEL("                  "+NAME+VER+" Back="+S0(BackTest)+" Risk="+S1(Risk)+" MaxRisk="+S0(MaxRisk));
      LABEL("                  Time["+S0(Bars)+"]="+TimeToStr(Time[Bars-1],TIME_DATE)+" Time[1]="+TimeToStr(Time[1],TIME_DATE));    
      if (!INPUT_FILE_READ()) return (INIT_FAILED); // занесение в массив CSV считанных из файла #.csv входных параметров всех экспертов  
      if (!GlobalVariableCheck("LastBalance"))     GlobalVariableSet("LastBalance",AccountBalance()); 
      GlobalVariableSet("CHECK_OUT_Time",TimeCurrent()); // глобал для обеспечения периодичности проверки ордеров
      GlobalVariableSet("LastOrdTime",LAST_ORD_TIME()); // время последнего выставленного ордера  
   }else{
      if (BackTest==0){// режим оптимизации
         ExpTotal=1; // отключение режима перебора экспертов
         MAGIC_GENERATOR();
         CONSTANT_COUNTER(); // Индивидуальные константы: MinProfit, PerAdapter, AtrPer, HLper, время входа/выхода...
      }else{// работа экспетра со считанными из файла #.csv параметрами
         if (!INPUT_FILE_READ()) return (INIT_FAILED); // занесение в массив CSV считанных из файла #.csv входных параметров всех экспертов
         Exp=0; // в режиме теста/оптимизации в массиве всего одно значение с параметрами эксперта из строки BackTest 
         DATA_PROCESSING(0, READ_ARR); // считываем параметры строки "Exp" в переменные эксперта
         }
      if (StringLen(SkipPer)==5){   
         SkipFrom=2000+short(StrToDouble(StringSubstr(SkipPer,0,2)));
         SkipTo  =2000+short(StrToDouble(StringSubstr(SkipPer,3,2))); Print("Skip From-To =  ",SkipFrom,"-",SkipTo);
         }    
      INPUT_PARAMETERS_PRINT();  // ПЕЧАТЬ В ЛЕВОЙ ЧАСТИ ГРАФИКА ВХОДНЫХ ПАРАМЕТРОВ ЭКСПЕРТА   
      }
   ERROR_CHECK(__FUNCTION__);
   return (INIT_SUCCEEDED);   
   }  
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
void TESTER_FILE_CREATE(string Inf, string FileName){ // создание файла отчета со всеми характеристиками  //////////////////////////////////////////////////////////////////////////////////////////////////
   ResetLastError(); 
   TesterFile=FileOpen(FileName, FILE_READ|FILE_WRITE | FILE_SHARE_READ | FILE_SHARE_WRITE, ';'); 
   if (TesterFile<0){
      REPORT(__FUNCTION__+" Can't open file "+FileName+"!!!"); // нельзя вызывать ERROR_CHECK(), т.к. в ней вызывается TESTER_FILE_CREATE()
      return;}
   string SymPer=SYMBOL+S0(Per);
   //MAGIC_GENERATOR();
   if (FileReadString(TesterFile)==""){
      FileWrite(TesterFile,"INFO","SymPer",Str1,Str2,Str3,Str4,Str5,Str6,Str7,Str8,Str9,Str10,Str11,Str12,Str13,"Magic"); 
      DATA_PROCESSING(TesterFile, WRITE_HEAD);
      FileSeek (TesterFile,-2,SEEK_END); FileWrite(TesterFile,""," ","start");
      for (short i=1; i<=day; i++){ 
         FileSeek (TesterFile,-2,SEEK_END);  
         FileWrite(TesterFile,"",TimeToStr(DayTime[i],TIME_DATE)); // ежегодные отсечки высотой в последний баланс
      }  }
   int magic=Magic;
   if (Real)   magic=CSV[Exp].Magic;//    ID=CSV[Exp].ID;   
   FileSeek (TesterFile, 0,SEEK_END); // перемещаемся в конец   
   FileWrite(TesterFile,    Inf  , SymPer ,Prm1,Prm2,Prm3,Prm4,Prm5,Prm6,Prm7,Prm8,Prm9,Prm10,Prm11,Prm12,Prm13, magic); 
   DATA_PROCESSING(TesterFile, WRITE_PARAM);
   FileSeek (TesterFile,-2,SEEK_END); FileWrite(TesterFile,""," "," ");
   }
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
void MAGIC_GENERATOR(){
   MagicLong=0;
   DATA_PROCESSING(0, MAGIC_GEN);   // генерит огромное чило MagicLong типа ulong складыая побитно все входные параметры
   ID=CODE(MagicLong);  // Уникальное 70-ти разрядное строковое имя из символов, сгенерированных на основе числа MagicLong 
   Magic=MathAbs(int(MagicLong));   // обрезаем до размеров, используемых в функциях OrderSend(), OrderModify()...
   }  
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ     
void INPUT_PARAMETERS_PRINT(){ // ПЕЧАТЬ В ЛЕВОЙ ЧАСТИ ГРАФИКА ВХОДНЫХ ПАРАМЕТРОВ ЭКСПЕРТА и создание файла настроек magic.set 
   if (IsOptimization()) return;
   //Print("Magic=",Magic);
   LABEL("                  "+NAME+VER+" Back="+S0(BackTest)+" Magic="+S0(Magic));
   LABEL("                  Time["+S0(Bars)+"]="+TimeToStr(Time[Bars-1],TIME_DATE)+" Time[1]="+TimeToStr(Time[1],TIME_DATE));
   LABEL(" "); 
   string FileName=NAME+"_"+S0(Magic)+".set";   // TerminalInfoString(TERMINAL_DATA_PATH)+"\\tester\\files\\"+Name+DoubleToString(Magic,0)+".txt";
   int file=FileOpen(FileName,FILE_WRITE|FILE_TXT);
   if (file<0){   
      ERROR_CHECK(__FUNCTION__+" Can't open file "+FileName+"!!!");   
      return;}
   FileWrite(file,"BackTest=",0);
   DATA_PROCESSING(file, LABEL_WRITE);
   FileClose(file);
   ERROR_CHECK(__FUNCTION__); 
   }  
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ     
void DATA(string name, char& param, int& source, char ProcessingType){// выбор типа обработки входных данных в DATA_PROCESSING
   char i=2; 
   switch (ProcessingType){// тип обработки входных данных
      case LABEL_WRITE: LABEL(name+"="+S0(param));  FileWrite(source,name+"=",S0(param)); ERROR_CHECK("DATA/LABEL_WRITE"); break;
      case READ_FILE:   param=char(StrToDouble(FileReadString(source)));                  ERROR_CHECK("DATA/READ_FILE");   break; 
      case READ_ARR:    param=CSV[Exp].PRM[source];    source++;                          ERROR_CHECK("DATA/READ_ARR");    break;//  присвоение переменным эксперта параметров строки Exp массива CSV, считанного из файла #.csv   Print(name,"=",param);
      case WRITE_HEAD:  FileSeek (source,-2,SEEK_END); FileWrite(source,"",name);         ERROR_CHECK("DATA/WRITE_HEAD");  break;   
      case WRITE_PARAM: FileSeek (source,-2,SEEK_END); FileWrite(source,"",param);        ERROR_CHECK("DATA/WRITE_PARAM"); break;    
      case MAGIC_GEN:   // формирование длинного числа из всех параметров эксперта
         while (i<param) {i*=2; if (i>4) break;} // кол-во зарзрядов (бит), необходимое для добавления нового параметра, но не более 3, чтобы не сильно растягивать число
         MagicLong*=i; // сдвиг MagicLong на i кол-во зарзрядов  
         MagicLong+=param; // Добавление очередного параметра
         ERROR_CHECK("DATA/MAGIC_GEN");
         break;
   }  }      
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ 
bool INPUT_FILE_READ (){// считывание из csv файла входных параметров
   string str, FileName="#.csv"; 
   int StrPosition, File=-1, chr;
   datetime StartWaiting=TimeLocal(); 
   ExpPause=NONSYNCHRO(); // индивидуальная пауза для каждого эксперта в пределах 100мс
   File=FileOpen(FileName, FILE_SHARE_READ | FILE_SHARE_WRITE); 
   if (File<0){
      ERROR_CHECK(__FUNCTION__+" Can't open file "+FileName+"!!!"); 
      if (!IsTesting() && !IsOptimization()) MessageBox(__FUNCTION__+" Can't open file "+FileName);
      return(false);
      }        
   short Column, e=0,  TheSameChart=0, Back=1; 
   while (!FileIsEnding(File)){ 
      Back++; // номер строки в файле параметров
      str=FileReadString(File); while (!FileIsLineEnding(File)) str=FileReadString(File); // читаем всю херь, пока не кончилась строка 
      if (!Real && (IsTesting() || IsOptimization()) && Back!=BackTest) continue; // режим бэктеста: нужна только одна строка с заданными параметрами
      str=FileReadString(File); // считываем первый столбец с именем эксперта, датами оптимизации и спредами 
      if (StringFind(str," ",0)<0 || StringFind(str,"-",0)<0){
         CSV[e].Magic=1; // признак пустой строки
         CSV[e].Risk=0;  // признак "пустого" эксперта
         continue;} // если в первом столбце не найдены символы " " и "-" то это левая строка, и параметры из нее не читаем
      StrPosition=StringFind(str," ",0); // ищем в строке пробел
      CSV[e].Back=Back; // номер строки в файле параметров
      CSV[e].Name=StringSubstr(str,0,StrPosition); 
      StrPosition=StringFind(str,"-",10); // ищем "-" разелитель между началом и концом теста
      CSV[e].TestEndTime=StrToTime(StringSubstr(str,StrPosition+1,10)); // дату конца теста сразу переводим в секунды  Print("Seconds=",TestEndTime," TestEndTime=",TimeToStr(TestEndTime,TIME_DATE));
      StrPosition=StringFind(str,"OPT-",30); // ищем "OPT-" надпись перед сохраненным периодом оптимизации
      if (StrPosition>0)   CSV[e].OptPeriod=StringSubstr(str,StrPosition+4,0); 
      else                 CSV[e].OptPeriod="UnKnown"; // Print("OptPeriod=",OptPeriod);// период начальной оптимизации, сохраненный при самой первой оптимизации
      str=FileReadString(File);// считываем второй столбец с названием пары и ТФ     
      for (chr=0; chr<StringLen(str); chr++)  // Print("s=",StringSubstr(str,chr,1)," cod=",StringGetChar(str,chr));      
         if (StringGetChar(str,chr)>47 && StringGetChar(str,chr)<58) break; // попалось число с кодом: ("0"-48, "1"-49, "2"-50,..., "9"-57)
      CSV[e].Sym=StringSubstr(str,0,chr); 
      CSV[e].Per=short(StrToDouble(StringSubstr(str,chr,0)));       //Print(" Name=",CSV[e].Name," Sym=",CSV[e].Sym," Per=",CSV[e].Per);
      for (Column=3; Column<15; Column++){ // все столбцы до Risk
         str=FileReadString(File); // читаем просадки HistDD и LastTestDD
         if (Column==7){
            StrPosition=StringFind(str,"_",0);
            CSV[e].HistDD=short(StrToDouble(StringSubstr(str,0,StrPosition)));         //Print("aHistDD[",e,"]=",CSV[e].HistDD);
            CSV[e].LastTestDD=short(StrToDouble(StringSubstr(str,StrPosition+1,0)));   //Print("aLastTestDD[",e,"]=",CSV[e].LastTestDD);
         }  }   
      CSV[e].Risk =float(StrToDouble(FileReadString(File))); // 15-й столбец (Risk)
      CSV[e].Magic=int(StrToDouble(FileReadString(File))); // 16-й столбец (Magic) нельзя прописывать значение в Magic, т.к. в Before() его надо обновлять только при совпадении Expert,Sym,Per. В GlobalOrdersSet() значение Magic формируется из str, нельзя через DataRead(), т.к. разные эксперты формируют его посвоему.     
      //CSV[e].ID=FileReadString(File);  
      if (CSV[e].Name==NAME+VER && CSV[e].Sym==Symbol() && CSV[e].Per==Period() && CSV[e].Risk>0) TheSameChart++; // признак того, что попалась хоть одна строка для текущего чарта   
      if (!GlobalVariableCheck(CSV[e].Name+CSV[e].Sym+S0(CSV[e].Per)))     GlobalVariableSet(CSV[e].Name+CSV[e].Sym+S0(CSV[e].Per), iTime(CSV[e].Sym,CSV[e].Per,0));  // глобал чарта эксперта для проверки готовности в ф. END()
      for (chr=0; chr<PARAMS; chr++) CSV[e].PRM[chr]=char(StrToDouble(FileReadString(File)));
      LOAD_GLOBALS(CSV[e].Magic);// Print(CSV[e].Magic," ",Symbol(),Period()," RealParamRestore");
      CSV[e].Hist="";
      CSV[e].Bar=BarTime;
      CSV[e].Buy=memBUY.Val;  CSV[e].BuyStp=memBUY.Stp; CSV[e].BuyPrf=memBUY.Prf; CSV[e].BuyExp=memBUY.Exp;
      CSV[e].Sel=memSEL.Val;  CSV[e].SelStp=memSEL.Stp; CSV[e].SelPrf=memSEL.Prf; CSV[e].SelExp=memSEL.Exp;
      CSV[e].ExpMemory=ExpMemory;  
      Print("--",CSV[e].Name," Magic[",e,"]=",CSV[e].Magic," Back=",CSV[e].Back," HistDD=",CSV[e].HistDD," LastTestDD=",CSV[e].LastTestDD," Risk=",CSV[e].Risk," PRM=",CSV[e].PRM[0],",",CSV[e].PRM[1],",",CSV[e].PRM[2],",",CSV[e].PRM[3]," memBUY=",CSV[e].Buy," memSELL=",CSV[e].Sel," ExpBar=",CSV[e].Bar," ExpMemory=",CSV[e].ExpMemory," TestEndTime=",DTIME(CSV[e].TestEndTime));
      if (CSV[e].Risk<=0 && CSV[e].Magic>1){  // считаем количество участвующих в торговле экспертов
         Magic=CSV[e].Magic; 
         EMPTY_EXPERTS_DELETE();
         }
      else e++;   
      }    
   FileClose(File); 
   ExpTotal=e;
   if (Real){// удаление всех ордеров, мэджики которых отсутствуют в файле #.csv
      for (int i=0; i<OrdersTotal(); i++){// перебераем все открытые и отложенные ордера всех экспертов счета 
         if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)!=true) continue;
         if (OrderType()==6) continue; // ролловеры 
         bool MustDie=true;
         for (short ex=0; ex<ExpTotal; ex++) if (CSV[ex].Magic==OrderMagicNumber()) MustDie=false; // если мэджик ордера есть в списке, не трогаем его         
         if (MustDie){
            Alert("Expert ",OrderMagicNumber()," does not exist in #.csv, It's orders will be deleted");
            Magic=OrderMagicNumber();   
            EMPTY_EXPERTS_DELETE();
      }  }  }
   if (Real && TheSameChart==0){
      if (!IsTesting() && !IsOptimization()) 
      MessageBox(__FUNCTION__+": File "+FileName+" have no data for "+NAME+VER+Symbol()+S0(Period()));
      REPORT    (__FUNCTION__+": File "+FileName+" have no data for "+NAME+VER+Symbol()+S0(Period())+"!");
      }
   REPORT(__FUNCTION__+": ExpetrsTotal="+S0(ExpTotal)+" ExpPause="+S0(ExpPause)+"ms");   
   ERROR_CHECK(__FUNCTION__);
   return(true);
   }        
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
void EMPTY_EXPERTS_DELETE(){// удаление всех поз экспертов с риском=0.
   if (!Real) return;
   ORDER_CHECK();
   if (BUY.Val==0 && BUYSTP==0 && BUYLIM==0 && SEL.Val==0 && SELSTP==0 && SELLIM==0) return;          
   BUY.Val=0; BUYSTP=0; BUYLIM=0; SEL.Val=0; SELSTP=0; SELLIM=0; 
   Alert("Expert ",Magic," remove it's orders");
   MODIFY(); // херим все ордера c этим Мэджиком 
   ERROR_CHECK(__FUNCTION__);
   }
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ  
bool EXPERT_SET(){ // запуск в начале функции Start 
   if (!Real && BackTest==0) return (true);     // флаг продолжения основного цикла ф. OnTick() 
   if (BackTest>0 && CSV[Exp].Back!=BackTest) return (false);  // ожидание совпадения перебираемого Exp с заданным номером строки BackTest  
   if (CSV[Exp].Magic==0 || CSV[Exp].Risk==0 || CSV[Exp].Name!=NAME+VER || CSV[Exp].Sym!=Symbol() || CSV[Exp].Per!=Period()) return(false); // данные из строки BackTest соответствуют этому эксперту
   DATA_PROCESSING(0, READ_ARR); // считываем параметры строки "Exp" в переменные эксперта
   if (!CHECKSUM()) return(false); // Если не совпала контрольная сумма входных параметров, отключаем работу
   CONSTANT_COUNTER(); // вычисление индивидуальных констант: MinProfit, PerAdapter, AtrPer, время входа/выхода...
   LOAD_VARIABLES(Exp);// восстановление индивидуальных переменных (HI,LO,DM,DayBar) на каждом баре в режиме последовательного запуска
   //Print("Exp=",Exp," Name[",Exp,"]=",CSV[Exp].Name," CSV[",Exp,"].Risk=", CSV[Exp].Risk," Risk=",Risk," Magic=",Magic," ExpMemory=",TIME(ExpMemory)); 
   ERROR_CHECK(__FUNCTION__);
   return(true); // продолжаем выпоалнение эксперта с выбраными параметрами из строки Exp файла #.csv
   } 
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
bool CHECKSUM(){ // Проверка контрольной суммы входных параметров
   MAGIC_GENERATOR();
   if (Magic==CSV[Exp].Magic) return(true);
   //if (ID==CSV[Exp].ID) return(true); // проверка контрольной суммы считанных параметров: ID - посчитан из входных параметров,  CSV[Exp].ID - считан из файла
   REPORT(" ATTENTION! CSV["+S0(Exp)+"].Magic != Magic :  CSV["+S0(Exp)+"].Magic="+S0(CSV[Exp].Magic)+", Magic="+S0(Magic));
   Alert (" ATTENTION! CSV["+S0(Exp)+"].Magic != Magic :  CSV["+S0(Exp)+"].Magic="+S0(CSV[Exp].Magic)+", Magic="+S0(Magic));
   return(false); // отключаем торговлю для этого эксперта
   } 
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
void AFTER(){// запуск в конце функции Start 
   if (!Real) return; 
   CSV[Exp].Buy   =memBUY.Val; // сохраняем индивидуальные переменные эксперта
   CSV[Exp].BuyStp=memBUY.Stp; 
   CSV[Exp].BuyPrf=memBUY.Prf;
   CSV[Exp].BuyExp=memBUY.Exp;
   CSV[Exp].Sel   =memSEL.Val; 
   CSV[Exp].SelStp=memSEL.Stp;
   CSV[Exp].SelPrf=memSEL.Prf;
   CSV[Exp].SelExp=memSEL.Exp; 
   CSV[Exp].Bar=Time[0];
   SAVE_VARIABLES(Exp); // сохранение индивидуальных переменных (HI,LO,DM,DayBar) на каждом баре в режиме последовательного запуска
   CHECK_VARIABLES(); // сравнение значений индикаторов Real/Test
   //Print (Magic,"/",SYMBOL, CSV[BackTest-1].Per,": After(",BackTest-1,")"," Risk=",Risk," RevBUY=",RevBUY," RevSELL=",RevSELL," ExpMemory=",TimeToStr(ExpMemory,TIME_DATE | TIME_SECONDS)," HistDD=",HistDD," LastTestDD=",LastTestDD," Bar=",TimeToStr(Time[0],TIME_DATE | TIME_MINUTES)); 
   }
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ      
void END(){// запуск после прохода всех экспертов 
   if (!Real) return; 
   GlobalVariableSet(NAME+VER+Symbol()+S0(Period()), Time[0]); // флаг завершения обработки своих ордеров маркируем временем открытия текущего бара для дальнейшей прверки общей готовности
   ERROR_CHECK(__FUNCTION__+" line-"+S0(__LINE__));
   WAITING("GlobalOrdersSet",120);            // захват доступа к функции "GlobalOrdersSet"
   if (GlobalVariableGet(NAME+VER+Symbol()+S0(Period())) == Time[0]){// собственный глобал готовности НЕ изменился, т.е. не участвовал в ф. GLOBAL_ORDERS_SET() 
      string   WarningExperts;
      for (int i=0; i<300; i++){// на протяжении 30 секунд ждем флаги готовноси всех экспертов проверяя их каждые 100мс
         WarningExperts=""; // список опоздавших
         for (uchar e=0; e<ExpTotal; e++){ // сверяем время готовности каждого эксперта с текущим времением с учетом его ТФ   
            string NameSymPer=CSV[e].Name+CSV[e].Sym+S0(CSV[e].Per); // текстовый идентификатор эксперта,
            if (TimeCurrent() - GlobalVariableGet(NameSymPer) < CSV[e].Per*60 - 300)    continue; // флаг готовности эксперта был выставлен менее (Период-5мин) назад, т.е. он "свежий"
            if (WarningExperts=="" || StringFind(WarningExperts,NameSymPer,0)<0){// Список опоздавших пуст, либо там нет записи об этом эксперте
               WarningExperts=WarningExperts+" \n"+NameSymPer;                     // обновляем список "опоздавших"
               // if (i==299) Print(NameSymPer," FlagTime=",TimeToString((datetime)GlobalVariableGet(NameSymPer),TIME_SECONDS),", CurTime=",TimeToString(TimeCurrent(),TIME_SECONDS), " FlagAge=",(TimeCurrent() - GlobalVariableGet(NameSymPer))/60," minutes");
            }  }   
         if (WarningExperts==""){ // если список "опоздавших" пуст, заканчиваем ожидание
            Print(Magic,": ExpertsWaitingTime=",i*100,"ms, All ",ExpTotal," Experts Ready");
            break;}   
         Sleep(100); // мс
         } 
      if (WarningExperts!="") REPORT("Warning!!! ExpertsNotReady:"+WarningExperts);
      for (uchar e=0; e<ExpTotal; e++)  // маркируем все обрабатываемые эксперты, увеличивая их флаг на 1
         GlobalVariableSet(CSV[e].Name+CSV[e].Sym+S0(CSV[e].Per), GlobalVariableGet(CSV[e].Name+CSV[e].Sym+S0(CSV[e].Per)) + 1); 
      GLOBAL_ORDERS_SET();    //  
      }
   FREE("GlobalOrdersSet");   
   ERROR_CHECK(__FUNCTION__+" line-"+S0(__LINE__));
   SAVE_PARAMS(); // Сохранение глобальных переменных экспертов данного чарта в файл, доклад о их последних сделках
   SAVE_HISTORY();  
   MAIL_SEND(); 
   if (TimeHour(Time[bar])<TimeHour(Time[bar+1])){// раз в сутки обновляем инфу о экспертах
      REPORT("MIDNIGHT CSV FILE RELOAD");
      INPUT_FILE_READ();} 
   MaxSpred=0; // для статистики пишем макс спред в функции ValueCheck()
   }
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ   
datetime WAITING(string GlobalName, double MaxWaitingTime){// ожидание освобождения глобальной переменнной не более MaxWaitingTime секунд
   if (!Real) return(0); // 
   if (!GlobalVariableCheck(GlobalName)){ // глобал объявляется впервые 
      GlobalVariableSet(GlobalName,0);    // установка глобала
      GlobalVariableSet(GlobalName+"Busy",TimeLocal());} // фиксация времени его установки
   datetime StartWaiting=TimeLocal(), WaitingTime=0, BusyTime=0;
   while (1){ // захват потока 
      BusyTime=TimeLocal()-datetime(GlobalVariableGet(GlobalName+"Busy")); // время с момента последнего изменения глобала
      WaitingTime=TimeLocal()-StartWaiting; // время ожидания
      GlobalVariableSetOnCondition(GlobalName,Magic,0); // установка глобальной переменной GlobalName в значение Magic, если она равна 0.
      if (GlobalVariableGet(GlobalName)==Magic) break;  // если уже был захвачен
      Sleep(ExpPause); 
      if (BusyTime>MaxWaitingTime && WaitingTime>MaxWaitingTime){ // прождали, насильно захватываем торговый поток, т.к. что-то значит не в порядке
         REPORT("Expert "+S0(GlobalVariableGet(GlobalName))+" hold global '"+GlobalName+"' "+TimeToString(BusyTime,TIME_SECONDS)+"!!! Set own flag: "+S0(Magic)); // докладываем о занятом торговом потоке
         GlobalVariableSet(GlobalName,Magic); // принудительный захват
         StartWaiting=TimeLocal();
      }  }
   Print(Magic,": '",GlobalName,"' WaitingTime=",TimeToString(WaitingTime,TIME_SECONDS),", BusyTime=",TimeToString(BusyTime,TIME_SECONDS));   
   GlobalVariableSet(GlobalName+"Busy",TimeLocal());// обновляем время последнего изменения глобала
   return(BusyTime); // кол-во секунд с момента последнего изменения глобала
   }
void FREE(string GlobalName){// освобождение глобальной переменной
   if (!Real) return; // 
   if (GlobalVariableGet(GlobalName)!=Magic) // кто-то уже занял без спроса
      REPORT("Expert "+S0(GlobalVariableGet(GlobalName))+" already get global '"+GlobalName+"' !!! LastSetTime="+TimeToString(TimeLocal()-datetime(GlobalVariableGet(GlobalName+"Busy")),TIME_SECONDS)); 
   else{
      GlobalVariableSet(GlobalName,0);  // освобождаем глобальную переменную
   }  }
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ   
uchar ExpPause;
uchar NONSYNCHRO(){  // индивидуальная пауза для каждого эксперта. 
   int ms=0;
   for (int i=0; i<StringLen(Symbol()); i++)  ms+=StringGetChar(Symbol(),i); //Print(StringGetChar(Symbol(),i),"+");}
   for (int i=0; i<StringLen(NAME+VER); i++)  ms+=StringGetChar(NAME+VER,i); //Print(StringGetChar(Name,i),"+");}
   ms+=Period(); // индивидуальная пауза для каждого эксперта, чтобы не стартовали разом
   while (ms>100) ms-=100;  
   Sleep(ms);
   return (uchar(ms));
   }
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ   
void OnDeinit(const int reason){
   if (!Real) return;
   if (!IsTesting() && !IsOptimization()) EventKillTimer();
   switch (reason){ // вместо reason можно использовать UninitializeReason()
      //case 0: str="Эксперт самостоятельно завершил свою работу"; break;
      case 1: REPORT("Program "+NAME+VER+" removed from chart"); break;
      case 2: REPORT("Program "+NAME+VER+" recompile"); break;
      case 3: REPORT("Symbol or Period was CHANGED!"); break;
      case 4: REPORT("Chart closed!"); break;
      case 5: REPORT("Input Parameters Changed!"); break;
      case 6: REPORT("Another Account Activate!"); break; 
      case 9: REPORT("Terminal closed!"); break;   
      }
   if (IsTesting() || IsOptimization()) SAVE_PARAMS(); // (только при тестировании реала) пропишем в конец файла историю совершенных сделок и кривую баланса 
   CLEAR_CHART();
   if (GlobalVariableGet("GlobalOrdersSet")==Magic) GlobalVariableSet("GlobalOrdersSet",0);     
   if (GlobalVariableGet("Terminal")==Magic) GlobalVariableSet("Terminal",0);
   }
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
string EXP_INFO(){
   string SkipPeriod="";
   if (SkipFrom>0) SkipPeriod=S0(SkipFrom)+"..."+S0(SkipTo)+"-"; // формирование пропущенного периода, если задана его дата
   string RunPeriod=TimeToStr(DayTime[1],TIME_DATE)+"-"+SkipPeriod+TimeToStr(DayTime[day],TIME_DATE); // период теста/оптимизации
   if (BackTest==0 && IsOptimization())  OptPeriod=RunPeriod; // фиксируем интервал оптимизации, чтобы потом отразить его на графике матлаба жирным
   return (NAME+VER+" "+RunPeriod+", Sprd="+S0(Spred/Point)+", StpLev="+S0(StopLevel/Point)+", Swaps="+DoubleToStr((MarketInfo(Symbol(),MODE_SWAPLONG)+MarketInfo(Symbol(),MODE_SWAPSHORT)),2)+", OPT-"+OptPeriod);
   }  
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ    
double OnTester(){////  Ф О Р М И Р О В А Н И Е   Ф А Й Л А    О Т Ч Е Т А   /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
   float CustomMax=0;
   if (Real)  for (Exp=0; Exp<ExpTotal; Exp++){
      DATA_PROCESSING(0, READ_ARR);
      CustomMax=TEST_RESULT(CSV[Exp].Magic); 
      }
   else CustomMax=TEST_RESULT(Magic);
   return (CustomMax); // возвращаем критерий оптимизации 
   }
float TEST_RESULT(int magic){
   float   CustomMax, SD=0,  iDD=0, GrossProfit=0, GrossLoss=0, MidWin, MidLoss,  profit, MaxWin[5], FullProfit=0, MaxProfit=0, Years, MO,RF=555, iRF=555, PF=555, Sharp=555;  
   short LossesCnt=0, WinCnt=0;       
   double MinDepo=InitDeposit; 
   ArrayInitialize(MaxWin,0);
   Years=float(day/260.0)-(SkipTo-SkipFrom); //Print("days=",day," Years=",Years, " SkipYears=",SkipTo-SkipFrom);
   ushort Trades=0;
   //InitDeposit=TesterStatistics(STAT_INITIAL_DEPOSIT);
   //PF=TesterStatistics(STAT_PROFIT_FACTOR);
   for(int Ord=0; Ord<OrdersHistoryTotal(); Ord++){   // поиск MO, PF, iRF, kDD
      if (OrderSelect(Ord, SELECT_BY_POS, MODE_HISTORY)!=true || OrderMagicNumber()!=magic) continue; // выясним текущие бай/селл позы и гарантированную прибыль по ним, закрепленную стопами
      int Order=OrderType();
      if (Order==OP_BUY || Order==OP_SELL){
         Trades++; 
         profit=float((OrderProfit()+OrderSwap()+OrderCommission())/MarketInfo(Symbol(),MODE_TICKVALUE));///MarketInfo(Symbol(),MODE_TICKVALUE); //Print(Symbol(),": Pips profit=",profit," OrderProfit()=",OrderProfit()," OrderSwap()=",OrderSwap()," OrderCommission()=",OrderCommission()," TICKVALUE=",MarketInfo(Symbol(),MODE_TICKVALUE));
         FullProfit+=profit; // Значение депо после очередной сделки
         if (profit>MaxWin[0]){ // ищем пять самых крупных выигрышей, чтобы вычесть их потом из профита, т.к. уверены, что они не повторятся 
            for (uchar i=4; i>0; i--) MaxWin[i]=MaxWin[i-1];
            MaxWin[0]=profit;  // т.е. резы тестера будут отличаться в худшую сторону
            } //Print("profit=",profit," FullProfit=",FullProfit);
         if (profit>0) {GrossProfit+=profit; WinCnt++;}
         if (profit<0) {GrossLoss-=profit;   LossesCnt++;}
         if (FullProfit>=MaxProfit) MaxProfit=FullProfit;// подсчет iRF - прибыль делим на среднюю просадку
         else  iDD+=MaxProfit-FullProfit;// нахождение в очередной просадке.   площадь просадочной части эквити в период просадки (подсчет по сделкам)      
      }  }     
   if (Trades<1 || day<1) return(0);
   if (WinCnt>0)    MidWin=GrossProfit/WinCnt;   else MidWin=0;
   if (LossesCnt>0) MidLoss=GrossLoss/LossesCnt; else MidLoss=float(0.01);
   LastTestDD=short(MaxEquity-Equity); // последняя незакрытая просадка на тесте
   for (uchar i=1; i<5; i++) MaxWin[0]+=MaxWin[i]; // суммируем все члены массива в первый член
   FullProfit-=MaxWin[0]; //Print("MaxWin=",MaxWin[0]," FullProfit=",FullProfit);// вычитаем из полного профита пять максимальных винов 
   GrossProfit-=MaxWin[0];
   MaxProfit-=MaxWin[0];
   MO=float(FullProfit/Trades); // МатОжидание или Наклон Эквити     
   if (iDD>0) iRF=float(MaxProfit/iDD*100); //  Своя формула для фактора восстановления 
   iDD=iDD/Trades*10;
   for(int Ord=0; Ord<OrdersHistoryTotal(); Ord++){   // поиск MO, PF, iRF, kDD
      if (OrderSelect(Ord, SELECT_BY_POS, MODE_HISTORY)==true && OrderMagicNumber()==magic){ // выясним текущие бай/селл позы и гарантированную прибыль по ним, закрепленную стопами
         int Order=OrderType();
         if (Order==OP_BUY || Order==OP_SELL){
            profit=float((OrderProfit()+OrderSwap()+OrderCommission())/MarketInfo(Symbol(),MODE_TICKVALUE));
            SD+=MathAbs(MO-profit); // Суммарное отклонение
      }  }  } 
   SD/=Trades; // Отклонение результата сделки от MO
   MO/=(float)MarketInfo(Symbol(),MODE_SPREAD);
   if (GrossLoss>0)  PF=float(GrossProfit/GrossLoss);  
   if (DrawDown>0)   RF=float(MaxProfit/Years/DrawDown); // Фактор восстановления (% в год!)
   if (SD>0)  Sharp=float(MO*1000/SD); // Своя формула для к.Шарпа 
   switch(CustMax){// Критерий оптимизации
      default: CustomMax=FullProfit; break;
      case 1:  CustomMax=RF;         break;
      case 2:  CustomMax=iRF;        break;
      case 3:  CustomMax=Sharp;      break;
      }
   string FileName="";
   if (IsOptimization()){ // Оптимизация / РеОптимизация
      if (BackTest==0) FileName="Opt"; else FileName="ReOpt";
      FileName=FileName+"_"+Symbol()+DoubleToStr(Period(),0);
      if (PF<PF_ && PF_>0) return (CustomMax); //return(PF/PF_*CustomMax);  // если при оптимизации резы не катят, 
      if (RF<RF_ && RF_>0) return (CustomMax); //return(RF/RF_*CustomMax);  // не пишем их в файл отчета
      if (MO<MO_ && MO_>0) return (CustomMax); //return(MO/cMO*CustomMax);  // и пропорционально уменьшаем критерий оптимизации
      if (Trades/Years<Opt_Trades)  return(CustomMax);                                                     
      }
   else  {if (BackTest==0) FileName="Test"; else FileName="Back";} // тест / бэктест
//// формируем файл со статистикой текущей оптимизации    
   FileName=FileName+"_"+ NAME+".csv"; 
   Str1="Pip/Y";           Prm1=S0(FullProfit/Years); // Профит пункты / год 
   Str2="Trd/Y";           Prm2=S0(Trades/Years); 
   Str3="RF=MaxPrf/Y/DD";  Prm3=S2(RF);    // Фактор восстановления = профит в месяц / просадку 
   Str4="PF";              Prm4=S2(PF);    // Профит фактор
   Str5="DD/LastDD";       Prm5=" "+S0(DrawDown)+"_"+S0(LastTestDD);  // Максимальная историческая просадка / последняя незакрытая просадка
   Str6="iDD";             Prm6=S0(iDD);   // Средняя площадь всех просадок
   Str7="MO/Spred";        Prm7=S2(MO);    // Мат Ожидание
   Str8="SD";              Prm8=S0(SD);    // Стандартное отклонение SD
   Str9="MO/SD";           Prm9=S1(Sharp); // 
   Str10="iRF=MaxPrf/iDD"; Prm10=S0(iRF);  // Модиф. фактора восстановления
   Str11="W/L*W%";         Prm11=" "+S1(MidWin/MidLoss)+"*"+S0(WinCnt*100/Trades)+" ="; // (Средний профит / Средний лосс ) * процент выигрышных сделок = ...Робастность(см. ниже)
   Str12="  = ";           Prm12=S0(MidWin/MidLoss*WinCnt*100/Trades); //    DoubleToStr(MidWin/MidLoss*(WinCnt/Trades)*100,0);  // Робастность =  (Средний профит / Средний лосс ) * процент выигрышных сделок либо  FullProfit*260*1000/day/MaxDD/Trades  
   Str13="RISK=PF*RF";     Prm13=S1(PF*RF);// выравнивает просадки в портфеле  // старый R I S K = 50*day/MaxDD/Trades
   TESTER_FILE_CREATE(EXP_INFO(),FileName); // создание файла отчета со всеми характеристиками  //
   //Print(magic, ": FullProfit=",S0(FullProfit)," RF=",S1(RF)," PF=",S1(PF)," DD/LastDD=",Prm5, " Trades=",Trades);  
   for (short i=1; i<=day; i++){ // допишем в конец каждой строки еженедельные балансы  
      FileSeek (TesterFile,-2,SEEK_END); // перемещаемся в конец строки
      FileWrite(TesterFile, "",DayBal[i]/MarketInfo(Symbol(),MODE_TICKVALUE));    // пишем ежедневные Эквити из созданного массива
      }
   FileClose(TesterFile); 
   if (BackTest>0) MATLAB_LOG();
   if (Real) ERROR_CHECK(__FUNCTION__);
   return (CustomMax); // возвращаем критерий оптимизации   
   }
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ    
short LastYear, day;
int      DayBal[10000];
datetime DayTime[10000];
void DAY_STATISTIC(){ // расчет параметров DD, Trades, массив с резами сделок // ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
   if (Today!=DayOfYear()){ // начался новый день
      Today=DayOfYear(); //Print("DayMinEquity=",DayMinEquity," DayOfYear()=",DayOfYear());
      day++;
      DayTime[day]=TimeCurrent();
      DayBal[day]=int((DayMinEquity-InitDeposit)); // сперва умножим на 1000, а в OnTester() разделим. Это для более точного отображения на графике.    
      //if (LastYear<Year()) {LastYear=short(Year()); DayTime[day]=1;}
      DayMinEquity=float(AccountEquity());
      }
   if (AccountEquity()<DayMinEquity) DayMinEquity=float(AccountEquity());
   // вычисление DD
   Equity=float(AccountEquity()/MarketInfo(Symbol(),MODE_TICKVALUE)); 
   if (Equity>=MaxEquity) MaxEquity=Equity;  // Новый максимум депо
   else{ 
      if (MaxEquity-Equity>DrawDown) DrawDown=MaxEquity-Equity;
   }  } 
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
void LOAD_GLOBALS(int mgc){ // Восстановление на реале глобальных переменных // ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
   if (!Real) return;
   datetime StartWaiting=TimeLocal();
   int File=-1;  
   string FileName=Company+"_"+AccountCurrency()+"_"+DoubleToStr(mgc,0)+".csv";
   while (File<0){ // ждем, пока не откроется, т.к. без этих данных торговлю лучше не начинать
      Sleep(100); // 
      File=FileOpen(FileName, FILE_READ | FILE_WRITE);  
      if (TimeLocal()-StartWaiting>30){
         if (!IsTesting() && !IsOptimization()) 
         MessageBox(__FUNCTION__+" Can't open file "+FileName);
         ERROR_CHECK(__FUNCTION__+" Can't open file "+FileName); 
         StartWaiting=TimeLocal();
      }  }
   if (FileReadString(File)==""){ // файл только что создан, заполним
      BarTime=Time[bar+1];  ExpMemory=0;
      FileWrite(File, TimeToString(Time[bar],TIME_DATE|TIME_MINUTES), 0, 0, TimeToString(Time[bar],TIME_DATE|TIME_MINUTES)); // для резервирования места запись произвольных значений вместо глобальных переменных
      FileWrite(File,"BarTime", "memBUY",   "BUY.Stp",  "BUY.Prf",  "BUY.Exp",   "memSEL",   "SEL.Stp",  "SEL.Prf",  "SEL.Exp",  "ExpMemory"); // ниже заголовок для глобальных переменных
      FileWrite(File, BarTime ,  memBUY.Val, memBUY.Stp, memBUY.Prf, memBUY.Exp,  memSEL.Val, memSEL.Stp, memSEL.Prf, memSEL.Exp, ExpMemory); // сохраняем глобальные переменные в файл
      Alert("Create file ",FileName," to save individual history"); 
      //GlobalVariableSet("Mem"+DoubleToStr(mgc,0), 0);
      }
   else{ // чтение переменных из файла
      FileSeek(File,0,SEEK_SET);     // перемещаемся в начало   
      FileReadString(File); while (!FileIsLineEnding(File)) FileReadString(File); // читаем всю херь, пока не кончилась строка 
      BarTime     =StringToTime(FileReadString(File));  // Преобразование строки, содержащей время в формате "yyyy.mm.dd [hh:mi]", в число типа datetime.  
      memBUY.Val  =float(StrToDouble(FileReadString(File))); 
      memBUY.Stp  =float(StrToDouble(FileReadString(File)));
      memBUY.Prf  =float(StrToDouble(FileReadString(File)));
      memBUY.Exp  =datetime(StrToDouble(FileReadString(File)));
      memSEL.Val  =float(StrToDouble(FileReadString(File)));
      memSEL.Stp  =float(StrToDouble(FileReadString(File)));
      memSEL.Prf  =float(StrToDouble(FileReadString(File)));
      memSEL.Exp  =datetime(StrToDouble(FileReadString(File)));
      ExpMemory=StringToTime(FileReadString(File));
      ResetLastError(); // после ф. StringToTime появляется ошибка, т.к. Exel переворачивает дату. Тем не менее дата считывается корректно
      }
   FileClose(File);
   ERROR_CHECK(__FUNCTION__);
   }  
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
void REPORT(string Missage){ // собираем все сообщения экспертов в одну кучу 
   if (!Real)  return;
   if (Missage=="") return;
   int e;
   for (e=0; e<ExpTotal; e++)  if (CSV[e].Magic==Magic) break; // ищем номер экспетра в массиве для данного меджика
   if (CSV[e].Hist=="") CSV[e].Hist=Missage;
   else     CSV[e].Hist=CSV[e].Hist+"\n "+Missage; // без разделителя ";" при записи в RestoreFileName (MailSender()) все сообщения лепятся в одну строку.
   Print(Magic,":: ",Missage);
   }
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ   
void SAVE_HISTORY(){ // пишем собранные сообщения в один общий файл   
   if (history=="") return; 
   string   FileName="Reports.csv"; 
   WAITING(FileName,60);// ожидание освобождения общего фала со всеми репортами
   int File=FileOpen(FileName, FILE_READ | FILE_WRITE);
   if (File>0){
      FileSeek (File,0,SEEK_END);     // перемещаемся в конец
      FileWrite(File, history);
      FileClose(File);
      history="";
      }
   else ERROR_CHECK(__FUNCTION__+" Can't open file "+FileName+"!!!");  
   FREE(FileName);   
   ERROR_CHECK(__FUNCTION__);
   }
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ    
void SAVE_PARAMS(){// Сохранение глобальных переменных в файл, доклад о последних сделках  ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ  
   int  MagicTemp=Magic; // Print(Magic,": IndividualSaving(), сохраняем RevBUY и RevSELL всех экспертов с графика ",Symbol(),Period());  
   for (short e=0; e<ExpTotal; e++){    
      if (CSV[e].Name!=NAME+VER || CSV[e].Sym!=Symbol() || CSV[e].Per!=Period() || CSV[e].Risk==0) continue; // имя+ТФ+период  совпадают, выбали эксперта с того же чарта
      Magic=CSV[e].Magic; HistDD=CSV[e].HistDD; LastTestDD=CSV[e].LastTestDD; TestEndTime=CSV[e].TestEndTime;
      ushort Trades=0;
      datetime OrdMemory=0;
      string ExpParams="";
      float MaxBal=0, DD=0, PF=555, RF=555, Plus=0, Minus=0, TradePrf=0, Profit=0, CheckRisk=0;
      for (int Ord=0; Ord<OrdersHistoryTotal(); Ord++){// перебераем историю сделок эксперта
         if (OrderSelect(Ord,SELECT_BY_POS,MODE_HISTORY)==true && OrderMagicNumber()==Magic && OrderCloseTime()>0 && OrderLots()>0){
            TradePrf=float(OrderProfit()+OrderSwap()+OrderCommission()); // прибыль от выбранного ордера в валюте депозита 
            if (TradePrf==0) continue; 
            Trades++;
            Profit +=TradePrf; 
            if (TradePrf>0)  Plus+=TradePrf;  else  Minus-=TradePrf;
            if (Profit>MaxBal) MaxBal=Profit;
            else if (MaxBal-Profit>DD) DD=MaxBal-Profit;
            OrdMemory=OrderCloseTime();  
         }  }    
      if (OrdMemory>0 && OrdMemory!=CSV[e].ExpMemory){// если время последней сделки обновилось,
         //Print("TradePrf=",TradePrf," Open-Close=",N5(MathAbs(OrderOpenPrice()-OrderClosePrice()))," Open=",N5(OrderOpenPrice())," Close=",N5(OrderClosePrice()) ," Lots=",OrderLots()," tick=", MarketInfo(Symbol(),MODE_TICKVALUE) ); 
         CSV[e].ExpMemory=OrdMemory; // Print("Update "+"Mem"+S0(Magic)+":",GlobalVariableGet("Mem"+S0(Magic)));
         if (DD>0) RF=MaxBal/DD;  // фактор восстановления
         double Stop=100*Point; // возьмем любой стоп для расчета риска
         Lot = MM(Stop,CSV[e].Risk,Symbol());   // расчет пробного лота для стопа в 100п
         CheckRisk=CHECK_RISK(Lot,Stop,Symbol()); //расчет текущего риска в связи с просадкой
         string CurrentRisk; // запишем, на сколько истинный риск (с учетом просадки) отличается от заданного в настройках 
         if (CheckRisk>CSV[e].Risk) CurrentRisk="+"+S1(CheckRisk-CSV[e].Risk);
         if (CheckRisk<CSV[e].Risk) CurrentRisk=    S1(CheckRisk-CSV[e].Risk);
         if ( Minus>0)  PF= Plus/ Minus;
         if (TradePrf>0) ExpParams="\n WIN="; else ExpParams="\n LOSS="; // запомним значение баланса на случай, если этот лось для данного эксперта - начало ДД (пригодится потом в ММ)
         ExpParams=ExpParams+S1(TradePrf*100/AccountBalance())+"% "+
            "\r Prf="+S0(Profit)+"$ Risk="+S1(CSV[e].Risk)+" CheckRisk="+S1(CheckRisk)+ // 
            "\r RF="+S1(RF)+" PF="+S1(PF)+" Trades="+ S0(Trades)+    // 
            "\n Hist/CurDD="+S0(HistDD)+"/"+S0(CUR_DD(Symbol()))+"pips";    //
         REPORT(ExpParams); // шлем миссагу
         }  
      // Сохранение глобальных переменных на случай выключения программы   
      string FileName=Company+"_"+AccountCurrency()+"_"+S0(Magic)+".csv";
      int File=FileOpen(FileName, FILE_READ|FILE_WRITE);  
      if (File<0){
         ERROR_CHECK(__FUNCTION__+" Can't open file "+FileName+"!!!");  
         continue;}
      FileWrite (File, CSV[e].Bar, CSV[e].Buy, CSV[e].BuyStp, CSV[e].BuyPrf ,CSV[e].BuyExp, CSV[e].Sel, CSV[e].SelStp, CSV[e].SelPrf, CSV[e].SelExp, CSV[e].ExpMemory); // сохраняем переменные эксперта в файл
      if (CSV[e].Hist!=""){
         FileSeek (File,0,SEEK_END); 
         FileWrite (File, TIME(TimeCurrent())+";"+CSV[e].Hist); 
         history+="\n  "+S0(CSV[e].Magic)+": "+CSV[e].Hist;
         //Print("IndividualSaving: CSV[",e,"].Hist=",CSV[e].Hist);
         CSV[e].Hist="";
         }
      FileClose(File); 
      }  
   Magic=MagicTemp; 
   ERROR_CHECK(__FUNCTION__);   
   }   
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ   
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ   
void MAIL_SEND(){ // отправляем мыло из файла Reports.csv с отчетами
   if (IsTesting() || IsOptimization()) return;
   while (TimeLocal()-GlobalVariableTime("GlobalOrdersSet")<60) Sleep(1000+ExpPause);// ждем, пока после последнего обращения к глобалу пройдет больше минуты, т.е. все отчитались
   WAITING("Mail",60);
   if (!GlobalVariableCheck("MailTime")) GlobalVariableSet("MailTime",TimeCurrent()-4000); // при первом запуске эксперта время поиска сделок для отчета чуть больше часа
   if (GlobalVariableGet("MailTime")<TimeCurrent()-4000) GlobalVariableSet("MailTime",TimeCurrent()-4000); // если давно не обновлялось, тоже освежим
   if (TimeHour(datetime(GlobalVariableGet("MailTime")))==TimeHour(TimeCurrent())){// за этот час мыло уже отправлено 
      //Print(Magic,": Mail already sent"); 
      FREE("Mail"); 
      return;} 
   ERROR_CHECK(__FUNCTION__+S0(__LINE__));   
   MATLAB_LOG();
   ERROR_CHECK(__FUNCTION__+S0(__LINE__));
   float MaxBal=0, MinBal=0, AccDD=0, AccCDD=0, AccPF=555, Plus=0, Minus=0, AccRF=555, AccPrf=0,  profit=0, RollPlus=0, RollMinus=0, LastHourProfit=0;
   int  Trades=0;  
   for(int i=0; i<OrdersHistoryTotal(); i++){// перебераем историю сделок эксперта
      if (OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)==false) continue; // история всех экспертов
      profit=float(OrderProfit()+OrderSwap()+OrderCommission()); // прибыль от выбранного ордера в валюте депозита 
      if (profit==0) continue;
      if (OrderType()==6 && iTime(NULL,60,0)-OrderOpenTime()<3300){// 6-ролловер, т.е. инвестиции. За прошлый час с небольшим запасом в 55мин = 3300с 
         if (profit>0) RollPlus +=profit;   
         else RollMinus+=profit;
         }
      if (OrderOpenPrice()>0){ // ордер открыт экспертом
         Trades++;   // подсчет показателей работы эксперта
         AccPrf+=profit; 
         if (profit>0) Plus+=profit; else Minus-=profit;
         if (AccPrf>MaxBal) {MaxBal=AccPrf; MinBal=MaxBal;}
         if (AccPrf<MinBal) {MinBal=AccPrf; if (MaxBal-MinBal>AccDD) AccDD=MaxBal-MinBal;}   // DD
         if (OrderCloseTime()>GlobalVariableGet("MailTime")) LastHourProfit+=profit; // суммируем всю прибыль за последний час
      }  }       
   // Суммарный риск открытых позиций и отложенных ордеров
   double OpenOrdMargNeed=0, LongRisk=0, ShortRisk=0, MargNeed=0, PerCent=0;
   for (int i=0; i<OrdersTotal(); i++){// перебераем все открытые и отложенные ордера всех экспертов счета Ролловеры (OrderType=6) туда не пишем.
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)==false) continue;
      if (OrderType()==6) continue; // ролловеры не нужны
      if (OrderType()<2)   OpenOrdMargNeed+=float(OrderLots()*MarketInfo(OrderSymbol(),MODE_MARGINREQUIRED)); // кол-во маржи, необходимой для открытия лотов
      else                 MargNeed       +=float(OrderLots()*MarketInfo(OrderSymbol(),MODE_MARGINREQUIRED));//маржа отложников
      if (OrderType()==0 || OrderType()==2 || OrderType()==4)  LongRisk +=CHECK_RISK(float(OrderLots()), float(MathAbs(OrderOpenPrice()-OrderStopLoss())), OrderSymbol());
      if (OrderType()==1 || OrderType()==3 || OrderType()==5)  ShortRisk+=CHECK_RISK(float(OrderLots()), float(MathAbs(OrderOpenPrice()-OrderStopLoss())), OrderSymbol());   
      }    // теперь массив ORD содержит список всех открытых, отложенных и предстоящих установке ордеров   
   ERROR_CHECK(__FUNCTION__+S0(__LINE__));
   AccCDD=MaxBal-AccPrf;
   if (AccDD>0) AccRF=AccPrf/AccDD;
   if (Minus>0) AccPF=Plus/Minus;
   string AccountParams= "\n"+//"\nAccountParams:"+
   "\n  RISK: Long+Short = "+DoubleToStr(LongRisk,1)+"%+"+DoubleToStr(ShortRisk,1)+"%"+
   "\n  MARGIN: Open+Depend="+DoubleToStr(OpenOrdMargNeed/AccountFreeMargin()*100,0)+"%+"+DoubleToStr(MargNeed/AccountFreeMargin()*100,0)+"%"+
   "\n  EQUITY="+DoubleToStr(AccountEquity(),0)+" FreeMargin="+DoubleToStr(AccountFreeMargin(),0)+
   "\n  MarketInfo "+Symbol()+":"+
   "\nMaxSpred="+DoubleToStr(MaxSpred,Digits)+
   "\nSwap/StpLev = "+DoubleToStr(MarketInfo(Symbol(),MODE_SWAPLONG)+MarketInfo(Symbol(),MODE_SWAPSHORT),Digits) + "/" + DoubleToStr(MarketInfo(Symbol(),MODE_STOPLEVEL),Digits);   
   string CurPrf, Agr="";
   if (Aggress>1) Agr="x"+DoubleToStr(Aggress,0);
   if (AccountProfit()>0) CurPrf="+"+DoubleToStr(AccountProfit()*100/AccountBalance(),1)+"%"; // текущая незакрытая прибыль в процентах
   if (AccountProfit()<0) CurPrf=    DoubleToStr(AccountProfit()*100/AccountBalance(),1)+"%";
   CurPrf=AccountCurrency()+Agr+"  "+MONEY2STR(AccountBalance())+CurPrf;
   string Warning, RollList, MailText;
   if ((RollPlus-RollMinus)!=0){
      CurPrf=CurPrf+" Roll="+MONEY2STR(RollPlus+RollMinus);// были роловеры
      if (RollPlus>0)  RollList=DoubleToStr(RollPlus,0);
      if (RollMinus<0) RollList=RollList+DoubleToStr(RollMinus,0);
      MailText=MailText+"\n"+"Roll="+RollList+AccountCurrency(); 
      }
   if (BarTime!=Time[1]) // проверка пропущенных баров: разница с прошлым баром (в барах)   
      REPORT("Missed Bars!  LastOnLine="+DTIME(BarTime)+",  CurTime="+DTIME(Time[0]));   
   if (LastHourProfit>0){
      PerCent=LastHourProfit/((float)AccountBalance()-LastHourProfit)*100;
      CurPrf=CurPrf+" Win="+DoubleToStr(PerCent,2)+"%";
      }
   if (LastHourProfit<0){
      PerCent=LastHourProfit/((float)AccountBalance()+LastHourProfit)*100;
      CurPrf=CurPrf+" Loss="+DoubleToStr(PerCent,2)+"%"; //
      }
   // открытие файла Reports.csv
   string FileName="Reports.csv";   
   int File=FileOpen(FileName, FILE_READ | FILE_WRITE);  
   if (File>0){
      while (!FileIsEnding(File)) MailText=MailText+"\n"+ FileReadString(File); // пихаем все в мыло 
      if (StringFind(MailText,"!",0)>0) Warning="WARNING"; // если были предупреждения, выносим их в заголовок мыла
      FileClose(File); 
      FileDelete(FileName);
   }else{
      ERROR_CHECK(__FUNCTION__+" Can't open file "+FileName+"!!!"); 
      MailText=MailText+"\n"+__FUNCTION__+" Can't open file "+FileName+"!!!";
      }  
   SendMail(CurPrf, ORDERS_INF(Warning) + MailText + AccountParams); 
   GlobalVariableSet("MailTime",TimeCurrent()); // время отправки "мыла" 
   FREE("Mail"); 
   Print(Magic,":      *   S E N D   M A I L   * ",MailText,"\n");
   ERROR_CHECK(__FUNCTION__+S0(__LINE__));  
   }
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ    
string MONEY2STR(double Balance){
   if (Balance<1000)       return(DoubleToStr(Balance,0));
   if (Balance<10000)      return(DoubleToStr(Balance/1000,1)+"K");  
   if (Balance<1000000)    return(DoubleToStr(Balance/1000,0)+"K"); 
   if (Balance<10000000)   return(DoubleToStr(Balance/1000000,1)+"M"); 
   return (DoubleToStr(Balance/1000000,0)+"M"); 
   } 
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ    
string ORDERS_INF(string Warning){ // инфа о текущих рыночных характеристиках и профите 
   string MarketOrders=TIME(TimeCurrent())+" "+Company+" "+Warning;
   float POINT, TakeProfit;
   int Ord;
   if (OrdersTotal()==0) return (MarketOrders);
   for(Ord=0; Ord<OrdersTotal(); Ord++){// проверка отложенных ордеров 
      if (OrderSelect(Ord, SELECT_BY_POS, MODE_TRADES)!=true) continue;
      if (OrderType()==6) continue;
      SYMBOL=OrderSymbol(); // для ф.CHECK_RISK нужен символ ордера
      POINT =(float)MarketInfo(SYMBOL,MODE_POINT); 
      MARKET_UPDATE(SYMBOL);
      if (OrderTakeProfit()==0) TakeProfit=(float)OrderOpenPrice(); else TakeProfit=(float)OrderTakeProfit(); 
      if (OrderType()==OP_BUYSTOP)  {MarketOrders =MarketOrders+"\n"+DoubleToStr(OrderMagicNumber(),0)+": BS/"  +DoubleToStr(OrderOpenPrice(),DIGITS-1)+        "/"+DoubleToStr((OrderStopLoss()-OrderOpenPrice())/POINT/10,0)+"/"+DoubleToStr((TakeProfit-OrderOpenPrice())/POINT/10,0)+"x"+DoubleToStr(OrderLots(),2)+"="+DoubleToStr(CHECK_RISK((float)OrderLots(),float(OrderStopLoss()-OrderOpenPrice()),SYMBOL),1)+"%";}
      if (OrderType()==OP_SELLSTOP) {MarketOrders =MarketOrders+"\n"+DoubleToStr(OrderMagicNumber(),0)+": SS/"  +DoubleToStr(OrderOpenPrice(),DIGITS-1)+        "/"+DoubleToStr((OrderOpenPrice()-OrderStopLoss())/POINT/10,0)+"/"+DoubleToStr((OrderOpenPrice()-TakeProfit)/POINT/10,0)+"x"+DoubleToStr(OrderLots(),2)+"="+DoubleToStr(CHECK_RISK((float)OrderLots(),float(OrderOpenPrice()-OrderStopLoss()),SYMBOL),1)+"%";} 
      if (OrderType()==OP_BUYLIMIT) {MarketOrders =MarketOrders+"\n"+DoubleToStr(OrderMagicNumber(),0)+": BL/"  +DoubleToStr(OrderOpenPrice(),DIGITS-1)+        "/"+DoubleToStr((OrderStopLoss()-OrderOpenPrice())/POINT/10,0)+"/"+DoubleToStr((TakeProfit-OrderOpenPrice())/POINT/10,0)+"x"+DoubleToStr(OrderLots(),2)+"="+DoubleToStr(CHECK_RISK((float)OrderLots(),float(OrderStopLoss()-OrderOpenPrice()),SYMBOL),1)+"%";}
      if (OrderType()==OP_SELLLIMIT){MarketOrders =MarketOrders+"\n"+DoubleToStr(OrderMagicNumber(),0)+": SL/"  +DoubleToStr(OrderOpenPrice(),DIGITS-1)+        "/"+DoubleToStr((OrderOpenPrice()-OrderStopLoss())/POINT/10,0)+"/"+DoubleToStr((OrderOpenPrice()-TakeProfit)/POINT/10,0)+"x"+DoubleToStr(OrderLots(),2)+"="+DoubleToStr(CHECK_RISK((float)OrderLots(),float(OrderOpenPrice()-OrderStopLoss()),SYMBOL),1)+"%";}  
      if (OrderType()==OP_BUY)      {MarketOrders =MarketOrders+"\n"+DoubleToStr(OrderMagicNumber(),0)+": BUY/" +DoubleToStr((BID-OrderOpenPrice())/POINT/10,0)+"/"+DoubleToStr((OrderStopLoss()-OrderOpenPrice())/POINT/10,0)+"/"+DoubleToStr((TakeProfit-OrderOpenPrice())/POINT/10,0)+"x"+DoubleToStr(OrderLots(),2)+"="+DoubleToStr(CHECK_RISK((float)OrderLots(),float(OrderStopLoss()-OrderOpenPrice()),SYMBOL),1)+"%";}   // профит в пунктах / закрепленный стопом профит в пунктах х лот    
      if (OrderType()==OP_SELL)     {MarketOrders =MarketOrders+"\n"+DoubleToStr(OrderMagicNumber(),0)+": SELL/"+DoubleToStr((OrderOpenPrice()-ASK)/POINT/10,0)+"/"+DoubleToStr((OrderOpenPrice()-OrderStopLoss())/POINT/10,0)+"/"+DoubleToStr((OrderOpenPrice()-TakeProfit)/POINT/10,0)+"x"+DoubleToStr(OrderLots(),2)+"="+DoubleToStr(CHECK_RISK((float)OrderLots(),float(OrderOpenPrice()-OrderStopLoss()),SYMBOL),1)+"%";}   // профит в пунктах / закрепленный стопом профит в пунктах х лот 
      }   
   return (MarketOrders);
   } 
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ   
#define  EXPERTS_LIM  255    // максимальное кол-во проверяемых экспертов
#define  ORDERS_LIM   65535   // максимальное кол-во сделок одного эксперта за последние два года

struct AllExperts{  //  C Т Р У К Т У Р А   P I C
   int      magic;
   short    trade[ORDERS_LIM];
   datetime time[ORDERS_LIM];
   float    tickval,risk;
   };
AllExperts Expert[EXPERTS_LIM];   
uchar Experts=0;   
datetime HistoryPeriod=3600*24*365*2; // анализ истории не глубже 2 лет
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ    
void MATLAB_LOG (){// Сохранение истории сделок в файл 
   short profit=0;
   ushort TradeCnt[EXPERTS_LIM]; // счетчик сделок
   string FileName; 
   ArrayInitialize(TradeCnt,0);
   if (Real){ 
      FileName="MatLab"+AccountCurrency()+".csv";
      if (FileIsExist(FileName))  if (!FileDelete(FileName)) ERROR_CHECK("MATLAB_LOG_Delete "+FileName);
      }  
   else   
      FileName="MatLabTest.csv";//  
   
   int File=FileOpen(FileName, FILE_READ | FILE_WRITE); 
   if (File<0){
      ERROR_CHECK(__FUNCTION__+" Can't open file "+FileName+"!!!");
      return;}
   //else Print(Magic,": Create new file ",FileName);
   FileWrite(File, "Magic","TickVal","Risk","Deal/Time..."); // прописываем в первую строку названия столбцов
   for(int i=0; i<OrdersHistoryTotal(); i++){// перебераем историю сделок эксперта
      if (OrderSelect(i, SELECT_BY_POS,MODE_HISTORY)==false || OrderMagicNumber()==0 || OrderCloseTime()==0 || OrderProfit()==0 || OrderLots()==0 || MarketInfo(OrderSymbol(),MODE_TICKVALUE)==0) continue;
      //if (Time[0]-OrderCloseTime()>HistoryPeriod) continue; // Пропускаем все ордера старше двух лет, чтобы не переполнять масссив. Для гарфического анализа они не пригодятся.  
      uchar e=0;
      EXPERTS_PARAMS(e, OrderMagicNumber());
      Expert[e].trade[TradeCnt[e]]=short((OrderProfit()+OrderSwap()+OrderCommission())/OrderLots()/MarketInfo(OrderSymbol(),MODE_TICKVALUE));
      Expert[e].time[TradeCnt[e]]=OrderCloseTime();  //Print(" TrdCnt[",e,"]=",TradeCnt[e]," trade=",Expert[e].trade[TradeCnt[e]]," time=",Expert[e].time[TradeCnt[e]]);
      TradeCnt[e]++; 
      }    
   for (uchar e=0; e<=Experts; e++){
      short order=1; // Alert("magic[",e,"]=",magic[e]);
      FileSeek (File,0,SEEK_END); // перемещаемся в конец файла MatLabTest.csv
      FileWrite(File, DoubleToStr(Expert[e].magic,0)+";"+DoubleToStr(Expert[e].tickval,5)+";"+DoubleToStr(Expert[e].risk,1)); // прописываем в первую ячейку magic,
      for (ushort t=0; t<=TradeCnt[e]; t++){ //
         if (Expert[e].trade[t]==0) continue;  
         FileSeek (File,-2,SEEK_END); // потом дописываем
         FileWrite(File,  ""    , DoubleToStr(Expert[e].trade[t],0)+"/"+TimeToStr(Expert[e].time[t],TIME_DATE|TIME_MINUTES));    // ежедневные профиты/время сделки из созданного массива    
      }  }
   FileClose(File);
   ERROR_CHECK(__FUNCTION__); 
   }  
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ 
void EXPERTS_PARAMS(uchar& exp, int ExpMagic){// создание массива параметров для всех экспертов
   for (exp=0; exp<EXPERTS_LIM; exp++){
      if (Expert[exp].magic==ExpMagic) break;
      if (Expert[exp].magic==0){
         Expert[exp].magic=ExpMagic;
         for (short e=0; e<ExpTotal; e++)    if (ExpMagic==CSV[e].Magic)   Expert[exp].risk =CSV[e].Risk; 
         Expert[exp].tickval=float(MarketInfo(OrderSymbol(),MODE_TICKVALUE));
         Experts=exp;
         break;
         }
      if (exp>=EXPERTS_LIM) {Alert("WARNING!!! Experts>",EXPERTS_LIM, " Can't create MatLabLog File"); }   
   }  }      
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ 
void CHECK_VARIABLES(){  // сравнение значений индикаторов Real/Test
   string   FileName=Company+"_Check_"+NAME+"_"+S0(Magic)+".csv",
            OHlC=S5(Open[0])+" | "+S5(H)+" | "+S5(L)+" | "+S5(C),  
            AskBid=S5(Ask)+" | "+S5(Bid), buy, sel;
   if (setBUY.Val>0)                   buy="set"+S5(setBUY.Val)+" | "+S5(setBUY.Stp)+" | "+S5(setBUY.Prf); // открытие лонга
   else if (BUY.Val+BUYSTP+BUYLIM>0)   buy=S5(BUY.Val+BUYSTP+BUYLIM)+" | "+S5(BUY.Stp)+" | "+S5(BUY.Prf);
   if (setSEL.Val>0)                   sel="set"+S5(setSEL.Val)+" | "+S5(setSEL.Stp)+" | "+S5(setSEL.Prf); 
   else if (SEL.Val+SELSTP+SELLIM>0)   sel=S5(SEL.Val+SELSTP+SELLIM)+" | "+S5(SEL.Stp)+" | "+S5(SEL.Prf);
   int File=FileOpen(FileName, FILE_READ|FILE_WRITE); 
   if (File<0){
      ERROR_CHECK(__FUNCTION__+" Can't open file "+FileName+"!!!");  
      return;}
   if (FileReadString(File)=="")// пропишем заголовки столбцов   
      FileWrite (File,"OHLC","ask bid",  "Spread"  , "atr" , "ATR" , "HI" , "LO" ,"BUY","SELL","ServerTime","TrUp","TrDn","InUp","InDn","OutUp","OutDn","Tr0","Tr1","Tr2","Tr3","In0","In1","In2","In3","Out0","Out1","Out2","Out3"); // сохраняем переменные в файл
   FileSeek(File,0,SEEK_END);     // перемещаемся в конец
   FileWrite    (File, OHlC ,  AskBid ,S5(MaxSpred),S5(atr),S5(ATR),S5(HI),S5(LO), buy , sel  , BTIME(bar) , ch[0], ch[1], ch[2], ch[3], ch[4] , ch[5] ,PS[0],PS[1],PS[2],PS[3],PS[4],PS[5],PS[6],PS[7], PS[8], PS[9],PS[10],PS[11]);
   FileClose(File); 
   ArrayInitialize (PS,0); // обнулим значения массива перед следующим запуском  
   ERROR_CHECK(__FUNCTION__);
   }
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ    

