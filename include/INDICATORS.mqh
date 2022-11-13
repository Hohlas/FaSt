


// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ 
//                                        D I R E C T     M O V E N T 
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ                             
float DM, DM1, DMmax,DMmin, DMmax1, DMmin1;
int BarDM=1;
void iDM(int DmMode, int per){//      MODE=0..3, per=1..10
   for (int B=Bars-BarDM; B>0; B--){ // чтобы функция не была чусвстительна к пропуску бар в следствии нерегулярного подключеия к графику 
      if (B+per>=Bars) continue;
      float Noise=0, Line=0, Delta=0, UP=0, DN=0, MO=0; 
      DM1=DM; 
      switch (DmMode){
         case 0: // Classic
            DM=0;
            for (int b=B; b<B+per; b++){ 
               if (High[b]>High[b+1]) DM+=float(High[b]-High[b+1]);
               if (Low[b] <Low [b+1]) DM+=float(Low [b]-Low [b+1]); 
               }
         break;
         case 1: // Signal / Noise
            for (int b=B; b<B+per; b++)  Noise+=MathAbs(float(High[b]+Low[b]+Close[b])/3 - float(High[b+1]+Low[b+1]+Close[b+1])/3); 
            if (Noise>0) DM = (float(High[B]+Low[B]+Close[B])/3 - float(High[B+per]+Low[B+per]+Close[B+per])/3) / Noise;  
         break;
         case 2: // UpIntegral - DnIntegral
            MO=float(Close[B]-Close[B+per])/per; // Momentum
            for (int b=B; b<B+per; b++){ 
               Line=float(Close[B])-MO*(b-B); // расчетное значение цены на прямой B..(B+per) знак "-", т.к. считаем с зада на перед
               Delta=float(Close[b])-Line;
               if (Delta>0) DN+=Delta; else UP-=Delta;
               }
            DM=UP-DN;
         break;
         case 3: // Momentum
            DM=float(Open[B]-Open[B+per]);
         break;
         }
      if ((DM>=0 && DM1<0) || (DM<=0 && DM1>0)) {DMmax=0; DMmin=0;}
      if (DM>DMmax) DMmax=DM;
      if (DM<DMmin) DMmin=DM; 
   //Print(TimeToStr(Time[bar],TIME_DATE | TIME_MINUTES)," DM=",DM," Min=", DMmin," Max=",DMmax);   
      }
   BarDM=Bars;   //     Print
   }    
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ 
void ATR_DOUBLE(int B){      // тупое медленное усреднение HL на каждом баре. Остальные методы: как стандартный МТ индюк,
   atr=0;                    // так и метод сдвига массива HL,  имеют расхождения Реал/Тест из-за пропусков бар и ХЗ знает от чего
   if (B+FastAtrPer>=Bars) return;
   for (int b=B; b<B+FastAtrPer; b++) atr+=float(High[b]-Low[b]);
   atr/=FastAtrPer;   
   if (TimeDay(Time[B])==TimeDay(Time[B+1]) || B+SlowAtrPer>=Bars) return; // медленный АТР считается раз в сутки (при А=15 его период около 9 дней)
   ATR=0;
   for (int b=B; b<B+SlowAtrPer; b++) ATR+=float(High[b]-Low[b]);
   ATR/=SlowAtrPer;
   Lim=(atr+ATR)*AtrLim/200;   // допуск уровней в % ATR
   //atr=float(PerAdapter*iATR(NULL,0,FastAtrPer,B)); //Print("atr=",atr);
   //ATR=float(PerAdapter*iATR(NULL,0,SlowAtrPer,B)); // Print("ATR(",SlowAtrPer,")=",ATR);
   }
