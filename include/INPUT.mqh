void INPUT(){ // Ф И Л Ь Т Р Ы    В Х О Д А    ///////////////////////////////////////////////////////
   bool SigUp=(InUp && TrUp && !BUY.Val); 
   bool SigDn=(InDn && TrDn && !SEL.Val);  
   if (!SigUp && !SigDn) return; // Print(" Up=",Up," Dn=",Dn);   
   float DELTA =ATR*D/2;   // 0 .. 2.5 
   //if (D>0) DELTA+=ATR/2;   
   //if (D<0) DELTA-=ATR/2;     
   switch (Iprice){  // расчет цены входов: 
      case 0:  // LO / HI (was Not used in previous release)
         setBUY.Val = LO+DELTA;     
         setSEL.Val = HI-DELTA;     
      break;         
      case 1:  // по рынку + ATR          
         setBUY.Val=float(Open[0])+Spred+DELTA;     // ask и bid формируем из Open[0],
         setSEL.Val=float(Open[0])-DELTA;          // чтоб отложники не зависели от шустрых движух   
      break;
      case 2:  // HI / LO
         setBUY.Val=HI+DELTA;    
         setSEL.Val=LO-DELTA;    
      break; 
      case 3: // по ФИБО уровням       
         setBUY.Val=FIBO( D);       
         setSEL.Val=FIBO(-D);     
      break;
      }    
   if (SigUp){  // 
      SET_BUY_STOP();
      if (Del==1){      // удаление старого ордера при появлении нового сигнала  
         if (BUYSTP && MathAbs(setBUY.Val-BUYSTP)>ATR/2)  BUYSTP=0;     // если старый ордер далеко от нового
         if (memBUY.Val && MathAbs(setBUY.Val-memBUY.Val)>ATR/2) memBUY.Val=0;
         if (BUYLIM && MathAbs(setBUY.Val-BUYLIM)>ATR/2)  BUYLIM=0;     // то удаляем его
         }
      if (Del==2){   // при появлении нового сигнала удаляем противоположный или если ордер остался один;
         if (SEL.Val && Ask<SEL.Val)   SEL.Val=0; // если есть прибыльный селл, закрываем его
         if (setSEL.Val==0){
            SELSTP=0; SELLIM=0; memSEL.Val=0;// если есть противоположный отложник и сигналы не одновременные, т.е. чтоб не пришлось тут же его восстанавливать  
      }  }  }
   if (SigDn){  // 
      SET_SEL_STOP();
      if (Del==1){
         if (SELSTP && MathAbs(setSEL.Val-SELSTP)>ATR/2)  SELSTP=0; 
         if (memSEL.Val && MathAbs(setSEL.Val-memSEL.Val)>ATR/2)  memSEL.Val=0; 
         if (SELLIM && MathAbs(setSEL.Val-SELLIM)>ATR/2)  SELLIM=0;  
         }
      if (Del==2){
         if (BUY.Val && Bid>BUY.Val)   BUY.Val=0;
         if (setBUY.Val==0){
            BUYSTP=0; BUYLIM=0; memBUY.Val=0;   
      }  }  }
   if (!SigUp || BUYSTP || BUYLIM || memBUY.Val) setBUY.Val=0;  // если остались старые ордера,
   if (!SigDn || SELSTP || SELLIM || memSEL.Val) setSEL.Val=0;  // новые не выставляем 
   ERROR_CHECK(__FUNCTION__);
   }
//ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
//ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
void SET_BUY_STOP(){// стопы в отдельную ф., чтобы использовать в откатах VIRTUAL_ORDERS() 
   setBUY.Stp=setBUY.Val-ATR*S; 
   setBUY.Prf=setBUY.Val+ATR*P;
   if (Iprice==3){
      setBUY.Stp =FIBO( D-S);       
      setBUY.Prf =FIBO( D+P);} 
   if (P==0)  setBUY.Prf =0; 
   }   
