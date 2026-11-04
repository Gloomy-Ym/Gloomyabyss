// SPDX-License-Identifier: PolyForm-Noncommercial-1.0.0
// Copyright (C) 2026 Gloomy-Ym, JO-Beacon
//
// 大世界网格引擎（段落模型）
//
// 世界 = segments[]，每段：
//   id / rows / origin(列,行) / repeat(x|y) / repeat_count(0=无限)
//   段内还可以有 prop / solid / spawn / portal 指令
//
// 兼容旧的单文件地图：没有 world.json 时，把整张 .seg 当成 origin=(0,0) 的一段。

function Scr_World_Log(_message) {
    show_debug_message("[Gloomy_World] " + _message);
}

// ---------- 读文件 ----------

function Scr_World_ReadJson(_path) {
    if (!file_exists(_path)) {
        return undefined;
    }
    var file_id = file_text_open_read(_path);
    if (file_id == -1) {
        return undefined;
    }
    var content = "";
    while (!file_text_eof(file_id)) {
        content += file_text_readln(file_id);
    }
    file_text_close(file_id);
    try {
        return json_parse(content);
    } catch (_error) {
        Scr_World_Log("json parse failed: " + _path + " (" + string(_error) + ")");
        return undefined;
    }
}

function Scr_World_ReadLines(_path) {
    if (!file_exists(_path)) {
        return undefined;
    }
    var file_id = file_text_open_read(_path);
    if (file_id == -1) {
        return undefined;
    }
    var lines = [];
    while (!file_text_eof(file_id)) {
        array_push(lines, file_text_readln(file_id));
    }
    file_text_close(file_id);
    return lines;
}

// ---------- 地形表 ----------

function Scr_World_LoadTerrain(_path) {
    var data = Scr_World_ReadJson(_path);
    if (data == undefined || !is_struct(data) || !variable_struct_exists(data, "types")) {
        Scr_World_Log("terrain table invalid: " + _path);
        return undefined;
    }

    var tile_size = (variable_struct_exists(data, "tile_size") ? data.tile_size : 20);
    var types = [];
    var code_map = {};
    var count = array_length(data.types);

    for (var i = 0; i < count; i++) {
        var raw = data.types[i];
        if (!is_struct(raw) || !variable_struct_exists(raw, "code")) {
            Scr_World_Log("terrain type #" + string(i) + " has no code");
            return undefined;
        }
        var code = raw.code;
        if (string_length(code) != 1 || variable_struct_exists(code_map, code)) {
            Scr_World_Log("bad or duplicate terrain code: " + string(code));
            return undefined;
        }

        var colour = c_white;
        if (variable_struct_exists(raw, "color") && is_array(raw.color) && array_length(raw.color) >= 3) {
            colour = make_colour_rgb(raw.color[0], raw.color[1], raw.color[2]);
        }

        types[i] = {
            code: code,
            name: (variable_struct_exists(raw, "name") ? raw.name : code),
            colour: colour,
            block: (variable_struct_exists(raw, "block") ? raw.block : false),
            speed: (variable_struct_exists(raw, "speed") ? raw.speed : 1.0),
            damage: (variable_struct_exists(raw, "damage") ? raw.damage : 0)
        };
        code_map[$ code] = i;
    }

    return { tile_size: tile_size, types: types, code_map: code_map };
}

// ---------- 道具表 ----------

function Scr_World_LoadPropTypes(_path) {
    var data = Scr_World_ReadJson(_path);
    if (data == undefined || !is_struct(data) || !variable_struct_exists(data, "types")) {
        Scr_World_Log("prop table invalid: " + _path);
        return undefined;
    }

    var types = {};
    var count = array_length(data.types);

    for (var i = 0; i < count; i++) {
        var raw = data.types[i];
        if (!is_struct(raw) || !variable_struct_exists(raw, "id")) {
            Scr_World_Log("prop type #" + string(i) + " has no id");
            return undefined;
        }
        if (variable_struct_exists(types, raw.id)) {
            Scr_World_Log("duplicate prop id: " + string(raw.id));
            return undefined;
        }

        var prop_sprite = -1;
        if (variable_struct_exists(raw, "sprite")) {
            prop_sprite = asset_get_index(raw.sprite);
            if (prop_sprite < 0) {
                Scr_World_Log("unknown prop sprite: " + string(raw.sprite));
                return undefined;
            }
        }

        types[$ raw.id] = {
            id: raw.id,
            name: (variable_struct_exists(raw, "name") ? raw.name : raw.id),
            sprite_index: prop_sprite,
            block: (variable_struct_exists(raw, "block") ? raw.block : true),
            width: (variable_struct_exists(raw, "width") ? raw.width : 1),
            height: (variable_struct_exists(raw, "height") ? raw.height : 1),
            interaction: (variable_struct_exists(raw, "interaction") ? raw.interaction : "")
        };
    }

    return types;
}

// ---------- 指令解析 ----------

function Scr_World_ParseSpawn(_text) {
    var parts = string_split(_text, ",");
    var count = array_length(parts);
    if (count != 3 && count != 5) {
        Scr_World_Log("bad spawn directive: " + _text);
        return undefined;
    }
    return {
        object: string_trim(parts[0]),
        col: real(string_trim(parts[1])),
        row: real(string_trim(parts[2])),
        width: (count == 5 ? real(string_trim(parts[3])) : 1),
        height: (count == 5 ? real(string_trim(parts[4])) : 1)
    };
}

