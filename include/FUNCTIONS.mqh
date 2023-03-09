   
 
   
template <typename type0> 
type0 ArrMax(type0 &arr[]){ 
   uint size=ArraySize(arr); 
   if (size==0) return(0);           
   type0 max=arr[0]; 
   for (uint i=1; i<size; i++) 
      if(max<arr[i]) max=arr[i]; 
   return(max); 
   }
   
template <typename type1> // шаблон функций для любых типов входных переменных
type1 MAX(type1 n1, type1 n2){  
   if (n1>n2) return(n1);
   else return(n2); 
   }
   
template <typename type2>   
type2 MAX(type2 n1, type2 n2, type2 n3){  
   if (n1>=n2 && n1>=n3) return(n1); else 
   if (n2>=n1 && n2>=n3) return(n2); else
   return (n3); 
   }   
   
template <typename type3> // шаблон функций
type3 MIN(type3 n1, type3 n2){  
   if (n1<n2) return(n1);
   else return(n2); 
   }   

template <typename type4>   
type4 MIN(type4 n1, type4 n2, type4 n3){  
   if (n1<=n2 && n1<=n3) return(n1); else 
   if (n2<=n1 && n2<=n3) return(n2); else
   return (n3); 
   }   
   
template <typename type5>    
type5 ABS(type5 num){
   if (num<0) return (-num);       else return (num); 
   } 
   
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ    
//+------------------------------------------------------------------+
//| класс по сохранению и восстановлению                             |
//| глобальных переменных                                            |
//+------------------------------------------------------------------+      


   
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ 
//+------------------------------------------------------------------+
//| родительский класс по соднанию и обработке                       |
//| списка внешних переменных                                        |
//+------------------------------------------------------------------+       
class EXTERNAL_VARIABLES_PARENT_CLASS { // parent class
   public:
      void EXTERN_VARS(); // ф. обработки внешних переменных (модифицируется в дочерних классах)
      virtual void DATA(string head){} // в разных дочерних классах выполняются разные функции DATA
      virtual void DATA(string name, char& value){} // в разных дочерних классах выполняются разные функции DATA 
   }; 
     
class PRINT_TO_CHART_CLASS : public EXTERNAL_VARIABLES_PARENT_CLASS { // дочерний класс печати внешних переменных на график
   public:     
      virtual void DATA(string head)               {LABEL(head);}                // печать заголовка (... - O U T P U T - ...)
      virtual void DATA(string name, char& value)  {LABEL(name+"="+S0(value));}  // печать списка входных параметров (ATR=4)     
   }PRINT_TO_CHART;

class WRITE_TO_FILE_CLASS : public EXTERNAL_VARIABLES_PARENT_CLASS { // дочерний класс записи внешних переменных в файл
   private: int file;
   public:
      void EXTERN_VARS(int file_index){   // создание дочерней функции с тем же именем, 
         file=file_index;                 // но с внешним параметром индекса файла
         EXTERN_VARS();
         }   
      virtual void DATA(string name, char& value)  {FileWrite(file,name+"=",S0(value));}
   }CREATE_SET_FILE;

class READ_ARRAY_CLASS : public EXTERNAL_VARIABLES_PARENT_CLASS { // дочерний класс создания массива внешних переменных
   private: int index; uchar ExpertNum;
   public:
      void EXTERN_VARS(uchar SetExpertNum){   // создание дочерней функции с тем же именем, 
         index=0;                // но с внешним параметром индекса 
         ExpertNum=SetExpertNum;
         EXTERN_VARS();
         }        
      virtual void DATA(string name, char& value){ // ф. DATA выполняет разные функции в зависимости от дочернего класса
         //Print("ExpertNum=",ExpertNum," index=",index);
         value=      EXP[ExpertNum].PRM[index];    index++;
         TestEndTime=EXP[ExpertNum].TestEndTime;
         OptPeriod=  EXP[ExpertNum].OptPeriod;
         HistDD=     EXP[ExpertNum].HistDD;
         LastTestDD= EXP[ExpertNum].LastTestDD;
     //  Risk=       EXP[ExpertNum].Risk;
         Magic=      EXP[ExpertNum].Mgc;
         ID=         EXP[ExpertNum].ID;
         }
   }READ_ARRAY;

class READ_FROM_FILE_CLASS : public EXTERNAL_VARIABLES_PARENT_CLASS {// дочерний класс чтения внешних переменных из файла 
   private: int file;
   public:
      void EXTERN_VARS(int file_index){
         file=file_index;
         EXTERN_VARS();
         }   
      virtual void DATA(string name, char& value)  {value=char(StrToDouble(FileReadString(file)));}
   }READ_FROM_FILE;  
   
class WRITE_HEAD_CLASS : public EXTERNAL_VARIABLES_PARENT_CLASS { // дочерний класс записи в файл заголовков внешних переменных
   private: int file;
   public:
      void EXTERN_VARS(int file_index){
         file=file_index;
         EXTERN_VARS();
         }   
      virtual void DATA(string name, char& value)  {FileSeek (file,-2,SEEK_END); FileWrite(file,"",name);}
   }WRITE_HEAD_TO_FILE;    

class WRITE_PARAM_CLASS : public EXTERNAL_VARIABLES_PARENT_CLASS { // дочерний класс записи в файо значений внешних переменных
   private: int file;
   public:
      void EXTERN_VARS(int file_index){
         file=file_index;
         EXTERN_VARS();
         }   
      virtual void DATA(string name, char& value)  {FileSeek (file,-2,SEEK_END); FileWrite(file,"",value);}
   }WRITE_TO_FILE;

class MAGIC_GEN_CLASS : public EXTERNAL_VARIABLES_PARENT_CLASS { // дочерний класс генерации Magic из внешних переменных
   public:   
      virtual void DATA(string name, char& value){ // ф. DATA выполняет разные функции в зависимости от дочернего класса
         char i=2;
         while (i<value) {i*=2; if (i>4) break;} // кол-во зарзрядов (бит), необходимое для добавления нового параметра, но не более 3, чтобы не сильно растягивать число
         MagicLong*=i; // сдвиг MagicLong на i кол-во зарзрядов  
         MagicLong+=value; // Добавление очередного параметра
         }
   }MAGIC_GENERATE;
   
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ 

   