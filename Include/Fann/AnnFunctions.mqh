//+------------------------------------------------------------------+
//|                                                 AnnFunctions.mqh |
//|                                                  Igor Kharchenko |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Igor Kharchenko"
#property link      ""
#property strict


// Диапазон генерации начальных коэффициентов.
// Enum:
//     COEFF_FROM_MINUS_1_TO_1 - диапазон [-1; 1].
//     COEFF_MARIUSZ_WOLOSZYN  - диапазон [-0.4; 0.4].
// See:
//     Подробнее о коэффициентах Мариуша Волошина см. его статью  
//     https://www.mql5.com/ru/articles/1565
//     В созданном автором советнике используются коэффициенты от -0.4 до 0.4.
enum InitialCoefficients
{
   COEFF_FROM_MINUS_1_TO_1 = 1,
   COEFF_MARIUSZ_WOLOSZYN = 2,
};


// Откуда берём значения.
// 
// Enum:
//    DATA_SOURCE_OPEN  - цены открытия бара.
//    DATA_SOURCE_CLOSE - цены закрытия бара.
//    DATA_SOURCE_SMA   - данные от SMA.
//    DATA_SOURCE_EMA   - данные от EMA.
enum DataSource 
{
   DATA_SOURCE_OPEN = 0,
   DATA_SOURCE_CLOSE = 1,
   DATA_SOURCE_SMA = 10,
   DATA_SOURCE_EMA = 11,
};


// ==================================================
// ======= Функции запуска и уничтожения ИНС ========
// ==================================================

// Запускает ИНС.
// Parameters:
//     InitialCoefficients initialCoefficientsType — диапазон генерации начальных коэффициентов (см. перечисление InitialCoefficients).
// Returns:
//     int
//     дескриптор ИНС в случае, если всё норм,
//     -1 в случае ошибки.
// ======
int ann_load (InitialCoefficients initialCoefficientsType) 
{
    int ann_entity = -1;
    
	 ann_entity = f2M_create_standard (4, AmountOfInputNeurons, AmountOfHiddenNeurons, AmountOfHiddenNeurons, AmountOfOutputNeurons);
	 if (-1 == ann_entity) {
	   debug(ERROR, "FANN initialization failed!");
	 }
	 if (-1 == f2M_set_act_function_hidden (ann_entity, FANN_SIGMOID_SYMMETRIC_STEPWISE)) {
	   debug(ERROR, "f2M_set_act_function_hidden failed!");
	 }
 	 if (-1 == f2M_set_act_function_output (ann_entity, FANN_SIGMOID_SYMMETRIC_STEPWISE)) {
 	   debug(ERROR, "f2M_set_act_function_output failed!");
 	 }
 	 
 	 double diapason[];
 	 ArrayResize(diapason, 2);
 	 if (COEFF_MARIUSZ_WOLOSZYN == initialCoefficientsType) {
 	   diapason[0] = -0.4;
 	   diapason[1] = 0.4;
 	 } else if (COEFF_FROM_MINUS_1_TO_1 == initialCoefficientsType) {
 	   diapason[0] = -1.0;
 	   diapason[1] = 1.0;
 	 }

	 if (-1 == f2M_randomize_weights (ann_entity, diapason[0], diapason[1])) {
	   debug(ERROR, "f2M_randomize_weights failed!");
	 }
	 
    return ann_entity;
}

// Загружает ИНС из файла.
// Parameters:
//     string filename — название файла.
// Returns:
//     int
//     дескриптор ИНС в случае, если всё норм,
//     -1 в случае ошибки.
// ======
int ann_load_from_file(string filename)
{
   
   uchar p[];
   StringToCharArray(filename, p, 0, -1, CP_ACP);
   
   int res = f2M_create_from_file(p);
   if (-1 == res) {
      debug(ERROR, "f2M_create_from_file failed!");
   }
   
   return res;
}

// Схороняет ИНС в файл.
// Parameters:
//     string filename — название файла.
// Returns:
//     int
//     0 в случае, если всё норм,
//     -1 в случае ошибки.
// ======
int ann_save_to_file(string filename)
{
   uchar p[];
   StringToCharArray(filename, p, 0, -1, CP_ACP);
     
   int res = f2M_save(ann, p);
   if (-1 == res) {
      debug(ERROR, "f2M_save failed!");
   }
   
   return res;
}

// Уничтожает ИНС.
// Returns:
//     int
//     0 в случае, если всё норм,
//     -1 в случае ошибки.
// ======
int ann_destroy (int ann_entity)
{
    return f2M_destroy (ann_entity);
}

// ==================================================
// ========== Подготовка данных для ИНС. ============
// ==================================================

// Подготавливает входные параметры для ИНС.
// 
// Parameters:
//     double   &_input_vector[] - вектор входных данных ИНС.
//     MqlRates &_rates[]        - массив OHLCT.
// Returns:
//     void
// ======
void ann_prepare_inputs (double &_input_vector[], MqlRates &_rates[])
{
   ann_prepare_data(_input_vector, _rates, offset);
}

// Подготавливает вхходные параметры для ИНС.
// Parameters:
//     double   &_output_vector[] - вектор выходных данных ИНС.
//     MqlRates &_rates[]         - массив OHLCT.
// Returns:
//     void
// ======
void ann_prepare_outputs(double &_output_vector[], MqlRates &_rates[])
{
   ann_prepare_data(_output_vector, _rates, offset + WindowSize);
}

