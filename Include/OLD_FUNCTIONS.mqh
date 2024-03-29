void EXPERT::COUNT_200900(){
   if (Mod>0){ // Mod=1
      Present=ATR*FIBO(Oprf); // 0 0.5 1 2 3 5 
   }else{            // Mod=0
      if (Oprf==0)   Present=-999999;   // пороговая прибыль, 
      else           Present=float(Oprf*Oprf*ATR/10);  // без которой не хочется закрываться  0.1  0.4  0.9  1.6
   }  }
   
   // INPUT
void EXPERT::SET_BUY_200900(){
   if (S>0)    set.BUY.Stp=set.BUY.Val-ATR*FIBO(S);   
   else{       for (int b=bar; b<Bars; b++)  if (FIND_LO(bar,b,-S, set.BUY.Stp, set.BUY.Val-Low[b]>ATR*FIBO(-S)))  {A("stpBUY ",set.BUY.Stp,b,clrRed); break;}  set.BUY.Stp-=ATR/2;}
   if (P==0)   set.BUY.Prf =0;                      else
   if (P>0)    set.BUY.Prf=set.BUY.Val+ATR*FIBO(P);  else
   if (P<0)    set.BUY.Prf=set.BUY.Val-(set.BUY.Val-set.BUY.Stp)/2*P; 
   }
void EXPERT::SET_SEL_200900(){
   if (S>0)    set.SEL.Stp=set.SEL.Val+ATR*FIBO(S);  
   else{       for (int b=bar; b<Bars; b++)  if (FIND_HI(bar,b,-S, set.SEL.Stp, High[b]-set.SEL.Val>ATR*FIBO(-S))) {V("stpSEL ",set.SEL.Stp,b,clrRed); break;}    set.SEL.Stp+=ATR/2;}
   if (P==0)   set.SEL.Prf =0;                      else
   if (P>0)    set.SEL.Prf=set.SEL.Val-ATR*FIBO(P);  else
   if (P<0)    set.SEL.Prf=set.SEL.Val+(set.SEL.Stp-set.SEL.Val)/2*P; 
   }   
   
   // OUTPUT
void EXPERT::TRAILING_200833(float& TrlBuy, float& TrlSel){ // Mod=0
   if (Tk>0){  TrlBuy=H-ATR*FIBO(Tk);                 TrlSel=L+ATR*FIBO(Tk);}
   if (Tk==1){ TrlBuy=LO-ATR/2;                       TrlSel=HI+ATR/2;}
   if (Tk<0){  TrlBuy=PIC_LO(bar,-Tk,H+Tk*ATR)-ATR/2; TrlSel=PIC_HI(bar,-Tk,L-Tk*ATR)+ATR/2;}
   }   
   
void EXPERT::TRAILING_200900(float& TrlBuy, float& TrlSel){ // mod=1
   if (Ver<200.900){ 
      TRAILING_200833(TrlBuy,TrlSel); 
      return;}
   if (Tk>1){  TrlBuy=H-Tk*ATR;                       TrlSel=L+Tk*ATR;}          // классика через ATR
   if (Tk==1){ TrlBuy=LO-ATR/2;                       TrlSel=HI+ATR/2;}          // текущий HI/LO с допуском ATR/2
   if (Tk==-1){set.BUY.Val=H;  SET_BUY_STOP();         TrlBuy=set.BUY.Stp;         // стандартная функция стопов
               set.SEL.Val=L;  SET_SEL_STOP();         TrlSel=set.SEL.Stp;}
   if (Tk<-1){ TrlBuy=PIC_LO(bar,0,H+Tk*ATR)-ATR/2;   TrlSel=PIC_HI(bar,0,L-Tk*ATR)+ATR/2;} // пик удаленный на ATR*Tk 
   }         