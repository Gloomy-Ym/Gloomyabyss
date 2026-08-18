#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include <imm.h>

#include <atomic>
#include <vector>

#pragma comment(lib, "imm32.lib")

namespace {

constexpr UINT kKeyCount = 256;

std::atomic<bool> g_key_down[kKeyCount];
std::atomic<bool> g_key_pressed[kKeyCount];
std::atomic<bool> g_key_released[kKeyCount];
std::atomic<bool> g_ready{false};
HWND g_window = nullptr;
HANDLE g_thread = nullptr;
ULONGLONG g_last_ime_refresh_ms = 0;

struct ProcessWindowContext {
    DWORD process_id;
    std::vector<HWND> windows;
};

BOOL CALLBACK CollectProcessWindows(HWND hwnd, LPARAM lparam) {
    auto* context = reinterpret_cast<ProcessWindowContext*>(lparam);
    DWORD window_process_id = 0;
    GetWindowThreadProcessId(hwnd, &window_process_id);
    if (window_process_id == context->process_id) {
        context->windows.push_back(hwnd);
    }
    return TRUE;
}

BOOL CALLBACK DisableChildWindowIme(HWND hwnd, LPARAM) {
    ImmAssociateContext(hwnd, nullptr);
    return TRUE;
}

void DisableImeForGameWindows() {
    ImmDisableIME(-1);

    ProcessWindowContext context;
    context.process_id = GetCurrentProcessId();
    EnumWindows(CollectProcessWindows, reinterpret_cast<LPARAM>(&context));

    for (HWND hwnd : context.windows) {
        ImmAssociateContext(hwnd, nullptr);
        EnumChildWindows(hwnd, DisableChildWindowIme, 0);
    }
}

UINT NormalizeVk(USHORT vk, USHORT flags) {
    if ((flags & RI_KEY_E0) != 0) {
        switch (vk) {
            case VK_SHIFT:
                return VK_RSHIFT;
            case VK_CONTROL:
                return VK_RCONTROL;
            case VK_MENU:
                return VK_RMENU;
            default:
                break;
        }
    }
    return vk;
}

void SetKeyState(USHORT vk, bool down) {
    if (vk == 0 || vk >= kKeyCount) {
        return;
    }

    if (down) {
        if (!g_key_down[vk].exchange(true)) {
            g_key_pressed[vk].store(true);
        }
    }
    else {
        if (g_key_down[vk].exchange(false)) {
            g_key_released[vk].store(true);
        }
    }
}

void ProcessKeyboard(const RAWKEYBOARD& keyboard) {
    const USHORT vk = NormalizeVk(keyboard.VKey, keyboard.Flags);
    const bool down = (keyboard.Flags & RI_KEY_BREAK) == 0;
    SetKeyState(vk, down);
}

LRESULT CALLBACK RawInputWindowProc(HWND hwnd, UINT message, WPARAM wparam, LPARAM lparam) {
    if (message == WM_INPUT) {
        UINT size = 0;
        GetRawInputData(
            reinterpret_cast<HRAWINPUT>(lparam),
            RID_INPUT,
            nullptr,
            &size,
            sizeof(RAWINPUTHEADER)
        );

        if (size > 0) {
            std::vector<BYTE> buffer(size);
            const UINT result = GetRawInputData(
                reinterpret_cast<HRAWINPUT>(lparam),
                RID_INPUT,
                buffer.data(),
                &size,
                sizeof(RAWINPUTHEADER)
            );

            if (result == size) {
                const RAWINPUT* raw = reinterpret_cast<const RAWINPUT*>(buffer.data());
                if (raw->header.dwType == RIM_TYPEKEYBOARD) {
                    ProcessKeyboard(raw->data.keyboard);
                }
            }
        }
    }

    return DefWindowProcW(hwnd, message, wparam, lparam);
}

DWORD WINAPI RawInputThreadProc(LPVOID) {
    HMODULE module = GetModuleHandleW(nullptr);
    g_window = CreateWindowExW(
        0,
        L"STATIC",
        L"GloomytaleRawInput",
        0,
        0,
        0,
        0,
        0,
        HWND_MESSAGE,
        nullptr,
        module,
        nullptr
    );

    if (g_window == nullptr) {
        return 0;
    }

    SetWindowLongPtrW(
        g_window,
        GWLP_WNDPROC,
        reinterpret_cast<LONG_PTR>(&RawInputWindowProc)
    );

    RAWINPUTDEVICE device{};
    device.usUsagePage = 0x01;
    device.usUsage = 0x06;
    device.dwFlags = RIDEV_INPUTSINK;
    device.hwndTarget = g_window;

    if (!RegisterRawInputDevices(&device, 1, sizeof(device))) {
        DestroyWindow(g_window);
        g_window = nullptr;
        return 0;
    }

    g_ready.store(true);

    MSG message{};
    while (GetMessageW(&message, nullptr, 0, 0) > 0) {
        TranslateMessage(&message);
        DispatchMessageW(&message);
    }

    g_ready.store(false);
    return 0;
}

bool IsKeyDown(USHORT vk) {
    if (vk == VK_SHIFT) {
        return g_key_down[VK_LSHIFT].load() || g_key_down[VK_RSHIFT].load() || g_key_down[VK_SHIFT].load();
    }
    if (vk == VK_CONTROL) {
        return g_key_down[VK_LCONTROL].load() || g_key_down[VK_RCONTROL].load() || g_key_down[VK_CONTROL].load();
    }
    if (vk == VK_MENU) {
        return g_key_down[VK_LMENU].load() || g_key_down[VK_RMENU].load() || g_key_down[VK_MENU].load();
    }
    return vk < kKeyCount && g_key_down[vk].load();
}

bool IsKeyPressed(USHORT vk) {
    if (vk == VK_SHIFT) {
        return g_key_pressed[VK_LSHIFT].load() || g_key_pressed[VK_RSHIFT].load() || g_key_pressed[VK_SHIFT].load();
    }
    if (vk == VK_CONTROL) {
        return g_key_pressed[VK_LCONTROL].load() || g_key_pressed[VK_RCONTROL].load() || g_key_pressed[VK_CONTROL].load();
    }
    if (vk == VK_MENU) {
        return g_key_pressed[VK_LMENU].load() || g_key_pressed[VK_RMENU].load() || g_key_pressed[VK_MENU].load();
    }
    return vk < kKeyCount && g_key_pressed[vk].load();
}

bool IsKeyReleased(USHORT vk) {
    if (vk == VK_SHIFT) {
        return g_key_released[VK_LSHIFT].load() || g_key_released[VK_RSHIFT].load() || g_key_released[VK_SHIFT].load();
    }
    if (vk == VK_CONTROL) {
        return g_key_released[VK_LCONTROL].load() || g_key_released[VK_RCONTROL].load() || g_key_released[VK_CONTROL].load();
    }
    if (vk == VK_MENU) {
        return g_key_released[VK_LMENU].load() || g_key_released[VK_RMENU].load() || g_key_released[VK_MENU].load();
    }
    return vk < kKeyCount && g_key_released[vk].load();
}

}  // namespace

