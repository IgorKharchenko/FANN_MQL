//+------------------------------------------------------------------+
//|                                                        CsvIO.mqh |
//|                                                  Igor Kharchenko |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Igor Kharchenko"
#property link      "https://www.mql5.com"
#property strict

// todo вынести в библиотеку

int open_csv_file(string path, bool deleteOldFile)
{
   int file;
   
   if (true == deleteOldFile && FileIsExist(path)) {
      FileDelete(path);
   }
   
   file = FileOpen(path, FILE_READ|FILE_WRITE|FILE_CSV, ";");
   
   return file;
}

void close_csv_file(int file) 
{
   FileClose(file);
}

bool file_ended(int file)
{
   return FileIsEnding(file);
}

double read_double_from_csv_file(int file)
{
   // число имеет примерно 15 знаков после запятой, ну ещё малёх добавлю
   return StringToDouble(FileReadString(file, 20));
}

string read_string_from_csv_file(int file, int length)
{
   return FileReadString(file, length);
}


void write_double_to_csv_file(int file, double value)
{
   string val = DoubleToString(value, 20);
   FileWrite(file, val);
}

void write_string_to_csv_file(int file, string value)
{
   FileWrite(file, value);
}


void write_string_vector_to_csv_file(int file, string &value[])
{
   FileWriteArray(file, value);
}

void write_double_vector_to_csv_file(int file, string &value[])
{
   FileWriteArray(file, value);
}