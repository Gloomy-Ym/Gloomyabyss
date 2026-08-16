//锁等级
if (LV > 20) {
	LV = 20;
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
//Final_Atk和Final_Def计算逻辑
Atk_Final = Atk_Self + Atk_Equip;
Def_Final = Def_Self + Def_Equip;
//升级升Atk_Self和Def_Self逻辑
Atk_Self = 2 * (LV - 1);
Def_Self = floor((LV - 1) * 0.25);
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
//红魂
if (sprite_index == Spr_Soul_Red && Hp_Final > 0) {
	Move_Up = keyboard_check(ord("W")) || keyboard_check(vk_up); 
    Move_Down = keyboard_check(ord("S")) || keyboard_check(vk_down);
    Move_Left = keyboard_check(ord("A")) || keyboard_check(vk_left);
    Move_Right = keyboard_check(ord("D")) || keyboard_check(vk_right);
    H = Move_Right - Move_Left;
    V = Move_Down - Move_Up;
    if (H != 0 && V != 0) { 
        H *= 0.707;
        V *= 0.707;
    }
}
//橙魂
if (sprite_index == Spr_Soul_Orange && Hp_Final > 0) {
	if (keyboard_check_pressed(ord("W")) || keyboard_check_pressed(vk_up)) {
    	Move_Up = true;
        Move_Down = false;
        Move_Left = false;
        Move_Right = false;
    }
    else if (keyboard_check_pressed(ord("S")) || keyboard_check_pressed(vk_down)) {
    	Move_Down = true;
        Move_Up = false;
        Move_Left = false;
        Move_Right = false;
    }
    else if (keyboard_check_pressed(ord("A")) || keyboard_check_pressed(vk_left)) {
    	Move_Left = true;
        Move_Up = false;
        Move_Down = false;
        Move_Right = false;
    }
    else if (keyboard_check_pressed(ord("D")) || keyboard_check_pressed(vk_right)) {
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
    if (keyboard_check_pressed(ord("Z")) || keyboard_check_pressed(vk_enter)) {
        audio_play_sound(Snd_Soul_Yellow_Shoot_Bullet, 0, false);
        instance_create_depth(x, y - 17, depth, Odj_Bullet_Soul_Yellow);
    }
	Move_Up = keyboard_check(ord("W")) || keyboard_check(vk_up); 
    Move_Down = keyboard_check(ord("S")) || keyboard_check(vk_down);
    Move_Left = keyboard_check(ord("A")) || keyboard_check(vk_left);
    Move_Right = keyboard_check(ord("D")) || keyboard_check(vk_right);
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
    if (keyboard_check_pressed(ord("W")) || keyboard_check_pressed(vk_up)) {
    	Obj_Shield_Soul_Green.image_angle = 0;
    }
    else if (keyboard_check_pressed(ord("S")) || keyboard_check_pressed(vk_down)) {
    	Obj_Shield_Soul_Green.image_angle = 180;
    }
    else if (keyboard_check_pressed(ord("A")) || keyboard_check_pressed(vk_left)) {
    	Obj_Shield_Soul_Green.image_angle = 90;
    }
    else if (keyboard_check_pressed(ord("D")) || keyboard_check_pressed(vk_right)) {
    	Obj_Shield_Soul_Green.image_angle = 270;
    }
}
//移速与移动计算逻辑
if (keyboard_check(ord("X")) || keyboard_check(vk_shift)) { 
    Move_Speed_Final = Move_Speed * Move_Speed_modifier_Penalty * Move_Speed_modifier_Hold_X_Or_Shift;
}
else {
	Move_Speed_Final = Move_Speed * Move_Speed_modifier_Penalty;
}
if (Move_Speed_modifier_Penalty_timer > 0) {
	Move_Speed_modifier_Penalty_timer -= 1;
}
else {
    Move_Speed_modifier_Penalty_timer = 0;
    Move_Speed_modifier_Penalty = 1;
}
move_and_collide(H * Move_Speed_Final, V * Move_Speed_Final, Broder_Battle);
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
    Invincible_Frames_Falsh_Timer = 0
    visible = true;
}
//无敌模式
if (keyboard_check_pressed(ord("1"))) {
	Mode_Invincible = !Mode_Invincible;
}
if (Mode_Invincible == false) {
	Mode_Invincible_print = "关闭无敌模式";
}
else {
	Mode_Invincible_print = "开启无敌模式";
}
//恢复所有血量
if (keyboard_check_pressed(ord("3"))) {
	Hp_Normal = Hp_Max;
    Hp_Karma = 0;
}
//输出状态
if (keyboard_check(ord("2"))) {
    show_debug_message("Normal_Hp : " + string(Hp_Normal));
    show_debug_message("Karma_Hp : " + string(Hp_Karma));
    show_debug_message("Final_Hp : " + string(Hp_Final));
}
if (keyboard_check(ord("1"))) {
	show_debug_message(Mode_Invincible_print);
}
if (Move_Speed_Final < 4) {
	show_debug_message(Move_Speed_Final);
    show_debug_message(Move_Speed_modifier_Penalty_timer);
}