function Scr_World_ParseProp(_text) {
    var parts = string_split(_text, ",");
    var count = array_length(parts);
    if (count != 3 && count != 5) {
        Scr_World_Log("bad prop directive: " + _text);
        return undefined;
    }
    return {
        id: string_trim(parts[0]),
        col: real(string_trim(parts[1])),
        row: real(string_trim(parts[2])),
        width: (count == 5 ? real(string_trim(parts[3])) : 0),
        height: (count == 5 ? real(string_trim(parts[4])) : 0)
    };
}

function Scr_World_ParseSolid(_text, _tile_size) {
    var parts = string_split(_text, ",");
    var count = array_length(parts);
    if (count < 6 || (count mod 2) != 0) {
        Scr_World_Log("bad solid directive: " + _text);
        return undefined;
    }
    var points = [];
    for (var i = 0; i < count; i += 2) {
        array_push(points, {
            x: real(string_trim(parts[i])) * _tile_size,
            y: real(string_trim(parts[i + 1])) * _tile_size
        });
    }
    return { points: points };
}

function Scr_World_ParsePortal(_text) {
    var parts = string_split(_text, ",");
    if (array_length(parts) != 4) {
        Scr_World_Log("bad portal directive: " + _text);
        return undefined;
    }
    return {
        col: real(string_trim(parts[0])),
        row: real(string_trim(parts[1])),
        target_col: real(string_trim(parts[2])),
        target_row: real(string_trim(parts[3]))
    };
}

// ---------- 段落 ----------

function Scr_World_ParseSegment(_dir, _spec, _terrain, _prop_types, _tile_size) {
    var seg = {
        id: _spec.id,
        origin_col: (variable_struct_exists(_spec, "origin") ? _spec.origin[0] : 0),
        origin_row: (variable_struct_exists(_spec, "origin") ? _spec.origin[1] : 0),
        repeat_x: false,
        repeat_y: false,
        repeat_count: (variable_struct_exists(_spec, "repeat_count") ? _spec.repeat_count : 0),
        width: 0,
        height: 0,
        rows: [],
        props: [],
        solids: [],
        spawns: [],
        portals: [],
        blocked_cells: {}
    };

    if (variable_struct_exists(_spec, "repeat")) {
        seg.repeat_x = (string_pos("x", _spec.repeat) > 0);
        seg.repeat_y = (string_pos("y", _spec.repeat) > 0);
    }

    var lines = Scr_World_ReadLines(_dir + "/" + _spec.file);
    if (lines == undefined) {
        Scr_World_Log("segment file missing: " + _spec.file);
        return undefined;
    }

    var rows = [];
    var width = -1;
    var line_count = array_length(lines);

    for (var i = 0; i < line_count; i++) {
        var line = string_trim(lines[i]);
        if (line == "") {
            continue;
        }

        if (string_char_at(line, 1) == ";") {
            var body = string_trim(string_delete(line, 1, 1));
            var eq = string_pos("=", body);
            if (eq > 0) {
                var key = string_trim(string_copy(body, 1, eq - 1));
                var value = string_trim(string_copy(body, eq + 1, string_length(body) - eq));
                switch (key) {
                    case "prop":
                        var pr = Scr_World_ParseProp(value);
                        if (pr != undefined) array_push(seg.props, pr);
                        break;
                    case "spawn":
                        var sp = Scr_World_ParseSpawn(value);
                        if (sp != undefined) array_push(seg.spawns, sp);
                        break;
                    case "solid":
                        var so = Scr_World_ParseSolid(value, _tile_size);
                        if (so != undefined) array_push(seg.solids, so);
                        break;
                    case "portal":
                        var po = Scr_World_ParsePortal(value);
                        if (po != undefined) array_push(seg.portals, po);
                        break;
                }
            }
            continue;
        }

        if (width == -1) {
            width = string_length(line);
        }
        else if (string_length(line) != width) {
            Scr_World_Log("segment " + _spec.id + " row " + string(i + 1) + " width mismatch");
            return undefined;
        }
        array_push(rows, line);
    }

    if (width <= 0 || array_length(rows) == 0) {
        Scr_World_Log("segment has no grid: " + _spec.id);
        return undefined;
    }

    seg.rows = rows;
    seg.width = width;
    seg.height = array_length(rows);

    // 校验字符
    for (var r = 0; r < seg.height; r++) {
        for (var c = 0; c < seg.width; c++) {
            var code = string_char_at(rows[r], c + 1);
            if (!variable_struct_exists(_terrain.code_map, code)) {
                Scr_World_Log("unknown terrain '" + code + "' in " + _spec.id + " at " + string(c) + "," + string(r));
                return undefined;
            }
        }
    }

    // 道具占格
    for (var i = 0; i < array_length(seg.props); i++) {
        var prop = seg.props[i];
        if (!variable_struct_exists(_prop_types, prop.id)) {
            Scr_World_Log("unknown prop id: " + string(prop.id));
            return undefined;
        }
        prop.def = _prop_types[$ prop.id];
        prop.width = (prop.width > 0 ? prop.width : prop.def.width);
        prop.height = (prop.height > 0 ? prop.height : prop.def.height);
        if (prop.def.block) {
            for (var r = prop.row; r < prop.row + prop.height; r++) {
                for (var c = prop.col; c < prop.col + prop.width; c++) {
                    seg.blocked_cells[$ string(r * seg.width + c)] = true;
                }
            }
        }
    }

    return seg;
}

