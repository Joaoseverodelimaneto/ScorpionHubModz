--===[ SERVIÇOS ]===--
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local lp = Players.LocalPlayer
local camera = workspace.CurrentCamera

--===[ VARIÁVEIS DE ESTADO ]===--
local AimbotOn = false
local ESPLineOn = true
local ESPBoxOn = false
local CamuflagemOn = false
local currentTarget = nil
local espColor = Color3.fromRGB(0, 255, 0)

--===[ FUNÇÕES AUXILIARES ]===--
local function isEnemy(plr)
    return plr ~= lp and plr.Team ~= lp.Team and plr.Character and plr.Character:FindFirstChild("Head")
end

local function getClosestEnemy()
    local closest, shortest = nil, math.huge
    for _, plr in pairs(Players:GetPlayers()) do
        if isEnemy(plr) then
            local pos, visible = camera:WorldToViewportPoint(plr.Character.Head.Position)
            local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
            local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
            if dist < shortest then
                shortest = dist
                closest = plr
            end
        end
    end
    return closest
end

local function updateTarget()
    currentTarget = getClosestEnemy()
end

local function lockCameraToTarget()
    if currentTarget and isEnemy(currentTarget) then
        local head = currentTarget.Character.Head
        local screenPos = camera:WorldToViewportPoint(head.Position)
        local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
        local offset = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude

        if offset > 100 then
            updateTarget()
            if not currentTarget then return end
        end

        camera.CFrame = CFrame.new(camera.CFrame.Position, currentTarget.Character.Head.Position)
    end
end

--===[ ESP LINE ]===--
local espLines = {}
local function clearESPLine()
    for _, v in pairs(espLines) do v:Remove() end
    espLines = {}
end

local function createESPLine()
    clearESPLine()
    for _, plr in pairs(Players:GetPlayers()) do
        if isEnemy(plr) then
            local line = Drawing.new("Line")
            line.Thickness = 2
            line.Transparency = 1
            espLines[plr] = line
        end
    end
end

local function updateESPLine()
    if not ESPLineOn then clearESPLine() return end
    local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    for plr, line in pairs(espLines) do
        if isEnemy(plr) then
            local pos, visible = camera:WorldToViewportPoint(plr.Character.Head.Position)
            line.Visible = visible
            line.Color = espColor
            if visible then
                line.From = center
                line.To = Vector2.new(pos.X, pos.Y)
            end
        else
            line.Visible = false
        end
    end
end

--===[ ESP BOX ]===--
local espBoxes = {}
local function clearESPBox()
    for _, v in pairs(espBoxes) do v:Remove() end
    espBoxes = {}
end

local function createESPBox()
    clearESPBox()
    for _, plr in pairs(Players:GetPlayers()) do
        if isEnemy(plr) then
            local box = Drawing.new("Square")
            box.Thickness = 2
            box.Transparency = 1
            box.Color = Color3.fromRGB(0, 255, 0)
            box.Filled = false
            espBoxes[plr] = box
        end
    end
end

local function updateESPBox()
    if not ESPBoxOn then clearESPBox() return end
    for plr, box in pairs(espBoxes) do
        if isEnemy(plr) then
            local char = plr.Character
            local head = char:FindFirstChild("Head")
            local root = char:FindFirstChild("HumanoidRootPart")
            if head and root then
                local headPos = camera:WorldToViewportPoint(head.Position)
                local rootPos = camera:WorldToViewportPoint(root.Position)
                local height = math.abs(rootPos.Y - headPos.Y)
                local width = height / 2
                box.Position = Vector2.new(headPos.X - width / 2, headPos.Y)
                box.Size = Vector2.new(width, height)
                box.Visible = true
            end
        else
            box.Visible = false
        end
    end
end

--===[ CAMUFLAGEM ]===--
local function setCamouflage(state)
    if lp.Character then
        for _, part in pairs(lp.Character:GetChildren()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.Transparency = state and 0.7 or 0
            end
        end
    end
end

--===[ GUI ]===--
local gui = Instance.new("ScreenGui", game.CoreGui)
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 270, 0, 310)
frame.Position = UDim2.new(0.5, -135, 0.5, -155)
frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
frame.Active = true
frame.Draggable = true

local function neonColor(btn)
    coroutine.wrap(function()
        while btn.Parent do
            btn.TextColor3 = Color3.fromHSV(tick() % 5 / 5, 1, 1)
            RunService.RenderStepped:Wait()
        end
    end)()
end

local function createToggle(text, y, callback, initial)
    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(0, 240, 0, 40)
    btn.Position = UDim2.new(0, 15, 0, y)
    btn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 18
    btn.Text = text .. (initial and " [ON]" or " [OFF]")
    neonColor(btn)
    local state = initial
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = text .. (state and " [ON]" or " [OFF]")
        callback(state)
    end)
end

createToggle("Aimbot Android", 20, function(v) AimbotOn = v if v then updateTarget() end end, false)
createToggle("ESP Line", 70, function(v) ESPLineOn = v if v then createESPLine() else clearESPLine() end end, true)
createToggle("ESP Box", 120, function(v) ESPBoxOn = v if v then createESPBox() else clearESPBox() end end, false)
createToggle("Camuflagem", 170, function(v) CamuflagemOn = v setCamouflage(v) end, false)

--===[ COR DO ESP ]===--
local colorBtn = Instance.new("TextButton", frame)
colorBtn.Size = UDim2.new(0, 240, 0, 40)
colorBtn.Position = UDim2.new(0, 15, 0, 220)
colorBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
colorBtn.Font = Enum.Font.GothamBold
colorBtn.TextSize = 18
neonColor(colorBtn)

local colors = {
    Color3.fromRGB(0, 255, 0),
    Color3.fromRGB(255, 0, 0),
    Color3.fromRGB(0, 170, 255),
    Color3.fromRGB(170, 0, 255),
    Color3.fromRGB(255, 255, 0),
    "random"
}
local colorNames = {"Verde", "Vermelho", "Azul", "Roxo", "Amarelo", "Aleatória"}
local colorIndex = 1
colorBtn.Text = "Cor ESP: " .. colorNames[colorIndex]

colorBtn.MouseButton1Click:Connect(function()
    colorIndex += 1
    if colorIndex > #colors then colorIndex = 1 end
    espColor = colors[colorIndex] == "random" and Color3.fromHSV(math.random(), 1, 1) or colors[colorIndex]
    colorBtn.Text = "Cor ESP: " .. colorNames[colorIndex]
end)

--===[ BOTÃO MINIMIZAR ]===--
local toggleBtn = Instance.new("TextButton", gui)
toggleBtn.Size = UDim2.new(0, 40, 0, 40)
toggleBtn.Position = UDim2.new(0, 10, 0, 10)
toggleBtn.Text = "☰"
toggleBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
toggleBtn.TextSize = 28
toggleBtn.Font = Enum.Font.GothamBlack
neonColor(toggleBtn)

toggleBtn.MouseButton1Click:Connect(function()
    frame.Visible = not frame.Visible
    toggleBtn.Text = frame.Visible and "☰" or "▶"
end)

--===[ LOOP ]===--
RunService.RenderStepped:Connect(function()
    if AimbotOn then
        if not currentTarget or not isEnemy(currentTarget) then updateTarget() end
        lockCameraToTarget()
    end
    if ESPLineOn then updateESPLine() end
    if ESPBoxOn then updateESPBox() end
end)

--===[ COMANDO LOCAL ]===--
lp.Chatted:Connect(function(msg)
    if msg:lower() == "/menu" then
        frame.Visible = not frame.Visible
    end
end)

createESPLine()
createESPBox()
