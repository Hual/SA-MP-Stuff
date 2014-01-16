/******************************************************/
/********** Unoccupied vehicle damage script **********/
/******************** By King_Hual ********************/
/******************************************************/

#define MINIGUN_DAMAGE_ENABLED false

#include <a_samp>

new	Float:wdamage[13] = {
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
					SetVehicleHealth(hitid, vhp-wdamage[weaponid-22]);
			}
			#if MINIGUN_DAMAGE_ENABLED == true
			case 38:
			{
				if(vhp-140.0 >= 0)
					SetVehicleHealth(hitid, vhp-140.0);
			}
			#endif
		}
	}
	return 1;
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
