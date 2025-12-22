--!strict
local M = {}
M.__index = M

export type AnimationUtilConfig = {
    owner: Player,
    speed: number,
    looped: boolean?,
    r6AnimId: string,
    r15AnimId: string,
    onError: ((cause: string) -> ())?,
    onStatusChange: ((status: string) -> ())?,
}

type AnimationUtilData = {
    new: (config: AnimationUtilConfig) -> AnimationUtil,
    Start: (self: AnimationUtil) -> (),
    Stop: (self: AnimationUtil) -> (),
    FollowPlayer: (self: AnimationUtil, target: string | Player, offset: CFrame, followDelay: number?) -> thread?,
    UpdateConfig: (self: AnimationUtil, newConfig: AnimationUtilConfig) -> (),

    _running: boolean,
    _config: AnimationUtilConfig,
    _animationTrack: AnimationTrack
}

export type AnimationUtil = typeof(setmetatable({} :: AnimationUtilData, M))

function M.new(config: AnimationUtilConfig): AnimationUtil
    local self: AnimationUtil = setmetatable({} :: AnimationUtilData, M)

    self._running = false
    self:UpdateConfig(config)

    return self :: any
end

function M.Start(self: AnimationUtil)
    if self._running then return end

    self._animationTrack:Play();
    self._animationTrack:AdjustSpeed(self._config.speed)
    
    self._running = true
    if self._config.onStatusChange then
        self._config.onStatusChange("playing")
    end
end

function M.Stop(self: AnimationUtil)
    if not self._running then return end

    self._animationTrack:Stop()
    self._animationTrack.TimePosition = 0

    self._running = false
    if self._config.onStatusChange then
        self._config.onStatusChange("stopped")
    end
end

function M.FollowPlayer(self: AnimationUtil, target: Player | string, offset: CFrame, followDelay: number?): thread?
    local Players = self._config.owner.Parent :: Players
    
    if typeof(target) == "string" then
        target = Players:FindFirstChild(target) :: Player
    end

    if not target then
        if self._config.onError then
            self._config.onError(":FollowPlayer() -> target not found")
        end
        return nil
    end

    local targetHumanoid = ((target :: Player).Character or (target :: Player).CharacterAdded:Wait()):WaitForChild("Humanoid") :: Humanoid
    local targetHRP = targetHumanoid:FindFirstChild("HumanoidRootPart") :: Part
	
    if not targetHumanoid or not targetHRP then
        if self._config.onError then
            self._config.onError(":FollowPlayer() -> target humanoid not found")
        end
        return nil
    end

    targetHumanoid.Died:Connect(function()
        self:Stop()
    end)

    local ownerHumanoid = (self._config.owner.Character or self._config.owner.CharacterAdded:Wait()):WaitForChild("Humanoid") :: Humanoid
    local ownerHRP = ownerHumanoid:FindFirstChild("HumanoidRootPart") :: Part
	
    if not ownerHumanoid or not ownerHRP then
        if self._config.onError then
            self._config.onError(":FollowPlayer() -> animation owner humanoid not found")
        end
    end

    ownerHumanoid.Died:Connect(function()
        self:Stop()
    end)

    return task.spawn(function()
        while self._running do
            ownerHRP.CFrame = targetHRP.CFrame * offset
            task.wait(followDelay or 0)
        end
    end)
end

function M.UpdateConfig(self: AnimationUtil, newConfig: AnimationUtilConfig)
    -- ts bouta be ugly
    if not self._config or (self._config.owner ~= newConfig.owner
     or self._config.r15AnimId ~= newConfig.r15AnimId
     or self._config.r6AnimId ~= newConfig.r6AnimId) then
        local ownerHumanoid = (newConfig.owner.Character or newConfig.owner.CharacterAdded:Wait()):WaitForChild("Humanoid") :: Humanoid
        local ownerAnimator = ownerHumanoid:WaitForChild("Animator") :: Animator
        local isR6 = ownerHumanoid.RigType == Enum.HumanoidRigType.R6

        local animation = Instance.new("Animation")
        animation.AnimationId = isR6 and newConfig.r6AnimId or newConfig.r15AnimId

        self._animationTrack = ownerAnimator:LoadAnimation(animation)

        if self._animationTrack then
            self._animationTrack.Looped = newConfig.looped or false

            if newConfig.onStatusChange then
                newConfig.onStatusChange("ready")
            end
        else
            if newConfig.onError then
                newConfig.onError(".new() -> failed to load animation (wrong rbxassetid?)")
            end
        end
    end

    self._config = newConfig
end

return M
