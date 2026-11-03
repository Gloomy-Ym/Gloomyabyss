// SPDX-License-Identifier: PolyForm-Noncommercial-1.0.0
// Copyright (C) 2026 Gloomy-Ym, JO-Beacon

death_blink_timer += Scr_Time_Scale();
if (Scr_Input_ConfirmPressed()) {
    global.Gloomy_Death_Triggered = false;
    room_goto(Title_Room);
}
