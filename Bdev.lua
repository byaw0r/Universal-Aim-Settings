local plr = game.Players.LocalPlayer
local ws = workspace
local cam = ws.CurrentCamera
local rs = game:GetService("RunService")
local uis = game:GetService("UserInputService")

local gui = Instance.new("ScreenGui")
gui.Name = "BYWMenu"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = plr.PlayerGui

local fovCircle = Instance.new("Frame")
fovCircle.Name = "FOVCircle"
fovCircle.BackgroundTransparency = 1
fovCircle.BorderSizePixel = 0
fovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
fovCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
fovCircle.Size = UDim2.new(0, 900, 0, 900)
fovCircle.Visible = false
fovCircle.Parent = gui

local circleUI = Instance.new("UICorner")
circleUI.CornerRadius = UDim.new(1, 0)
circleUI.Parent = fovCircle

local circleStroke = Instance.new("UIStroke")
circleStroke.Color = Color3.fromRGB(255, 255, 255)
circleStroke.Thickness = 3
circleStroke.LineJoinMode = Enum.LineJoinMode.Round
circleStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
circleStroke.Parent = fovCircle

local btn = Instance.new("TextButton")
btn.Size = UDim2.new(0, 60, 0, 60)
btn.Position = UDim2.new(0, 50, 0, 50)
btn.BackgroundColor3 = Color3.new(0, 0, 0)
btn.TextColor3 = Color3.new(1, 1, 1)
btn.Text = "B"
btn.Font = Enum.Font.SourceSansBold
btn.TextSize = 32
btn.BorderSizePixel = 0
btn.Parent = gui

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 16)
btnCorner.Parent = btn

local menu = Instance.new("Frame")
menu.Size = UDim2.new(0, 280, 0, 270)
menu.BackgroundColor3 = Color3.new(0, 0, 0)
menu.BorderSizePixel = 0
menu.Visible = false
menu.Parent = gui

local menuCorner = Instance.new("UICorner")
menuCorner.CornerRadius = UDim.new(0, 16)
menuCorner.Parent = menu

local aim = false
local esp = false
local wall = false
local fovSize = 50

local highlights = {}

local function canSee(pos1, pos2)
    local ray = Ray.new(pos1, pos2 - pos1)
    local part, hit = ws:FindPartOnRayWithIgnoreList(ray, {plr.Character})
    return (hit - pos1).Magnitude >= (pos2 - pos1).Magnitude - 2
end

local function makeToggle(name, y, def, callback)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, 260, 0, 45)
    b.Position = UDim2.new(0, 10, 0, y)
    b.BackgroundColor3 = def and Color3.new(0.2, 0.2, 0.2) or Color3.new(0.1, 0.1, 0.1)
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Text = name .. ": " .. (def and "ON" or "OFF")
    b.Font = Enum.Font.SourceSansBold
    b.TextSize = 20
    b.BorderSizePixel = 0
    b.Parent = menu

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 10)
    c.Parent = b

    b.MouseButton1Click:Connect(function()
        def = not def
        b.BackgroundColor3 = def and Color3.new(0.2, 0.2, 0.2) or Color3.new(0.1, 0.1, 0.1)
        b.Text = name .. ": " .. (def and "ON" or "OFF")
        if callback then callback(def) end
    end)
    return b
end

local label = Instance.new("TextLabel")
label.Size = UDim2.new(0, 260, 0, 25)
label.Position = UDim2.new(0, 10, 0, 175)
label.Text = "FOV: " .. math.floor(fovSize)
label.TextColor3 = Color3.new(1, 1, 1)
label.BackgroundTransparency = 1
label.Font = Enum.Font.SourceSansBold
label.TextSize = 20
label.Parent = menu

local box = Instance.new("TextBox")
box.Size = UDim2.new(0, 260, 0, 40)
box.Position = UDim2.new(0, 10, 0, 203)
box.Text = tostring(math.floor(fovSize))
box.BackgroundColor3 = Color3.new(0.15, 0.15, 0.15)
box.TextColor3 = Color3.new(1, 1, 1)
box.Font = Enum.Font.SourceSansBold
box.TextSize = 20
box.ClearTextOnFocus = false
box.Parent = menu

