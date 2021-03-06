//+------------------------------------------------------------------+
//|                                      AnnCheckAnswerFunctions.mqh |
//|                                                  Igor Kharchenko |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Igor Kharchenko"
#property link      ""
#property strict


// Алгоритм вычисления правильности ответа ИНС.
// Enum:
//     ALG_DIVERGENCE_BETWEEN_POINTS  - расхождение между точками реальных данных и данных от ИНС.
//     ALG_DIVERGENCE_BETWEEN_SPREADS - расхождение между спредами реальных данных и данных от ИНС.
//     ALG_TREND_DIRECTION            - сравнение направления движения тренда реальных данных и данных от ИНС.
enum AnnAnswerCheckAlgorithm
{
   ALG_DIVERGENCE_BETWEEN_POINTS = 0,
   ALG_DIVERGENCE_BETWEEN_SPREADS = 1,
   ALG_TREND_DIRECTION = 2,
};


double Epsilon = 0.001; // Ошибка для метода проверки правильности ответа ИНС


// Сверяет выходной слой ИНС с реальными данными.
// Parameters:
//     double                  &ann_output[] - выходной слой ИНС.
//     double                  &rates[]      - реальные данные из графика.
//     AnnAnswerCheckAlgorithm algorithm     - алгоритм сравнения работы ИНС (см. Fann-Expert)
// Returns:
//     double
//     Количество в процентах, сколько раз сеть дала правильный ответ.
// ======
double check_answer_of_ann(double &ann_output[], double &rates[], AnnAnswerCheckAlgorithm algorithm)
{
   int _rightAnswers = 0;
   
   bool res = false;
   for (int i = 1; i < AmountOfOutputNeurons; i++) {
      if (ALG_DIVERGENCE_BETWEEN_POINTS == algorithm) {
         res = compare_divergences_between_points(ann_output, rates, i);
      } else if (ALG_DIVERGENCE_BETWEEN_SPREADS == algorithm) {
         res = compare_divergences_between_spreads(ann_output, rates, i);
      } else if (ALG_TREND_DIRECTION == algorithm) {
         res = compare_trend_direction(ann_output, rates, i);
      }
      
      if (true == res) {
         _rightAnswers++;
      }
   }
   
   // Это чтобы не было ошибки при делении, когда 0.99 == 1.
   if (_rightAnswers == (AmountOfOutputNeurons - 1)) {
      return 1.0;
   }
   
   // Кол-во правильных ответов в процентном соотношении 
   // к кол-ву выходных нейронов сети - 1.
   double multiplier = 1 / (double)(AmountOfOutputNeurons - 1);
   double result = _rightAnswers * multiplier;
   return result;
}

// Сравнивает направление движения данных ИНС и реальных данных.
// Parameters:
//     double &ann_output[] - выходной слой ИНС.
//     double &rates[]      - реальные данные из графика.
//     int    index         - индекс текущего значения в массивах (см. check_answer_of_ann).
// Returns:
//     bool
//     true в случае, если направления движения совпали,
//     false в противном случае.
// ======
bool compare_trend_direction(double &ann_output[], double &rates[], int index)
{
   double ann_spread = ann_output[index] - ann_output[index - 1];
   double rates_spread = rates[index] - rates[index - 1];
   
   if (ann_spread >= 0 && rates_spread >= 0) {
      return true;
   } else if (ann_spread < 0 && rates_spread < 0) {
      return true;
   }
   
   return false;
}

// Сравнивает расхождения данных ИНС и реальных данных.
// Parameters:
//     double &ann_output[] - выходной слой ИНС.
//     double &rates[]      - реальные данные из графика.
//     int    index         - индекс текущего значения в массивах (см. check_answer_of_ann).
// Returns:
//     bool
//     true в случае, если расхождения спредов не превышают значения Epsilon,
//     false в противном случае.
// ======
bool compare_divergences_between_points(double &ann_output[], double &rates[], int index)
{
   double divergence = MathAbs(ann_output[index] - rates[index]);
   
   if (divergence < Epsilon) {
      return true;
   }
   
   return false;
}

// Сравнивает расхождения спредов данных ИНС и реальных данных.
// Parameters:
//     double &ann_output[] - выходной слой ИНС.
//     double &rates[]      - реальные данные из графика.
//     int    index         - индекс текущего значения в массивах (см. check_answer_of_ann).
// Returns:
//     bool
//     true в случае, если расхождения спредов не превышают значения Epsilon,
//     false в противном случае.
// ======
bool compare_divergences_between_spreads(double &ann_output[], double &rates[], int index)
{
   double ann_spread = ann_output[index] - ann_output[index - 1];
   double rates_spread = rates[index] - rates[index - 1];
   
   double divergence = MathAbs(ann_spread - rates_spread);
   
   if (divergence < Epsilon) {
      return true;
   }
   
   return false;
}