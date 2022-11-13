void OUTPUT(){ 
   if (!BUY.Val && !SEL.Val) return;
   float CloseSel=0, CloseBuy=0; // цена, по которой планируется закрываться
   bool  OutUp=0, OutDn=0;   
   if (OTr>0){// пропадание тренда - удаляем отложники, закрываем позы 
      if (!TrUp) {BUYSTP=0;  BUYLIM=0;  OutUp=1;}
      if (!TrDn) {SELSTP=0;  SELLIM=0;  OutDn=1;}
      }
   if (OTr<0){// появление противоположного тренда - удаляем отложники, закрываем позы 
      if (TrDn) {BUYSTP=0;  BUYLIM=0;  OutUp=1;}
      if (TrUp) {SELSTP=0;  SELLIM=0;  OutDn=1;}
      } 
   if (Out){// появление противоположного сигнала
      if (InDn) {BUYSTP=0;  BUYLIM=0;  OutUp=1;}  
      if (InUp) {SELSTP=0;  SELLIM=0;  OutDn=1;}  
      }  
   
   float DELTA =ATR*OD/2; 
   switch (Oprc){  // расчет цены выходов: 
      case  1: // по рынку немедленно
         CloseBuy=float(Bid)+DELTA;     
         CloseSel=float(Ask)-DELTA;    
      break;   
      case  2: // профит на максимально достигнутой в сделке цене
         CloseBuy=MaxFromBuy +ATR/2-DELTA; 
         CloseSel=MinFromSell-ATR/2+DELTA; 
      break;   
      case  3: // на текущий экстремум
         CloseBuy=HI-DELTA; 
         CloseSel=LO+DELTA; 
      break; 
      }        
   if (BUY.Val && OutUp){// Выходим из длинной  
      if (CloseBuy<BUY.Val+Present) CloseBuy=BUY.Val+Present; // двинем выход вверх, если требует жаба
      if (CloseBuy<BUY.Prf || BUY.Prf==0){ // если выход ниже профит таргета, или таргета нет вовсе
         if (CloseBuy-Bid<ATR/4) BUY.Val=0;   else   BUY.Prf=CloseBuy;} 
      X("CloseBuy, Present="+S4(Present), CloseBuy, bar, clrGreenYellow);   // Print("CloseBuy=",CloseBuy," Buy.Val=",BUY.Val);  
      }  
   if (SEL.Val && OutDn){// Выходим из короткой  
      if (CloseSel>SEL.Val-Present) CloseSel=SEL.Val-Present;  // двинем выход вниз, если требует жаба
      if (CloseSel>SEL.Prf || SEL.Prf==0){      
         if (Ask-CloseSel<ATR/4) SEL.Val=0;   else   SEL.Prf=CloseSel;}  // цена закрытия блеже к цене чем текущее значение, если оно вообще установлено
      X("CloseSel, Present="+S4(Present), CloseSel, bar, clrGreenYellow);  // Print("CloseSel=",CloseSel," Sel.Val=",SEL.Val);   
      }  
   ERROR_CHECK(__FUNCTION__);
   }   
     
