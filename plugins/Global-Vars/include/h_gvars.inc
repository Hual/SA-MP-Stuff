/*************************************************************************************************/
/*                            SA-MP global variables plugin by King_Hual                         */
/*************************************************************************************************/


native SetGlobalString(const key[], const val[]);
native GetGlobalString(const key[], val[], const len, const bool:packed = false);
native UnsetGlobalString(const key[]);
native bool:GlobalStringExists(const key[]);

native SetGlobalInteger(const key[], val);
native GetGlobalInteger(const key[]);
native UnsetGlobalInteger(const key[]);
native bool:GlobalIntegerExists(const key[]);

native SetGlobalFloat(const key[], Float:val);
native Float:GetGlobalFloat(const key[]);
native UnsetGlobalFloat(const key[]);
native bool:GlobalFloatExists(const key[]);
