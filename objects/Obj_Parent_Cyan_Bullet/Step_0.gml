Collisions = move_and_collide(H_speed, V_speed, Obj_Shield_Soul_Green)
if (array_length(Collisions) > 0) {
	audio_play_sound(Snd_Block_Bullet, 0, false);
    instance_destroy();
}