// ---------- 世界 ----------

function Scr_World_LoadSegments(_name, _base = "") {
    var dir = (_base == "" ? "world/" + _name : _base);
    var manifest = Scr_World_ReadJson(dir + "/world.json");
    if (manifest == undefined) {
        return undefined;
    }

    var terrain = Scr_World_LoadTerrain("world/terrain.json");
    if (terrain == undefined) {
        return undefined;
    }
    var prop_types = Scr_World_LoadPropTypes("world/props.json");
    if (prop_types == undefined) {
        return undefined;
    }

    var world = {
        name: _name,
        dir: dir,
        tile_size: terrain.tile_size,
        types: terrain.types,
        code_map: terrain.code_map,
        segments: [],
        by_id: {},
        portals: [],
        portal_planes: [],
        seams: [],
        start: manifest.start
    };

    for (var i = 0; i < array_length(manifest.segments); i++) {
        var seg = Scr_World_ParseSegment(dir, manifest.segments[i], terrain, prop_types, terrain.tile_size);
        if (seg == undefined) {
            return undefined;
        }
        array_push(world.segments, seg);
        world.by_id[$ seg.id] = seg;
    }

    // 传送门：段内坐标 -> 世界坐标
    if (variable_struct_exists(manifest, "portals")) {
        for (var i = 0; i < array_length(manifest.portals); i++) {
            var p = manifest.portals[i];
            var seg = world.by_id[$ p.segment];
            if (seg == undefined) {
                Scr_World_Log("portal references unknown segment: " + string(p.segment));
                return undefined;
            }
            array_push(world.portals, {
                id: p.id,
                col: seg.origin_col + p.col,
                row: seg.origin_row + p.row,
                target_col: undefined,
                target_row: undefined
            });
        }
    }

    // 连线：把 from 的 target 指向 to 的世界坐标
    if (variable_struct_exists(manifest, "links")) {
        for (var i = 0; i < array_length(manifest.links); i++) {
            var link = manifest.links[i];
            var from_portal = Scr_World_FindPortalById(world, link.from);
            var to_portal = Scr_World_FindPortalById(world, link.to);
            if (from_portal == undefined || to_portal == undefined) {
                Scr_World_Log("link references unknown portal");
                return undefined;
            }
            from_portal.target_col = to_portal.col;
            from_portal.target_row = to_portal.row;
            if (variable_struct_exists(link, "bidirectional") && link.bidirectional) {
                to_portal.target_col = from_portal.col;
                to_portal.target_row = from_portal.row;
            }
        }
    }

    // 传送门平面：门另一侧整片区域映射到目标坐标
    if (variable_struct_exists(manifest, "portal_planes")) {
        for (var i = 0; i < array_length(manifest.portal_planes); i++) {
            var plane = manifest.portal_planes[i];
            array_push(world.portal_planes, {
                axis: plane.axis,
                at: plane.at,
                from: plane.from,
                to: plane.to,
                dx: plane.target[0],
                dy: plane.target[1],
                direction: (variable_struct_exists(plane, "direction") ? plane.direction : "+")
            });
        }
    }

    // 接缝：段内越界时重定原点
    if (variable_struct_exists(manifest, "seams")) {
        for (var i = 0; i < array_length(manifest.seams); i++) {
            var seam = manifest.seams[i];
            if (!variable_struct_exists(world.by_id, seam.segment)) {
                Scr_World_Log("seam references unknown segment: " + string(seam.segment));
                return undefined;
            }
            array_push(world.seams, seam);
        }
    }

    // 每段自己的 portal 指令（段内坐标 -> 世界坐标）
    for (var i = 0; i < array_length(world.segments); i++) {
        var seg = world.segments[i];
        for (var p = 0; p < array_length(seg.portals); p++) {
            var po = seg.portals[p];
            if (po.target_col != undefined) {
                array_push(world.portals, {
                    id: "seg_" + seg.id + "_" + string(p),
                    col: seg.origin_col + po.col,
                    row: seg.origin_row + po.row,
                    target_col: seg.origin_col + po.target_col,
                    target_row: seg.origin_row + po.target_row
                });
            }
        }
    }

    // 世界边界
    var min_col = undefined;
    var max_col = undefined;
    var min_row = undefined;
    var max_row = undefined;
    var unbounded_x = false;
    var unbounded_y = false;

    for (var i = 0; i < array_length(world.segments); i++) {
        var seg = world.segments[i];
        var seg_max_col = seg.origin_col + seg.width * (seg.repeat_count > 0 ? seg.repeat_count : 1);
        var seg_max_row = seg.origin_row + seg.height * (seg.repeat_count > 0 ? seg.repeat_count : 1);
        if (seg.repeat_x && seg.repeat_count == 0) unbounded_x = true;
        if (seg.repeat_y && seg.repeat_count == 0) unbounded_y = true;
        if (min_col == undefined || seg.origin_col < min_col) min_col = seg.origin_col;
        if (min_row == undefined || seg.origin_row < min_row) min_row = seg.origin_row;
        if (max_col == undefined || seg_max_col > max_col) max_col = seg_max_col;
        if (max_row == undefined || seg_max_row > max_row) max_row = seg_max_row;
    }

    for (var i = 0; i < array_length(world.seams); i++) {
        if (world.seams[i].axis == "x") unbounded_x = true;
        if (world.seams[i].axis == "y") unbounded_y = true;
    }
    for (var i = 0; i < array_length(world.portal_planes); i++) {
        if (world.portal_planes[i].axis == "x") unbounded_x = true;
        if (world.portal_planes[i].axis == "y") unbounded_y = true;
    }

    world.min_col = min_col;
    world.max_col = max_col;
    world.min_row = min_row;
    world.max_row = max_row;
    world.unbounded_x = unbounded_x;
    world.unbounded_y = unbounded_y;

    if (world.start == undefined && array_length(world.segments) > 0) {
        world.start = { col: world.segments[0].origin_col + 1, row: world.segments[0].origin_row + 1 };
    }

    return world;
}

