// SPDX-License-Identifier: PolyForm-Noncommercial-1.0.0
// Copyright (C) 2026 Gloomy-Ym, JO-Beacon

function Scr_Save_FormatId(_prefix, _number) {
    var number_text = string(_number);
    while (string_length(number_text) < 4) {
        number_text = "0" + number_text;
    }
    return _prefix + "_" + number_text;
}

function Scr_Save_CreateStorySlot(_world_index, _name) {
    if (!variable_global_exists("Gloomy_Save")) {
        return -1;
    }
    if (_world_index < 0 || _world_index >= array_length(global.Gloomy_Save.worlds)) {
        return -1;
    }

    var world = global.Gloomy_Save.worlds[_world_index];
    if (world == undefined) {
        return -1;
    }

    var slot_index = array_length(world.story_slots);
    var slot_id = Scr_Save_FormatId("slot", world.next_story_slot);
    world.next_story_slot = world.next_story_slot + 1;

    world.story_slots[slot_index] = {
        id: slot_id,
        name: _name,
        chapter: "prologue",
        route: "normal",
        flags: {}
    };

    return slot_index;
}

function Scr_Save_CreateWorld(_name) {
    var world_index = array_length(global.Gloomy_Save.worlds);
    var world_id = Scr_Save_FormatId("world", global.Gloomy_Save.next_world_id);
    global.Gloomy_Save.next_world_id = global.Gloomy_Save.next_world_id + 1;

    global.Gloomy_Save.worlds[world_index] = {
        id: world_id,
        name: _name,
        next_story_slot: 1,
        story_slots: []
    };

    Scr_Save_CreateStorySlot(world_index, "STORY 1");
    return world_index;
}

function Scr_Save_GetNextWorldName() {
    return "WORLD " + string(global.Gloomy_Save.next_world_id);
}

function Scr_Save_SetWorldName(_world_index, _name) {
    var world = Scr_Save_GetWorld(_world_index);
    if (world == undefined || string_length(_name) <= 0) {
        return false;
    }

    world.name = _name;
    return true;
}

function Scr_Save_DestroyWorldDirectory(_world_id) {
    var world_directory = Scr_Save_GetWorldDirectory(_world_id);
    if (directory_exists(world_directory)) {
        directory_destroy(world_directory);
    }
}

function Scr_Save_DeleteWorld(_world_index) {
    var world = Scr_Save_GetWorld(_world_index);
    if (world == undefined) {
        return false;
    }

    var world_id = world.id;
    array_delete(global.Gloomy_Save.worlds, _world_index, 1);

    if (global.Gloomy_Save.active_world_index == _world_index) {
        global.Gloomy_Save.active_world_index = min(_world_index, Scr_Save_GetWorldCount() - 1);
        global.Gloomy_Save.active_story_index = 0;
    }
    else if (global.Gloomy_Save.active_world_index > _world_index) {
        global.Gloomy_Save.active_world_index = global.Gloomy_Save.active_world_index - 1;
    }

    Scr_Save_DestroyWorldDirectory(world_id);
    return true;
}

function Scr_Save_ClearAllSaves() {
    if (!variable_global_exists("Gloomy_Save")) {
        return false;
    }

    while (Scr_Save_GetWorldCount() > 0) {
        Scr_Save_DeleteWorld(0);
    }

    global.Gloomy_Save.worlds = [];
    global.Gloomy_Save.active_world_index = -1;
    global.Gloomy_Save.active_story_index = -1;
    global.Gloomy_Save.next_world_id = 1;

    var save_directory = Scr_Save_GetSaveBaseDirectory();
    if (directory_exists(save_directory)) {
        directory_destroy(save_directory);
    }

    Scr_Save_WriteIndex();
    return true;
}

