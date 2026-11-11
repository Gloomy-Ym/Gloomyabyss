// SPDX-License-Identifier: PolyForm-Noncommercial-1.0.0
// Copyright (C) 2026 Gloomy-Ym, JO-Beacon

var overworld_menu_open = variable_global_exists("Gloomy_Overworld_UI_Open") && global.Gloomy_Overworld_UI_Open;
var move_left = Scr_Input_KeyDown(ord("A")) || Scr_Input_KeyDown(vk_left);
var move_right = Scr_Input_KeyDown(ord("D")) || Scr_Input_KeyDown(vk_right);
var move_up = Scr_Input_KeyDown(ord("W")) || Scr_Input_KeyDown(vk_up);
var move_down = Scr_Input_KeyDown(ord("S")) || Scr_Input_KeyDown(vk_down);
var horizontal = move_right - move_left;
var vertical = move_down - move_up;

if (overworld_menu_open) {
    horizontal = 0;
    vertical = 0;
}

if (horizontal != 0 && vertical != 0) {
    horizontal *= 0.70710678;
    vertical *= 0.70710678;
}

if (vertical < 0) {
    player_direction = 3;
}
else if (vertical > 0) {
    player_direction = 0;
}
else if (horizontal < 0) {
    player_direction = 2;
}
else if (horizontal > 0) {
    player_direction = 1;
}

var is_moving = horizontal != 0 || vertical != 0;
if (is_moving) {
    player_frame_timer += Scr_Time_Scale();
    if (player_frame_timer >= 6) {
        player_frame_timer = 0;
        player_frame = (player_frame + 1) mod 4;
    }
}
else {
    player_frame = 0;
    player_frame_timer = 0;
}

image_index = player_direction * 4 + player_frame;
if (variable_global_exists("Gloomy_World") && global.Gloomy_World != undefined) {
    var world = global.Gloomy_World;
    // 碰撞只用下半身：18×18（比一格小 2px，否则 20 宽的缝永远挤不进去）。
    var box_width = 18;
    var box_height = 18;
    var left_offset = bbox_left - x + (bbox_right - bbox_left - box_width) * 0.5;
    var top_offset = bbox_bottom - y - box_height;

    // 地形：速度倍率 + 持续伤害
    var terrain = Scr_World_DefAt(world, Scr_World_WorldToCol(world, x), Scr_World_WorldToRow(world, y));
    var terrain_speed = (terrain != undefined ? terrain.speed : 1);

    if (terrain != undefined && terrain.damage > 0 && variable_global_exists("Gloomy_Player")) {
        terrain_damage_accum += terrain.damage * Scr_Time_Dt();
        while (terrain_damage_accum >= 1) {
            terrain_damage_accum -= 1;
            global.Gloomy_Player.Hp_Final = max(0, global.Gloomy_Player.Hp_Final - 1);
        }

        if (global.Gloomy_Player.Hp_Final <= 0 && (!variable_global_exists("Gloomy_Death_Triggered") || !global.Gloomy_Death_Triggered)) {
            global.Gloomy_Death_Triggered = true;
            room_goto(Death_Room);
            exit;
        }
    }

    // 网格 + 碰撞形状（带滑动）
    var prev_cx = x + left_offset + box_width * 0.5;
    var prev_cy = y + top_offset + box_height * 0.5;
    var moved = Scr_World_MoveRectSmooth(
        world,
        x + left_offset,
        y + top_offset,
        box_width,
        box_height,
        horizontal * player_move_speed * terrain_speed,
        vertical * player_move_speed * terrain_speed
    );
    x = moved.left - left_offset;
    y = moved.top - top_offset;

    // 线传送门：跨过线时按入口面送到目标线。
    if (line_portal_cooldown > 0) {
        line_portal_cooldown -= Scr_Time_Scale();
    }
    var cur_cx = x + left_offset + box_width * 0.5;
    var cur_cy = y + top_offset + box_height * 0.5;
    if (line_portal_cooldown <= 0 && (cur_cx != prev_cx || cur_cy != prev_cy)) {
        var portal_target = Scr_World_LinePortalCross(
            world,
            prev_cx,
            prev_cy,
            cur_cx,
            cur_cy
        );
        if (portal_target != undefined) {
            x = portal_target.x - left_offset - box_width * 0.5;
            y = portal_target.y - top_offset - box_height * 0.5;
            line_portal_cooldown = 15;
        }
    }

    portal_eye_x = x + left_offset + box_width * 0.5;
    portal_eye_y = y + top_offset + box_height * 0.5;

    // 接缝：只挪世界原点，不挪玩家
    Scr_World_ApplySeams(world, x, y);

    // 传送格
    if (pad_cooldown > 0) {
        pad_cooldown -= Scr_Time_Scale();
    }
    var pad = Scr_World_PadAt(world, Scr_World_WorldToCol(world, x), Scr_World_WorldToRow(world, y));
    if (pad != undefined && pad_cooldown <= 0) {
        x = pad.target_col * world.tile_size + world.tile_size * 0.5;
        y = pad.target_row * world.tile_size + world.tile_size * 0.5;
        pad_cooldown = 15;
    }
}
else {
    move_and_collide(horizontal * player_move_speed * Scr_Time_Scale(), 0, player_colliders);
    move_and_collide(0, vertical * player_move_speed * Scr_Time_Scale(), player_colliders);
}
depth = -y;
