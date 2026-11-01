// SPDX-License-Identifier: PolyForm-Noncommercial-1.0.0
// Copyright (C) 2026 Gloomy, JO-Beacon

event_inherited();
if (Scr_Input_KeyPressed(ord("3"))) {
	H_speed -= 1;
}
if (Scr_Input_KeyPressed(ord("4"))) {
	H_speed += 1;
}
if (Scr_Input_KeyPressed(ord("5"))) {
	V_speed -= 1;
}
if (Scr_Input_KeyPressed(ord("6"))) {
	V_speed += 1;
}
