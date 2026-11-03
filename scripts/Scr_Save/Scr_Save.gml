// SPDX-License-Identifier: PolyForm-Noncommercial-1.0.0
// Copyright (C) 2026 Gloomy-Ym, JO-Beacon

function Scr_Save_FormatId(_prefix, _number) {
    var number_text = string(_number);
    while (string_length(number_text) < 4) {
        number_text = "0" + number_text;
    }
    return _prefix + "_" + number_text;
}

function Scr_Save_GetFormatVersion() {
    return 1;
}

function Scr_Save_LogError(_message) {
    show_debug_message("[Gloomy_Save] " + _message);
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

// ---- 第三层：剧情内部读写 ----

function Scr_Save_Story_GetChapter() {
    var story = Scr_Save_GetActiveStory();
    return (story == undefined ? undefined : story.chapter);
}

function Scr_Save_Story_GetRoute() {
    var story = Scr_Save_GetActiveStory();
    return (story == undefined ? undefined : story.route);
}

function Scr_Save_Story_GetFlag(_key, _default = undefined) {
    var story = Scr_Save_GetActiveStory();
    if (story == undefined) {
        return _default;
    }
    if (!is_struct(story.flags)) {
        story.flags = {};
    }
    if (!variable_struct_exists(story.flags, _key)) {
        return _default;
    }
    return story.flags[$ _key];
}

function Scr_Save_Story_HasFlag(_key) {
    var story = Scr_Save_GetActiveStory();
    if (story == undefined || !is_struct(story.flags)) {
        return false;
    }
    return variable_struct_exists(story.flags, _key);
}

function Scr_Save_Story_SetFlag(_key, _value) {
    var story = Scr_Save_GetActiveStory();
    if (story == undefined || !is_string(_key) || string_length(_key) <= 0) {
        return false;
    }
    if (!is_struct(story.flags)) {
        story.flags = {};
    }
    story.flags[$ _key] = _value;
    Scr_Save_MarkDirty();
    return true;
}

function Scr_Save_Story_DeleteFlag(_key) {
    var story = Scr_Save_GetActiveStory();
    if (story == undefined || !is_struct(story.flags) || !variable_struct_exists(story.flags, _key)) {
        return false;
    }
    variable_struct_remove(story.flags, _key);
    Scr_Save_MarkDirty();
    return true;
}

function Scr_Save_Story_ClearFlags() {
    var story = Scr_Save_GetActiveStory();
    if (story == undefined) {
        return false;
    }
    story.flags = {};
    Scr_Save_MarkDirty();
    return true;
}

// 立即把当前剧情槽位写到磁盘，玩家强退也不会丢
function Scr_Save_Story_Commit() {
    if (!variable_global_exists("Gloomy_Save")) {
        return false;
    }
    var world_index = global.Gloomy_Save.active_world_index;
    var story_index = global.Gloomy_Save.active_story_index;
    if (world_index < 0 || story_index < 0) {
        return false;
    }
    return Scr_Save_WriteStorySlot(world_index, story_index);
}

function Scr_Save_MarkDirty() {
    if (variable_global_exists("Gloomy_Save")) {
        global.Gloomy_Save.dirty = true;
    }
}

function Scr_Save_IsDirty() {
    if (!variable_global_exists("Gloomy_Save") || !variable_struct_exists(global.Gloomy_Save, "dirty")) {
        return false;
    }
    return global.Gloomy_Save.dirty;
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
    var temp_path = _path + ".tmp";
    var file_id = file_text_open_write(temp_path);
    if (file_id == -1) {
        Scr_Save_LogError("cannot open for write: " + temp_path);
        return false;
    }

    file_text_write_string(file_id, json_stringify(_data, true));
    file_text_close(file_id);

    // 写完后先读回来确认能解析，再覆盖正式文件
    if (Scr_Save_ReadJsonFile(temp_path) == undefined) {
        Scr_Save_LogError("written file failed verification: " + temp_path);
        file_delete(temp_path);
        return false;
    }

    // 覆盖前保留一份备份
    if (file_exists(_path)) {
        var backup_path = _path + ".bak";
        if (file_exists(backup_path)) {
            file_delete(backup_path);
        }
        file_copy(_path, backup_path);
        file_delete(_path);
    }

    file_copy(temp_path, _path);
    file_delete(temp_path);

    if (!file_exists(_path)) {
        Scr_Save_LogError("cannot move temp file into place: " + _path);
        return false;
    }

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

    try {
        return json_parse(content);
    } catch (_error) {
        Scr_Save_LogError("json parse failed: " + _path + " (" + string(_error) + ")");
        return undefined;
    }
}

function Scr_Save_ReadJsonFileWithBackup(_path) {
    var data = Scr_Save_ReadJsonFile(_path);
    if (data != undefined) {
        return data;
    }

    var backup_path = _path + ".bak";
    if (file_exists(backup_path)) {
        Scr_Save_LogError("falling back to backup: " + backup_path);
        return Scr_Save_ReadJsonFile(backup_path);
    }

    return undefined;
}

function Scr_Save_LoadIndex() {
    var data = Scr_Save_ReadJsonFileWithBackup(Scr_Save_GetIndexPath());
    if (data == undefined) {
        return undefined;
    }

    data = Scr_Save_MigrateIndex(data);
    if (data == undefined) {
        return undefined;
    }

    if (!Scr_Save_ValidateIndex(data)) {
        Scr_Save_LogError("index validation failed");
        return undefined;
    }

    return data;
}

function Scr_Save_MigrateIndex(_data) {
    if (!is_struct(_data)) {
        return undefined;
    }

    var version = 1;
    if (variable_struct_exists(_data, "version") && !is_undefined(_data.version)) {
        version = _data.version;
    }

    var target_version = Scr_Save_GetFormatVersion();
    if (version > target_version) {
        Scr_Save_LogError("index version " + string(version) + " is newer than supported " + string(target_version));
        return undefined;
    }

    while (version < target_version) {
        switch (version) {
            // 以后加存档格式版本时，在这里补一步迁移：
            // case 1: _data = Scr_Save_Migrate_1_to_2(_data); break;
            default:
                Scr_Save_LogError("no migration path from version " + string(version));
                return undefined;
        }
        version = version + 1;
    }

    _data.version = target_version;
    return _data;
}

function Scr_Save_ValidateIndex(_data) {
    if (!is_struct(_data)) {
        return false;
    }
    if (!variable_struct_exists(_data, "worlds") || !is_array(_data.worlds)) {
        return false;
    }
    return true;
}

function Scr_Save_LoadStorySlot(_world_id, _slot_id) {
    var data = Scr_Save_ReadJsonFileWithBackup(Scr_Save_GetStorySlotPath(_world_id, _slot_id));
    if (data == undefined || !is_struct(data)) {
        return undefined;
    }

    if (!variable_struct_exists(data, "id") || is_undefined(data.id)) {
        Scr_Save_LogError("story slot missing id: " + string(_slot_id));
        return undefined;
    }

    return {
        id: data.id,
        name: (variable_struct_exists(data, "name") ? data.name : string(_slot_id)),
        chapter: (variable_struct_exists(data, "chapter") ? data.chapter : "prologue"),
        route: (variable_struct_exists(data, "route") ? data.route : "normal"),
        flags: (variable_struct_exists(data, "flags") && is_struct(data.flags) ? data.flags : {})
    };
}

function Scr_Save_LoadWorld(_world_id) {
    var data = Scr_Save_ReadJsonFileWithBackup(Scr_Save_GetWorldPath(_world_id));
    if (data == undefined || !is_struct(data)) {
        return undefined;
    }

    if (!variable_struct_exists(data, "id") || is_undefined(data.id)) {
        Scr_Save_LogError("world missing id: " + string(_world_id));
        return undefined;
    }

    var world = {
        id: data.id,
        name: (variable_struct_exists(data, "name") ? data.name : string(data.id)),
        next_story_slot: (variable_struct_exists(data, "next_story_slot") ? data.next_story_slot : 1),
        story_slots: []
    };

    if (variable_struct_exists(data, "story_slot_ids") && is_array(data.story_slot_ids)) {
        var story_slot_count = array_length(data.story_slot_ids);
        for (var story_i = 0; story_i < story_slot_count; story_i++) {
            var story_slot_id = data.story_slot_ids[story_i];
            var story_slot = Scr_Save_LoadStorySlot(_world_id, story_slot_id);
            if (story_slot != undefined) {
                world.story_slots[array_length(world.story_slots)] = story_slot;
            } else {
                Scr_Save_LogError("story slot failed to load: " + string(story_slot_id) + " in " + string(_world_id));
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
        version: Scr_Save_GetFormatVersion(),
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

    global.Gloomy_Save.dirty = false;
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
            next_world_id: 1,
            dirty: false
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