function Scr_World_FindPortalById(_world, _id) {
    for (var i = 0; i < array_length(_world.portals); i++) {
        if (_world.portals[i].id == _id) {
            return _world.portals[i];
        }
    }
    return undefined;
}

function Scr_World_Load(_name, _base = "") {
    return Scr_World_LoadSegments(_name, _base);
}

// ---------- 查询 ----------

// 传送门：把坐标解析到真正的数据坐标
function Scr_World_Resolve(_world, _col, _row) {
    if (_world.portal_planes == undefined) {
        return { col: _col, row: _row };
    }

    for (var iter = 0; iter < 8; iter++) {
        var moved = false;
        for (var i = 0; i < array_length(_world.portal_planes); i++) {
            var plane = _world.portal_planes[i];
            if (plane.axis == "x") {
                if (_row >= plane.from && _row < plane.to) {
                    // 正向：作用于 >= at 的一侧
                    if (plane.direction == "+" && _col >= plane.at) {
                        var span_p = abs(plane.dx);
                        var kp = floor((_col - plane.at) / span_p) + 1;
                        _col += kp * plane.dx;
                        _row += kp * plane.dy;
                        moved = true;
                        break;
                    }
                    // 反向：作用于 < at 的一侧
                    if (plane.direction == "-" && _col < plane.at) {
                        var span_n = abs(plane.dx);
                        var kn = floor((plane.at - _col - 1) / span_n) + 1;
                        _col += kn * plane.dx;
                        _row += kn * plane.dy;
                        moved = true;
                        break;
                    }
                }
            }
            else if (plane.axis == "y") {
                if (_row >= plane.at && _col >= plane.from && _col < plane.to) {
                    if (plane.dy < 0) {
                        var span_y = -plane.dy;
                        var ky = floor((_row - plane.at) / span_y) + 1;
                        _row += ky * plane.dy;
                        _col += ky * plane.dx;
                    }
                    else {
                        _row += plane.dy;
                        _col += plane.dx;
                    }
                    moved = true;
                    break;
                }
            }
        }
        if (!moved) break;
    }

    return { col: _col, row: _row };
}

function Scr_World_SegmentAt(_world, _col, _row) {
    var resolved = Scr_World_Resolve(_world, _col, _row);
    _col = resolved.col;
    _row = resolved.row;
    var count = array_length(_world.segments);
    for (var i = 0; i < count; i++) {
        var seg = _world.segments[i];
        var local_col = 0;
        var local_row = 0;

        if (seg.repeat_x) {
            if (seg.repeat_count > 0 && (_col < seg.origin_col || _col >= seg.origin_col + seg.width * seg.repeat_count)) {
                continue;
            }
            local_col = ((_col - seg.origin_col) mod seg.width + seg.width) mod seg.width;
        }
        else {
            if (_col < seg.origin_col || _col >= seg.origin_col + seg.width) {
                continue;
            }
            local_col = _col - seg.origin_col;
        }

        if (seg.repeat_y) {
            if (seg.repeat_count > 0 && (_row < seg.origin_row || _row >= seg.origin_row + seg.height * seg.repeat_count)) {
                continue;
            }
            local_row = ((_row - seg.origin_row) mod seg.height + seg.height) mod seg.height;
        }
        else {
            if (_row < seg.origin_row || _row >= seg.origin_row + seg.height) {
                continue;
            }
            local_row = _row - seg.origin_row;
        }

        return { seg: seg, col: local_col, row: local_row };
    }
    return undefined;
}

function Scr_World_DefAt(_world, _col, _row) {
    if (_world == undefined) {
        return undefined;
    }
    var hit = Scr_World_SegmentAt(_world, _col, _row);
    if (hit == undefined) {
        return undefined;
    }
    var code = string_char_at(hit.seg.rows[hit.row], hit.col + 1);
    if (!variable_struct_exists(_world.code_map, code)) {
        return undefined;
    }
    return _world.types[_world.code_map[$ code]];
}

function Scr_World_IsBlocked(_world, _col, _row) {
    var hit = Scr_World_SegmentAt(_world, _col, _row);
    if (hit == undefined) {
        return true;
    }
    var code = string_char_at(hit.seg.rows[hit.row], hit.col + 1);
    var def = _world.types[_world.code_map[$ code]];
    if (def.block) {
        return true;
    }
    return variable_struct_exists(hit.seg.blocked_cells, string(hit.row * hit.seg.width + hit.col));
}

function Scr_World_WorldToCol(_world, _x) {
    return floor(_x / _world.tile_size);
}

