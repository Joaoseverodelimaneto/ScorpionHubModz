--===[ LOGIN GUI ]===--
local Players = game:GetService("Players")
local lp = Players.LocalPlayer

local function createLoginGUI()
    local gui = Instance.new("ScreenGui", game.CoreGui)
    gui.Name = "LoginSystem"

    local frame = Instance.new("Frame", gui)
    frame.Size = UDim2.new(0, 300, 0, 180)
    frame.Position = UDim2.new(0.5, -150, 0.5, -90)
    frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
    frame.BorderSizePixel = 0

    local title = Instance.new("TextLabel", frame)
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Text = "Login"
    title.TextColor3 = Color3.new(1,1,1)
    title.BackgroundColor3 = Color3.fromRGB(40,40,40)
    title.Font = Enum.Font.SourceSansBold
    title.TextSize = 24

    local userBox = Instance.new("TextBox", frame)
    userBox.Size = UDim2.new(0, 260, 0, 30)
    userBox.Position = UDim2.new(0, 20, 0, 50)
    userBox.PlaceholderText = "Usuário"
    userBox.Text = ""
    userBox.BackgroundColor3 = Color3.fromRGB(50,50,50)
    userBox.TextColor3 = Color3.new(1,1,1)
    userBox.Font = Enum.Font.SourceSans
    userBox.TextSize = 18

    local passBox = Instance.new("TextBox", frame)
    passBox.Size = UDim2.new(0, 260, 0, 30)
    passBox.Position = UDim2.new(0, 20, 0, 90)
    passBox.PlaceholderText = "Senha"
    passBox.Text = ""
    passBox.BackgroundColor3 = Color3.fromRGB(50,50,50)
    passBox.TextColor3 = Color3.new(1,1,1)
    passBox.Font = Enum.Font.SourceSans
    passBox.TextSize = 18

    local msg = Instance.new("TextLabel", frame)
    msg.Size = UDim2.new(1, 0, 0, 20)
    msg.Position = UDim2.new(0, 0, 1, 0)
    msg.Text = ""
    msg.TextColor3 = Color3.fromRGB(0, 255, 0)
    msg.BackgroundTransparency = 1
    msg.Font = Enum.Font.SourceSans
    msg.TextSize = 18

    local loginBtn = Instance.new("TextButton", frame)
    loginBtn.Size = UDim2.new(0, 260, 0, 35)
    loginBtn.Position = UDim2.new(0, 20, 0, 130)
    loginBtn.Text = "Logar"
    loginBtn.TextColor3 = Color3.new(1,1,1)
    loginBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    loginBtn.Font = Enum.Font.SourceSansBold
    loginBtn.TextSize = 22

    loginBtn.MouseButton1Click:Connect(function()
        if userBox.Text == "SCORPION MODZ" and passBox.Text == "V1" then
            msg.Text = "Logado com sucesso!"
            wait(1)
            gui:Destroy()
            setupMainMenu()
        else
            msg.Text = "Usuário ou senha incorretos!"
            msg.TextColor3 = Color3.fromRGB(255, 0, 0)
            wait(2)
            msg.Text = ""
            msg.TextColor3 = Color3.fromRGB(0, 255, 0)
        end
    end)
end

--===[ FUNÇÕES PRINCIPAIS ]===--
local AimbotOn = false
local SilentAimOn = false
local ESPLineOn = true
local currentTarget = nil

local function getClosestEnemy()
    local closest, dist = nil, math.huge
    for _, plr in pairs(game.Players:GetPlayers()) do
        if plr ~= lp and plr.Team ~= lp.Team and plr.Character and plr.Character:FindFirstChild("Head") then
            local head = plr.Character.Head.Position
            local mag = (lp.Character.Head.Position - head).Magnitude
            if mag < dist then
                dist = mag
                closest = plr
            end
        end
    end
    return closest
end

local function updateTarget()
    local newTarget = getClosestEnemy()
    if newTarget then currentTarget = newTarget end
end

