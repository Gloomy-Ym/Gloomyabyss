function Scr_Input_Init() {
    global.__Scr_Input_Ready = RawInput_Init() > 0;
    if (global.__Scr_Input_Ready) {
        RawInput_Update();
    }
}

function Scr_Input_Update() {
    if (variable_global_exists("__Scr_Input_Ready") && global.__Scr_Input_Ready) {
        RawInput_Update();
    }
}

function Scr_Input_KeyDown(_key) {
    if (variable_global_exists("__Scr_Input_Ready") && global.__Scr_Input_Ready && window_has_focus()) {
        return RawInput_KeyDown(_key) > 0;
    }
    return keyboard_check(_key);
}

function Scr_Input_KeyPressed(_key) {
    if (variable_global_exists("__Scr_Input_Ready") && global.__Scr_Input_Ready && window_has_focus()) {
        return RawInput_KeyPressed(_key) > 0;
    }
    return keyboard_check_pressed(_key);
}

function Scr_Input_KeyReleased(_key) {
    if (variable_global_exists("__Scr_Input_Ready") && global.__Scr_Input_Ready && window_has_focus()) {
        return RawInput_KeyReleased(_key) > 0;
    }
    return keyboard_check_released(_key);
}

function Scr_Input_ConfirmPressed() {
    return Scr_Input_KeyPressed(ord("Z")) || Scr_Input_KeyPressed(vk_enter);
}

function Scr_Input_CancelPressed() {
    return Scr_Input_KeyPressed(ord("X")) || Scr_Input_KeyPressed(vk_shift);
}

function Scr_Input_UpPressed() {
    return Scr_Input_KeyPressed(ord("W")) || Scr_Input_KeyPressed(vk_up);
}

function Scr_Input_DownPressed() {
    return Scr_Input_KeyPressed(ord("S")) || Scr_Input_KeyPressed(vk_down);
}

function Scr_Input_LeftPressed() {
    return Scr_Input_KeyPressed(ord("A")) || Scr_Input_KeyPressed(vk_left);
}

function Scr_Input_RightPressed() {
    return Scr_Input_KeyPressed(ord("D")) || Scr_Input_KeyPressed(vk_right);
}
