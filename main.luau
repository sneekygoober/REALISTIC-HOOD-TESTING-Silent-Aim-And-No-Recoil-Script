if not game:IsLoaded() then game.Loaded:Wait(); end;

local cloneref = cloneref or function(i: Instance) return i; end;
local executor = (identifyexecutor and select(2, pcall(identifyexecutor))) and identifyexecutor() or "Your executor";
local SG = loadstring(game:HttpGet("https://raw.githubusercontent.com/sneekygoober/sneeky-s-notifications/refs/heads/main/main.luau"))();

if not (hookfunction and (filtergc or (getgc and debug.getconstants)) and run_on_actor) then
    SG["error"](executor .. " is missing " .. (not hookfunction and "hookfunction " or "") .. (not (filtergc and (getgc and debug.getconstants)) and "filtergc getgc debug.getconstants " or "") .. (not run_on_actor and "run_on_actor" or ""));
    return;
end;

local Players: Players = cloneref(game:GetService("Players"));

local plr = Players.LocalPlayer;

local acs = workspace:FindFirstChild("ACS_WorkSpace");
if not acs then
    SG["error"]("Script needs updating");
    return;
end;

local client, server = acs:FindFirstChild("Client"), acs:FindFirstChild("Server");
if not (client and server) then
    SG["error"]("Script needs updating");
    return;
end;

local a: Actor?;
if get_actors then
    for _, v in next, get_actors() do
        if v.Parent == plr.PlayerScripts then
            a = v;
            break;
        end;
    end;
else
    a = plr.PlayerScripts:FindFirstChildOfClass("Actor");
end;

if not a then
    SG["error"]("Couldn't find active actor!");
    return;
end;

local max = 100;
local payload = [[
local cloneref = cloneref or function(i: Instance) return i; end;
local clonefunction = clonefunction or function(f: (...any) -> (...any)) return f; end;
local newcclosure = newcclosure or clonefunction;
local SG = loadstring(game:HttpGet("https://raw.githubusercontent.com/sneekygoober/sneeky-s-notifications/refs/heads/main/main.luau"))();

local Players: Players = cloneref(game:GetService("Players"));
local UIS: UserInputService = cloneref(game:GetService("UserInputService"));

local plr = Players.LocalPlayer;
local cam = workspace.CurrentCamera;

local mouse: Mouse?;
if not UIS.TouchEnabled and UIS.MouseEnabled and UIS.KeyboardEnabled then
    mouse = plr:GetMouse();
end;

local filter = loadstring(game:HttpGet("https://raw.githubusercontent.com/sneekygoober/sneeky-s-filtergc/refs/heads/main/main.luau"))();

local isVisible = function(part: BasePart): (boolean, Instance?)
    local char = plr.Character;
    if not (char and part) then return false, nil; end;

    local rp = RaycastParams.new();
    rp.FilterType = Enum.RaycastFilterType.Exclude;
    rp.FilterDescendantsInstances = {char, workspace.ACS_WorkSpace.Client, workspace.ACS_WorkSpace.Server};
    rp.IgnoreWater = true;

    local origin = cam.CFrame.Position;

    local dir = part.Position - origin;
    local result: RaycastResult = workspace:Raycast(origin, dir, rp);
    if not result then return true, nil; end;

    if result.Instance:IsDescendantOf(part.Parent) then
        return true, result.Instance;
    end;

    return false, result.Instance;
end;

local getTarget = function(Muzzle: BasePart): BasePart
    local cPart, cDistance = nil, math.huge;

    for _, player: Player in next, Players:GetPlayers() do
        if player == plr then continue; end;

        local char = player.Character;
        if not char or char:FindFirstChildOfClass("ForceField") or (char:FindFirstChild("Humanoid") and char.Humanoid.Health <= 0) then continue; end;

        local tPart: BasePart = char:FindFirstChild("Head") or char.PrimaryPart or char:FindFirstChild("HumanoidRootPart");
        if not tPart then continue; end;

        local pos, onScreen = cam:WorldToViewportPoint(tPart.Position);
        if not onScreen then continue; end;

        local v, nTPart = isVisible(tPart);
        if not v then 
            v, nTPart = isVisible(char.PrimaryPart or char:FindFirstChild("HumanoidRootPart"));
            if not v then continue; end;
        end;

        if nTPart then tPart = nTPart; end;

        local mdistance = mouse and (Vector2.new(pos.X, pos.Y) - Vector2.new(mouse.X, mouse.Y)).Magnitude or Vector2.new(pos.X, pos.Y).Magnitude;
        if mdistance < cDistance then
            cPart = tPart;
            cDistance = mdistance;
        end;
    end;

    return cPart;
end;

local tr = filter(nil, false, "getfenv", "print", "wow you must like hooking getfenv", "debug", "setmemorycategory", "ACS_Framework/CharacterAdded/CurrentThread/CastRay");
local r = filter(nil, false, "camRecoilUp", "camRecoilTilt", "camRecoilLeft", "camRecoilRight", "IPHONE", "warn", "recoil hack 1");
if not (tr and r) then
    SG["error"]("Could not find functions");
    return;
end;

clonefunction(hookfunction(r, newcclosure(function() return true; end)));

local old; old = clonefunction(hookfunction(tr, newcclosure(function(bullet, ...)
    local c = getTarget();
    if c then
        task.spawn(function()
            while bullet ~= nil and bullet.Parent ~= nil do
                bullet.CFrame = c.CFrame;
                task.wait();
            end;
        end);
    end;

    return old(bullet, ...);
end)));

if restorefunction and isfunctionhooked then
    plr.CharacterRemoving:Once(function()
        if tr and isfunctionhooked(tr) then restorefunction(tr); end;
        if r and isfunctionhooked(r) then restorefunction(r); end;
    end);
end;
]];

local inject = function()
    local retries = 0;
    local injected = false;

    while retries < max do
        local s, err = pcall(run_on_actor, a, payload);
        if s then
            injected = true;
            break;
        else
            SG["error"](err);
        end;

        retries += 1;
        task.wait(0.05);
    end;

    if not injected and retries >= max then
        SG["error"]("Failed to inject payload to " .. a:GetFullName());
        return;
    end;
end;

inject();

plr.CharacterAdded:Connect(inject);

SG["success"]("Silent aim successfully executed!\nIf you have any issues press F9 or type /console in chat and then send me a screenshot of the console.");