local boxCorner = Instance.new("UICorner")
boxCorner.CornerRadius = UDim.new(0, 10)
boxCorner.Parent = box

box.FocusLost:Connect(function()
    local v = tonumber(box.Text)
    if v then
        fovSize = math.clamp(v, 50, 300)
        label.Text = "FOV: " .. math.floor(fovSize)
        box.Text = tostring(math.floor(fovSize))
    else
        box.Text = tostring(math.floor(fovSize))
    end
end)

makeToggle("Aimbot", 10, aim, function(v) aim = v end)
makeToggle("ESP", 65, esp, function(v) esp = v end)
makeToggle("WallCheck", 120, wall, function(v) wall = v end)

local dragging = false
local dragStart
local startPos

btn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = btn.Position
        uis.MouseIconEnabled = false
    end
end)

btn.InputEnded:Connect(function(input)
    if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and dragging then
        dragging = false
        uis.MouseIconEnabled = true
    end
end)

uis.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        btn.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )

        if menu.Visible then
            local absX = btn.AbsolutePosition.X
            local screenW = cam.ViewportSize.X
            local menuW = menu.AbsoluteSize.X

            if absX < screenW / 2 then
                menu.Position = UDim2.new(0, btn.AbsolutePosition.X + 65, 0, btn.AbsolutePosition.Y)
            else
                menu.Position = UDim2.new(0, btn.AbsolutePosition.X - menuW - 5, 0, btn.AbsolutePosition.Y)
            end
        end
    end
end)

btn.MouseButton1Click:Connect(function()
    menu.Visible = not menu.Visible
    if menu.Visible then
        local absX = btn.AbsolutePosition.X
        local screenW = cam.ViewportSize.X
        local menuW = menu.AbsoluteSize.X
        if absX < screenW / 2 then
            menu.Position = UDim2.new(0, btn.AbsolutePosition.X + 65, 0, btn.AbsolutePosition.Y)
        else
            menu.Position = UDim2.new(0, btn.AbsolutePosition.X - menuW - 5, 0, btn.AbsolutePosition.Y)
        end
    end
end)

rs.RenderStepped:Connect(function()
    if esp then
        for _, p in ipairs(game.Players:GetPlayers()) do
            if p ~= plr and p.Character then
                if not highlights[p] then
                    local h = Instance.new("Highlight")
                    h.FillColor = Color3.new(1, 0, 0)
                    h.FillTransparency = 0.7
                    h.OutlineColor = Color3.new(1, 1, 1)
                    h.OutlineTransparency = 0.2
                    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    h.Parent = p.Character
                    highlights[p] = h

                    p.CharacterAdded:Connect(function()
                        if highlights[p] then
                            highlights[p]:Destroy()
                            highlights[p] = nil
                        end
                    end)
                end
            end
        end

        for p, h in pairs(highlights) do
            if not p or not p.Character or not h.Parent then
                if h then h:Destroy() end
                highlights[p] = nil
            end
        end
    else
        for _, h in pairs(highlights) do
            if h then h:Destroy() end
        end
        highlights = {}
    end

    if aim and plr.Character then
        local camPos = cam.CFrame.Position
        local center = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
        local best = nil
        local bestDist = math.huge

        for _, p in ipairs(game.Players:GetPlayers()) do
            if p ~= plr and p.Character then
                local head = p.Character:FindFirstChild("Head")
                if head then
                    local scr, onScreen = cam:WorldToViewportPoint(head.Position)
                    if onScreen and scr.Z > 0 then
                        local dist2d = (Vector2.new(scr.X, scr.Y) - center).Magnitude
                        if dist2d <= fovSize then
                            local ok = true
                            if wall then ok = canSee(camPos, head.Position) end
                            if ok and dist2d < bestDist then
                                bestDist = dist2d
                                best = head.Position
                            end
                        end
                    end
                end
            end
        end

        if best then
            cam.CFrame = CFrame.lookAt(camPos, best)
        end
    end

    local circleSize = fovSize * 2
    fovCircle.Size = UDim2.new(0, circleSize, 0, circleSize)
    fovCircle.Visible = aim
    
    local offsetY = -27
    fovCircle.Position = UDim2.new(0.5, 0, 0.5, offsetY)
end)
print("Bdev Script loaded!")