// Подготавливает параметры для ИНС.
// Parameters:
//     double   &_vector[] - вектор входных/выходных данных ИНС.
//     MqlRates &_rates[]  - массив OHLCT.
//     int      _offset    - смещение относительно массива &_rates[].
// Returns:
//     void
// ======
void ann_prepare_data(double &_vector[], MqlRates &_rates[], int _offset)
{
   switch (AnnDataSource) {
      case DATA_SOURCE_CLOSE:
         ann_prepare_prices(_vector, _offset, _rates, DATA_SOURCE_CLOSE);
         break;
      case DATA_SOURCE_OPEN:
         ann_prepare_prices(_vector, _offset, _rates, DATA_SOURCE_OPEN);
         break;
      case DATA_SOURCE_SMA:
         ann_prepare_ma(_vector, _offset, MODE_SMA);
         break;
      case DATA_SOURCE_EMA:
         ann_prepare_ma(_vector, _offset, MODE_EMA);
         break;
   }
}

// Подготавливает массив цен для ИНС.
// Некоторые рынки имеют значения цен вплоть до 170, а значения должны быть в промежутке [-1; 1].
// Поэтому каждое значение делится на 1000.
// 
// Parameters:
//     double     &vector[]  - вектор входных/выходных данных ИНС.
//     int        _offset    - смещение относительно массива &_rates[].
//     MqlRates   &_rates[]  - массив OHLCT.
//     DataSource dataSource - источник входных данных для ИНС.
// Returns:
//     void
// ======
void ann_prepare_prices(double &vector[], int _offset, MqlRates &_rates[], DataSource dataSource)
{
   int i = 0;
   double res = 0;
   for(i = 0; i < ArraySize(vector); i++) {
      if (DATA_SOURCE_OPEN == dataSource) {
         res = _rates[_offset + i].open / 1000;
      } else if (DATA_SOURCE_CLOSE == dataSource) {
         res = _rates[_offset + i].close / 1000;
      }
      
      if (MathAbs(res) < 1) {
         vector[i] = res;
         continue;
      }
      
      if (res > 0) {
         vector[i] = 1.0;
      } else {
         vector[i] = -1.0;
      }
   }
}

// Вычисляет SMA/EMA с заданным смещением на графике.
// Из-за того, что диапазон входных значений должен быть [-1; 1], 
// то значение MA делится на 1000.
// 
// Parameters:
//     double         &vector[]  - вектор входных/выходных данных ИНС.
//     int            _offset    - смещение относительно массива &_rates[].
//     ENUM_MA_METHOD MAMethod   - метод MA: SMA либо EMA.
// Returns:
//     void
// ======
void ann_prepare_ma(double &vector[], int _offset, ENUM_MA_METHOD MAMethod)
{
    int i;
    double res = 0;
	 for(i = 0; i < ArraySize(vector); i++) {
      res = iMA(NULL, 0, AmountOfInputNeurons, _offset, MAMethod, PRICE_CLOSE, i);
      res = res / 1000;
      
      if (MathAbs(res) < 1) {
         vector[i] = res;
         continue;
      }
      
      if (res > 0) {
         vector[i] = 1.0;
      } else {
         vector[i] = -1.0;
      }
   }
}

// ==================================================
// ============= Функции работы ИНС. ================
// ==================================================

// Производит обучение ИНС.
// Parameters:
//     int    ann_entity        - дескриптор ИНС.
//     double &_input_vector[]  - вектор входных данных ИНС (см. ann_prepare_inputs).
//     double &_output_vector[] - вектор выходных данных ИНС (см. ann_prepare_outputs).
// Returns:
//     int
//     0 в случае, если всё норм,
//     -1 в случае ошибки тренировки сети.
// ======
int ann_train (int ann_entity, double &_input_vector[], double &_output_vector[]) 
{
   int train_result = f2M_train (ann_entity, _input_vector, _output_vector);
   
   if (-1 == train_result) {
      debug (ERROR, "Network train error!");
   }
   
   return train_result;
}

// Запускает ИНС на реальных данных.
// Parameters:
//     int    ann_entity   - дескриптор ИНС.
//     double &vector[]    - вектор входных данных ИНС (см. ann_prepare_inputs).
//     int    neuronNumber - номер нейрона в выходном слое ИНС.
// Returns:
//     int
//     0 в случае, если всё норм,
//     FANN_DOUBLE_ERROR в случае ошибки при запуске сети.
// ======
double ann_run (int ann_entity, double &vector[], int neuronNumber) 
{
    int ret;
    ret = f2M_run (ann_entity, vector);
    
    if (ret < 0) {
	     debug (ERROR, "Error during running ann!");
	     return FANN_DOUBLE_ERROR;
    }
    
    return f2M_get_output (ann_entity, neuronNumber);
}

// Возвращает среднеквадратическую ошибку (СКО) сети.
// Parameters:
//     int ann_entity - дескриптор ИНС.
// Returns:
//     int
//     СКО в случае, если всё норм,
//     -1 в случае ошибки получения.
// ======
double ann_get_MSE(int ann_entity)
{
   double mse = f2M_get_MSE(ann_entity);
   
   if (-1 == mse) {
      debug(ERROR, "f2M_get_MSE failed!");
   }
   
   return mse;
}

// Обнуляет среднеквадратическую ошибку сети.
// Parameters:
//     int ann_entity - дескриптор ИНС.
// Returns:
//     int
//     0 в случае, если всё норм,
//     -1 в случае ошибки обнуления.
// ======
double ann_reset_MSE(int ann_entity)
{
   double mse = f2M_reset_MSE(ann_entity);
   
   if (-1 == mse) {
      debug(ERROR, "f2M_reset_MSE failed!");
      return -1;
   }
   
   return 0;
}