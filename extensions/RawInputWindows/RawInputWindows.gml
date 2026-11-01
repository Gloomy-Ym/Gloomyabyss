// SPDX-License-Identifier: PolyForm-Noncommercial-1.0.0
// Copyright (C) 2026 Gloomy, JO-Beacon

#define RawInput_Init
return raw_input_native_init();

#define RawInput_Update
return raw_input_native_update();

#define RawInput_KeyDown
return raw_input_native_key_down(argument0);

#define RawInput_KeyPressed
return raw_input_native_key_pressed(argument0);

#define RawInput_KeyReleased
return raw_input_native_key_released(argument0);
