// SPDX-License-Identifier: PolyForm-Noncommercial-1.0.0
// Copyright (C) 2026 Gloomy-Ym, JO-Beacon

if (sprite_index == Spr_Bullet_Soul_Yellow_1) {
	Frames += 1;
    if (Frames >= 3) {
    	sprite_index = Spr_Bullet_Soul_Yellow_2;
        Frames = 0;
    }
}
else if (sprite_index == Spr_Bullet_Soul_Yellow_2) {
	Frames += 1;
    if (Frames >= 3) {
    	sprite_index = Spr_Bullet_Soul_Yellow_3;
        Frames = 0;
    }
}
else if (sprite_index == Spr_Bullet_Soul_Yellow_3) {
	Frames += 1;
    if (Frames >= 3) {
    	sprite_index = Spr_Bullet_Soul_Yellow_4;
        Frames = 0;
    }
}
else if (sprite_index == Spr_Bullet_Soul_Yellow_4) {
	Frames += 1;
    if (Frames >= 3) {
    	sprite_index = Spr_Bullet_Soul_Yellow_5;
        Frames = 0;
    }
}
else if (sprite_index == Spr_Bullet_Soul_Yellow_5) {
	Frames += 1;
    if (Frames >= 3) {
    	sprite_index = Spr_Bullet_Soul_Yellow_6;
        Frames = 0;
    }
}
Collisions = move_and_collide(0, -15, Obj_Parent_Bullet);
if (array_length(Collisions) > 0) {
	Collisions_Bullet = Collisions[0];
    if (Collisions_Bullet.Hit == true) {
        Collisions_Bullet.Hp_Bullet -= 1;
        if (Collisions_Bullet.Hp_Bullet == 0) {
            instance_destroy(Collisions_Bullet);
        }
    }
    instance_destroy();
}