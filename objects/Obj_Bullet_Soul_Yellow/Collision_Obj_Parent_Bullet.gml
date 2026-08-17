if (other.Hit == true) {
    other.Hp_Bullet -= 1;
    if (other.Hp_Bullet == 0) {
        instance_destroy(other);
    }
}
instance_destroy();