function Scr_World_WorldToRow(_world, _y) {
    return floor(_y / _world.tile_size);
}

// ---------- 碰撞 ----------

function Scr_World_ProjectOverlap(_cx, _cy, _hw, _hh, _points, _ax, _ay) {
    var rect_center = _cx * _ax + _cy * _ay;
    var rect_radius = _hw * abs(_ax) + _hh * abs(_ay);
    var min_p = undefined;
    var max_p = undefined;
    var count = array_length(_points);
    for (var i = 0; i < count; i++) {
        var dist = _points[i].x * _ax + _points[i].y * _ay;
        if (min_p == undefined || dist < min_p) min_p = dist;
        if (max_p == undefined || dist > max_p) max_p = dist;
    }
    return !(rect_center + rect_radius < min_p || rect_center - rect_radius > max_p);
}

function Scr_World_RectHitsSolid(_left, _top, _width, _height, _solid) {
    var points = _solid.points;
    var count = array_length(points);
    if (count < 3) return false;

    var cx = _left + _width * 0.5;
    var cy = _top + _height * 0.5;
    var hw = _width * 0.5;
    var hh = _height * 0.5;

    if (!Scr_World_ProjectOverlap(cx, cy, hw, hh, points, 1, 0)) return false;
    if (!Scr_World_ProjectOverlap(cx, cy, hw, hh, points, 0, 1)) return false;

    for (var i = 0; i < count; i++) {
        var p1 = points[i];
        var p2 = points[(i + 1) mod count];
        var ex = p2.x - p1.x;
        var ey = p2.y - p1.y;
        var len = sqrt(ex * ex + ey * ey);
        if (len <= 0) continue;
        if (!Scr_World_ProjectOverlap(cx, cy, hw, hh, points, -ey / len, ex / len)) return false;
    }
    return true;
}

function Scr_World_RectBlocked(_world, _left, _top, _right, _bottom) {
    var ts = _world.tile_size;
    var c0 = floor(_left / ts);
    var c1 = floor((_right - 0.001) / ts);
    var r0 = floor(_top / ts);
    var r1 = floor((_bottom - 0.001) / ts);

    for (var r = r0; r <= r1; r++) {
        for (var c = c0; c <= c1; c++) {
            if (Scr_World_IsBlocked(_world, c, r)) return true;
        }
    }

    var width = _right - _left;
    var height = _bottom - _top;
    for (var i = 0; i < array_length(_world.segments); i++) {
        var seg = _world.segments[i];
        for (var s = 0; s < array_length(seg.solids); s++) {
            if (Scr_World_RectHitsSolid(_left, _top, width, height, seg.solids[s])) return true;
        }
    }
    return false;
}

function Scr_World_MoveRect(_world, _left, _top, _width, _height, _dx, _dy) {
    if (_dx != 0) {
        var dir_x = sign(_dx);
        var remain_x = abs(_dx);
        while (remain_x > 0) {
            var step_x = min(1, remain_x);
            var next_x = _left + dir_x * step_x;
            if (Scr_World_RectBlocked(_world, next_x, _top, next_x + _width, _top + _height)) break;
            _left = next_x;
            remain_x -= step_x;
        }
    }
    if (_dy != 0) {
        var dir_y = sign(_dy);
        var remain_y = abs(_dy);
        while (remain_y > 0) {
            var step_y = min(1, remain_y);
            var next_y = _top + dir_y * step_y;
            if (Scr_World_RectBlocked(_world, _left, next_y, _left + _width, next_y + _height)) break;
            _top = next_y;
            remain_y -= step_y;
        }
    }
    return { left: _left, top: _top };
}

function Scr_World_RectSolidMTV(_left, _top, _width, _height, _solid) {
    var points = _solid.points;
    var count = array_length(points);
    if (count < 3) return undefined;

    var cx = _left + _width * 0.5;
    var cy = _top + _height * 0.5;
    var hw = _width * 0.5;
    var hh = _height * 0.5;

    var axes = [[1, 0], [0, 1]];
    for (var i = 0; i < count; i++) {
        var p1 = points[i];
        var p2 = points[(i + 1) mod count];
        var ex = p2.x - p1.x;
        var ey = p2.y - p1.y;
        var len = sqrt(ex * ex + ey * ey);
        if (len > 0) array_push(axes, [-ey / len, ex / len]);
    }

    var best_overlap = undefined;
    var best_nx = 0;
    var best_ny = 0;

    for (var a = 0; a < array_length(axes); a++) {
        var ax = axes[a][0];
        var ay = axes[a][1];
        var rect_center = cx * ax + cy * ay;
        var rect_radius = hw * abs(ax) + hh * abs(ay);
        var min_p = undefined;
        var max_p = undefined;
        for (var i = 0; i < count; i++) {
            var dist = points[i].x * ax + points[i].y * ay;
            if (min_p == undefined || dist < min_p) min_p = dist;
            if (max_p == undefined || dist > max_p) max_p = dist;
        }
        var overlap = min(rect_center + rect_radius, max_p) - max(rect_center - rect_radius, min_p);
        if (overlap <= 0) return undefined;
        if (best_overlap == undefined || overlap < best_overlap) {
            best_overlap = overlap;
            var push_sign = (rect_center > (min_p + max_p) * 0.5) ? 1 : -1;
            best_nx = ax * push_sign;
            best_ny = ay * push_sign;
        }
    }
    return { nx: best_nx, ny: best_ny, overlap: best_overlap };
}