//                                        H I  /  L O 
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ                              
short BarsInDay, HLper, HLwid, HLtrend; 
int   BarHL=1, LimitBars=1000; // счетчик посчитанных бар
float H,H1,L,L1,C,C1, HI, LO, HI1, LO1, HI2, LO2, HI3, LO3, VolClaster;
void HL_init(){
   double Adpt=1; // 60/Period(); // адаптация периода индикатора к таймфрейму
   HLper=0; HLwid=1;   // при HLper=0 ширина фрактала адаптивна - пропорциональна его удалению 
   switch (HL){ // в зависимости от случая, меняются либо HLper, либо HLwid. По умолчанию они равны 1. 
      case 1:  HLper=short(MathPow(HLk,1.7)+2);break; // При пробое одного из уровней ищутся ближайшие фракталы шириной HLper (3  5  8  12  17  23  29  36). 
      case 2:  HLwid=short(HLk+1);             break; // При пробое одного из уровней ищутся фракталы адаптивной ширины далее ATR*HLk от текущей цены 
      case 3:  HLwid=short(HLk+3);           break; // смена тренда при пробое границ канала, подтягивание границ на ATR*(HLk+3) за трендом
      case 4:  HLwid=short(HLk+1);           break; // При пробое Н ищется LO далее HLwid*ATR от минимальной цены 
      case 5:  HLper=short(MathPow(HLk,1.7)+2);break; // Фракталы шириной HLper (3  5  8  12  17  23  29  36). 
      case 6:  HLper=short(HLk-1)*3;         break; // Hi/Lo за 24+HLper часов
      default: HLper=1;             
      }
   //Print("init iHILO: ",TimeToStr(Time[1],TIME_DATE | TIME_MINUTES)," HLper=",HLper," HLwid=",HLwid," Bars=",Bars," Time[bars]=",TimeToStr(Time[Bars-1],TIME_DATE | TIME_MINUTES)," VolClaster=",VolClaster);  
   BarsInDay=short(24*60/Period());
   }
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ                             
void iHILO(){      
   for (int B=Bars-BarHL; B>0; B--) iHL(B);     // чтобы функция iHL(B) была не чусвстительна к пропуску бар в следствии нерегулярного подключеия к графику 
   BarHL=Bars;   //     Print("bar=",bar," B=",B," BarHL=",BarHL," ATR=",ATR," Bars=",Bars," Time[B]=",TimeToStr(Time[B],TIME_DATE | TIME_MINUTES));
   }   
