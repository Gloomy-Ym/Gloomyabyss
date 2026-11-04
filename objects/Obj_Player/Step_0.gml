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
    var left_offset = bbox_left - x;
    var top_offset = bbox_top - y;
    var box_width = bbox_right - bbox_left;
    var box_height = bbox_bottom - bbox_top;

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
    var moved = Scr_World_MoveRectSmooth(
        world,
        x + left_offset,
        y + top_offset,
        box_width,
        box_height,
        horizontal * player_move_speed * terrain_speed * Scr_Time_Scale(),
        vertical * player_move_speed * terrain_speed * Scr_Time_Scale()
    );
    x = moved.left - left_offset;
    y = moved.top - top_offset;

    // 平面传送门：跨过时把玩家折回目标坐标。
    // 平面两侧内容一致，折回后视觉无缝；道具和对象留在原坐标，不会消失。
    if (variable_struct_exists(world, "portal_planes")) {
        var pcol = Scr_World_WorldToCol(world, x);
        var prow = Scr_World_WorldToRow(world, y);
        for (var plane_i = 0; plane_i < array_length(world.portal_planes); plane_i++) {
            var plane = world.portal_planes[plane_i];
            var crossed = false;
            if (plane.axis == "x") {
                if (prow >= plane.from && prow < plane.to) {
                    if (plane.direction == "+" && pcol >= plane.at) crossed = true;
                    if (plane.direction == "-" && pcol < plane.at) crossed = true;
                }
            }
            else if (plane.axis == "y") {
                if (pcol >= plane.from && pcol < plane.to) {
                    if (plane.direction == "+" && prow >= plane.at) crossed = true;
                    if (plane.direction == "-" && prow < plane.at) crossed = true;
                }
            }
            if (crossed) {
                x += plane.dx * world.tile_size;
                y += plane.dy * world.tile_size;
                // 折回后把碰撞盒推回段内：周期边界在 x=0 时，
                // 盒左会落到 -1 列，碰撞查询会把那里当成墙。
                x = max(x, -left_offset + 1);
                y = max(y, -top_offset + 1);
                break;
            }
        }
    }

    // 接缝：只挪世界原点，不挪玩家
    Scr_World_ApplySeams(world, x, y);

    // 传送门
    if (portal_cooldown > 0) {
        portal_cooldown -= Scr_Time_Scale();
    }
    var portal = Scr_World_PortalAt(world, Scr_World_WorldToCol(world, x), Scr_World_WorldToRow(world, y));
    if (portal != undefined && portal_cooldown <= 0) {
        x = portal.target_col * world.tile_size + world.tile_size * 0.5;
        y = portal.target_row * world.tile_size + world.tile_size * 0.5;
        portal_cooldown = 15;
    }
}
else {
    move_and_collide(horizontal * player_move_speed * Scr_Time_Scale(), 0, player_colliders);
    move_and_collide(0, vertical * player_move_speed * Scr_Time_Scale(), player_colliders);
}
depth = -y;
