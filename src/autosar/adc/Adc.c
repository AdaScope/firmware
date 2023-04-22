#include "Adc.h"
#include "Std_Types.h"

/* Function to start ADC Conversion */
extern Ada_Adc_Start_Group_Conversion (Adc_GroupType Group);
void Adc_StartGroupConversion( Adc_GroupType Group )
{
  Ada_Adc_Start_Group_Conversion (Group);
}

/* Function API to read ADC group */
extern unsigned int Ada_Adc_Read_Group (Adc_GroupType Group, unsigned int* Value);
Std_ReturnType Adc_ReadGroup(Adc_GroupType Group, Adc_ValueGroupType* DataBufferPtr)
{
  unsigned int Value = 0;
  Std_ReturnType Result;

  Result = (Std_ReturnType)Ada_Adc_Read_Group(Group, &Value);

  *DataBufferPtr = Value;

  return Result;
}
