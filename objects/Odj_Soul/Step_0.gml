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
//移速与移动计算逻辑
if (keyboard_check(ord("X")) || keyboard_check(vk_shift)) {
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
//蓝魂（移动前：先把玩家按的键读出来，再算出这一帧要往哪飞）
//这里必须放在 move_and_collide 之前，这样算出来的速度才能当帧就用上，不会慢半拍
if (sprite_index == Spr_Soul_Blue && Hp_Final > 0) {
    //左右：按住 A/← 往左，按住 D/→ 往右。两个方向用数字相减，结果只能是 -1、0 或 1
    Move_Left = keyboard_check(ord("A")) || keyboard_check(vk_left);
    Move_Right = keyboard_check(ord("D")) || keyboard_check(vk_right);
    H = Move_Right - Move_Left;

    //Move_Jump 是“站在地上”的标志。true 表示脚踩在地上、还没跳起来
    if (Move_Jump == true) {
        //站在地上时按了 W/↑，就开始起跳
        if (keyboard_check(ord("W")) || keyboard_check(vk_up)) {
            Move_Up = 2;          //往上飞的速度：2
            Move_Jump = false;    //已经离开地面，不再算“站在地上”
            Move_Jump_Timer = 0;  //重置按住跳跃的计时器
        }
        else {
            Move_Up = 0;          //没按跳跃，就不往上飞
        }
        Move_Down = 0;            //站在地上时不受重力，往下掉的速度清零
    }
    else {
        //已经离开地面了：只要还按着 W/↑ 且计时器没到 15，就一直保持上升
        //这样“长按跳更高，短按跳得矮”
        if ((keyboard_check(ord("W")) || keyboard_check(vk_up)) && Move_Jump_Timer < 15) {
            Move_Up = 2;          //保持上升速度
            Move_Jump_Timer += 1; //每帧多算一次，用来限制最长上升时间
        }
        else {
            Move_Up = 0;          //松开了或者时间到，就停止上升，交给重力往下拉
        }
        //重力：每帧把往下掉的速度加一点，最多加到 1，别掉得太快
        Move_Down = min(Move_Down + 0.05, 1);
    }

    //垂直方向 = 往下掉的速度 减去 往上飞的速度（往上飞时是负数，就代表向上）
    V = Move_Down - Move_Up;
}
move_and_collide(H * Move_Speed_Final, 0, Broder_Battle);
Collisions = move_and_collide(0, V * Move_Speed_Final, Broder_Battle);
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
//蓝魂（移动后：检查是不是撞到地板了，撞到就重新算作“落地”）
//Collisions 是上面 move_and_collide 返回的结果，撞到东西时它的长度会大于 0
if (sprite_index == Spr_Soul_Blue && Hp_Final > 0) {
    //两个条件同时满足才是“落地”：确实撞到了东西，而且这一帧是在往下掉（V > 0）
    //如果是在往上飞时撞到东西，就不会被误判成落地
    if (array_length(Collisions) > 0 && V > 0) {
        Move_Jump = true;  //重新标记为“站在地上”，这样就能再次起跳
        Move_Down = 0;     //往下掉的速度清零
        Move_Up = 0;       //往上飞的速度也清零，安安稳稳站在地上
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
    show_debug_message(Move_Speed_Modifier_Penalty_Timer);
}