function Scr_World_FindSolidHit(_world, _left, _top, _width, _height) {
    var best = undefined;
    for (var i = 0; i < array_length(_world.segments); i++) {
        var seg = _world.segments[i];
        for (var s = 0; s < array_length(seg.solids); s++) {
            var hit = Scr_World_RectSolidMTV(_left, _top, _width, _height, seg.solids[s]);
            if (hit != undefined && (best == undefined || hit.overlap < best.overlap)) best = hit;
        }
    }
    return best;
}

function Scr_World_MoveRectSmooth(_world, _left, _top, _width, _height, _dx, _dy) {
    var distance = sqrt(_dx * _dx + _dy * _dy);
    var steps = max(1, ceil(distance / 2));
    var step_x = _dx / steps;
    var step_y = _dy / steps;

    for (var s = 0; s < steps; s++) {
        var move_x = step_x;
        var move_y = step_y;

        for (var iter = 0; iter < 3; iter++) {
            if (move_x == 0 && move_y == 0) break;

            var target_left = _left + move_x;
            var target_top = _top + move_y;

            if (!Scr_World_RectBlocked(_world, target_left, target_top, target_left + _width, target_top + _height)) {
                _left = target_left;
                _top = target_top;
                break;
            }

            var hit = Scr_World_FindSolidHit(_world, target_left, target_top, _width, _height);
            if (hit != undefined) {
                var dot = move_x * hit.nx + move_y * hit.ny;
                if (dot < 0) {
                    move_x -= hit.nx * dot;
                    move_y -= hit.ny * dot;
                    continue;
                }
            }

            if (!Scr_World_RectBlocked(_world, _left + move_x, _top, _left + move_x + _width, _top + _height)) {
                _left += move_x;
            }
            if (!Scr_World_RectBlocked(_world, _left, _top + move_y, _left + _width, _top + move_y + _height)) {
                _top += move_y;
            }
            break;
        }
    }
    return { left: _left, top: _top };
}

// ---------- 渲染 ----------

function Scr_World_Draw(_world, _cam_x, _cam_y, _cam_w, _cam_h) {
    if (_world == undefined) return;

    var ts = _world.tile_size;
    var c0 = floor(_cam_x / ts);
    var c1 = floor((_cam_x + _cam_w) / ts);
    var r0 = floor(_cam_y / ts);
    var r1 = floor((_cam_y + _cam_h) / ts);

    for (var r = r0; r <= r1; r++) {
        for (var c = c0; c <= c1; c++) {
            var def = Scr_World_DefAt(_world, c, r);
            if (def == undefined) continue;
            draw_set_colour(def.colour);
            draw_rectangle(c * ts, r * ts, (c + 1) * ts - 1, (r + 1) * ts - 1, false);
        }
    }
    draw_set_colour(c_white);
}

function Scr_World_PropWorldX(_world, _seg, _prop) {
    return (_seg.origin_col + _prop.col) * _world.tile_size + _prop.width * _world.tile_size * 0.5;
}

function Scr_World_PropWorldY(_world, _seg, _prop) {
    return (_seg.origin_row + _prop.row) * _world.tile_size + _prop.height * _world.tile_size * 0.5;
}

function Scr_World_DrawProps(_world, _cam_x, _cam_y, _cam_w, _cam_h) {
    if (_world == undefined) return;

    for (var i = 0; i < array_length(_world.segments); i++) {
        var seg = _world.segments[i];
        for (var p = 0; p < array_length(seg.props); p++) {
            var prop = seg.props[p];
            var sprite = prop.def.sprite_index;
            if (sprite == -1) continue;

            var center_x = Scr_World_PropWorldX(_world, seg, prop);
            var center_y = Scr_World_PropWorldY(_world, seg, prop);
            var half = _world.tile_size;

            if (center_x + half < _cam_x || center_x - half > _cam_x + _cam_w) continue;
            if (center_y + half < _cam_y || center_y - half > _cam_y + _cam_h) continue;

            var draw_x = center_x + sprite_get_xoffset(sprite) - sprite_get_width(sprite) * 0.5;
            var draw_y = center_y + sprite_get_yoffset(sprite) - sprite_get_height(sprite) * 0.5;
            draw_sprite(sprite, 0, draw_x, draw_y);
        }
    }
}

function Scr_World_DrawSolids(_world) {
    if (_world == undefined) return;
    draw_set_colour(c_red);
    for (var i = 0; i < array_length(_world.segments); i++) {
        var seg = _world.segments[i];
        for (var s = 0; s < array_length(seg.solids); s++) {
            var points = seg.solids[s].points;
            var count = array_length(points);
            for (var p = 0; p < count; p++) {
                var p1 = points[p];
                var p2 = points[(p + 1) mod count];
                draw_line(p1.x, p1.y, p2.x, p2.y);
            }
        }
    }
    draw_set_colour(c_white);
}

// ---------- 生成实体 ----------

function Scr_World_PlaceObject(_world, _object_name, _world_col, _world_row, _layer) {
    var spawn_obj = asset_get_index(_object_name);
    if (spawn_obj < 0) {
        Scr_World_Log("unknown object in map: " + _object_name);
        return undefined;
    }

    var ts = _world.tile_size;
    var pos_x = _world_col * ts + ts * 0.5;
    var pos_y = _world_row * ts + ts * 0.5;

    var sprite = object_get_sprite(spawn_obj);
    if (sprite != -1) {
        pos_x += sprite_get_xoffset(sprite) - sprite_get_width(sprite) * 0.5;
        pos_y += sprite_get_yoffset(sprite) - sprite_get_height(sprite) * 0.5;
    }

    return instance_create_layer(pos_x, pos_y, _layer, spawn_obj);
}

