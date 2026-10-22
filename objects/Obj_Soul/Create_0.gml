if (!variable_global_exists("Gloomy_Player")) {
    global.Gloomy_Player = {
        LV: 10,
        EXP: 0,
        GOLD: 0,
        Hp_Max: 50,
        Hp_Normal: 50,
        Hp_Karma: 0,
        Hp_Final: 50,
        Atk_Self: 0,
        Atk_Equip: 0,
        Atk_Final: 0,
        Def_Self: 0,
        Def_Equip: 0,
        Def_Final: 0,
        Exp_Next: 20
    };
}

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
Move_Speed = 4;
Move_Speed_Jump = -8;
Move_Speed_Jump_Gravity = 0.25;
Move_Speed_Jump_Min = 0;
Move_Speed_Fall = 0;
Move_Speed_Fall_Gravity = 0.25;
Move_Speed_Fall_Max = 20;
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