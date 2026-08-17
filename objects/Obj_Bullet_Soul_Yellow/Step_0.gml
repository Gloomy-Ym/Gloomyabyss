Frames += 1;
if (Frames >= 3) {
    if (sprite_index = Spr_Bullet_Soul_Yellow_1) {
        sprite_index = Spr_Bullet_Soul_Yellow_2;
    }
    else if (sprite_index = Spr_Bullet_Soul_Yellow_2) {
        sprite_index = Spr_Bullet_Soul_Yellow_3;
    }
    else if (sprite_index = Spr_Bullet_Soul_Yellow_3) {
        sprite_index = Spr_Bullet_Soul_Yellow_4;
    }
    else if (sprite_index = Spr_Bullet_Soul_Yellow_4) {
        sprite_index = Spr_Bullet_Soul_Yellow_5;
    }
    else if (sprite_index = Spr_Bullet_Soul_Yellow_5) {
        sprite_index = Spr_Bullet_Soul_Yellow_6;
    }
    Frames = 0;
}
Collisions = move_and_collide(0, Bullet_speed, Parent_Bullet);
if (array_length(Collisions) > 0) {
    Collision_Bullet = Collisions[0];
    if (Collision_Bullet.Hit == true) {
        Collision_Bullet.Hp_Bullet -= 1;
    }
    if (Collision_Bullet.Hp_Bullet <= 0) {
        instance_destroy(Collision_Bullet);
    }
    Collision_Bullet = [];
    instance_destroy();
}