void TRAILING_STOP(){   // Подвигаем трейлинги:  
   if (TS<0) return;
   float TrlBuy=0, TrlSell=0, STOP=0;
   
   switch (Tk){  // трейлинг согласно расчету цен входов: 
      case  1: // StpHi / StpLo
         if (D<0) STOP=N5(0.9*ATR); else STOP=N5(0.4*ATR); // 
         TrlBuy  = N5(LO-STOP); // стоп ниже LO на: 0.4  0.9 
         TrlSell = N5(HI+STOP);
      break;   
      case  2: // по рынку, все расчеты через ATR          
         STOP  =N5(ATR*(S+1)*0.5);  //  1.0ATR  1.5ATR  2.0ATR  2.5ATR  3.0ATR  3.5ATR  4ATR  4.5ATR
         TrlBuy =float(Low [1])-STOP;   
         TrlSell=float(High[1])+STOP;   
      break;
      case  3: // по ФИБО уровням       
         TrlBuy =FIBO( D-S); //Print("Up>0 setBUY.Val=",setBUY.Val," BUY.Val=",BUY.Val+BUYSTOP+BUYLIMIT);
         TrlSell=FIBO(-D+S); //Print("Dn>0 setSEL.Val=",setSEL.Val," SELL=",SEL.Val+SELLSTOP+SELLLIMIT);//Print("setSEL.Val=",setSEL.Val," setSEL.Stp=",setSEL.Stp, " OrdLim=",OrdLim," setSEL.Val-Open[0]=",setSEL.Val-Open[0]," Open[0]-setSEL.Val=",Open[0]-setSEL.Val);   
      break;
      case 4:  // HI / LO
         STOP=N5((MathAbs(D)+1)*ATR*0.4); // 0.4 0.8 1.2 1.6 2.0 2.4
         if (D>0){
            TrlBuy =HI-STOP; 
            TrlSell=LO+STOP;
         }else{   
            TrlBuy =LO-STOP;    
            TrlSell=HI+STOP; 
            }
      break;   
      }               
   //if (BUY.Val) LINE("TrlBuy",  bar,TrlBuy,  bar+1,TrlBuy,  clrPink,0);
   //if (SEL.Val) LINE("TrlSell", bar,TrlSell, bar+1,TrlSell, clrPink,0);                    
   if (BUY.Val  && TrlBuy>BUY.Stp   && ((TrlBuy>BUY.Val && TrlBuy<Bid-StopLevel) || TS==0)){
      LINE("TrlBuy", bar,TrlBuy, bar+1,TrlBuy, clrRed,1);
      BUY.Stp=TrlBuy;}
   if (SEL.Val && TrlSell<SEL.Stp && ((TrlSell<SEL.Val && TrlSell>Ask+StopLevel) || TS==0)){
      LINE("TrlSell", bar,TrlSell, bar+1,TrlSell, clrRed,1);
      SEL.Stp=TrlSell;} //{Print("SELL=",SEL.Val," TrlSell=",TrlSell);} 
   ERROR_CHECK(__FUNCTION__);
   }
   
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ 
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ   

void TRAILING_PROFIT(){ // модификации профита (профитТаргет тока приближается к цене открытия)  
   if (!PM1 && !PM2) return;
   float NewProfitBuy=0, NewProfitSel=0;
   if (PM1){// приближение профита при каждом откате
      float BuyBack=N5((High[2]-High[1])*(PM2+1)*(PM2+1)*0.1); // 0.4  0.9  1.6  2.5
      float SelBack=N5((Low [1]-Low [2])*(PM2+1)*(PM2+1)*0.1); // 0.4  0.9  1.6  2.5
      if (BUY.Val>0 && BuyBack>0 && SHIFT(BUY.T)>1){// если был обратный откат
         if (BUY.Prf==0) BUY.Prf=MaxFromBuy;
         if (BUY.Prf-BuyBack>BUY.Val) NewProfitBuy=BUY.Prf-BuyBack;  else  NewProfitBuy=BUY.Val;// двигаем профит не ниже максимальнодостигнутой в сделке цены                              
         //V("NewProfitBuy "+S0(SHIFT(BuyTime)), NewProfitBuy, bar, clrMagenta);
         }  
      if (SEL.Val>0 &&  SelBack>0 && SHIFT(SEL.T)>1){
         if (SEL.Prf==0) SEL.Prf=MinFromSell; 
         if (SEL.Prf+SelBack<SEL.Val) NewProfitSel=SEL.Prf+SelBack; else  NewProfitSel=SEL.Val;// не двигаем профит выше минимальнодостигнутой в сделке цены
         //A("NewProfitSel "+S0(SHIFT(SellTime)), NewProfitSel, bar, clrMagenta);
      }  }
   if (PM2){// если цена провалится от максимальнодостигнутого на xATR, выставляется тейк на максимальнодостигнутый уровень
      float temp=ATR*(PM1+1); // 2  3  4  
      if (BUY.Val>0 && MaxFromBuy-Low [1] >temp && (BUY.Prf>MaxFromBuy  || BUY.Prf==0))   {NewProfitBuy=MaxFromBuy;}   //     V("MaxFromBuy", MaxFromBuy, bar, clrRed);
      if (SEL.Val>0 && High[1]-MinFromSell>temp && (SEL.Prf<MinFromSell || SEL.Prf==0))   {NewProfitSel=MinFromSell;}  //     A("MinFromSell", MinFromSell, bar, clrRed);
      }  
   if (NewProfitBuy>0   && (NewProfitBuy <BUY.Prf || BUY.Prf==0)){ 
      LINE("NewProfitBuy", bar,NewProfitBuy, bar+1,NewProfitBuy, clrBlue,1);
      BUY.Prf=NewProfitBuy;}
   if (NewProfitSel>0  && (NewProfitSel>SEL.Prf || SEL.Prf==0)){ 
      LINE("NewProfitSel", bar,NewProfitSel, bar+1,NewProfitSel, clrBlue,1);
      SEL.Prf=NewProfitSel;}
   ERROR_CHECK(__FUNCTION__);
   }  
   
    
   
              