function Scr_World_SpawnObjects(_world, _layer) {
    if (_world == undefined) return;

    for (var i = 0; i < array_length(_world.segments); i++) {
        var seg = _world.segments[i];
        for (var s = 0; s < array_length(seg.spawns); s++) {
            var entry = seg.spawns[s];
            if (variable_struct_exists(entry, "object")) {
                var spawned = Scr_World_PlaceObject(_world, entry.object, seg.origin_col + entry.col, seg.origin_row + entry.row, _layer);
                if (spawned != undefined) spawned.depth = -spawned.y;
            }
        }
    }
}

// ---------- 传送门 / 道具查询 ----------

function Scr_World_PortalAt(_world, _col, _row) {
    if (_world == undefined) return undefined;
    for (var i = 0; i < array_length(_world.portals); i++) {
        var portal = _world.portals[i];
        if (portal.col == _col && portal.row == _row && portal.target_col != undefined) {
            return portal;
        }
    }
    return undefined;
}

function Scr_World_FindProp(_world, _x, _y, _radius, _interaction) {
    if (_world == undefined) return undefined;

    var best = undefined;
    var best_distance = _radius;

    for (var i = 0; i < array_length(_world.segments); i++) {
        var seg = _world.segments[i];
        for (var p = 0; p < array_length(seg.props); p++) {
            var prop = seg.props[p];
            if (_interaction != "" && prop.def.interaction != _interaction) continue;

            var distance = point_distance(_x, _y, Scr_World_PropWorldX(_world, seg, prop), Scr_World_PropWorldY(_world, seg, prop));
            if (distance <= best_distance) {
                best_distance = distance;
                best = prop;
            }
        }
    }
    return best;
}

// ---- 接缝：重定原点 ----

function Scr_World_Rebase(_world, _dx, _dy) {
    for (var i = 0; i < array_length(_world.segments); i++) {
        _world.segments[i].origin_col += _dx;
        _world.segments[i].origin_row += _dy;
    }
    _world.min_col += _dx;
    _world.max_col += _dx;
    _world.min_row += _dy;
    _world.max_row += _dy;
}

// 玩家越过接缝线时调用：只挪原点，不动玩家和相机
function Scr_World_ApplySeams(_world, _x, _y) {
    if (_world == undefined || _world.seams == undefined) {
        return;
    }

    var ts = _world.tile_size;
    var col = floor(_x / ts);
    var row = floor(_y / ts);
    var hit = Scr_World_SegmentAt(_world, col, row);
    if (hit == undefined) {
        return;
    }

    for (var i = 0; i < array_length(_world.seams); i++) {
        var seam = _world.seams[i];
        if (seam.segment != hit.seg.id) {
            continue;
        }

        if (seam.axis == "x" && hit.col >= seam.at_local) {
            Scr_World_Rebase(_world, seam.shift, 0);
            return;
        }
        if (seam.axis == "y" && hit.row >= seam.at_local) {
            Scr_World_Rebase(_world, 0, seam.shift);
            return;
        }
    }
}

// ---------- .gmap 单文件容器 ----------
//
// 布局（小端）：
//   4 字节   "GMAP"
//   2 字节   版本号（1）
//   2 字节   条目数
//   每条目：
//     2 字节  名字长度
//     n 字节  名字（UTF-8，只接受 ASCII）
//     4 字节  数据长度
//     m 字节  数据
//
// 不压缩。编辑器与游戏共用这个格式。

function Scr_World_GmapSafeName(_name) {
    if (string_length(_name) == 0 || string_length(_name) > 200) {
        return false;
    }
    if (string_pos("/", _name) > 0 || string_pos("\\", _name) > 0) {
        return false;
    }
    if (string_pos("..", _name) > 0) {
        return false;
    }
    return true;
}

/// 把 _dir 下的 world.json 和各段文件打包成一个 buffer。
/// 失败返回 -1。
function Scr_World_BuildGmap(_dir) {
    var manifest = Scr_World_ReadJson(_dir + "/world.json");
    if (manifest == undefined) {
        Scr_World_Log("gmap export: world.json missing in " + _dir);
        return -1;
    }

    var names = ["world.json"];
    if (variable_struct_exists(manifest, "segments")) {
        for (var i = 0; i < array_length(manifest.segments); i++) {
            var seg = manifest.segments[i];
            if (variable_struct_exists(seg, "file")) {
                array_push(names, seg.file);
            }
        }
    }

    var out = buffer_create(1024, buffer_grow, 1);
    buffer_write(out, buffer_u8, 0x47);
    buffer_write(out, buffer_u8, 0x4D);
    buffer_write(out, buffer_u8, 0x41);
    buffer_write(out, buffer_u8, 0x50);
    buffer_write(out, buffer_u16, 1);
    buffer_write(out, buffer_u16, array_length(names));

    for (var i = 0; i < array_length(names); i++) {
        var name = names[i];
        if (!Scr_World_GmapSafeName(name)) {
            Scr_World_Log("gmap export: unsafe name " + string(name));
            buffer_delete(out);
            return -1;
        }

        var path = _dir + "/" + name;
        if (!file_exists(path)) {
            Scr_World_Log("gmap export: missing " + path);
            buffer_delete(out);
            return -1;
        }

        var data = buffer_load(path);
        if (data < 0) {
            Scr_World_Log("gmap export: cannot read " + path);
            buffer_delete(out);
            return -1;
        }

        var size = buffer_get_size(data);
        buffer_write(out, buffer_u16, string_byte_length(name));
        buffer_write(out, buffer_text, name);
        buffer_write(out, buffer_u32, size);
        buffer_copy(data, 0, size, out, buffer_tell(out));
        buffer_seek(out, buffer_seek_relative, size);
        buffer_delete(data);
    }

    buffer_seek(out, buffer_seek_start, 0);
    return out;
}