void iHL(int B){
   HI3=HI2; HI2=HI1; HI1=HI; LO3=LO2; LO2=LO1; LO1=LO;  H1=H; L1=L; C1=C; 
   H=float(High[B]); 
   L=float(Low [B]);
   C=float(Close[B]);
   if (B+HLper>=Bars) return;
   ATR_DOUBLE(B);
   if (ATR==0) return;
   float Delta=ATR*HLwid; 
   //Print("time[",B,"]=",BTIME(B)," BarHL=",BarHL," atr=",atr," ATR=",ATR,"    H=",H," HI=",HI," LO=",LO," HLwid=",HLwid);
   switch (HL){
      case 1: // Nearest F(HLper). При пробое одного из уровней ищутся ближайшие фракталы шириной HLper бар. 
         if (H>=HI || L<=LO){   // пробитие одной из границ канала
            for (int b=B+1; b<Bars; b++)   if (FIND_HI(B,b,HLper,HI,true)) break; // поиск ближайшего фрактала шириной HLper
            for (int b=B+1; b<Bars; b++)   if (FIND_LO(B,b,HLper,LO,true)) break; //
            }
      break; 
      case 2: // При пробое одного из уровней ищутся фракталы адаптивной ширины далее ATR*HLk от текущей цены 
         if (H>=HI || L<=LO){   // пробитие одной из границ канала
            for (int b=B+1; b<Bars; b++)   if (FIND_HI(B,b,HLper,HI,High[b]-L>Delta)) break; // 
            for (int b=B+1; b<Bars; b++)   if (FIND_LO(B,b,HLper,LO,H-Low [b]>Delta)) break; //
            }      
      break;       
      case 3: // смена тренда при пробое границ канала, подтягивание границ на ATR*(HLk+3) за трендом
         if (H>=HI){ // пробой HI = тренд вверх
               for (int b=B+1; b<Bars; b++)   if (FIND_HI(B,b,HLper,HI,true)) break; // ищем выше ближайший фрактал адаптивной ширины
               HLtrend=1;}
         if (L<=LO){  // пробой LO
               for (int b=B+1; b<Bars; b++)   if (FIND_LO(B,b,HLper,LO,true)) break; // ищем ниже ближайший фрактал адаптивной ширины
               HLtrend=-1;}
         if (HLtrend>0){ // Тренд вверх
            if (L-LO>Delta){// отдаление от нижней границы
               for (int b=B+1; b<Bars; b++)   if (FIND_LO(B,b,HLper,LO,L-Low[b]>Delta/2)) break; // обновление LO 
            }  }        
         else{ // при нисходящем тренде
            if (HI-H>Delta){ // при отдалении от верхней границы
               for (int b=B+1; b<Bars; b++)   if (FIND_HI(B,b,HLper,HI,High[b]-H>Delta/2)) break; // обновление HI
            }  }    
      break;             
      case 4: // Power HiLo - При пробое Н ищется LO далее HLper*ATR от текущей цены (аналогично 2)
         if (H>=HI || L<=LO){  // пробой одной из границ
            float maxHi=float(High[B]), minLo=float(Low[B]);
            for (int b=B+1; b<Bars; b++){
               if (Low[b]<minLo) minLo=float(Low[b]); // максимальная величина движения вниз из High[b] 
               if (FIND_HI(B,b,HLper,HI,High[b]-minLo>Delta))   break; // ближайший фрактал сверху  удаленный на Delta
               }
            for (int b=B+1; b<Bars; b++){
               if (High[b]>maxHi) maxHi=float(High[b]);// минимальная величина движения вверх из Low[b] 
               if (FIND_LO(B,b,HLper,LO,maxHi-Low[b]>Delta))    break; // любой фрактал ниже текущей цены на Delta
            }  }
      break;
      case 5: // Classic F(HLper). Фракталы шириной HLper бар. 
         if (B+HLper>=Bars) break;
         if (H>=HI){ for (int b=B+1; b<Bars; b++)   if (FIND_HI(B,b,HLper,HI,true)) break;} // при пробое верхней границы ищем ближайший фрактал шириной HLper
         if (L<=LO){ for (int b=B+1; b<Bars; b++)   if (FIND_LO(B,b,HLper,LO,true)) break;} 
         if (High[B+HLper]==High[iHighest(NULL,0,MODE_HIGH,HLper*2+1,B)])  HI=float(High[B+HLper]); // сформировался фрактал шириной HLper
         if (Low[B+HLper] ==Low [iLowest (NULL,0,MODE_LOW ,HLper*2+1,B)])  LO=float(Low [B+HLper]);
      break;
      case 6: // (was 8) LastDay Hi/Lo за 24+HLper часов
         if (HLper<0 || B+2+HLper>Bars) break;
         if (TimeHour(Time[B+HLper])<TimeHour(Time[B+1+HLper])){
            HI=float(High[iHighest(NULL,0,MODE_HIGH,BarsInDay,B)]);  
            LO=float(Low [iLowest (NULL,0,MODE_LOW ,BarsInDay,B)]);}
         if (L<=LO || H>=HI){
            short cntbar=0;    
            for (int b=B+1; b<Bars; b++){
               cntbar++;
               if (b<Bars-1-HLper && TimeHour(Time[b+HLper])<TimeHour(Time[b+1+HLper])) cntbar=0;    
               if (L<=LO)  if (FIND_LO(B,b,24-cntbar,LO,true)) break; 
               if (H>=HI)  if (FIND_HI(B,b,24-cntbar,HI,true)) break;
            }  }
      break;
      
      case 7: // test
         if (H>=HI){   // пробитие одной из границ канала  || L<=LO
            for (int b=B+3; b<Bars; b++){
            if (High[b]==High[iHighest(NULL,0,MODE_HIGH,3,b-1)]){// максимальный пик и фрактал периодом width
                HI=float(High[b]);
                break;}}
            //for (int b=B+1; b<Bars; b++)   if (FIND_LO(b,b+3,5,LO,LO> Low[B])) break; //
            }
      break; 
      
      
      default://
         HI=H; LO=L;
      break;   
      }
      
   color Clr=clrRed;
   if (HLtrend>0) Clr=clrRed; else Clr=clrBlack;
      LINE("HI, HLper="+S0(HLper), bar+1,HI1, bar,HI, Clr,0);
      LINE("LO, HLper="+S0(HLper), bar+1,LO1, bar,LO, Clr,0);
     
   iOSC();      
   }   
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ                             
bool FIND_HI(int B, int b, int width, float& NewHI, bool Condition){ // Поиск фрактала шириной width. Condition - доп. внешнее условие
   if (b-B>LimitBars || b>Bars-2){ // добрались до предельного кол-ва обсчитываемых бар
      NewHI=H+ATR*2;  return(true);}     // это будет искомый пик, дальше искать нет смысла 
   if (width==0) width=int(MathPow(b-B,0.4)+3);  //  // при HLper=0 ширина фрактала width пропорциональна его удалению, начиная с 4 
   if (High[b]==High[iHighest(NULL,0,MODE_HIGH,b-B+width,B)]){// максимальный пик и фрактал периодом width
      NewHI=float(High[b]);  return(true && Condition);} 
   return (false); // пока не найдется новый фрактал выше текущего бара заданной ширины   
   } 
bool FIND_LO(int B, int b, int width, float& NewLO, bool Condition){
   if (b-B>LimitBars || b>Bars-2){ // -width
      NewLO=L-ATR*2; return(true);}
   if (width==0) width=int(MathPow(b-B,0.4)+3); //  // при HLper=0 ширина фрактала width пропорциональна его удалению, начиная с 4 
   if (Low[b]==Low[iLowest (NULL,0,MODE_LOW ,b-B+width,B)]){
      NewLO=float(Low[b]); return(true && Condition);} // пока не найдется новый фрактал выше текущего бара заданной ширины
   return (false);    
   }            
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ  
//                                 L A Y E R S
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ  
float LayH4,LayH3,LayH2,LayH1,LayL4,LayL3,LayL2,LayL1,
      _HLC, _H, _L, _C;
