// SPDX-License-Identifier: PolyForm-Noncommercial-1.0.0
// Copyright (C) 2026 Gloomy, JO-Beacon

audio_play_sound(Snd_Heal, 0, false); 
Hp_Normal += other.Heal_Value;
if (Hp_Final > Hp_Max) { 
    Hp_Normal = Hp_Max - Hp_Karma;
}
instance_destroy(other);