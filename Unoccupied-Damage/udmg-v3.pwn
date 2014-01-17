/******************************************************/
/********** Unoccupied vehicle damage script **********/
/********************** Version 3 *********************/
/******************** By King_Hual ********************/
/******************************************************/

#define MINIGUN_DAMAGE_ENABLED true
#define VEHICLE_STATE_INACTIVE 0
#define VEHICLE_STATE_SPAWNED 1
#define VEHICLE_STATE_DYING 2

#include <a_samp>

enum SyncVehInfo
{
	STATE,
	MODELID,
	Float:POS[4],
	TIMER,
	COL[2],
	RESPAWN_TIME,
	Float:MAX_HEALTH
};

new
	info[MAX_VEHICLES][SyncVehInfo],
	Float:wdamage[13] = {
		25.0,
		40.0,
		140.0,
		90.0,
		135.0,
		60.0,
		20.0,
		25.0,
		30.0,
		30.0,
		20.0,
		75.0,
		125.0
	},
	settings[2] = {
	    false,
	    true
	};

forward UVDMG_OUVD(vehicleid);
forward UVDMG_OUVR(vehicleid);
forward UVDMG_AddVehicle(mdl, Float:x, Float:y, Float:z, Float:a, col1, col2, respawn, Float:health);
forward UVDMG_RemoveVehicle(id);
forward UVDMG_Set(setting, value);
forward UVDM_GetState(vehicleid);

public UVDMG_AddVehicle(mdl, Float:x, Float:y, Float:z, Float:a, col1, col2, respawn, Float:health)
{
	new id = CreateVehicle(mdl, x, y, z, a, col1, col2, respawn);
	SetVehicleHealth(id, health);
	info[id][STATE] = VEHICLE_STATE_SPAWNED;
	info[id][MODELID] = mdl;
	info[id][POS][0] = x;
	info[id][POS][1] = y;
	info[id][POS][2] = z;
	info[id][POS][3] = a;
	info[id][TIMER] = -1;
	info[id][COL][0] = col1;
	info[id][COL][1] = col2;
	info[id][RESPAWN_TIME] = respawn;
	info[id][MAX_HEALTH] = health;
	return id;
}

public UVDMG_RemoveVehicle(id)
{
	if(info[id][STATE] != VEHICLE_STATE_INACTIVE)
	{
		info[id][STATE] = VEHICLE_STATE_INACTIVE;
		if(info[id][TIMER] != -1)
		    KillTimer(info[id][TIMER]);
		return DestroyVehicle(id);
	}
	else
	    return 0;
}

public UVDMG_Set(setting, value)
{
	if(setting < sizeof(settings))
	{
		settings[setting] = value;
		return 1;
	}
	else
		return 0;
}

public UVDM_GetState(vehicleid)
{
	return info[vehicleid][STATE];
}

public OnFilterScriptInit()
{
	Initialize();
}

stock Initialize()
{
	for(new i=0;i<MAX_VEHICLES;++i)
	{
	    info[i][STATE] = VEHICLE_STATE_INACTIVE;
	    info[i][TIMER] = -1;
	}
}

public UVDMG_OUVD(vehicleid)
{
	CallRemoteFunction("OnUnoccupiedSyncVehicleDeath", "i", vehicleid);
	info[vehicleid][TIMER] = SetTimerEx("UVDMG_OUVR", 4999, false, "i", vehicleid);
}

public UVDMG_OUVR(vehicleid)
{
	info[vehicleid][TIMER] = -1;
	DestroyVehicle(vehicleid);
	if(settings[1] == 1)
	{
		CreateVehicle(info[vehicleid][MODELID], info[vehicleid][POS][0], info[vehicleid][POS][1], info[vehicleid][POS][2], info[vehicleid][POS][3], info[vehicleid][COL][0], info[vehicleid][COL][1], info[vehicleid][RESPAWN_TIME]);
		SetVehicleHealth(vehicleid, info[vehicleid][MAX_HEALTH]);
		info[vehicleid][STATE] = VEHICLE_STATE_SPAWNED;
		CallRemoteFunction("OnUnoccupiedSyncVehicleRespawn", "i", vehicleid);
	}
	else
		info[vehicleid][STATE] = VEHICLE_STATE_INACTIVE;
}

public OnPlayerWeaponShot(playerid, weaponid, hittype, hitid, Float:fX, Float:fY, Float:fZ)
{
	if(hittype == BULLET_HIT_TYPE_VEHICLE && info[hitid][STATE] != VEHICLE_STATE_INACTIVE && !isVehicleOccupied(hitid))
	{
		new Float:vhp;
		GetVehicleHealth(hitid, vhp);
		switch(weaponid)
		{
			case 22..34:
			{
				if(vhp-wdamage[weaponid-22] >= 0)
				{
					SetVehicleHealth(hitid, (vhp = vhp-wdamage[weaponid-22]));
					CallRemoteFunction("OnUnoccupiedSyncVehicleDamage", "iiif", playerid, hitid, weaponid, wdamage[weaponid-22]);
				}
			}
			case 38:
			{
				if(settings[0] == 1 && vhp-140.0 >= 0)
				{
					SetVehicleHealth(hitid, (vhp = vhp-140.0));
					CallRemoteFunction("OnUnoccupiedSyncVehicleDamage", "iiif", playerid, hitid, 38, 140.0);
				}
			}
		}
		if(info[hitid][STATE] != VEHICLE_STATE_DYING && vhp <= 250.0)
		{
		    info[hitid][STATE] = VEHICLE_STATE_DYING;
		    info[hitid][TIMER] = SetTimerEx("UVDMG_OUVD", 5000, false, "i", hitid);
		    CallRemoteFunction("OnUnoccupiedSyncVehicleDying", "i", hitid);
		}
	}
	return 1;
}

public OnVehicleSpawn(vehicleid)
{
	if(info[vehicleid][STATE] != VEHICLE_STATE_INACTIVE)
	{
	    SetVehicleHealth(vehicleid, info[vehicleid][MAX_HEALTH]);
	}
}

stock isVehicleOccupied(vehicleid)
{
	for(new i;i < GetMaxPlayers();++i)
	{
		if(IsPlayerConnected(i) && GetPlayerVehicleID(i) == vehicleid && GetPlayerVehicleSeat(i) == 0)
			return true;
	}
	return false;
}
