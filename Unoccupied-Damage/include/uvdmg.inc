/******************************************************/
/************ Unoccupied vehicle damage API ***********/
/********************** Version 3 *********************/
/******************** By King_Hual ********************/
/******************************************************/

#define VEHICLE_STATE_INACTIVE 0
#define VEHICLE_STATE_SPAWNED 1
#define VEHICLE_STATE_DYING 2

#define SV_MINIGUN_ENABLED 0
#define SV_RESPAWN_VEHICLES 1

#include <a_samp>

forward OnUnoccupiedSyncVehicleDying(vehicleid);
forward OnUnoccupiedSyncVehicleDeath(vehicleid);
forward OnUnoccupiedSyncVehicleRespawn(vehicleid);
forward OnUnoccupiedSyncVehicleDamage(playerid, vehicleid, weaponid, Float:amount);

stock CreateSyncVehicle(vehicletype, Float:x, Float:y, Float:z, Float:rotation, color1, color2, respawn_delay, Float:health = 1000.0)
{
	return CallRemoteFunction("UVDMG_AddVehicle", "iffffiiif", vehicletype, x, y, z, rotation, color1, color2, respawn_delay, health);
}

stock DestroySyncVehicle(vehicleid)
{
	return CallRemoteFunction("UVDMG_RemoveVehicle", "i", vehicleid);
}

stock SetSyncVehiclesOption(option, value)
{
	return CallRemoteFunction("UVDMG_Set", "ii", option, value);
}

stock GetSyncVehicleState(vehicleid)
{
	return CallRemoteFunction("UVDMG_GetState", "i", vehicleid);
}

stock IsVehicleSyncVehicle(vehicleid)
{
	return GetSyncVehicleState(vehicleid) != VEHICLE_STATE_INACTIVE;
}
