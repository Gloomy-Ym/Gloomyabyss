//锁等级
if (LV > 20) {
    LV = 20;
}
if (LV < 20) {
    Exp_Next = 20;
}
else {
    Exp_Next = 0;
}
//升级升Hp逻辑
if (EXP >= 20 && LV < 20) {
    LV += 1;
    EXP = 0;
}
if (LV < 20) {
    Hp_Max = 20 + (LV - 1) * 4;
}
else if (LV == 20) {
    Hp_Max = 99;
}
//升级升Atk_Self和Def_Self逻辑
Atk_Self = 2 * (LV - 1);
Def_Self = floor((LV - 1) * 0.25);
//Final_Atk和Final_Def计算逻辑
Atk_Final = Atk_Self + Atk_Equip;
Def_Final = Def_Self + Def_Equip;
//Hp计算逻辑
if (Hp_Normal <= 0) {
    Hp_Normal = 0;
    Hp_Karma = 0;
}
if (Hp_Karma > 0) {
    Hp_Karma = Hp_Karma - 1;
}
else if (Hp_Karma < 0) {
    Hp_Normal += Hp_Karma;
    Hp_Karma = 0;
}
Hp_Final = Hp_Normal + Hp_Karma;
var overworld_menu_open = variable_global_exists("Gloomy_Overworld_UI_Open") && global.Gloomy_Overworld_UI_Open;
var solid_collision_objects = [Obj_Broder_Battle, Obj_Ender_Chest];
//红魂
if (sprite_index == Spr_Soul_Red && Hp_Final > 0) {
    if (!overworld_menu_open) {
        Move_Up = Scr_Input_KeyDown(ord("W")) || Scr_Input_KeyDown(vk_up);
        Move_Down = Scr_Input_KeyDown(ord("S")) || Scr_Input_KeyDown(vk_down);
        Move_Left = Scr_Input_KeyDown(ord("A")) || Scr_Input_KeyDown(vk_left);
        Move_Right = Scr_Input_KeyDown(ord("D")) || Scr_Input_KeyDown(vk_right);
        H = Move_Right - Move_Left;
        V = Move_Down - Move_Up;
        if (H != 0 && V != 0) {
            H *= 0.707;
            V *= 0.707;
        }
    }
    else {
        Move_Up = false;
        Move_Down = false;
        Move_Left = false;
        Move_Right = false;
        H = 0;
        V = 0;
    }
}
//橙魂
if (sprite_index == Spr_Soul_Orange && Hp_Final > 0) {
    if (Scr_Input_KeyPressed(ord("W")) || Scr_Input_KeyPressed(vk_up)) {
        Move_Up = true;
        Move_Down = false;
        Move_Left = false;
        Move_Right = false;
    }
    else if (Scr_Input_KeyPressed(ord("S")) || Scr_Input_KeyPressed(vk_down)) {
        Move_Down = true;
        Move_Up = false;
        Move_Left = false;
        Move_Right = false;
    }
    else if (Scr_Input_KeyPressed(ord("A")) || Scr_Input_KeyPressed(vk_left)) {
        Move_Left = true;
        Move_Up = false;
        Move_Down = false;
        Move_Right = false;
    }
    else if (Scr_Input_KeyPressed(ord("D")) || Scr_Input_KeyPressed(vk_right)) {
        Move_Right = true;
        Move_Up = false;
        Move_Down = false;
        Move_Left = false;
    }
    H = Move_Right - Move_Left;
    V = Move_Down - Move_Up;
    if (H != 0 && V != 0) {
        H *= 0.707;
        V *= 0.707;
    }
}
//黄魂
if (sprite_index == Spr_Soul_Yellow && Hp_Final > 0) {
    if (Scr_Input_KeyPressed(ord("Z")) || Scr_Input_KeyPressed(vk_enter)) {
        audio_play_sound(Snd_Soul_Yellow_Shoot_Bullet, 0, false);
        instance_create_depth(x, y - 17, depth, Obj_Bullet_Soul_Yellow);
    }
    Move_Up = Scr_Input_KeyDown(ord("W")) || Scr_Input_KeyDown(vk_up);
    Move_Down = Scr_Input_KeyDown(ord("S")) || Scr_Input_KeyDown(vk_down);
    Move_Left = Scr_Input_KeyDown(ord("A")) || Scr_Input_KeyDown(vk_left);
    Move_Right = Scr_Input_KeyDown(ord("D")) || Scr_Input_KeyDown(vk_right);
    H = Move_Right - Move_Left;
    V = Move_Down - Move_Up;
    if (H != 0 && V != 0) {
        H *= 0.707;
        V *= 0.707;
    }
}
//绿魂
if (sprite_index == Spr_Soul_Green && Hp_Final > 0) {
    if (instance_exists(Obj_Shield_Soul_Green) == false) {
        instance_create_depth(x, y, depth, Obj_Shield_Soul_Green);
    }
    if (Scr_Input_KeyPressed(ord("W")) || Scr_Input_KeyPressed(vk_up)) {
        Obj_Shield_Soul_Green.image_angle = 0;
    }
    else if (Scr_Input_KeyPressed(ord("S")) || Scr_Input_KeyPressed(vk_down)) {
        Obj_Shield_Soul_Green.image_angle = 180;
    }
    else if (Scr_Input_KeyPressed(ord("A")) || Scr_Input_KeyPressed(vk_left)) {
        Obj_Shield_Soul_Green.image_angle = 90;
    }
    else if (Scr_Input_KeyPressed(ord("D")) || Scr_Input_KeyPressed(vk_right)) {
        Obj_Shield_Soul_Green.image_angle = 270;
    }
}
//青魂
if (sprite_index == Spr_Soul_Cyan && Hp_Final > 0) {
    Move_Up = false;
    Move_Down = false;
    Move_Left = false;
    Move_Right = false;
    H = Move_Right - Move_Left;
    V = Move_Down - Move_Up;
    if (H != 0 && V != 0) {
        H *= 0.707;
        V *= 0.707;
    }
}
//蓝魂
if (sprite_index == Spr_Soul_Blue) {
	Move_Left = keyboard_check(ord("A")) || keyboard_check(vk_left);
    Move_Right = keyboard_check(ord("D")) || keyboard_check(vk_right);
    H = Move_Right - Move_Left;
    On_Ground = place_meeting(x, y + 1, solid_collision_objects);
    if (On_Ground == true) {
        Move_Fall = false;
        Move_Speed_Fall = 0;
        if (keyboard_check(ord("W")) || keyboard_check(vk_up)) {
            Move_Jump = true;
            Move_Speed_Jump = -8;
        }
    }
    if (On_Ground == false) {
    	if (Move_Jump == true && Move_Speed_Jump <= Move_Speed_Jump_Min) {
        	Move_Speed_Jump += Move_Speed_Jump_Gravity;
            Move_Speed_Fall = 0;
            Move_Fall = false;
        }
        if (Move_Speed_Jump >= Move_Speed_Jump_Min || (!keyboard_check(ord("W")) && !keyboard_check(vk_up))) {
        	Move_Jump = false;
            Move_Fall = true;
        }
        if (Move_Fall == true && Move_Speed_Fall <= Move_Speed_Fall_Max) {
        	Move_Speed_Fall += Move_Speed_Fall_Gravity;
        }
        if (Move_Speed_Fall > Move_Speed_Fall_Max) {
        	Move_Speed_Fall = Move_Speed_Fall_Max;
        }
    }
}
//移速与移动计算逻辑
if (Scr_Input_KeyDown(ord("X")) || Scr_Input_KeyDown(vk_shift)) {
    Move_Speed_Final = Move_Speed * Move_Speed_Modifier_Penalty * Move_Speed_Modifier_Hold_X_Or_Shift;
}
else {
    Move_Speed_Final = Move_Speed * Move_Speed_Modifier_Penalty;
}
if (Move_Speed_Modifier_Penalty_Timer > 0) {
    Move_Speed_Modifier_Penalty_Timer -= 1;
}
else {
    Move_Speed_Modifier_Penalty_Timer = 0;
    Move_Speed_Modifier_Penalty = 1;
}
if (overworld_menu_open) {
    H = 0;
    V = 0;
}
x += H * Move_Speed_Final;
y += V * Move_Speed_Final;
if (sprite_index == Spr_Soul_Blue) {
	if (Move_Jump == true) {
        move_and_collide(0, Move_Speed_Jump, solid_collision_objects);
    }
    if (Move_Fall == true) {
    	move_and_collide(0, Move_Speed_Fall, solid_collision_objects);
    }
}
//减少无敌帧与闪烁
if (Invincible_Frames > 0) {
    Invincible_Frames -= 1;
    Invincible_Frames_Falsh_Timer += 1;
    if (Invincible_Frames_Falsh_Timer >= 3) {
        Invincible_Frames_Falsh_Timer = 0;
        visible = !visible;
    }
}
else {
    Invincible_Frames = 0;
    Invincible_Frames_Falsh_Timer = 0;
    visible = true;
}
//无敌模式
if (Scr_Input_KeyPressed(ord("1"))) {
    Mode_Invincible = !Mode_Invincible;
}
if (Mode_Invincible == false) {
    Mode_Invincible_print = "关闭无敌模式";
}
else {
    Mode_Invincible_print = "开启无敌模式";
}
//恢复所有血量
if (Scr_Input_KeyPressed(ord("3"))) {
    Hp_Normal = Hp_Max;
    Hp_Karma = 0;
}
//同步到全局，供大世界菜单等界面读取真实数值
if (variable_global_exists("Gloomy_Player")) {
    global.Gloomy_Player.LV = LV;
    global.Gloomy_Player.EXP = EXP;
    global.Gloomy_Player.GOLD = GOLD;
    global.Gloomy_Player.Hp_Max = Hp_Max;
    global.Gloomy_Player.Hp_Normal = Hp_Normal;
    global.Gloomy_Player.Hp_Karma = Hp_Karma;
    global.Gloomy_Player.Hp_Final = Hp_Final;
    global.Gloomy_Player.Atk_Self = Atk_Self;
    global.Gloomy_Player.Atk_Equip = Atk_Equip;
    global.Gloomy_Player.Atk_Final = Atk_Final;
    global.Gloomy_Player.Def_Self = Def_Self;
    global.Gloomy_Player.Def_Equip = Def_Equip;
    global.Gloomy_Player.Def_Final = Def_Final;
    global.Gloomy_Player.Exp_Next = Exp_Next;
}

if (Hp_Final <= 0 && (!variable_global_exists("Gloomy_Death_Triggered") || !global.Gloomy_Death_Triggered)) {
    global.Gloomy_Death_Triggered = true;
    room_goto(Death_Room);
    exit;
}

//输出状态
if (Scr_Input_KeyDown(ord("2"))) {
    show_debug_message("Normal_Hp : " + string(Hp_Normal));
    show_debug_message("Karma_Hp : " + string(Hp_Karma));
    show_debug_message("Final_Hp : " + string(Hp_Final));
}
if (Scr_Input_KeyPressed(ord("1"))) {
    show_debug_message(Mode_Invincible_print);
}
if (Move_Speed_Final < 4) {
    show_debug_message(Move_Speed_Final);
    show_debug_message(Move_Speed_Modifier_Penalty_Timer);
}