extern "C" {

__declspec(dllexport) double raw_input_native_init() {
    if (g_ready.load()) {
        return 1.0;
    }
    if (g_thread != nullptr) {
        return 0.0;
    }

    DisableImeForGameWindows();
    g_last_ime_refresh_ms = GetTickCount64();

    for (UINT i = 0; i < kKeyCount; ++i) {
        g_key_down[i].store(false);
        g_key_pressed[i].store(false);
        g_key_released[i].store(false);
    }

    g_thread = CreateThread(nullptr, 0, RawInputThreadProc, nullptr, 0, nullptr);
    if (g_thread == nullptr) {
        return 0.0;
    }

    for (int i = 0; i < 100 && !g_ready.load(); ++i) {
        Sleep(10);
    }

    return g_ready.load() ? 1.0 : 0.0;
}

__declspec(dllexport) double raw_input_native_update() {
    if (!g_ready.load()) {
        return 0.0;
    }

    for (UINT i = 0; i < kKeyCount; ++i) {
        g_key_pressed[i].store(false);
        g_key_released[i].store(false);
    }

    const ULONGLONG now_ms = GetTickCount64();
    if (now_ms - g_last_ime_refresh_ms >= 1000) {
        DisableImeForGameWindows();
        g_last_ime_refresh_ms = now_ms;
    }

    return 1.0;
}

__declspec(dllexport) double raw_input_native_ready() {
    return g_ready.load() ? 1.0 : 0.0;
}

__declspec(dllexport) double raw_input_native_key_down(double key) {
    const int vk = static_cast<int>(key);
    if (vk <= 0 || vk >= static_cast<int>(kKeyCount)) {
        return 0.0;
    }
    return IsKeyDown(static_cast<USHORT>(vk)) ? 1.0 : 0.0;
}

__declspec(dllexport) double raw_input_native_key_pressed(double key) {
    const int vk = static_cast<int>(key);
    if (vk <= 0 || vk >= static_cast<int>(kKeyCount)) {
        return 0.0;
    }
    return IsKeyPressed(static_cast<USHORT>(vk)) ? 1.0 : 0.0;
}

__declspec(dllexport) double raw_input_native_key_released(double key) {
    const int vk = static_cast<int>(key);
    if (vk <= 0 || vk >= static_cast<int>(kKeyCount)) {
        return 0.0;
    }
    return IsKeyReleased(static_cast<USHORT>(vk)) ? 1.0 : 0.0;
}

__declspec(dllexport) double raw_input_native_cleanup() {
    if (g_window != nullptr) {
        PostMessageW(g_window, WM_QUIT, 0, 0);
    }
    if (g_thread != nullptr) {
        WaitForSingleObject(g_thread, 1000);
        CloseHandle(g_thread);
        g_thread = nullptr;
    }
    g_window = nullptr;
    g_ready.store(false);
    return 1.0;
}

}  // extern "C"
