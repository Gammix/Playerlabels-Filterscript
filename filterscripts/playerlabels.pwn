//-------------------------------------------------
//
// Player Labels (/pl) filterscript; Now allow players to view other player statics from 3D labels
// Just relevant to /dl (default cmd by SAMP)
//
// Gammix 2015
// Thanks Incognito for streamer plugin
// Thanks Zeex for zcmd include
//
//-------------------------------------------------

#define FILTERSCRIPT//

//-------------------------------------------------

#include <a_samp>
#include <streamer>
#include <zcmd>
#include <playercalls>

//-------------------------------------------------

//labels configuration
#define LABEL_COLOR     			(0x20B2AAFF)//light sea green
#define LABEL_DRAW_DISTANCE     	(50.0)
#define LABEL_STREAM_DISTANCE   	(100.0)
#define LABEL_STRING_SIZE       	(256)

//label modes or types
#define MODE_ENABLED				(0)
#define MODE_DISABLED				(1)
#define MODE_SINGLE_PLAYER			(2)

//-------------------------------------------------

new
	g_LABEL_MODE[MAX_PLAYERS],
	Text3D:g_LABEL_3D[MAX_PLAYERS][MAX_PLAYERS]
;

//-------------------------------------------------

GetWeaponNameEx(weaponid, weapon[], len = sizeof(weapon))
{
	switch(weaponid)
	{
		case 0: return strcat(weapon, "Fist", len);
		case 18: return strcat(weapon, "Molotov Cocktail", len);
		case 44: return strcat(weapon, "Night Vision Goggles", len);
		case 45: return strcat(weapon, "Thermal Goggles", len);
		default: return GetWeaponName(weaponid, weapon, len);
	}
	return false;
}

//-------------------------------------------------

RetrievetLabelString(string[], playerid, extraid, len = sizeof(string))
{
	new Float:player_hp;
	GetPlayerHealth(extraid, player_hp);

	new Float:player_ar;
	GetPlayerArmour(extraid, player_ar);

	new Float:pos[3];
	GetPlayerPos(extraid, pos[0], pos[1], pos[2]);
	new Float:player_distance;
	player_distance = GetPlayerDistanceFromPoint(playerid, pos[0], pos[1], pos[2]);

	new player_weapon[32];
	GetWeaponNameEx(GetPlayerWeapon(extraid), player_weapon, sizeof(player_weapon));

	new Float:player_angle;
	GetPlayerFacingAngle(playerid, player_angle);

    format(	string,//puttins the values into the string
			len,
			"[id: %i, health: %0.2f, armour: %0.2f, ping: %i]\n\
				skin: %i, team: %i, money: $%i, score: %i\n\
					distance: %0.2f\n\
						weapon: %s (%i), ammo: %i\n\
							interior: %i, world: %i\n\
								pos: %0.4f, %0.4f, %0.4f, %0.4f",
            playerid, player_hp, player_ar, GetPlayerPing(extraid),
            	GetPlayerSkin(extraid), GetPlayerTeam(extraid), GetPlayerMoney(extraid), GetPlayerScore(extraid),
            		player_distance,
            			player_weapon, GetPlayerWeapon(extraid), GetPlayerAmmo(extraid),
            				GetPlayerInterior(extraid), GetPlayerVirtualWorld(extraid),
            					pos[0], pos[1], pos[2], player_angle
	);
}

//-------------------------------------------------

UpdatePlayersLabels(ofplayerid)
{
	new Float:pos[3];
	GetPlayerPos(ofplayerid, pos[0], pos[1], pos[2]);

    new string[LABEL_STRING_SIZE];

	for(new i = 0, j = GetPlayerPoolSize(); i <= j; i++)
	{
		if(IsPlayerConnected(i))
		{
		    if(i != ofplayerid)
  		 	{
  				if(IsPlayerInRangeOfPoint(i, LABEL_STREAM_DISTANCE, pos[0], pos[1], pos[2]))
		    	{
	   				if(g_LABEL_MODE[i] != MODE_DISABLED)
					{
			        	RetrievetLabelString(string, i, ofplayerid, sizeof(string));
						UpdateDynamic3DTextLabelText(g_LABEL_3D[i][ofplayerid], LABEL_COLOR, string);
					}
				}
			}
		}
	}
}

//-------------------------------------------------

DestroyPlayerLabel(playerid, ofplayerid)
{
    if(IsValidDynamic3DTextLabel(g_LABEL_3D[playerid][ofplayerid]))
	{
		DestroyDynamic3DTextLabel(g_LABEL_3D[playerid][ofplayerid]);
	}
}

//-------------------------------------------------

