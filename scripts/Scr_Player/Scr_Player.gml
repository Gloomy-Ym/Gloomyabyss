// SPDX-License-Identifier: PolyForm-Noncommercial-1.0.0
// Copyright (C) 2026 Gloomy-Ym, JO-Beacon
//
// 玩家数值的唯一初始化入口：大地图和战斗共用同一组初始值。
// 已经初始化过就不覆盖，避免进战斗时把大地图的状态重置。

function Scr_Player_Init() {
    if (variable_global_exists("Gloomy_Player")) {
        return;
    }

    global.Gloomy_Player = {
        LV: 1,
        EXP: 0,
        GOLD: 0,
        Hp_Max: 20,
        Hp_Normal: 20,
        Hp_Karma: 0,
        Hp_Final: 20,
        Atk_Self: 0,
        Atk_Equip: 0,
        Atk_Final: 0,
        Def_Self: 0,
        Def_Equip: 0,
        Def_Final: 0,
        Exp_Next: 20
    };
}
