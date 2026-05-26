-- Định nghĩa chuỗi hành động (Tọa độ X, Y tương đối theo góc Top-Left của cửa sổ hiện hành)
local relativeActions = {
    {x = 149, y = 450, delay = 2.5},
    {x = 36,  y = 84,  delay = 1.5},
    {x = 448, y = 426, delay = 3.5},
    {x = 36,  y = 84,  delay = 2.5}
}

local maxLoops = 500  -- Số lần lặp lại tổng cộng theo file plist
local currentLoop = 1
local currentAction = 1
local macroTimer = nil

function runMacroStep()
    if not macroTimer then return end

    -- Lấy thông tin cửa sổ đang active (để tính tọa độ tương đối)
    local win = hs.window.focusedWindow()
    if not win then
        hs.alert.show("Không tìm thấy cửa sổ nào đang active!")
        stopMacro()
        return
    end
    
    local winFrame = win:frame()
    local action = relativeActions[currentAction]
    
    -- Tính toán tọa độ tuyệt đối trên màn hình
    local absoluteX = winFrame.x + action.x
    local absoluteY = winFrame.y + action.y
    
    -- Thực hiện di chuyển chuột và click trái
    hs.mouse.absolutePosition({x = absoluteX, y = absoluteY})
    hs.eventtap.leftClick({x = absoluteX, y = absoluteY})
    
    -- Chuyển sang hành động tiếp theo
    currentAction = currentAction + 1
    
    -- Nếu đã đi hết chuỗi 4 click, tăng số vòng lặp lên
    if currentAction > #relativeActions then
        currentAction = 1
        currentLoop = currentLoop + 1
    end
    
    -- Kiểm tra nếu đã đạt giới hạn 500 lần lặp thì dừng
    if currentLoop > maxLoops then
        hs.alert.show("Đã hoàn thành 500 lần lặp!")
        stopMacro()
        return
    end
    
    -- Đặt thời gian chờ (delay) 3 giây trước khi chạy bước tiếp theo
    macroTimer = hs.timer.doAfter(action.delay, runMacroStep)
end

function stopMacro()
    if macroTimer then
        macroTimer:stop()
        macroTimer = nil
    end
    currentLoop = 1
    currentAction = 1
    hs.alert.show("Đã DỪNG Macro")
end

-- KÍCH HOẠT: Nhấn tổ hợp phím Cmd + L (hoặc phím bạn tự chọn) để Bật/Tắt
hs.hotkey.bind({"cmd"}, "L", function()
    if macroTimer then
        stopMacro()
    else
        currentLoop = 1
        currentAction = 1
        macroTimer = hs.timer.doAfter(0, runMacroStep)
        hs.alert.show("Đã BẮT ĐẦU Macro (Vòng lặp: " .. maxLoops .. ")")
    end
end)