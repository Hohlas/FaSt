void EXPERT::SIGNAL(bool TREND, char SigType, char SigParam, bool& Up, bool& Dn){  // Сигналы и направления тренда  SigMode=1-расчет тренда,                                                    //                              SigMode=2-расчет сигнала            
   if (SigParam==0 || SigType==0){ // игнорирование сигнала
      Up=1; Dn=1; 
      return;
   }else{ 
      Up=0; Dn=0;}
   int indper;
   float x0=0, x1=0, x2=0, x3=0, z=0, w=0;
   char K=MathAbs(SigParam);
   switch (MathAbs(SigType)){ 
      case 1:// сигналы по $Layers при N>3 ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
         if (K<5){   LAYERS(K*6);      x0=LayH2;    x1=LayL2;}// N=6, 12, 18, 24
         else{       LAYERS((K-4)*4);  x0=LayH3;    x1=LayL3;}// N=0, 6, 12, 18, 24
         if (H>x0)  {if (TREND) Up=1; else if (H1<x0) Up=1;}
         if (L<x1)  {if (TREND) Dn=1; else if (L1>x1) Dn=1;}              
      break; // ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
      case 2:// сигналы по $Layers N<3 ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
         switch(K){
            case 1:  LAYERS(0);  x0=LayH1; x1=LayL1; break;//  $Layers (N=0)
            case 2:  LAYERS(1);  x0=LayH1; x1=LayL1; break;
            case 3:  LAYERS(0);  x0=LayH3; x1=LayL3; break; //  $Layers (N=0)
            case 4:  LAYERS(1);  x0=LayH2; x1=LayL2; break;// опять $Layers(N=1) с теми же уровнями 1 и 5
            case 5:  LAYERS(0);  x0=LayH4; x1=LayL4; break;//  $Layers (N=0)
            case 6:  LAYERS(2);  x0=LayH2; x1=LayL2; break;//  $Layers(N=2) , тока с более дальними уровнями 1 и 5
            case 7:  LAYERS(1);  x0=LayH3; x1=LayL3; break;// перебор уровней 2-6 для индюка $Layers (N=1)
            case 8:  LAYERS(1);  x0=LayH4; x1=LayL4; break;// самые дальние уровни 3-7, они есть тока у $Layers при (N=1)
            case 9:  LAYERS(2);  x0=LayH3; x1=LayL3; break;//  $Layers(N=2) , тока с более дальними уровнями 1 и 5      
            }
         if (H>x0)  {if (TREND) Up=1; else if (H1<x0) Up=1;}
         if (L<x1)  {if (TREND) Dn=1; else if (L1>x1) Dn=1;} 
         //LINE("x0", bar, x0, bar+1, x0, clrBlue, 0);
         //LINE("x1", bar, x1, bar+1, x1, clrBlue, 0);               
      break; // ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
      case 3: // отскоки/приближения к экстремумам HiLo ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
         //if (K<9){
         //z=float((5-K)*0.1);   // 0.4  0.3  0.2  0.1  0  -0.1  -0.2  -0.3  -0.4     
         if (HI -LO >0)   x0=(C -LO )/(HI-LO)-float(0.5);
         if (HI1-LO1>0)   x1=(C1-LO1)/(HI1-LO1)-float(0.5);
         //if (x0> z && x1<= z) {Up=1;   UpTrend=1; DnTrend=0;}
         //if (x0<-z && x1>=-z) {Dn=1;   DnTrend=1; UpTrend=0;}
         if (K==5){
            if (H>=HI1) {Up=1; UpTrend=1; DnTrend=0;} // значения UpTrend/DnTrend запоминаются от бара к бару
            if (L<=LO1) {Dn=1; DnTrend=1; UpTrend=0;}
            }
         if (K<5){// 
            if (x0> K*0.1) {Up=1; UpTrend=1; DnTrend=0;}
            if (x0<-K*0.1) {Dn=1; DnTrend=1; UpTrend=0;}
            }
         if (K>5){
            if (x1> (K-5)*0.1 && x0< (K-5)*0.1) {Up=1; UpTrend=1; DnTrend=0;}
            if (x1<-(K-5)*0.1 && x0>-(K-5)*0.1) {Dn=1; DnTrend=1; UpTrend=0;}
            }   
         if (TREND)  {Up=UpTrend; Dn=DnTrend;}  // запоминаем значение сигнала, т.к. он существует только один бар    
      break; // ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
      case 4: // Сигнал / Шум ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
         indper=int(NormalizeDouble(MathPow(1.5,K+5),0)); // 11  17  26  38  58  86  130  195  291
         iDM(1,indper);
         if (TREND){
            if (DM> 0) Up=1;
            if (DM<-0) Dn=1;
            }
         else{
            if (DMmin<0 && DM-DMmin>0.1 && DM1-DMmin<=0.1) Up=1; // отскок от минимума 
            if (DMmax>0 && DMmax-DM>0.1 && DMmax-DM1<=0.1) Dn=1; // отскок от максимума
            }
         x0=DM; x1=DM1; x2=DMmax; x3=DMmin;  
      break; // ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
      case 5:// DM приоритетное направление движения цены ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
         indper=int(NormalizeDouble(MathPow(1.5,K+6),0)); // 17  26  38  58  86  130  195  291  438  
         if (TREND){ // положение индюка относительно нулевой линии (ATR для гистерезиса)
            iDM(0,indper);
            if (DM> ATR) Up=1; 
            if (DM<-ATR) Dn=1; 
            }
         else{ 
            if (K==1 || K==3 || K==5 || K== 7 || K==9) iDM(0,indper); // отскоки DM от максимального / минимального значений на ATR
            else   iDM(3,indper);// отскоки Momentum от максимального / минимального значений на ATR 
            if (DMmin<-ATR*2 && DM-DMmin>ATR && DM1-DMmin<=ATR) Up=1; // отскок от минимума 
            if (DMmax> ATR*2 && DMmax-DM>ATR && DMmax-DM1<=ATR) Dn=1;
            }  
         x0=DM; x1=DM1; x2=DMmax; x3=DMmin; 
      break; // ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
      case 6: // Фракталы (нет сигналов)
         if (TREND){// Тренд - формирование пика, либо моментум
            if (K==1){
               if (LO2>LO1 && LO1<=LO)  Up=1; // сформировался очередной минимум, тренд вверх 
               if (HI2<HI1 && HI1>=HI)  Dn=1; // сформировался очередной максимум, тренд вниз
            }else{
               indper=int(NormalizeDouble(MathPow(K+1,2.5),0)); // 15 32 56 88 130 181 243 316
               if (bar+indper>=Bars) break;
               if (Open[0]-Open[bar+indper]>0)  Up=1; 
               else                             Dn=1;
            }  }    
         else{// фрактал - резкий пик
            x3=ATR*K/2; // постоянная удаления вершины от краев (отсеиваем плоские фракталы)
            x0=(float)High[K+1]; // вершина
            x1=(float)High[iHighest(Sym,0,MODE_HIGH,K*2+1,1)];
            x2=(float) Low[ iLowest(Sym,0, MODE_LOW,K,K+1)];
            if (x0==x1 && Low [1]<x0-x3 && x2<x0-x3){    V("Dn", x0, K+1, clrRed);
               Dn=1;} // "чистый фрактал" (одна вершина, достаточно удаленная от краев)
            x0=(float)Low [K+1];
            x1=(float) Low[ iLowest(Sym,0, MODE_LOW,K*2+1,1)];
            x2=(float)High[iHighest(Sym,0,MODE_HIGH,K,K+1)];
            if (x0==x1 && High[1]>x0+x3 && x2>x0+x3){    A("Up", x0, K+1, clrRed);
               Up=1;}
            }     
      break; // ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ 
      case 7:// * Тренд Momentum. Сигнал на разрыве, или оч длинном баре, а так же по моментуму ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ     
         if (TREND){ // Классический моментум
            indper=int(NormalizeDouble(MathPow(2,K),0)); // 2 4 8 16 32 64 128 256 512
            if (bar+indper>=Bars) break;
            if (Open[0]-Open[bar+indper]>ATR*K/2) Up=1; 
            if (Open[bar+indper]-Open[0]>ATR*K/2) Dn=1;
            }
         else{//сигнал на разрыве, или оч длинном баре         (всего один сигнал)
            if (K==2 || K==4 || K==6 || K==8){
               x0=(float)ATR*(1+K/2); // 2  3  4  5
               x1=(float)Open[0]; // открытие нулевого бара
               if (x1-L>x0) Up=1; // наличие разрыва,
               if (H-x1>x0) Dn=1; // или оч длинного бара   
            }else{
               indper=int(NormalizeDouble(MathPow(1.5,K),0)); // 2 3 8 17 38
               DMmax1=DMmax; DMmin1=DMmin;
               iDM(3,indper);
               if (DMmax> ATR*2 && DMmax>DMmax1) Up=1;
               if (DMmin<-ATR*2 && DMmin<DMmin1) Dn=1;
               x0=DMmax; x1=DMmin; x2=DMmax1; x3=DMmin1;
            }  } 
      break; // ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ   
      case 8: // сужение/расширение ATR относительно предыдущих значений ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
         x1=Atr.Fst;  x2=Atr.Slw;
         if (x1<=0 || x2<=0) break;
         if (K<6) {z=float(0.65+K*0.05);  if (Atr.Fst/Atr.Slw<z) {Up=1; Dn=1;}} // при уменьшении atr в       0.7  0.75  0.8  0.85  0.9
         else     {z=float((22-K)*0.05);  if (Atr.Slw/Atr.Fst<z) {Up=1; Dn=1;}} // при увеличении atr в  0.65 0.7  0.75  0.8     
      break; // ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
      default: //  без всяких фильтров  ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
         Up=1; Dn=1; 
      break; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
      }
   if (SigType<0)    {bool k=Up; Up=Dn; Dn=k;} // смена сигналов местами 
   if (TREND && Inv) {Up=!Up;    Dn=!Dn;}      // инверсия сигналов тренда       
   ERROR_CHECK(__FUNCTION__);  
   if (!Real) return;  // сохраним значения индюков для сравнения Real / Test ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
   switch(TREND){
      case 0: // In
         ch[2]=Up; // InUp
         ch[3]=Dn; // InDn
         PS[4]=x0; // In0
         PS[5]=x1; // In1
         PS[6]=x2; // In2
         PS[7]=x3; // In3
      break;   
      case 1: // Trend
         ch[0]=Up; // TrUp
         ch[1]=Dn; // TrDn
         PS[0]=x0; // Tr0 
         PS[1]=x1; // Tr1
         PS[2]=x2; // Tr2
         PS[3]=x3; // Tr3
      break;   
      default:  // Out
         ch[4]=Up; // OutUp
         ch[5]=Dn; // OutDn
         PS[8] =x0; // Out0
         PS[9] =x1; // Out1
         PS[10]=x2; // Out2
         PS[11]=x3; // Out3
      break;     
   }  }  

