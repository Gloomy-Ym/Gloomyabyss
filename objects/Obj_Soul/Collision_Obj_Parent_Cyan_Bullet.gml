// SPDX-License-Identifier: PolyForm-Noncommercial-1.0.0
// Copyright (C) 2026 Gloomy-Ym, JO-Beacon

if (!Mode_Invincible && Invincible_Frames == 0 && Hp_Final > 0 && (H != 0 || V != 0 || Move_Jump = true || Move_Fall = true)) {
    audio_play_sound(Snd_Hurt, 0, false);
    Invincible_Frames = other.Invincible_Frames;
    Move_Speed_Modifier_Penalty = other.Move_Speed_Modifier_Penalty;
    Move_Speed_Modifier_Penalty_Timer = other.Move_Speed_Modifier_Penalty_Timer;
    //扣血
    Hp_Karma -= max(1, other.Damage_Normal - Def_Final);
    if (Hp_Karma < 0) {
    	Hp_Normal += Hp_Karma;
        Hp_Karma = 0;
    }
    Hp_Karma += Hp_Normal - max(1, Hp_Normal - other.Damage_Karma);
    Hp_Normal = max(1, Hp_Normal - other.Damage_Karma);
    if (other.Delete_Collision == true) {
        instance_destroy(other);
    }
}