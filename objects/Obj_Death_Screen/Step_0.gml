death_blink_timer += 1;
if (Scr_Input_ConfirmPressed()) {
    global.Gloomy_Death_Triggered = false;
    room_goto(Title_Room);
}