function Scr_Save_CopyWorld(_world_index, _name) {
    var source_world = Scr_Save_GetWorld(_world_index);
    if (source_world == undefined || string_length(_name) <= 0) {
        return -1;
    }

    var copy_index = Scr_Save_CreateWorld(_name);
    var copy_world = Scr_Save_GetWorld(copy_index);
    copy_world.next_story_slot = 1;
    copy_world.story_slots = [];

    var source_story_count = array_length(source_world.story_slots);
    for (var story_i = 0; story_i < source_story_count; story_i++) {
        var source_story = source_world.story_slots[story_i];
        if (source_story == undefined) {
            continue;
        }

        var copied_story = variable_clone(source_story);
        copied_story.id = Scr_Save_FormatId("slot", copy_world.next_story_slot);
        copy_world.next_story_slot = copy_world.next_story_slot + 1;
        copy_world.story_slots[array_length(copy_world.story_slots)] = copied_story;
    }

    if (array_length(copy_world.story_slots) == 0) {
        Scr_Save_CreateStorySlot(copy_index, "STORY 1");
    }

    return copy_index;
}

function Scr_Save_GetWorldCount() {
    if (!variable_global_exists("Gloomy_Save")) {
        return 0;
    }
    return array_length(global.Gloomy_Save.worlds);
}

function Scr_Save_GetWorld(_index) {
    if (!variable_global_exists("Gloomy_Save")) {
        return undefined;
    }
    if (_index < 0 || _index >= array_length(global.Gloomy_Save.worlds)) {
        return undefined;
    }
    return global.Gloomy_Save.worlds[_index];
}

function Scr_Save_GetStoryCount(_world_index) {
    var world = Scr_Save_GetWorld(_world_index);
    if (world == undefined) {
        return 0;
    }
    return array_length(world.story_slots);
}

function Scr_Save_GetStory(_world_index, _story_index) {
    var world = Scr_Save_GetWorld(_world_index);
    if (world == undefined) {
        return undefined;
    }
    if (_story_index < 0 || _story_index >= array_length(world.story_slots)) {
        return undefined;
    }
    return world.story_slots[_story_index];
}

function Scr_Save_SelectActive(_world_index, _story_index) {
    global.Gloomy_Save.active_world_index = _world_index;
    global.Gloomy_Save.active_story_index = _story_index;
}

function Scr_Save_GetActiveWorld() {
    if (!variable_global_exists("Gloomy_Save") || global.Gloomy_Save.active_world_index < 0) {
        return undefined;
    }
    return Scr_Save_GetWorld(global.Gloomy_Save.active_world_index);
}

function Scr_Save_GetActiveStory() {
    if (!variable_global_exists("Gloomy_Save") || global.Gloomy_Save.active_world_index < 0 || global.Gloomy_Save.active_story_index < 0) {
        return undefined;
    }
    return Scr_Save_GetStory(global.Gloomy_Save.active_world_index, global.Gloomy_Save.active_story_index);
}

function Scr_Save_GetSaveBaseDirectory() {
    return Scr_Save_JoinPath(working_directory, "saves");
}

function Scr_Save_JoinPath(_base, _part) {
    var base_length = string_length(_base);
    if (base_length > 0) {
        var final_character = string_char_at(_base, base_length);
        if (final_character == "/" || final_character == "\\") {
            return _base + _part;
        }
    }
    return _base + "/" + _part;
}

function Scr_Save_GetWorldsDirectory() {
    return Scr_Save_JoinPath(Scr_Save_GetSaveBaseDirectory(), "worlds");
}

function Scr_Save_GetWorldDirectory(_world_id) {
    return Scr_Save_JoinPath(Scr_Save_GetWorldsDirectory(), _world_id);
}

function Scr_Save_GetStorySlotDirectory(_world_id) {
    return Scr_Save_JoinPath(Scr_Save_GetWorldDirectory(_world_id), "story_slots");
}

function Scr_Save_GetIndexPath() {
    return Scr_Save_JoinPath(Scr_Save_GetSaveBaseDirectory(), "index.json");
}

function Scr_Save_GetWorldPath(_world_id) {
    return Scr_Save_JoinPath(Scr_Save_GetWorldDirectory(_world_id), "world.json");
}

function Scr_Save_GetStorySlotPath(_world_id, _slot_id) {
    return Scr_Save_JoinPath(Scr_Save_GetStorySlotDirectory(_world_id), _slot_id + ".json");
}

