local MacroUtils = --[[ require("./macroutil") or ]] loadstring(game:HttpGet("https://raw.githubusercontent.com/AltIsBacc/RobloxScripts/master/macroutil.luau"))()
local MakeDraggable = loadstring(game:HttpGet("https://raw.githubusercontent.com/ThatMG393/roblox-scripts/master/Utils/MakeDraggable.luau"))()
local MGUI = --[[ require("./mgui") or ]] loadstring(game:HttpGet("https://raw.githubusercontent.com/AltIsBacc/RobloxScripts/master/mgui.luau"))()
local MatchmakingService = game:GetService("MatchmakingService")
local Players = game:GetService("Players")
local ThreadLib = --[[ require("./threadlib") or ]] loadstring(game:HttpGet("https://raw.githubusercontent.com/AltIsBacc/RobloxScripts/master/threadlib.luau"))()
local VPSheetParser = --[[ require("./vpsheetparser") or ]] loadstring(game:HttpGet("https://raw.githubusercontent.com/AltIsBacc/RobloxScripts/master/vpsheetparser.luau"))()

-- Royale High Campus 2 specific
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

local NOTE_HOLD = 0.2
local CHORD_HOLD = 0.3
local REST_DURATION = 0.08

local function playSheet(sheet)
    local parsedSheet = VPSheetParser:parse(sheet)

    for _, step in ipairs(parsedSheet) do
        if #step == 0 then
            task.wait(REST_DURATION)
            continue
        end

        if #step == 1 then
            MacroUtils:triggerKey({ key = step[1], triggerTime = NOTE_HOLD })
            continue
        end

        MacroUtils:triggerKeysSync(step, CHORD_HOLD)
    end
end

local isPlaying = false
local sheetPlayTask = ThreadLib.new(function(sheet) playSheet(sheet) end)


-- UI BEGIN
local winOpt = MGUI.DefaultWindowOptions
winOpt.WindowTitle = "Auto Piano Player"
winOpt.WindowSize = { X = 400, Y = 300 }
winOpt.ResetOnSpawn = false

local mainWindow = MGUI.CreateWindow(winOpt)

mainWindow.RootUI.Destroying:Connect(function()
    sheetPlayTask:Stop()
end)

local mainSection = mainWindow:CreateSection("Main")

local transposeBox = mainSection:CreateInputField("Transpose", "0", 0)
transposeBox:RegisterOnPropertyChangeSignal("Text", function()
    local success, result = pcall(function()
        return tonumber(transposeBox.Text)
    end)

    if success then setTransposition(result) end
end)

local sheetBox = mainSection:CreateInputField("SheetBox", "[abc]", "")

local controlSection = mainWindow:CreateSection("Controls")
local playButton = controlSection:CreateButton("Play", function(self)
    if isPlaying then return end
    
    isPlaying = true
    self.UI.Text = "Playing..."
    sheetPlayTask:Start(sheetBox.Text)
end)

playButton:SetDisabled(true) -- safely disabled as sheetbox is empty by default

local stopButton = controlSection:CreateButton("Stop", function(self)
    isPlaying = false
    playButton.UI.Text = "Play"
    sheetPlayTask:Stop()
end)

sheetBox:RegisterOnPropertyChangeSignal("Text", function()
    playButton:SetDisabled(sheetBox:GetText() == "")
end)


sheetPlayTask:OnFinishCallback(function()
    isPlaying = false
    playButton.UI.Text("Play")
end)

mainWindow:Notify("Auto Piano Player loaded!")
