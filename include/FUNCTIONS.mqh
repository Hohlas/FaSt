float LOWEST (int shift, int from_bar)  {return (float(Low [iLowest (NULL,0,MODE_LOW ,shift, from_bar)]));} 
float HIGHEST(int shift, int from_bar)  {return (float(High[iHighest(NULL,0,MODE_HIGH,shift, from_bar)]));} 
    
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

template <typename type6>
void SWAP(type6 &n1, type6 &n2){
   type6 temp=n1;
   n1=n2; n2=temp;
   } 
   
template <typename type7>
void ADD_TO_ARRAY(type7 num, type7 &array[]){ 
   uint arr_size=ArraySize(array); 
   if (arr_size<2) return;            
   for (uint i=arr_size-1; i>0; i--) array[i]=array[i-1];
   array[0]=num;  
   } 
   
template <typename type8> 
type8 ARRAY_MAX(type8 &array[]){ 
   uint arr_size=ArraySize(array); 
   if (arr_size==0) return(0);           
   type8 max=array[0]; 
   for (uint i=1; i<arr_size; i++) if(max<array[i]) max=array[i]; 
   return(max); 
   }        
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ 
//+-------------------------------------------------------------+
//| родительский класс с общими функциями                       |
//| для разных экспертов                                        |
//+-------------------------------------------------------------+  
class EXPERT_PARENT_CLASS { // общие функции во всех последующих версиях 
   #define LOAD 1
   #define SAVE 2
   #define PARAMS 50 // максимальное количество входных параметров эксперта
   #define MAX_EXPERTS_AMOUNT 100 // 
   private: // переменные только этого класса
      uchar    cnt1, cnt2, mode;
   
   protected: // переменные этого и дочерних классов
      uchar    ExpNum; // порядковый номер в массиве (номер экземпляра класса)  эксперта       
      ushort   BarsInDay, FastAtrPer, SlowAtrPer, Tout, Tin, Tper,  ExpirBars;
      float    ATR, atr, Present;
      
   public: // переменные доступные отовсюду
      short    Per, HistDD, LastTestDD, Back;
      datetime Bar, TestEndTime, ExpMemory; 
      char     PRM[PARAMS];
      string   ID, Sym, Name, Hist, OptPer;
      float    Rsk;
      int      Mgc; 
      ORD_TYPE mem;
   
      
      void GLOBAL_VARIABLES_LIST();    // функция со списком глобальных переменных. Запускается в COUNT()
      void INIT(uchar e){ExpNum=e;}
      void ERROR_LOG(string ErrTxt);
      
      void BACKUP(){ // сохранение списка переменных заданного эксперта
         cnt1=0; cnt2=0;
         mode=SAVE; //Print("MODE=SAVE, expert=",SetExpertNum);
         GLOBAL_VARIABLES_LIST();
         }
   
      void RESTORE(){ // восстановление списка переменных заданного эксперта
         cnt1=0; cnt2=0;
         mode=LOAD; //Print("MODE=LOAD, expert=",SetExpertNum);
         GLOBAL_VARIABLES_LIST();
         }   
      
      template <typename type1>     
      void EXPERT_PARENT_CLASS::COPY(type1 &Data){ // сохранение/восстановление любого типа переменных
         static type1 copy_data[PARAMS][MAX_EXPERTS_AMOUNT];
         if (mode==SAVE)   copy_data[cnt1][ExpNum]=Data;
         if (mode==LOAD)   Data=copy_data[cnt1][ExpNum];
         cnt1++; 
         }; 
         
      template <typename type0> 
      void EXPERT_PARENT_CLASS::COPY(type0 &array[]){ // сохранение/восстановление массива любого типа переменных
         uint arr_size=ArraySize(array); 
         static type0 copy[][PARAMS][MAX_EXPERTS_AMOUNT];
         ArrayResize(copy,arr_size,0);
         if (mode==SAVE)   for (uint i=0; i<arr_size; i++) copy[i][cnt2][ExpNum]=array[i];
         if (mode==LOAD)   for (uint i=0; i<arr_size; i++) array[i]=copy[i][cnt2][ExpNum];
         cnt2++;
         } 
              
      void EXTERN_VARS(); // ф. обработки внешних переменных (модифицируется в дочерних классах)
      virtual void DATA(string head){} // в разных дочерних классах выполняются разные функции DATA
      virtual void DATA(string name, char& value){} // в разных дочерних классах выполняются разные функции DATA 


   }; 

// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ 
//+---------------------------------------------------------------+
//| дочерние классы по соднанию и обработке                       |
//| списка внешних переменных                                     |
//+---------------------------------------------------------------+       
     
class PRINT_TO_CHART_CLASS : public EXPERT_PARENT_CLASS { // дочерний класс печати внешних переменных на график
   public:     
      virtual void DATA(string head)               {LABEL(head);}                // печать заголовка (... - O U T P U T - ...)
      virtual void DATA(string name, char& value)  {LABEL(name+"="+S0(value));}  // печать списка входных параметров (ATR=4)     
   }PRINT_TO_CHART;

class WRITE_TO_FILE_CLASS : public EXPERT_PARENT_CLASS { // дочерний класс записи внешних переменных в файл
   private: int file;
   public:
      void EXTERN_VARS(int file_index){   // создание дочерней функции с тем же именем, 
         file=file_index;                 // но с внешним параметром индекса файла
         EXTERN_VARS();
         }   
      virtual void DATA(string name, char& value)  {FileWrite(file,name+"=",S0(value));}
   }CREATE_SET_FILE;

class READ_ARRAY_CLASS : public EXPERT_PARENT_CLASS { // дочерний класс создания массива внешних переменных
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
         OptPeriod=  EXP[ExpertNum].OptPer;
         HistDD=     EXP[ExpertNum].HistDD;
         LastTestDD= EXP[ExpertNum].LastTestDD;
     //  Risk=       EXP[ExpertNum].Risk;
         Magic=      EXP[ExpertNum].Mgc;
         ID=         EXP[ExpertNum].ID;
         }
   }READ_ARRAY;

class READ_FROM_FILE_CLASS : public EXPERT_PARENT_CLASS {// дочерний класс чтения внешних переменных из файла 
   private: int file;
   public:
      void EXTERN_VARS(int file_index){
         file=file_index;
         EXTERN_VARS();
         }   
      virtual void DATA(string name, char& value)  {value=char(StrToDouble(FileReadString(file)));}
   }READ_FROM_FILE;  
   
class WRITE_HEAD_CLASS : public EXPERT_PARENT_CLASS { // дочерний класс записи в файл заголовков внешних переменных
   private: int file;
   public:
      void EXTERN_VARS(int file_index){
         file=file_index;
         EXTERN_VARS();
         }   
      virtual void DATA(string name, char& value)  {FileSeek (file,-2,SEEK_END); FileWrite(file,"",name);}
   }WRITE_HEAD_TO_FILE;    

class WRITE_PARAM_CLASS : public EXPERT_PARENT_CLASS { // дочерний класс записи в файо значений внешних переменных
   private: int file;
   public:
      void EXTERN_VARS(int file_index){
         file=file_index;
         EXTERN_VARS();
         }   
      virtual void DATA(string name, char& value)  {FileSeek (file,-2,SEEK_END); FileWrite(file,"",value);}
   }WRITE_TO_FILE;

class MAGIC_GEN_CLASS : public EXPERT_PARENT_CLASS { // дочерний класс генерации Magic из внешних переменных
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

   