function Scr_Save_EnsureDirectory(_directory) {
    if (directory_exists(_directory)) {
        return true;
    }
    return directory_create(_directory);
}

function Scr_Save_EnsureWorldDirectories(_world_id) {
    if (!Scr_Save_EnsureDirectory(Scr_Save_GetSaveBaseDirectory())) {
        return false;
    }
    if (!Scr_Save_EnsureDirectory(Scr_Save_GetWorldsDirectory())) {
        return false;
    }
    if (!Scr_Save_EnsureDirectory(Scr_Save_GetWorldDirectory(_world_id))) {
        return false;
    }
    return Scr_Save_EnsureDirectory(Scr_Save_GetStorySlotDirectory(_world_id));
}

function Scr_Save_WriteJsonFile(_path, _data) {
    var file_id = file_text_open_write(_path);
    if (file_id == -1) {
        return false;
    }

    file_text_write_string(file_id, json_stringify(_data, true));
    file_text_close(file_id);
    return true;
}

function Scr_Save_ReadJsonFile(_path) {
    if (!file_exists(_path)) {
        return undefined;
    }

    var file_id = file_text_open_read(_path);
    if (file_id == -1) {
        return undefined;
    }

    var content = "";
    while (!file_text_eof(file_id)) {
        content += file_text_read_string(file_id);
        if (!file_text_eof(file_id)) {
            file_text_readln(file_id);
        }
    }
    file_text_close(file_id);
    content = string_trim(content);
    if (content == "") {
        return undefined;
    }

    return json_parse(content);
}

function Scr_Save_LoadIndex() {
    return Scr_Save_ReadJsonFile(Scr_Save_GetIndexPath());
}

function Scr_Save_LoadStorySlot(_world_id, _slot_id) {
    var data = Scr_Save_ReadJsonFile(Scr_Save_GetStorySlotPath(_world_id, _slot_id));
    if (data == undefined) {
        return undefined;
    }

    return {
        id: data.id,
        name: data.name,
        chapter: data.chapter,
        route: data.route,
        flags: data.flags
    };
}

function Scr_Save_LoadWorld(_world_id) {
    var data = Scr_Save_ReadJsonFile(Scr_Save_GetWorldPath(_world_id));
    if (data == undefined) {
        return undefined;
    }

    var world = {
        id: data.id,
        name: data.name,
        next_story_slot: data.next_story_slot,
        story_slots: []
    };

    if (data.story_slot_ids != undefined) {
        var story_slot_count = array_length(data.story_slot_ids);
        for (var story_i = 0; story_i < story_slot_count; story_i++) {
            var story_slot_id = data.story_slot_ids[story_i];
            var story_slot = Scr_Save_LoadStorySlot(_world_id, story_slot_id);
            if (story_slot != undefined) {
                world.story_slots[array_length(world.story_slots)] = story_slot;
            }
        }
    }

    return world;
}

function Scr_Save_WriteStorySlot(_world_index, _story_index) {
    var world = Scr_Save_GetWorld(_world_index);
    var story = Scr_Save_GetStory(_world_index, _story_index);
    if (world == undefined || story == undefined) {
        return false;
    }

    if (!Scr_Save_EnsureWorldDirectories(world.id)) {
        return false;
    }

    var data = {
        id: story.id,
        name: story.name,
        chapter: story.chapter,
        route: story.route,
        flags: story.flags
    };

    return Scr_Save_WriteJsonFile(Scr_Save_GetStorySlotPath(world.id, story.id), data);
}

function Scr_Save_WriteWorld(_world_index) {
    var world = Scr_Save_GetWorld(_world_index);
    if (world == undefined) {
        return false;
    }

    if (!Scr_Save_EnsureWorldDirectories(world.id)) {
        return false;
    }

    var story_slot_ids = [];
    var story_count = array_length(world.story_slots);
    for (var story_i = 0; story_i < story_count; story_i++) {
        var story_slot = world.story_slots[story_i];
        if (story_slot != undefined) {
            story_slot_ids[array_length(story_slot_ids)] = story_slot.id;
        }
    }

    var data = {
        id: world.id,
        name: world.name,
        next_story_slot: world.next_story_slot,
        story_slot_ids: story_slot_ids
    };

    if (!Scr_Save_WriteJsonFile(Scr_Save_GetWorldPath(world.id), data)) {
        return false;
    }

    for (var slot_i = 0; slot_i < story_count; slot_i++) {
        if (!Scr_Save_WriteStorySlot(_world_index, slot_i)) {
            return false;
        }
    }

    return true;
}

