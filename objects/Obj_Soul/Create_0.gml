// SPDX-License-Identifier: PolyForm-Noncommercial-1.0.0
// Copyright (C) 2026 Gloomy-Ym, JO-Beacon

event_inherited();
Scr_Player_Init();

global.Gloomy_Death_Triggered = false;

//血量
Hp_Max = global.Gloomy_Player.Hp_Max;
Hp_Normal = global.Gloomy_Player.Hp_Normal;
Hp_Karma = global.Gloomy_Player.Hp_Karma;
Hp_Final = global.Gloomy_Player.Hp_Final;
//等级与经验
LV = global.Gloomy_Player.LV;
EXP = global.Gloomy_Player.EXP;
GOLD = global.Gloomy_Player.GOLD;
//攻防
Atk_Final = global.Gloomy_Player.Atk_Final;
Atk_Self = global.Gloomy_Player.Atk_Self;
Atk_Equip = global.Gloomy_Player.Atk_Equip;
Def_Final = global.Gloomy_Player.Def_Final;
Def_Self = global.Gloomy_Player.Def_Self;
Def_Equip = global.Gloomy_Player.Def_Equip;
//移速
Move_Speed = 2;
Move_Speed_Jump = -4;
Move_Speed_Jump_Gravity = 0.125;
Move_Speed_Jump_Min = 0;
Move_Speed_Fall = 0;
Move_Speed_Fall_Gravity = 0.125;
Move_Speed_Fall_Max = 8;
Move_Speed_Modifier_Hold_X_Or_Shift = 0.5;
Move_Speed_Modifier_Penalty = 1;
Move_Speed_Modifier_Penalty_Timer = 0;
//移动方向
Move_Up = false;
Move_Down = false;
Move_Left = false;
Move_Right = false;
Move_Jump = false;
Move_Fall = false;
H = 0;
V = 0;
//无敌帧
Invincible_Frames = 0;
Invincible_Frames_Falsh_Timer = 0;
//Mode_Invincible
Mode_Invincible = false;
Mode_Invincible_print = "开启无敌模式"
visible = true;
depth = 0;
On_Ground = false;