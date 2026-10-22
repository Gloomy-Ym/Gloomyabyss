if (Hp_Final < Hp_Max) {
    audio_play_sound(Snd_Heal, 0, false);
	Hp_Normal += other.Heal_Value;
    if (Hp_Final > Hp_Max) {
    	Hp_Normal = Hp_Max - Hp_Karma;
    }
}
instance_destroy(other);