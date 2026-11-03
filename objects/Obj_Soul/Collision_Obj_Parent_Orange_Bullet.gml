// SPDX-License-Identifier: PolyForm-Noncommercial-1.0.0
// Copyright (C) 2026 Gloomy, JO-Beacon

if (!Mode_Invincible && Invincible_Frames == 0 && Hp_Final > 0 && H = 0 && V = 0 && Move_Jump = false && Move_Fall = false) {
	    audio_play_sound(Snd_Hurt, 0, false);
    Invincible_Frames = other.Invincible_Frames;
    Move_Speed_Modifier_Penalty = other.Move_Speed_Modifier_Penalty;
    Move_Speed_Modifier_Penalty_Timer = other.Move_Speed_Modifier_Penalty_Timer;
    if (Hp_Karma == 0 && Hp_Normal > 1) {
        Hp_Normal -= max(1, other.Damage_Normal - Def_Final + other.Damage_Karma);
        Hp_Karma += other.Damage_Karma;
        Hp_Karma = min(Hp_Final - 1, Hp_Karma);
    }
    else if (Hp_Karma > 0 && Hp_Normal > 1) {
        Hp_Normal = max(1, Hp_Normal - other.Damage_Karma);
        Hp_Karma -= max(1, other.Damage_Normal - Def_Final);
        Hp_Karma += other.Damage_Karma;
        Hp_Karma = min(Hp_Final - 1, Hp_Karma);
    }
    else if (Hp_Karma > 0 && Hp_Normal == 1) {
    	Hp_Karma -= max(1, other.Damage_Normal - Def_Final);
    }
    else if (Hp_Karma == 0 && Hp_Normal == 1) {
        Hp_Normal -= max(1, other.Damage_Normal - Def_Final);
    }
    if (Hp_Karma < 0) {
    	Hp_Normal += Hp_Karma;
        Hp_Karma = 0;
    }
    if (Hp_Normal < 0) {
    	Hp_Normal = 0;
    }
    if (other.Delete_Collision == true) {
        instance_destroy(other);
    }
}