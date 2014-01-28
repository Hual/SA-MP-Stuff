/*************************************************************************************************/
/*                        ANSI C/++ MultIV server query class by King_Hual                       */
/*************************************************************************************************/

#include "globalvars.h"

/* ================================== Global string functions ================================== */

static cell AMX_NATIVE_CALL GVARS_SetGlobalString(AMX* amx, cell* params)
{
	string_storage[GetStringFromCell(amx, params[1])] = GetStringFromCell(amx, params[2]);
	return 1;
}

static cell AMX_NATIVE_CALL GVARS_GetGlobalString(AMX* amx, cell* params)
{
	const std::string key = GetStringFromCell(amx, params[1]);
	if(string_storage.count(key) < 1) return 0;
	cell *out_addr = 0;
	amx_GetAddr(amx, params[2], &out_addr);
	amx_SetString(out_addr, string_storage[key].c_str(), params[4], 0, params[3]);
	return 1;
}

static cell AMX_NATIVE_CALL GVARS_UnsetGlobalString(AMX* amx, cell* params)
{
	return string_storage.erase(GetStringFromCell(amx, params[1]));
}

static cell AMX_NATIVE_CALL GVARS_GlobalStringExists(AMX* amx, cell* params) 
{
	return string_storage.count(GetStringFromCell(amx, params[1]));
}

/* ================================= Global integer functions ================================== */

static cell AMX_NATIVE_CALL GVARS_SetGlobalInteger(AMX* amx, cell* params)
{
	integer_storage[GetStringFromCell(amx, params[1])] = params[2];
	return 1;
}

static cell AMX_NATIVE_CALL GVARS_GetGlobalInteger(AMX* amx, cell* params)
{
	return integer_storage[GetStringFromCell(amx, params[1])];
}

static cell AMX_NATIVE_CALL GVARS_UnsetGlobalInteger(AMX* amx, cell* params)
{
	return integer_storage.erase(GetStringFromCell(amx, params[1]));
}

static cell AMX_NATIVE_CALL GVARS_GlobalIntegerExists(AMX* amx, cell* params) 
{
	return integer_storage.count(GetStringFromCell(amx, params[1]));
}

/* ============================= Global floating number functions ============================== */

static cell AMX_NATIVE_CALL GVARS_SetGlobalFloat(AMX* amx, cell* params)
{
	float_storage[GetStringFromCell(amx, params[1])] = amx_ctof(params[2]);
	return 1;
}

static cell AMX_NATIVE_CALL GVARS_GetGlobalFloat(AMX* amx, cell* params)
{
	return amx_ftoc(float_storage[GetStringFromCell(amx, params[1])]);
}

static cell AMX_NATIVE_CALL GVARS_UnsetGlobalFloat(AMX* amx, cell* params)
{
	return float_storage.erase(GetStringFromCell(amx, params[1]));
}

static cell AMX_NATIVE_CALL GVARS_GlobalFloatExists(AMX* amx, cell* params) 
{
	return float_storage.count(GetStringFromCell(amx, params[1]));
}

/* ====================================== Utility functions ==================================== */

std::string GetStringFromCell(AMX* amx, cell string_cell)
{
	cell *addr = 0;
	int len = 0;
	amx_GetAddr(amx, string_cell, &addr);
	amx_StrLen(addr, &len);
	++len;
	char* str = new char[len];
	amx_GetString(str, addr, 0, len);
	const std::string final_str(str);
	delete[] str;
	return final_str;
}

/* ======================================== AMX functions ====================================== */

PLUGIN_EXPORT unsigned int PLUGIN_CALL Supports()
{
    return SUPPORTS_VERSION | SUPPORTS_AMX_NATIVES;
}

PLUGIN_EXPORT bool PLUGIN_CALL Load(void **ppData) 
{
    pAMXFunctions = ppData[PLUGIN_DATA_AMX_EXPORTS];
    logprintf = (logprintf_t)ppData[PLUGIN_DATA_LOGPRINTF];
    logprintf(" -- Global variable plugin by King_Hual loaded -- ");
    return true;
}

PLUGIN_EXPORT void PLUGIN_CALL Unload()
{
    logprintf(" -- Global variable plugin by King_Hual unloaded -- ");
}

AMX_NATIVE_INFO PluginNatives[] =
{
    {"SetGlobalString", GVARS_SetGlobalString},
	{"GetGlobalString", GVARS_GetGlobalString},
	{"UnsetGlobalString", GVARS_UnsetGlobalString},
	{"GlobalStringExists", GVARS_GlobalStringExists},
	{"SetGlobalInteger", GVARS_SetGlobalInteger},
	{"GetGlobalInteger", GVARS_GetGlobalInteger},
	{"UnsetGlobalInteger", GVARS_UnsetGlobalInteger},
	{"GlobalIntegerExists", GVARS_GlobalIntegerExists},
	{"SetGlobalFloat", GVARS_SetGlobalFloat},
	{"GetGlobalFloat", GVARS_GetGlobalFloat},
	{"UnsetGlobalFloat", GVARS_UnsetGlobalFloat},
	{"GlobalFloatExists", GVARS_GlobalFloatExists},
    {0, 0}
};

PLUGIN_EXPORT int PLUGIN_CALL AmxLoad(AMX *amx) 
{
    return amx_Register(amx, PluginNatives, -1);
}


PLUGIN_EXPORT int PLUGIN_CALL AmxUnload(AMX *amx) 
{
    return AMX_ERR_NONE;
}
