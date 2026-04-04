
getgenv().CrouchSettings = {
    CrouchSpeed = 7,
    Delay = 0.4
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local playerGui = LocalPlayer:WaitForChild("PlayerGui")

local guiFolder = playerGui:WaitForChild("gui")
local mobileGui = guiFolder:WaitForChild("mobile ppl")
local crochButton = mobileGui:WaitForChild("croch")

crochButton.Active = false

local animation = ReplicatedStorage:WaitForChild("Animations"):WaitForChild("crouch")

local character
local humanoid
local animator
local animationTrack

local originalWalkSpeed = 16
local holding = false

local speedConn
local lockConn
local delayThread

local function stopAll()
    if speedConn then speedConn:Disconnect() speedConn = nil end
    if lockConn then lockConn:Disconnect() lockConn = nil end
end

local function startLock()
    stopAll()

    speedConn = RunService.RenderStepped:Connect(function()
        if humanoid and holding then
            if humanoid.WalkSpeed ~= getgenv().CrouchSettings.CrouchSpeed then
                humanoid.WalkSpeed = getgenv().CrouchSettings.CrouchSpeed
            end

            if humanoid.MoveDirection.Magnitude < 0.1 then
                animationTrack:AdjustSpeed(0)
            else
                animationTrack:AdjustSpeed(1)
            end
        end
    end)

    lockConn = humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
        if holding and humanoid.WalkSpeed ~= getgenv().CrouchSettings.CrouchSpeed then
            humanoid.WalkSpeed = getgenv().CrouchSettings.CrouchSpeed
        end
    end)
end

local function setupCharacter(newChar)
    character = newChar
    humanoid = newChar:WaitForChild("Humanoid")
    animator = humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator")
    animator.Parent = humanoid

    animationTrack = animator:LoadAnimation(animation)
    animationTrack.Looped = true
    animationTrack.Priority = Enum.AnimationPriority.Action

    originalWalkSpeed = humanoid.WalkSpeed
    holding = false
end

local function beginCrouch()
    if not humanoid or not animationTrack then return end

    holding = true

    if delayThread then
        delayThread = nil
    end

    originalWalkSpeed = humanoid.WalkSpeed
    humanoid.WalkSpeed = getgenv().CrouchSettings.CrouchSpeed

    if not animationTrack.IsPlaying then
        animationTrack:Play(0.1)
    end

    startLock()
end

local function endCrouch()
    if not humanoid or not animationTrack then return end

    holding = false

    delayThread = task.delay(getgenv().CrouchSettings.Delay, function()
        if not holding then
            stopAll()
            animationTrack:Stop(0.2)
            if humanoid then
                humanoid.WalkSpeed = originalWalkSpeed
            end
        end
    end)
end

crochButton.InputBegan:Connect(function(input, gameProcessedEvent)
    if gameProcessedEvent then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        beginCrouch()
    end
end)

crochButton.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        endCrouch()
    end
end)

if LocalPlayer.Character then
    setupCharacter(LocalPlayer.Character)
end

LocalPlayer.CharacterAdded:Connect(setupCharacter)
