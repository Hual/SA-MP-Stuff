/******************************************************/
/********** Unoccupied vehicle damage script **********/
/******************** By King_Hual ********************/
/******************************************************/

#define MINIGUN_DAMAGE_ENABLED true

#include <a_samp>

new
	bool:dying[MAX_VEHICLES] = {false,...},
	timers[MAX_VEHICLES] = {-1,...},
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
};

forward OUVD(vehicleid, modelid, Float:x, Float:y, Float:z, Float:a);

public OUVD(vehicleid, modelid, Float:x, Float:y, Float:z, Float:a)
{
	timers[vehicleid] = -1;
	DestroyVehicle(vehicleid);
	CreateVehicle(modelid, x, y, z, a, -1, -1, -1);
	dying[vehicleid] = false;
}

public OnPlayerWeaponShot(playerid, weaponid, hittype, hitid, Float:fX, Float:fY, Float:fZ)
{
	if(hittype == BULLET_HIT_TYPE_VEHICLE && !isVehicleOccupied(hitid))
	{
		new Float:vhp;
		GetVehicleHealth(hitid, vhp);
		switch(weaponid)
		{
			case 22..34:
			{
				if(vhp-wdamage[weaponid-22] >= 0)
					SetVehicleHealth(hitid, (vhp = vhp-wdamage[weaponid-22]));
			}
			#if MINIGUN_DAMAGE_ENABLED == true
			case 38:
			{
				if(vhp-140.0 >= 0)
					SetVehicleHealth(hitid, (vhp = vhp-140.0));
			}
			#endif
		}
		if(!dying[hitid] && vhp <= 250.0)
		{
		    dying[hitid] = true;
		    new Float:pos[4];
		    GetVehiclePos(hitid, pos[0], pos[1], pos[2]);
		    GetVehicleZAngle(hitid, pos[3]);
		    timers[hitid] = SetTimerEx("OUVD", 7000, false, "iiffff", hitid, GetVehicleModel(hitid), pos[0], pos[1],  pos[2], pos[3]);
		}
	}
	return 1;
}

public OnVehicleSpawn(vehicleid)
{
	if(timers[vehicleid] != -1)
	{
	    KillTimer(timers[vehicleid]);
	    timers[vehicleid] = -1;
	    dying[vehicleid] = false;
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
