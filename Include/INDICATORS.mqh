


// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ 
//                                        D I R E C T     M O V E N T 
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ                             

void EXPERT::iDM(int DmMode, int per){//      MODE=0..3, per=1..10
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

void EXPERT::ATR_DOUBLE(int B){       // тупое медленное усреднение HL на каждом баре. Остальные методы: как стандартный МТ индюк,
   if (B+SlowAtrPer>=Bars){   // так и метод сдвига массива HL,  имеют расхождения Реал/Тест из-за пропусков бар и ХЗ знает от чего
      ATR=0;   Atr.Fst=0;  Atr.Slw=0;
      return;}
   Atr.Fst=0; 
   for (int b=B; b<B+FastAtrPer; b++) Atr.Fst+=float(High[b]-Low[b]);    
   Atr.Fst/=FastAtrPer;
   atr=Atr.Fst;
   if (TimeDay(Time[B])!=TimeDay(Time[B+1])){  // медленный АТР считается раз в сутки (при А=15 его период около 9 дней)
      Atr.Slw=0;   
      for (int b=B; b<B+SlowAtrPer; b++) Atr.Slw+=float(High[b]-Low[b]);    
      Atr.Slw/=SlowAtrPer;
      }
   if (Mod==0) ATR=Atr.Slw;
   else        ATR=(Atr.Fst+Atr.Slw)/2;
   if (Atr.Fst>Atr.Slw) {Atr.Max=Atr.Fst; Atr.Min=Atr.Slw;}
   else                 {Atr.Max=Atr.Slw; Atr.Min=Atr.Fst;}
   Atr.Lim=ATR*AtrLim/100;   // допуск уровней в % Atr.Slw
   }  
//                                        H I  /  L O 
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ                              



float H,H1,L,L1,C,C1, HI, LO, HI1, LO1, HI2, LO2, HI3, LO3, VolClaster;
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ                             
void EXPERT::iHILO(){      
   for (int B=Bars-BarHL; B>0; B--) iHL(B);     // чтобы функция iHL(B) была не чусвстительна к пропуску бар в следствии нерегулярного подключеия к графику 
   BarHL=Bars;   //     Print("bar=",bar," B=",B," BarHL=",BarHL," ATR=",ATR," Bars=",Bars," Time[B]=",TimeToStr(Time[B],TIME_DATE | TIME_MINUTES));
   }   
void EXPERT::iHL(int B){
   short per=short(FIBO(HLk+1)); // 1 2 3 5 8 13 21 34 55
   HI3=HI2; HI2=HI1; HI1=HI; LO3=LO2; LO2=LO1; LO1=LO;  H1=H; L1=L; C1=C; 
   H=float(High[B]); 
   L=float(Low [B]);
   C=float(Close[B]);
   ATR_DOUBLE(B);
   if (ATR==0) return;
   float Delta=ATR*per; 
   //Print("time[",B,"]=",BTIME(B)," BarHL=",BarHL," Atr.Fst=",Atr.Fst," ATR=",ATR,"    H=",H," HI=",HI," LO=",LO," HLwid=",HLwid);
   if (H>=HI)  HLtrend=1;
   if (L<=LO)  HLtrend=-1;
   switch (HL){
      case 1: // Nearest F(HLper). При пробое одного из уровней ищутся ближайшие фракталы шириной per бар. 
         if (Mod==0) per=short(MathPow(HLk,1.7)-1);
         if (H>=HI || L<=LO){   // пробитие одной из границ канала
            HI=PIC_HI(B,per,0);  
            LO=PIC_LO(B,per,0);  
            }
      break; 
      case 2: // Фракталы адаптивной ширины далее Delta от текущей цены 
         if (Mod==0) Delta=ATR*(HLk+1);
         if (H>=HI || L<=LO){   // пробитие одной из границ канала
            HI=PIC_HI(B,0,L+Delta);
            LO=PIC_LO(B,0,H-Delta);
            }      
      break;       
      case 3: // 
         if (TimeHour(Time[B])<TimeHour(Time[B+1])){
            if (HLk<5){
               float dHL=0;
               for (int b=0; b<per; b++) dHL+=float(High[iHighest(NULL,0,MODE_HIGH,BarsInDay,B+b*BarsInDay)]-Low [iLowest (NULL,0,MODE_LOW ,BarsInDay,B+b*BarsInDay)]); 
               dHL/=per;
               HI=float(Close[B])+dHL/2;  // V("per="+S0(per), H, B, clrRed);
               LO=float(Close[B])-dHL/2;
            }else if (HLk==5){
               HI=PIC_HI(B,BarsInDay/2,0); // при пробое верхней границы ищем ближайший фрактал адаптивной ширины 
               LO=PIC_LO(B,BarsInDay/2,0);
            }else{   
               HI=float(Close[B])+Atr.Max*(HLk-5);
               LO=float(Close[B])-Atr.Max*(HLk-5);
            }  }
         if (H>=HI)  HI=PIC_HI(B,BarsInDay/2,0); // при пробое верхней границы ищем ближайший фрактал адаптивной ширины 
         if (L<=LO)  LO=PIC_LO(B,BarsInDay/2,0);
      break;             
      case 4: // Пики адаптивной ширины, давшие отскок более Delta 
         if (Mod==0) Delta=ATR*(HLk+1);
         if (H>=HI || L<=LO){  // пробой одной из границ
            float maxHi=float(High[B]), minLo=float(Low[B]);
            for (int b=B+1; b<Bars; b++){
               if (Low[b]<minLo) minLo=float(Low[b]); // максимальная величина движения вниз из High[b] 
               if (FIND_HI(B,b,0,HI,High[b]-minLo>Delta))   break; // ближайший фрактал сверху  удаленный на Delta
               }
            for (int b=B+1; b<Bars; b++){
               if (High[b]>maxHi) maxHi=float(High[b]);// минимальная величина движения вверх из Low[b] 
               if (FIND_LO(B,b,0,LO,maxHi-Low[b]>Delta))    break; // любой фрактал ниже текущей цены на Delta
            }  }
      break;
      case 5: // Classic F(HLper). Фракталы шириной HLper бар. 
         if (Mod==0) per=short(MathPow(HLk,1.7)-1);
         if (B+per>=Bars) break;
         if (H>=HI)  HI=PIC_HI(B,per,0);  // при пробое верхней границы ищем ближайший фрактал шириной HLwid
         if (L<=LO)  LO=PIC_LO(B,per,0);  
         if (High[B+per]==High[iHighest(NULL,0,MODE_HIGH,per*2+1,B)])  HI=float(High[B+per]); // сформировался фрактал шириной HLwid
         if (Low [B+per]==Low [iLowest (NULL,0,MODE_LOW ,per*2+1,B)])  LO=float(Low [B+per]);
      break;
      case 6: // (was 8) LastDay Hi/Lo за 24+HLwid часов
         per=short(HLk-1)*3;
         if (per<0 || B+2+per>Bars) break;
         if (TimeHour(Time[B+per])<TimeHour(Time[B+1+per])){
            HI=float(High[iHighest(NULL,0,MODE_HIGH,BarsInDay,B)]);  
            LO=float(Low [iLowest (NULL,0,MODE_LOW ,BarsInDay,B)]);}
         if (Mod==0){
            if (L<=LO || H>=HI){
               short cntbar=0;    
               for (int b=B+1; b<Bars; b++){
                  cntbar++;
                  if (b<Bars-1-per && TimeHour(Time[b+per])<TimeHour(Time[b+1+per])) cntbar=0;    
                  if (L<=LO)  if (FIND_LO(B,b,24-cntbar,LO,true)) break; 
                  if (H>=HI)  if (FIND_HI(B,b,24-cntbar,HI,true)) break;
               }  }
         }else{
            if (H>=HI)  HI=PIC_HI(B,BarsInDay,0); // при пробое верхней границы ищем ближайший фрактал шириной HLwid
            if (L<=LO)  LO=PIC_LO(B,BarsInDay,0); 
            }   
      break;
      
      case 7: // старый примитивный HL за Per последних бар (Ye$$)
         per=short(MathPow((HLk+1)*MathPow(60.00/Period(),0.5),1.7)); //  7.2  12  18  25  33  42  52  63  75    
         HI=float(High[iHighest(NULL,0,MODE_HIGH,per,B)]);
         LO=float(Low [iLowest (NULL,0,MODE_LOW ,per,B)]);
      break; 
      
      
      default://
         HI=H; LO=L;
      break;   
      }
      
   color Clr=clrRed;
   if (HLtrend>0) Clr=clrRed; else Clr=clrBlack;
   //LINE("HI, HLper", bar+1,HI1+Point*50, bar,HI+Point*50, Clr,2);
   //LINE("LO, HLper", bar+1,LO1-Point*50, bar,LO-Point*50, Clr,2);
     
   iOSC();      
   }   
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ                             
float EXPERT::PIC_HI(int B, int width, float CompareLev){
   float PicHi=0; 
   for (int b=B+1; b<Bars; b++)   if (FIND_HI(B,b,width,PicHi,High[b]>CompareLev))  break;   // V("b="+S0(b),High[b],b,clrRed); 
   return (PicHi);   // V("PicHi="+S4(PicHi),PicHi,B,clrBlue);
   }
float EXPERT::PIC_LO(int B, int width, float CompareLev){
   float PicLo=0;
   if (CompareLev<=0) CompareLev=999999;
   for (int b=B+1; b<Bars; b++)   if (FIND_LO(B,b,width,PicLo,Low[b]<CompareLev)) break;
   return (PicLo);
   }   
bool EXPERT::FIND_HI(int B, int b, int width, float& NewHI, bool Condition){ // Поиск фрактала шириной width. Condition - доп. внешнее условие
   if (b-B>LimitBars || b>Bars-2){ // добрались до предельного кол-ва обсчитываемых бар
      NewHI=ATH(NewHI);  return(true);}     // это будет искомый пик, дальше искать нет смысла 
   if (width==0) width=int(MathPow(b-B,0.5));  //  // при HLper=0 ширина фрактала width пропорциональна его удалению, начиная с 4 
   if (High[b]==High[iHighest(NULL,0,MODE_HIGH,b-B+width+1,B)]){// максимальный пик и фрактал периодом width
      NewHI=float(High[b]);  return(Condition);} 
   return (false); // пока не найдется новый фрактал выше текущего бара заданной ширины   
   }   
bool EXPERT::FIND_LO(int B, int b, int width, float& NewLO, bool Condition){
   if (b-B>LimitBars || b>Bars-2){ // -width
      NewLO=ATL(NewLO); return(true);}
   if (width==0) width=int(MathPow(b-B,0.5)); //  // при HLper=0 ширина фрактала width пропорциональна его удалению, начиная с 4 
   if (Low[b]==Low[iLowest (NULL,0,MODE_LOW ,b-B+width+1,B)]){
      NewLO=float(Low[b]); return(Condition);} // пока не найдется новый фрактал выше текущего бара заданной ширины
   return (false);    
   }            
float EXPERT::ATH(float LastHi){
   if (Mod==0) return(H+ATR*2);
   else{
      if (H<LastHi) return(LastHi); // если последний найденный пик выше Н, подставляем хотябы его
      else return(H+Atr.Max);       // в заданном диапазоне бар ни одного превосходящего пика, отступаем АТР
   }  }
float EXPERT::ATL(float LastLo){
   if (Mod==0) return(L-ATR*2);
   else{        
      if (L>LastLo && LastLo>0) return(LastLo); 
      else return(L-Atr.Max);
   }  }
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ  
//                                 L A Y E R S
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ  
void EXPERT::LAYERS(int Layer){      
   for (int B=Bars-BarLayers; B>0; B--) iLAYERS(B, Layer);     // чтобы функция iHL(B) была не чусвстительна к пропуску бар в следствии нерегулярного подключеия к графику 
   BarLayers=Bars;  
   }   
void EXPERT::iLAYERS(int B, int Layer){
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
void EXPERT::iOSC(){
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

     