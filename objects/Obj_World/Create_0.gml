// SPDX-License-Identifier: PolyForm-Noncommercial-1.0.0
// Copyright (C) 2026 Gloomy-Ym, JO-Beacon

depth = 50;
if (!variable_global_exists("Gloomy_Debug")) {
    global.Gloomy_Debug = false;  // F3 切换：调试界面
}

world = Scr_World_Load("corridor");   // 测试走廊；换回大世界改回 "overworld"
if (world == undefined) {
    show_debug_message("[Gloomy_World] failed to load overworld");
    exit;
}

global.Gloomy_World = world;

if (world.start != undefined) {
    with (Obj_Player) {
        x = other.world.start.col * other.world.tile_size + other.world.tile_size * 0.5;
        y = other.world.start.row * other.world.tile_size + other.world.tile_size * 0.5;
    }
}

Scr_World_SpawnObjects(world, "Instances");

// 相机：视口 320x240，跟随玩家，贴地图边界夹取
camera = camera_create_view(0, 0, 320, 240, 0, -1, -1, -1, -1, -1);
view_enabled = true;
view_visible[0] = true;
view_set_camera(0, camera);
