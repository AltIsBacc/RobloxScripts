local MacroUtils = require("./macroutil") or loadstring(game:HttpGet("https://raw.githubusercontent.com/AltIsBacc/roblox-scripts/master/macroutil.luau"))()
local MakeDraggable = loadstring(game:HttpGet("https://raw.githubusercontent.com/ThatMG393/roblox-scripts/master/Utils/MakeDraggable.luau"))()
local Players = game:GetService("Players")
local ThreadLib = require("./threadlib") or loadstring(game:HttpGet("https://raw.githubusercontent.com/AltIsBacc/roblox-scripts/master/threadlib.luau"))()
local VPSheetParser = require("./vpsheetparser") or loadstring(game:HttpGet("https://raw.githubusercontent.com/AltIsBacc/roblox-scripts/master/vpsheetparser.luau"))()

local temp = Players.LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("VirtualPianoPlayer")
if temp then temp:Destroy() end

-- Create GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "VirtualPianoPlayer"
screenGui.ResetOnSpawn = false
screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 400, 0, 300)
mainFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
mainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = mainFrame

-- Title bar for dragging
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 30)
titleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 8)
titleCorner.Parent = titleBar

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -10, 1, 0)
title.Position = UDim2.new(0, 10, 0, 0)
title.BackgroundTransparency = 1
title.Text = "Virtual Piano Player"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.Parent = titleBar

-- Transposition label
local transposeLabel = Instance.new("TextLabel")
transposeLabel.Size = UDim2.new(0, 100, 0, 20)
transposeLabel.Position = UDim2.new(0, 10, 0, 40)
transposeLabel.BackgroundTransparency = 1
transposeLabel.Text = "Transpose:"
transposeLabel.TextColor3 = Color3.new(1, 1, 1)
transposeLabel.TextXAlignment = Enum.TextXAlignment.Left
transposeLabel.Font = Enum.Font.Gotham
transposeLabel.TextSize = 12
transposeLabel.Parent = mainFrame

-- Transposition textbox
local transposeBox = Instance.new("TextBox")
transposeBox.Size = UDim2.new(0, 60, 0, 25)
transposeBox.Position = UDim2.new(0, 110, 0, 38)
transposeBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
transposeBox.BorderSizePixel = 0
transposeBox.Text = "0"
transposeBox.TextColor3 = Color3.new(1, 1, 1)
transposeBox.Font = Enum.Font.Gotham
transposeBox.TextSize = 12
transposeBox.PlaceholderText = "0"
transposeBox.Parent = mainFrame

local transposeCorner = Instance.new("UICorner")
transposeCorner.CornerRadius = UDim.new(0, 4)
transposeCorner.Parent = transposeBox

-- Sheet music label
local sheetLabel = Instance.new("TextLabel")
sheetLabel.Size = UDim2.new(0, 100, 0, 20)
sheetLabel.Position = UDim2.new(0, 10, 0, 75)
sheetLabel.BackgroundTransparency = 1
sheetLabel.Text = "Sheet Music:"
sheetLabel.TextColor3 = Color3.new(1, 1, 1)
sheetLabel.TextXAlignment = Enum.TextXAlignment.Left
sheetLabel.Font = Enum.Font.Gotham
sheetLabel.TextSize = 12
sheetLabel.Parent = mainFrame

-- Sheet music textbox
local sheetBox = Instance.new("TextBox")
sheetBox.Size = UDim2.new(1, -20, 0, 120)
sheetBox.Position = UDim2.new(0, 10, 0, 100)
sheetBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
sheetBox.BorderSizePixel = 0
sheetBox.Text = ""
sheetBox.TextColor3 = Color3.new(1, 1, 1)
sheetBox.Font = Enum.Font.Code
sheetBox.TextSize = 10
sheetBox.TextWrapped = true
sheetBox.TextXAlignment = Enum.TextXAlignment.Left
sheetBox.TextYAlignment = Enum.TextYAlignment.Top
sheetBox.ClearTextOnFocus = false
sheetBox.MultiLine = true
sheetBox.PlaceholderText = "Paste sheet music here..."
sheetBox.Parent = mainFrame

local sheetCorner = Instance.new("UICorner")
sheetCorner.CornerRadius = UDim.new(0, 4)
sheetCorner.Parent = sheetBox

-- Play button
local playButton = Instance.new("TextButton")
playButton.Size = UDim2.new(0, 120, 0, 35)
playButton.Position = UDim2.new(0, 10, 0, 255)
playButton.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
playButton.BorderSizePixel = 0
playButton.Text = "Play"
playButton.TextColor3 = Color3.new(1, 1, 1)
playButton.Font = Enum.Font.GothamBold
playButton.TextSize = 14
playButton.Parent = mainFrame

local playCorner = Instance.new("UICorner")
playCorner.CornerRadius = UDim.new(0, 6)
playCorner.Parent = playButton

-- Stop button
local stopButton = Instance.new("TextButton")
stopButton.Size = UDim2.new(0, 120, 0, 35)
stopButton.Position = UDim2.new(0, 140, 0, 255)
stopButton.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
stopButton.BorderSizePixel = 0
stopButton.Text = "Stop"
stopButton.TextColor3 = Color3.new(1, 1, 1)
stopButton.Font = Enum.Font.GothamBold
stopButton.TextSize = 14
stopButton.Parent = mainFrame

local stopCorner = Instance.new("UICorner")
stopCorner.CornerRadius = UDim.new(0, 6)
stopCorner.Parent = stopButton

-- Close button
local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -30, 0, 0)
closeButton.BackgroundTransparency = 1
closeButton.Text = "X"
closeButton.TextColor3 = Color3.new(1, 1, 1)
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = 16
closeButton.Parent = titleBar

MakeDraggable:MakeDraggableFromWithAnim(0.10, titleBar, mainFrame)

-- Royale High Castle 2 specific
local function setTransposition(value)
    local success, sliderScript = pcall(function()
        return Players.LocalPlayer.PlayerGui.PianoGUI.Frame.Transposition.SliderScript
    end)
    
    if success and sliderScript then
        sliderScript.OnChanged:Fire(value)
        sliderScript.Parent.Control.MiniText.Text = tostring(value)
    else
        warn("Could not find PianoGUI transposition slider!")
    end
end

local NOTE_DELAY = 0.05
local CHORD_HOLD = 0.08
local REST_DURATION = 0.1

local function playSheet(sheet)
    local parsedSheet = VPSheetParser:parse(sheet)

    for _, step in ipairs(parsedSheet) do
        if #step == 0 then
            task.wait(REST_DURATION)
            continue
        end

        if #step == 1 then
            MacroUtils:triggerKey({ key = step[1], triggerTime = NOTE_DELAY })
            continue
        end

        MacroUtils:triggerKeysSync(step, CHORD_HOLD)
    end
end

local isPlaying = false
local sheetPlayTask = ThreadLib.NewThread(function(sheet) playSheet(sheet) end)

-- Button handlers
playButton.MouseButton1Click:Connect(function()
    if isPlaying then
        return
    end
    
    local sheet = sheetBox.Text
    if sheet == "" then
        warn("No sheet music provided!")
        return
    end
    
    local transpose = tonumber(transposeBox.Text) or 0
    setTransposition(transpose)
    
    isPlaying = true
    playButton.Text = "Playing..."
    sheetPlayTask:Start(sheet)
end)

stopButton.MouseButton1Click:Connect(function()
    isPlaying = false
    playButton.Text = "Play"
    sheetPlayTask:Stop()
end)

closeButton.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

print("Virtual Piano Player loaded!")