CreatePlayerLabel(playerid, ofplayerid)
{
    if(IsValidDynamic3DTextLabel(g_LABEL_3D[playerid][ofplayerid]))
	{
		DestroyDynamic3DTextLabel(g_LABEL_3D[playerid][ofplayerid]);
	}
	new string[LABEL_STRING_SIZE];
	RetrievetLabelString(string, playerid, ofplayerid);
	g_LABEL_3D[playerid][ofplayerid] = CreateDynamic3DTextLabel(string, LABEL_COLOR, 0.0, 0.0, 0.0, LABEL_DRAW_DISTANCE, ofplayerid, _, _, _, _, playerid, LABEL_STREAM_DISTANCE);
}

//-------------------------------------------------

IsNumeric(str[])
{
	new ch, i;
	while ((ch = str[i++])) if (!('0' <= ch <= '9')) return false;
	return true;
}

//-------------------------------------------------

public OnPlayerConnect(playerid)
{
    g_LABEL_MODE[playerid] = MODE_DISABLED;
    
    for(new i = 0, j = GetPlayerPoolSize(); i <= j; i++)
	{
	    if(IsPlayerConnected(i))
	    {
			if(i != playerid)
			{
			    if(g_LABEL_MODE[i] == MODE_ENABLED)
			    {
			        CreatePlayerLabel(i, playerid);
				}
			}
		}
	}
	return 1;
}

//-------------------------------------------------

public OnPlayerDisconnect(playerid, reason)
{
    for(new i = 0, j = GetPlayerPoolSize(); i <= j; i++)
	{
	    if(IsPlayerConnected(i))
	    {
			if(i != playerid)
			{
				DestroyPlayerLabel(i, playerid);
			}
		}
	}
	return 1;
}

//-------------------------------------------------

public OnPlayerPosChange(playerid, Float:newx, Float:newy, Float:newz, Float:oldx, Float:oldy, Float:oldz)
{
    UpdatePlayersLabels(playerid);
	return 1;
}

//-------------------------------------------------

public OnPlayerFacingAngleChange(playerid, Float:newangle, Float:oldangle)
{
    UpdatePlayersLabels(playerid);
	return 1;
}

//-------------------------------------------------

public OnPlayerWeaponChange(playerid, newweapon, oldweapon)
{
    UpdatePlayersLabels(playerid);
	return 1;
}

//-------------------------------------------------

public OnPlayerHealthChange(playerid, Float:newhealth, Float:oldhealth)
{
    UpdatePlayersLabels(playerid);
	return 1;
}

//-------------------------------------------------

public OnPlayerArmourChange(playerid, Float:newarmour, Float:oldarmour)
{
    UpdatePlayersLabels(playerid);
	return 1;
}

//-------------------------------------------------

public OnPlayerVirtualWorldChange(playerid, newworld, oldworld)
{
    UpdatePlayersLabels(playerid);
	return 1;
}

//-------------------------------------------------

public OnPlayerSkinChange(playerid, newskin, oldskin)
{
    UpdatePlayersLabels(playerid);
	return 1;
}

//-------------------------------------------------

public OnPlayerPingChange(playerid, newping, oldping)
{
    UpdatePlayersLabels(playerid);
	return 1;
}

//-------------------------------------------------

public OnPlayerAmmoChange(playerid, weaponid, newammo, oldammo)
{
    UpdatePlayersLabels(playerid);
	return 1;
}

//-------------------------------------------------

public OnPlayerMoneyChange(playerid, newmoney, oldmoney)
{
    UpdatePlayersLabels(playerid);
	return 1;
}

//-------------------------------------------------

public OnPlayerScoreChange(playerid, newscore, oldscore)
{
    UpdatePlayersLabels(playerid);
	return 1;
}

//-------------------------------------------------

CMD:pl(playerid, params[])
{
    new
		ofplayerid
	;

	if(IsNumeric(params))
	{
	    ofplayerid = strval(params);
	}
	else
	{
	    ofplayerid = INVALID_PLAYER_ID;
	}

	if(	IsPlayerConnected(ofplayerid) &&
		ofplayerid != playerid)
	{
	   	//destroy all labels first
		for(new i = 0, j = GetPlayerPoolSize(); i <= j; i++)
		{
			DestroyPlayerLabel(playerid, i);
		}

		CreatePlayerLabel(playerid, ofplayerid);

		g_LABEL_MODE[playerid] = MODE_SINGLE_PLAYER;//enable labels
	}
	else
	{
		if(g_LABEL_MODE[playerid] == MODE_DISABLED)//enable labels
		{
		    for(new i = 0, j = GetPlayerPoolSize(); i <= j; i++)
			{
				if(IsPlayerConnected(i))
				{
				    if(i != ofplayerid)
		  		 	{
	                    CreatePlayerLabel(playerid, i);
				    }
				}
			}
			g_LABEL_MODE[playerid] = MODE_ENABLED;
		}
		else//disable labels
		{
		    for(new i = 0, j = GetPlayerPoolSize(); i <= j; i++)
			{
				DestroyPlayerLabel(playerid, i);
			}
			g_LABEL_MODE[playerid] = MODE_DISABLED;
		}
	}
	return 1;
}

//-------------------------------------------------
