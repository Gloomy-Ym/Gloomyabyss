Hp_Final = Hp_Normal + Hp_Karma;
for (var i = 0; i < array_length(Buff); i++) {
    if (Buff[i].Name == "Weak" && Hp_Final <= Hp_Max / 2) {
    	Buff[i].state = true;
        Buff[i].Timer = 1;
        show_debug_message("虚弱");
    }
    if (Buff[i].Name == "Weak" && Hp_Final > Hp_Max / 2) {
    	Buff[i].state = false;
        Buff[i].Timer = 0;
    }
	if (Buff[i].state == true) {
        if (Buff[i].Timer > 0 && Buff[i].Elapse == true) {
        	Buff[i].Timer -= (delta_time / 1000000);
        }
        if (Buff[i].Damage > 0) {
        	Buff[i].Rate_Timer += 1;
            if (Buff[i].Rate_Timer >= Buff[i].Rate) { 
                if (Hp_Karma == 0 && Hp_Normal > 1) {
                    Hp_Normal -= 
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
            Buff[i].Rate_Timer = 0;
            }
        } 
        if (Buff[i].Atk_Mult != 0) {
        	Atk_Self += Atk_Self * Buff[i].Atk_Mult;
        }
        if (Buff[i].Def_Mult != 0) {
        	Def_Self += Def_Self * Buff[i].Def_Mult;
        }
        if (Buff[i].Timer <= 0) {
            Buff[i].Timer = 0;
            Buff[i].Rate_Timer = 0;
        	Buff[i].state = false;
        }
    }
}