local function createESPLine()
    for _,v in pairs(workspace:GetChildren()) do
        if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("Head") then
            if v:FindFirstChildOfClass("Humanoid").Health > 0 then
                if v ~= lp.Character and Players:GetPlayerFromCharacter(v) and Players:GetPlayerFromCharacter(v).Team ~= lp.Team then
                    local line = Drawing.new("Line")
                    line.Color = Color3.new(1,0,0)
                    line.Thickness = 1
                    line.Transparency = 1
                    line.ZIndex = 2

                    coroutine.wrap(function()
                        while ESPLineOn and v and v:FindFirstChild("Head") and lp.Character and lp:FindFirstChild("Head") do
                            local pos1, onScreen1 = workspace.CurrentCamera:WorldToViewportPoint(lp.Character.Head.Position)
                            local pos2, onScreen2 = workspace.CurrentCamera:WorldToViewportPoint(v.Head.Position)
                            if onScreen1 and onScreen2 then
                                line.Visible = true
                                line.From = Vector2.new(pos1.X, pos1.Y)
                                line.To = Vector2.new(pos2.X, pos2.Y)
                            else
                                line.Visible = false
                            end
                            wait()
                        end
                        line:Remove()
                    end)()
                end
            end
        end
    end
end

--===[ INTERFACE MENU ]===--
function setupMainMenu()
    -- Cria GUI
    local gui = Instance.new("ScreenGui", game.CoreGui)
    gui.Name = "MainMenu"

    local frame = Instance.new("Frame", gui)
    frame.Size = UDim2.new(0, 250, 0, 200)
    frame.Position = UDim2.new(0, 100, 0, 100)
    frame.BackgroundColor3 = Color3.fromRGB(40,40,40)
    frame.Draggable = true
    frame.Active = true

    local closeBtn = Instance.new("TextButton", frame)
    closeBtn.Size = UDim2.new(0, 25, 0, 25)
    closeBtn.Position = UDim2.new(1, -30, 0, 5)
    closeBtn.Text = "-"
    closeBtn.TextColor3 = Color3.new(1,1,1)
    closeBtn.BackgroundColor3 = Color3.fromRGB(100,0,0)
    closeBtn.MouseButton1Click:Connect(function()
        frame.Visible = not frame.Visible
    end)

    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, -10, 0, 25)
    label.Position = UDim2.new(0, 5, 0, 5)
    label.Text = "SCORPION MODZ Menu"
    label.TextColor3 = Color3.new(1,1,1)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.SourceSansBold
    label.TextSize = 18

    -- Toggle Aimbot
    local aimbotToggle = Instance.new("TextButton", frame)
    aimbotToggle.Size = UDim2.new(0, 220, 0, 30)
    aimbotToggle.Position = UDim2.new(0, 15, 0, 40)
    aimbotToggle.Text = "Aimbot [OFF]"
    aimbotToggle.TextColor3 = Color3.new(1,1,1)
    aimbotToggle.BackgroundColor3 = Color3.fromRGB(60,60,60)
    aimbotToggle.MouseButton1Click:Connect(function()
        AimbotOn = not AimbotOn
        aimbotToggle.Text = AimbotOn and "Aimbot [ON]" or "Aimbot [OFF]"
        if AimbotOn then updateTarget() end
    end)

    -- Toggle Silent Aim
    local silentToggle = Instance.new("TextButton", frame)
    silentToggle.Size = UDim2.new(0, 220, 0, 30)
    silentToggle.Position = UDim2.new(0, 15, 0, 80)
    silentToggle.Text = "Silent Aim [OFF]"
    silentToggle.TextColor3 = Color3.new(1,1,1)
    silentToggle.BackgroundColor3 = Color3.fromRGB(60,60,60)
    silentToggle.MouseButton1Click:Connect(function()
        SilentAimOn = not SilentAimOn
        silentToggle.Text = SilentAimOn and "Silent Aim [ON]" or "Silent Aim [OFF]"
    end)

    -- Toggle ESP
    local espToggle = Instance.new("TextButton", frame)
    espToggle.Size = UDim2.new(0, 220, 0, 30)
    espToggle.Position = UDim2.new(0, 15, 0, 120)
    espToggle.Text = "ESP Line [ON]"
    espToggle.TextColor3 = Color3.new(1,1,1)
    espToggle.BackgroundColor3 = Color3.fromRGB(60,60,60)
    espToggle.MouseButton1Click:Connect(function()
        ESPLineOn = not ESPLineOn
        espToggle.Text = ESPLineOn and "ESP Line [ON]" or "ESP Line [OFF]"
        if ESPLineOn then createESPLine() end
    end)

    -- X key para mudar alvo
    game:GetService("UserInputService").InputBegan:Connect(function(input, processed)
        if input.KeyCode == Enum.KeyCode.X and AimbotOn then
            updateTarget()
        end
    end)

    -- ESP inicial ativado
    createESPLine()
end

-- INICIAR LOGIN
createLoginGUI()
