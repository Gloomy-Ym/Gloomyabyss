// SPDX-License-Identifier: PolyForm-Noncommercial-1.0.0
// Copyright (C) 2026 Gloomy-Ym, JO-Beacon
//
// 帧率无关的步长。
//
// 约定：所有速度、计时器仍然按“30 帧/步”的单位写。
// 每步乘上 Scr_Time_Scale()，60 帧时它等于 0.5，30 帧时等于 1。
//
// 上限 1/30 秒：掉帧时宁可慢一点，也不要一帧穿墙。

function Scr_Time_Dt() {
    return clamp(delta_time / 1000000, 0, 1 / 30);
}

function Scr_Time_Scale() {
    return Scr_Time_Dt() * 30;
}