void SET_SEL_STOP(){
   setSEL.Stp=setSEL.Val+ATR*S;  
   setSEL.Prf=setSEL.Val-ATR*P;
   if (Iprice==3){
      setSEL.Stp=FIBO(-D+S);        
      setSEL.Prf=FIBO(-D-P);}
   if (P==0)  setSEL.Prf =0; 
   } 
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ 
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
void VIRTUAL_ORDERS(){ // виртуальные ордера для откатов после пробоя
   if (BrkBck==0) return;  
   //  L O N G
   if (setBUY.Val){  // выставлен/обновлен лонг
      memBUY=setBUY; // запоминаем его параметры в виртуальник
      setBUY.Val=0;  // и удаляем сам ордер
      V("REV "+S4(memBUY.Val),memBUY.Val,bar,clrBlue);
      }
   if (ExpirBars && memBUY.Val && Time[0]>memBUY.Exp){ // Экспирация виртуального ордера проверяется вручную
      X("BUY_Expiration",memBUY.Val,bar,clrBlue);
      memBUY.Val=0;                     // удаляем виртуальник
      }
   if (memBUY.Val && High[1]>memBUY.Val){     // сработал виртуальный ордер
      if (BrkBck>0){ // расчет отката по АТР
         setBUY.Val=memBUY.Val-ATR*BrkBck;   // откат ниже пробитого уровня
         SET_BUY_STOP();
      }else{ // по последнему пробитому пику
         int B=bar+1;
         if (BrkBck==-1){  for (B=bar+1; B<Bars-10; B++){  if (High[B]>High[B-1] && High[B]>High[B+1]) break;}} // ближайший пик
         else{             for (B=bar+1; B<Bars-10; B++){  if (High[B]<High[B+1]) break;}}   // ближайшая впадина 
         setBUY.Val=(float)High[B]; 
         setBUY.Stp=(float)Low[iLowest (NULL,0,MODE_LOW ,B-bar+1,bar)]; // -ATR*S/2  минимальная цена от текущего бара до пробитого пика (зона покупки)
         float MinStop=ATR, MaxStop=ATR*6; // предельные значения стопа
         if (S<5) MinStop=ATR*S;    // 1..4
         else     MaxStop=ATR*(S-3);// 2..6
         if (setBUY.Val-setBUY.Stp<MinStop) {setBUY.Stp=setBUY.Val-MinStop;   A("MODIFY "+S4(setBUY.Stp),setBUY.Stp,bar,clrGreen);} // отодвиаем стоп если оч маленький
         if (setBUY.Val-setBUY.Stp>MaxStop) {setBUY.Val=setBUY.Stp+MaxStop;   A("MODIFY "+S4(setBUY.Val),setBUY.Val,bar,clrGreen);} // пододвигаем вход при оч большом стопе
         setBUY.Prf=setBUY.Val+(setBUY.Val-setBUY.Stp)*P/2; // тейк кратно стопу, а как еще?
         }    
      V("BUY "+S4(setBUY.Val),memBUY.Val,bar,clrBlue);
      memBUY.Val=0;                     // удаляем виртуальник
      }
   //  S H O R T
   if (setSEL.Val){         
      memSEL=setSEL;
      setSEL.Val=0;
      A("REV "+S4(memSEL.Val),memSEL.Val,bar,clrRed);
      }
   if (ExpirBars && memSEL.Val && Time[0]>memSEL.Exp){
      X("SEL_Expiration",memSEL.Val,bar,clrRed);
      memSEL.Val=0;
      }
   if (memSEL.Val && Low[1]<memSEL.Val){
      if (BrkBck>0){
         setSEL.Val=memSEL.Val+ATR*BrkBck;
         SET_SEL_STOP();
      }else{
         int B=bar+1;
         if (BrkBck==-1){  for (B=bar+1; B<Bars-10; B++){  if (Low[B]<Low[B-1] && Low[B]<Low[B+1]) break;}}
         else{             for (B=bar+1; B<Bars-10; B++){  if (Low[B]>Low[B+1]) break;}}
         setSEL.Val=(float)Low[B]; 
         setSEL.Stp=(float)High[iHighest (NULL,0,MODE_HIGH ,B-bar+1,bar)]; // -ATR*S/2
         float MinStop=ATR, MaxStop=ATR*6;
         if (S<5) MinStop=ATR*S;    // 1..4
         else     MaxStop=ATR*(S-3);// 2..6
         if (setSEL.Stp-setSEL.Val<MinStop) {setSEL.Stp=setSEL.Val+MinStop;   A("MODIFY "+S4(setSEL.Stp),setSEL.Stp,bar,clrGreen);}
         if (setSEL.Stp-setSEL.Val>MaxStop) {setSEL.Val=setSEL.Stp-MaxStop;   A("MODIFY "+S4(setSEL.Val),setSEL.Val,bar,clrGreen);}
         setSEL.Prf=setSEL.Val-(setSEL.Stp-setSEL.Val)*P/2;
         }
      A("SEL "+S4(setSEL.Val),memSEL.Val,bar,clrRed);
      memSEL.Val=0;
      }
   }   
   
   
   
//ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
//ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
float FIBO(int FiboLevel){ // Считаем ФИБУ:  Разбиваем диапазон HL   0   11.8   23.6   38.2  50  61.8   76.4  88.2   100 
   double Fib=0;
   switch(FiboLevel){
      case 16: Fib= (HI-LO)*2.500; break;
      case 15: Fib= (HI-LO)*2.382; break;
      case 14: Fib= (HI-LO)*2.236; break;
      case 13: Fib= (HI-LO)*2.118; break;
      case 12: Fib= (HI-LO)*2.000; break;
      case 11: Fib= (HI-LO)*1.882; break;
      case 10: Fib= (HI-LO)*1.764; break;
      case  9: Fib= (HI-LO)*1.618; break;
      case  8: Fib= (HI-LO)*1.500; break;
      case  7: Fib= (HI-LO)*1.382; break;
      case  6: Fib= (HI-LO)*1.236; break;
      case  5: Fib= (HI-LO)*1.118; break;
      case  4: Fib= (HI-LO)*1.000; break; // Hi
      case  3: Fib= (HI-LO)*0.882; break;
      case  2: Fib= (HI-LO)*0.764; break; 
      case  1: Fib= (HI-LO)*0.618; break; // Золотое сечение
      case  0: Fib= (HI-LO)*0.500; break; 
      case -1: Fib= (HI-LO)*0.382; break; // Золотое сечение 
      case -2: Fib= (HI-LO)*0.236; break;
      case -3: Fib= (HI-LO)*0.118; break; 
      case -4: Fib= (HI-LO)*0;     break; // Lo   
      case -5: Fib=-(HI-LO)*0.118; break; 
      case -6: Fib=-(HI-LO)*0.236; break;
      case -7: Fib=-(HI-LO)*0.382; break; 
      case -8: Fib=-(HI-LO)*0.500; break; 
      case -9: Fib=-(HI-LO)*0.618; break; 
      case-10: Fib=-(HI-LO)*0.764; break;
      case-11: Fib=-(HI-LO)*0.882; break;
      case-12: Fib=-(HI-LO)*1.000; break;
      case-13: Fib=-(HI-LO)*1.118; break;
      case-14: Fib=-(HI-LO)*1.236; break;
      case-15: Fib=-(HI-LO)*1.382; break;
      case-16: Fib=-(HI-LO)*1.500; break;
      } //Print("FIBO: HI=",S4(HI)," LO=",S4(LO));
   return(N5(LO+Fib));
   }


   
   
         
         
         
         
         
         
         
         
      

