for (var i = 0; i < array_length(Buff); i++) {
	if (Buff[i].state == true) {
        if (Buff[i].Timer > 0) {
        	Buff[i].Timer -= (delta_time / 1000000);
        }
        if (Buff[i].Damage > 0) {
        	Hp_Normal -= Buff[i].Damage;
        } 
    }
}