function Scr_World_ExportGmap(_dir, _path) {
    var buf = Scr_World_BuildGmap(_dir);
    if (buf < 0) {
        return false;
    }
    buffer_save(buf, _path);
    buffer_delete(buf);
    return true;
}

/// 弹保存对话框，把 _dir 导出成 .gmap。成功返回 true。
function Scr_World_ExportGmapDialog(_dir) {
    var suggested = filename_name(_dir);
    var path = get_save_filename("Gloomyabyss 世界|*.gmap", suggested + ".gmap");
    if (path == "") {
        return false;
    }
    return Scr_World_ExportGmap(_dir, path);
}

/// 把 .gmap 解到 _target_dir。成功返回 true。
function Scr_World_ReadGmap(_path, _target_dir) {
    var buf = buffer_load(_path);
    if (buf < 0) {
        Scr_World_Log("gmap import: cannot read " + _path);
        return false;
    }

    if (buffer_get_size(buf) < 8) {
        buffer_delete(buf);
        return false;
    }

    var m0 = buffer_read(buf, buffer_u8);
    var m1 = buffer_read(buf, buffer_u8);
    var m2 = buffer_read(buf, buffer_u8);
    var m3 = buffer_read(buf, buffer_u8);
    var version = buffer_read(buf, buffer_u16);
    var count = buffer_read(buf, buffer_u16);

    if (m0 != 0x47 || m1 != 0x4D || m2 != 0x41 || m3 != 0x50 || version != 1) {
        Scr_World_Log("gmap import: bad header");
        buffer_delete(buf);
        return false;
    }

    if (!directory_exists(_target_dir)) {
        if (!directory_create(_target_dir)) {
            Scr_World_Log("gmap import: cannot create " + _target_dir);
            buffer_delete(buf);
            return false;
        }
    }

    for (var i = 0; i < count; i++) {
        if (buffer_tell(buf) + 2 > buffer_get_size(buf)) {
            buffer_delete(buf);
            return false;
        }
        var name_len = buffer_read(buf, buffer_u16);
        var name = "";
        for (var c = 0; c < name_len; c++) {
            name += chr(buffer_read(buf, buffer_u8));
        }

        if (buffer_tell(buf) + 4 > buffer_get_size(buf)) {
            buffer_delete(buf);
            return false;
        }
        var size = buffer_read(buf, buffer_u32);

        if (!Scr_World_GmapSafeName(name)) {
            Scr_World_Log("gmap import: unsafe name " + string(name));
            buffer_delete(buf);
            return false;
        }
        if (buffer_tell(buf) + size > buffer_get_size(buf)) {
            Scr_World_Log("gmap import: truncated entry " + name);
            buffer_delete(buf);
            return false;
        }

        var data = buffer_create(size, buffer_fixed, 1);
        buffer_copy(buf, buffer_tell(buf), size, data, 0);
        buffer_seek(buf, buffer_seek_relative, size);
        buffer_save(data, _target_dir + "/" + name);
        buffer_delete(data);
    }

    buffer_delete(buf);
    return true;
}

/// 弹打开对话框，把 .gmap 解到存档目录下的 world/<名字>/。
/// 成功返回 { name, dir }，取消或失败返回 undefined。
function Scr_World_ImportGmapDialog() {
    var path = get_open_filename("Gloomyabyss 世界|*.gmap", "");
    if (path == "") {
        return undefined;
    }

    var base = filename_name(path);
    var dot = string_last_pos(".", base);
    var raw = (dot > 1 ? string_copy(base, 1, dot - 1) : base);

    // 只留字母、数字、下划线、短横线
    var safe = "";
    for (var i = 1; i <= string_length(raw); i++) {
        var c = string_char_at(raw, i);
        var ok = (c >= "a" && c <= "z")
            || (c >= "A" && c <= "Z")
            || (c >= "0" && c <= "9")
            || c == "_" || c == "-";
        if (ok) {
            safe += c;
        }
    }
    if (safe == "") {
        safe = "imported";
    }

    var root = game_save_id;
    if (string_char_at(root, string_length(root)) != "/"
        && string_char_at(root, string_length(root)) != "\\") {
        root += "/";
    }
    root += "world/";
    if (!directory_exists(root)) {
        directory_create(root);
    }

    var dir = root + safe;
    var n = 2;
    while (directory_exists(dir)) {
        dir = root + safe + "_" + string(n);
        n += 1;
    }

    if (!Scr_World_ReadGmap(path, dir)) {
        return undefined;
    }

    return { name: filename_name(dir), dir: dir };
}
