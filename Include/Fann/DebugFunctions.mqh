//+------------------------------------------------------------------+
//|                                               DebugFunctions.mqh |
//|                                                  Igor Kharchenko |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Igor Kharchenko"
#property link      ""
#property strict

// Уровни выводимых сообщений.
// Enum:
//     ERROR       - выводит все сообщения.
//     WARNING     - предупреждения и ошибки.
//     INFORMATION - только информационные сообщения.
//     NOTHING     - ничего не выводит.
enum DebugLevels 
{
   NOTHING = -1,
   ERROR = 0,
   WARNING = 1,
   INFORMATION = 2,
};


extern DebugLevels DebugLevel = NOTHING;        // Уровень отображаемых сообщений


// Выводит сообщение.
// Parameters:
//     DebugLevels level - уровень отображаемого сообщения (см. DebugLevels).
//     string      text  - выводимый текст.
// Returns:
//     void
// ======
void debug (DebugLevels level, string text) 
{
   if (DebugLevel >= level) {
      switch (level) {
         case ERROR:
            text = "ERROR: " + text;
            break;
         case WARNING:
            text = "Warning: " + text;
            break;
         case INFORMATION:
            text = "Information: " + text;
            break;
         default:
            break;
      }
      Print (text);
   }
}