int BarLayers=1; // счетчик посчитанных бар
short daybar;
void LAYERS(int Layer){      
   for (int B=Bars-BarLayers; B>0; B--) iLAYERS(B, Layer);     // чтобы функция iHL(B) была не чусвстительна к пропуску бар в следствии нерегулярного подключеия к графику 
   BarLayers=Bars;  
   }   
void iLAYERS(int B, int Layer){
   int per;
   if (B+BarsInDay>=Bars) return;
   if (Layer<3){
      if (TimeHour(Time[B])<TimeHour(Time[B+1])){  // ищем конец прошлого дня
         _H=float(High[iHighest(NULL,0,MODE_HIGH,BarsInDay,B)]);   // щитаем экстремумы
         _L=float(Low [iLowest (NULL,0,MODE_LOW ,BarsInDay,B)]);    // прошлого дня
         _C=float(Close[B+1]);                             // и его цену закрытия
         _HLC=(_H+_L+_C)/3;
         }
      if (Layer==0){// Camarilla Equation ORIGINAL
         LayH4=_C+(_H-_L)*1/2;    
         LayH3=_C+(_H-_L)*1/4;    
         LayH2=_C+(_H-_L)*1/6;  
         LayH1=_C+(_H-_L)*1/12;
         LayL4=_C-(_H-_L)*1/2;    
         LayL3=_C-(_H-_L)*1/4;    
         LayL2=_C-(_H-_L)*1/6;  
         LayL1=_C-(_H-_L)*1/12;  
         }
      if (Layer==1){ // Camarilla Equation My Edition
         LayH4=_C+(_H-_L)*4/4;    
         LayH3=_C+(_H-_L)*3/4;    
         LayH2=_C+(_H-_L)*2/4;  
         LayH1=_C+(_H-_L)*1/4;
         LayL4=_C-(_H-_L)*4/4;    
         LayL3=_C-(_H-_L)*3/4;    
         LayL2=_C-(_H-_L)*2/4;  
         LayL1=_C-(_H-_L)*1/4;  
         }
      if (Layer==2){// Метод Гнинспена (Валютный спекулянт-48, с.62)
         LayH1=_HLC; LayL1=_HLC;  
         LayH2=2*_HLC-_L;    
         LayL2=2*_HLC-_H;    
         LayH3=_HLC+(_H-_L);  
         LayL3=_HLC-(_H-_L);
         LayH4=LayH3; LayL4=LayL3;  
         }
   }else{ // if (Layer>=3) Метод Гнинспена (Валютный спекулянт-48, с.62), экстремум ищется не на прошлом дне, а на барах с 0 часов до Layer бара текущего дня
      if (Layer<24)  per=Layer*60/Period();
      else           per=  23 *60/Period();
      //if (B+BarsToCount+1>Bars) continue;
      daybar++;// номер бара с начала дня
      if (TimeHour(Time[B])<TimeHour(Time[B+1])) daybar=0; // новый день = обнуляем номер бара с начала дня
      if (daybar==per){// номер бара с начала дня совпал с заданным значением
         _H=float(High[iHighest(NULL,0,MODE_HIGH,per,B)]);
         _L=float(Low [iLowest (NULL,0,MODE_LOW,per,B)]);
         _C=float(Close[B]);
         _HLC=(_H+_L+_C)/3;
         }   
      LayH1=_HLC; LayL1=_HLC;  
      LayH2=2*_HLC-_L;    
      LayL2=2*_HLC-_H;    
      LayH3=_HLC+(_H-_L);  
      LayL3=_HLC-(_H-_L);
      LayH4=LayH3; 
      LayL4=LayL3; //   Print("Layer=",Layer," LayH1=",LayH1," LayL1=",LayL1," LayH2=",LayH2," LayL2=",LayL2," LayH3=",LayH3," LayL3=",LayL3); 
      }   
      
   }
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ  
//                                           O S C
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ 
#define OscN  30 // количество диапазонов HL для усреднения
float hl[OscN+1],Osc0=0, Osc1=0, Osc2=0;
void iOSC(){
   float hlc=0;
   Osc2=Osc1; // предыдущий диапазон HL 
   if (hl[0]!=HI-LO){// сформировался новый диапазон HL
      Osc0=0;
      hl[0]=HI-LO;   // обновим последний диапазон
      for (int b=OscN; b>0; b--){
         hl[b]=hl[b-1]; // пересортируем массив, чтобы новое значение было с индексом 1 
         Osc0+=hl[b];   // за одно посчитаем сумму всех значений
         }
      Osc0=Osc0/OscN; // посчитаем среднее N диапазонов без учета последнего диапазона
      }
   Osc1=hl[0]; // Последний диапазон HL
   }    
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ  
//                                           O S C

     