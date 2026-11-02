// SPDX-License-Identifier: PolyForm-Noncommercial-1.0.0
// Copyright (C) 2026 Gloomy-Ym, JO-Beacon

#define RawInput_Init
return 0;

#define RawInput_Update
return 0;

#define RawInput_KeyDown
return keyboard_check(argument0) ? 1 : 0;

#define RawInput_KeyPressed
return keyboard_check_pressed(argument0) ? 1 : 0;

#define RawInput_KeyReleased
return keyboard_check_released(argument0) ? 1 : 0;