function Scr_Save_WriteIndex() {
    if (!Scr_Save_EnsureDirectory(Scr_Save_GetSaveBaseDirectory())) {
        return false;
    }
    if (!Scr_Save_EnsureDirectory(Scr_Save_GetWorldsDirectory())) {
        return false;
    }

    var worlds = [];
    var world_count = Scr_Save_GetWorldCount();
    for (var world_i = 0; world_i < world_count; world_i++) {
        var world = Scr_Save_GetWorld(world_i);
        if (world == undefined) {
            continue;
        }

        worlds[array_length(worlds)] = {
            id: world.id,
            name: world.name,
            next_story_slot: world.next_story_slot,
            story_count: array_length(world.story_slots)
        };
    }

    var data = {
        version: 1,
        next_world_id: global.Gloomy_Save.next_world_id,
        active_world_index: global.Gloomy_Save.active_world_index,
        active_story_index: global.Gloomy_Save.active_story_index,
        worlds: worlds
    };

    return Scr_Save_WriteJsonFile(Scr_Save_GetIndexPath(), data);
}

function Scr_Save_SaveAll() {
    if (!variable_global_exists("Gloomy_Save")) {
        return false;
    }

    if (!Scr_Save_WriteIndex()) {
        return false;
    }

    var world_count = Scr_Save_GetWorldCount();
    for (var world_i = 0; world_i < world_count; world_i++) {
        if (!Scr_Save_WriteWorld(world_i)) {
            return false;
        }
    }

    return true;
}

function Scr_Save_Init() {
    if (variable_global_exists("__Scr_Save_Initialised") && global.__Scr_Save_Initialised) {
        return;
    }

    global.__Scr_Save_Initialised = true;

    if (!variable_global_exists("Gloomy_Save")) {
        global.Gloomy_Save = {
            worlds: [],
            active_world_index: -1,
            active_story_index: -1,
            next_world_id: 1
        };
    }

    var index_data = Scr_Save_LoadIndex();
    if (index_data != undefined && index_data.worlds != undefined) {
        global.Gloomy_Save.next_world_id = (index_data.next_world_id != undefined ? index_data.next_world_id : 1);

        var index_world_count = array_length(index_data.worlds);
        for (var index_i = 0; index_i < index_world_count; index_i++) {
            var index_world = index_data.worlds[index_i];
            if (index_world == undefined) {
                continue;
            }

            var loaded_world = Scr_Save_LoadWorld(index_world.id);
            if (loaded_world != undefined) {
                global.Gloomy_Save.worlds[array_length(global.Gloomy_Save.worlds)] = loaded_world;
            }
        }

        if (array_length(global.Gloomy_Save.worlds) == 0) {
            global.Gloomy_Save.active_world_index = -1;
            global.Gloomy_Save.active_story_index = -1;
            return;
        }

        global.Gloomy_Save.active_world_index = (index_data.active_world_index != undefined ? index_data.active_world_index : 0);
        global.Gloomy_Save.active_story_index = (index_data.active_story_index != undefined ? index_data.active_story_index : 0);

        if (global.Gloomy_Save.active_world_index < 0 || global.Gloomy_Save.active_world_index >= Scr_Save_GetWorldCount()) {
            global.Gloomy_Save.active_world_index = 0;
        }

        if (global.Gloomy_Save.active_story_index < 0 || global.Gloomy_Save.active_story_index >= Scr_Save_GetStoryCount(global.Gloomy_Save.active_world_index)) {
            global.Gloomy_Save.active_story_index = 0;
        }
        return;
    }

    global.Gloomy_Save.active_world_index = -1;
    global.Gloomy_Save.active_story_index = -1;
}
