/*************************************************************************************************/
/*                        ANSI C/++ MultIV server query class by King_Hual                       */
/*************************************************************************************************/

#pragma once
#pragma warning (disable:4005)

#include "../SDK/amx/amx.h"
#include "../SDK/plugincommon.h"
#include <string>
#include <map>

std::string GetStringFromCell(AMX*, cell);

typedef void (*logprintf_t)(char* format, ...);
logprintf_t logprintf;
extern void *pAMXFunctions;
std::map<std::string, std::string> string_storage;
std::map<std::string, int> integer_storage;
std::map<std::string, float> float_storage;