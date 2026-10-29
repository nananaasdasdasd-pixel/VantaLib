--[[
    VantaLib — Premium UI Framework
    Place as ModuleScript in ReplicatedStorage, then require() from a LocalScript.
    Executor use: loadstring(game:HttpGet("..."))() or paste inline.
    
    Setup:
        local VantaLib = require(game.ReplicatedStorage.VantaLib)
        -- or for executors:
        local VantaLib = loadstring(...)()
        
    Persistence: writefile / readfile used when available (executor env).
    All features require a LocalScript context (PlayerGui access).
--]]

local VantaLib   = {}
VantaLib.__index = VantaLib

------------------------------------------------------------------------
-- SERVICES
------------------------------------------------------------------------
local TweenService      = game:GetService("TweenService")
local UserInputService  = game:GetService("UserInputService")
local RunService        = game:GetService("RunService")
local Players           = game:GetService("Players")
local HttpService       = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui", 10)

------------------------------------------------------------------------
-- THEME PRESETS
------------------------------------------------------------------------
VantaLib.Themes = {
    Obsidian = {
        Name            = "Obsidian",
        Background      = Color3.fromRGB(10,  10,  14),
        Surface         = Color3.fromRGB(16,  16,  22),
        SurfaceElevated = Color3.fromRGB(22,  22,  30),
        SurfaceHigh     = Color3.fromRGB(30,  30,  42),
        Border          = Color3.fromRGB(44,  44,  60),
        BorderSubtle    = Color3.fromRGB(30,  30,  44),
        Accent          = Color3.fromRGB(52,  211, 153),
        AccentDim       = Color3.fromRGB(28,  120, 88),
        Text            = Color3.fromRGB(240, 240, 250),
        TextMuted       = Color3.fromRGB(140, 140, 165),
        TextSubtle      = Color3.fromRGB(80,  80,  105),
        Success         = Color3.fromRGB(52,  211, 153),
        Warning         = Color3.fromRGB(251, 191, 36),
        Error           = Color3.fromRGB(239, 68,  68),
        Info            = Color3.fromRGB(96,  165, 250),
    },
    EmeraldElite = {
        Name            = "Emerald Elite",
        Background      = Color3.fromRGB(5,   12,  10),
        Surface         = Color3.fromRGB(9,   20,  16),
        SurfaceElevated = Color3.fromRGB(13,  28,  22),
        SurfaceHigh     = Color3.fromRGB(18,  38,  30),
        Border          = Color3.fromRGB(28,  62,  48),
        BorderSubtle    = Color3.fromRGB(18,  44,  34),
        Accent          = Color3.fromRGB(16,  255, 160),
        AccentDim       = Color3.fromRGB(10,  148, 94),
        Text            = Color3.fromRGB(220, 255, 240),
        TextMuted       = Color3.fromRGB(120, 178, 155),
        TextSubtle      = Color3.fromRGB(70,  118, 98),
        Success         = Color3.fromRGB(16,  255, 160),
        Warning         = Color3.fromRGB(251, 191, 36),
        Error           = Color3.fromRGB(239, 68,  68),
        Info            = Color3.fromRGB(96,  165, 250),
    },
    ArcticSilver = {
        Name            = "Arctic Silver",
        Background      = Color3.fromRGB(8,   10,  15),
        Surface         = Color3.fromRGB(14,  16,  23),
        SurfaceElevated = Color3.fromRGB(20,  23,  33),
        SurfaceHigh     = Color3.fromRGB(27,  30,  44),
        Border          = Color3.fromRGB(58,  64,  84),
        BorderSubtle    = Color3.fromRGB(38,  42,  58),
        Accent          = Color3.fromRGB(186, 220, 255),
        AccentDim       = Color3.fromRGB(98,  148, 210),
        Text            = Color3.fromRGB(240, 244, 255),
        TextMuted       = Color3.fromRGB(148, 160, 188),
        TextSubtle      = Color3.fromRGB(92,  102, 130),
        Success         = Color3.fromRGB(52,  211, 153),
        Warning         = Color3.fromRGB(251, 191, 36),
        Error           = Color3.fromRGB(239, 68,  68),
        Info            = Color3.fromRGB(186, 220, 255),
    },
    MidnightViolet = {
        Name            = "Midnight Violet",
        Background      = Color3.fromRGB(9,   7,   16),
        Surface         = Color3.fromRGB(15,  11,  24),
        SurfaceElevated = Color3.fromRGB(21,  15,  34),
        SurfaceHigh     = Color3.fromRGB(28,  20,  46),
        Border          = Color3.fromRGB(56,  38,  84),
        BorderSubtle    = Color3.fromRGB(36,  24,  56),
        Accent          = Color3.fromRGB(167, 139, 250),
        AccentDim       = Color3.fromRGB(98,  80,  168),
        Text            = Color3.fromRGB(240, 235, 255),
        TextMuted       = Color3.fromRGB(152, 138, 186),
        TextSubtle      = Color3.fromRGB(96,  86,  130),
        Success         = Color3.fromRGB(52,  211, 153),
        Warning         = Color3.fromRGB(251, 191, 36),
        Error           = Color3.fromRGB(239, 68,  68),
        Info            = Color3.fromRGB(167, 139, 250),
    },
    CrimsonPrestige = {
        Name            = "Crimson Prestige",
        Background      = Color3.fromRGB(11,  6,   6),
        Surface         = Color3.fromRGB(19,  10,  10),
        SurfaceElevated = Color3.fromRGB(27,  14,  14),
        SurfaceHigh     = Color3.fromRGB(36,  19,  19),
        Border          = Color3.fromRGB(84,  34,  34),
        BorderSubtle    = Color3.fromRGB(56,  22,  22),
        Accent          = Color3.fromRGB(252, 82,  82),
        AccentDim       = Color3.fromRGB(185, 38,  38),
        Text            = Color3.fromRGB(255, 240, 240),
        TextMuted       = Color3.fromRGB(186, 148, 148),
        TextSubtle      = Color3.fromRGB(128, 92,  92),
        Success         = Color3.fromRGB(52,  211, 153),
        Warning         = Color3.fromRGB(251, 191, 36),
        Error           = Color3.fromRGB(252, 82,  82),
        Info            = Color3.fromRGB(96,  165, 250),
    },
}

------------------------------------------------------------------------
-- GLOBAL STATE
------------------------------------------------------------------------
VantaLib.ActiveTheme       = VantaLib.Themes.Obsidian
VantaLib.Settings          = {
    AnimationSpeed         = 1,
    NotificationDuration   = 4,
    SidebarExpanded        = true,
    ReducedMotion          = false,
}
VantaLib._ThemeCallbacks   = {}
VantaLib._Windows          = {}
VantaLib._NotifCount       = 0
VantaLib._NotifContainer   = nil
VantaLib._Keybinds         = {}

------------------------------------------------------------------------
-- UTILITY HELPERS
------------------------------------------------------------------------
local function T(inst, props, dur, style, dir)
    -- Thin wrapper: TweenService:Create + Play, respects ReducedMotion
    dur   = (dur or 0.22) * (VantaLib.Settings.ReducedMotion and 0.01 or 1)
          / math.max(VantaLib.Settings.AnimationSpeed, 0.1)
    style = style or Enum.EasingStyle.Quart
    dir   = dir   or Enum.EasingDirection.Out
    local tw = TweenService:Create(inst, TweenInfo.new(dur, style, dir), props)
    tw:Play()
    return tw
end

local function Corner(p, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 8)
    c.Parent = p
    return c
end

local function Stroke(p, col, thick, trans)
    local s = Instance.new("UIStroke")
    s.Color               = col   or VantaLib.ActiveTheme.Border
    s.Thickness           = thick or 1
    s.Transparency        = trans or 0
    s.ApplyStrokeMode     = Enum.ApplyStrokeMode.Border
    s.Parent = p
    return s
end

local function Padding(p, t, r, b, l)
    local u = Instance.new("UIPadding")
    u.PaddingTop    = UDim.new(0, t or 0)
    u.PaddingRight  = UDim.new(0, r or t or 0)
    u.PaddingBottom = UDim.new(0, b or t or 0)
    u.PaddingLeft   = UDim.new(0, l or r or t or 0)
    u.Parent = p
    return u
end

local function ListLayout(p, gap, halign, valign)
    local l = Instance.new("UIListLayout")
    l.SortOrder          = Enum.SortOrder.LayoutOrder
    l.Padding            = UDim.new(0, gap or 0)
    if halign then l.HorizontalAlignment = halign end
    if valign then l.VerticalAlignment   = valign end
    l.Parent = p
    return l
end

local function Frame(props)
    local f = Instance.new("Frame")
    f.BackgroundColor3    = props.Color       or Color3.new(0,0,0)
    f.BackgroundTransparency = props.Trans    or 0
    f.Size                = props.Size        or UDim2.new(1,0,1,0)
    f.Position            = props.Pos         or UDim2.new(0,0,0,0)
    f.BorderSizePixel     = 0
    f.ClipsDescendants    = props.Clips       or false
    f.ZIndex              = props.Z           or 1
    if props.Name   then f.Name   = props.Name   end
    if props.Parent then f.Parent = props.Parent end
    return f
end

local function Lbl(props)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.Text            = props.Text   or ""
    l.TextColor3      = props.Color  or VantaLib.ActiveTheme.Text
    l.TextSize        = props.Size   or 13
    l.Font            = props.Font   or Enum.Font.GothamMedium
    l.TextXAlignment  = props.XA     or Enum.TextXAlignment.Left
    l.TextYAlignment  = props.YA     or Enum.TextYAlignment.Center
    l.TextWrapped     = props.Wrap   or false
    l.RichText        = props.Rich   or false
    l.Size            = props.FSize  or UDim2.new(1,0,0,20)
    l.Position        = props.Pos    or UDim2.new(0,0,0,0)
    l.ZIndex          = props.Z      or 1
    if props.Name   then l.Name   = props.Name   end
    if props.Parent then l.Parent = props.Parent end
    return l
end

local function Btn(props)
    local b = Instance.new("TextButton")
    b.BackgroundColor3    = props.Color  or Color3.new(0,0,0)
    b.BackgroundTransparency = props.Trans or 1
    b.Text                = props.Text   or ""
    b.TextColor3          = props.TC     or VantaLib.ActiveTheme.Text
    b.TextSize            = props.TS     or 13
    b.Font                = props.Font   or Enum.Font.GothamMedium
    b.Size                = props.Size   or UDim2.new(1,0,0,36)
    b.Position            = props.Pos    or UDim2.new(0,0,0,0)
    b.BorderSizePixel     = 0
    b.AutoButtonColor     = false
    b.ZIndex              = props.Z      or 1
    if props.Name   then b.Name   = props.Name   end
    if props.Parent then b.Parent = props.Parent end
    return b
end

local function Img(props)
    local i = Instance.new("ImageLabel")
    i.BackgroundTransparency = 1
    i.Image           = props.Image or ""
    i.ImageColor3     = props.Color or Color3.new(1,1,1)
    i.ImageTransparency = props.Trans or 0
    i.Size            = props.Size  or UDim2.new(0,18,0,18)
    i.Position        = props.Pos   or UDim2.new(0,0,0,0)
    i.ScaleType       = Enum.ScaleType.Fit
    i.ZIndex          = props.Z     or 1
    if props.Name   then i.Name   = props.Name   end
    if props.Parent then i.Parent = props.Parent end
    return i
end

local function Grad(p, keys, rot)
    local g = Instance.new("UIGradient")
    g.Color    = ColorSequence.new(keys)
    g.Rotation = rot or 90
    g.Parent   = p
    return g
end

------------------------------------------------------------------------
-- PERSISTENCE
------------------------------------------------------------------------
local function Save()
    local ok, json = pcall(HttpService.JSONEncode, HttpService, {
        Theme    = VantaLib.ActiveTheme.Name,
        Settings = VantaLib.Settings,
    })
    if ok then pcall(writefile, "VantaLib.json", json) end
end

local function Load()
    local ok, raw = pcall(readfile, "VantaLib.json")
    if not ok or not raw then return end
    local ok2, data = pcall(HttpService.JSONDecode, HttpService, raw)
    if not ok2 or type(data) ~= "table" then return end
    if type(data.Settings) == "table" then
        for k, v in pairs(data.Settings) do
            if VantaLib.Settings[k] ~= nil then
                VantaLib.Settings[k] = v
            end
        end
    end
    if type(data.Theme) == "string" then
        for _, th in pairs(VantaLib.Themes) do
            if th.Name == data.Theme then
                VantaLib.ActiveTheme = th
                break
            end
        end
    end
end

------------------------------------------------------------------------
-- THEME API
------------------------------------------------------------------------
function VantaLib:SetTheme(theme)
    self.ActiveTheme = theme
    for _, cb in ipairs(self._ThemeCallbacks) do pcall(cb, theme) end
    Save()
end

function VantaLib:OnThemeChange(fn)
    table.insert(self._ThemeCallbacks, fn)
end

------------------------------------------------------------------------
-- NOTIFICATION SYSTEM
------------------------------------------------------------------------
local function EnsureNotifContainer()
    if VantaLib._NotifContainer and VantaLib._NotifContainer.Parent then return end
    local sg = Instance.new("ScreenGui")
    sg.Name           = "VantaNotifs"
    sg.ResetOnSpawn   = false
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    sg.DisplayOrder   = 999
    sg.IgnoreGuiInset = true
    sg.Parent         = PlayerGui

    local c = Frame({
        Color = Color3.new(0,0,0), Trans = 1,
        Size  = UDim2.new(0,320,1,0),
        Pos   = UDim2.new(1,-336,0,0),
        Clips = false,
        Name  = "NotifContainer", Parent = sg,
    })
    local ll = ListLayout(c, 8)
    ll.VerticalAlignment = Enum.VerticalAlignment.Bottom
    Padding(c, 12, 0, 12, 0)
    VantaLib._NotifContainer = c
end

function VantaLib:Notify(cfg)
    EnsureNotifContainer()
    local th   = self.ActiveTheme
    local dur  = cfg.Duration or self.Settings.NotificationDuration
    local kind = cfg.Type     or "info"

    local kindColor = ({
        info    = th.Info,
        success = th.Success,
        warning = th.Warning,
        error   = th.Error,
    })[kind] or th.Info

    local kindIcon = ({
        info    = "rbxassetid://7072706796",
        success = "rbxassetid://7072719159",
        warning = "rbxassetid://7072725342",
        error   = "rbxassetid://7072709278",
    })[kind] or "rbxassetid://7072706796"

    self._NotifCount += 1
    local n = Frame({
        Color = th.SurfaceElevated,
        Size  = UDim2.new(1,0,0,78),
        Pos   = UDim2.new(1.1,0,0,0),
        Clips = true,
        Name  = "N"..self._NotifCount,
        Parent = self._NotifContainer,
    })
    n.LayoutOrder = self._NotifCount
    Corner(n, 10)
    Stroke(n, th.Border, 1)

    -- Left accent strip
    local strip = Frame({ Color = kindColor, Size = UDim2.new(0,3,1,0), Parent = n })
    Corner(strip, 2)

    Img({
        Image = kindIcon, Color = kindColor,
        Size  = UDim2.new(0,16,0,16),
        Pos   = UDim2.new(0,14,0.5,-8), Parent = n,
    })

    Lbl({
        Text  = cfg.Title or "Notification",
        Color = th.Text,
        Size  = 13,
        Font  = Enum.Font.GothamBold,
        FSize = UDim2.new(1,-52,0,18),
        Pos   = UDim2.new(0,40,0,14), Parent = n,
    })
    Lbl({
        Text  = cfg.Description or "",
        Color = th.TextMuted,
        Size  = 11,
        Wrap  = true,
        FSize = UDim2.new(1,-52,0,28),
        Pos   = UDim2.new(0,40,0,34), Parent = n,
    })

    -- Progress drain bar
    local pbg = Frame({
        Color = th.SurfaceHigh,
        Size  = UDim2.new(1,-16,0,2),
        Pos   = UDim2.new(0,8,1,-5), Parent = n,
    })
    Corner(pbg, 2)
    local pfill = Frame({ Color = kindColor, Size = UDim2.new(1,0,1,0), Parent = pbg })
    Corner(pfill, 2)

    -- Entrance
    n.BackgroundTransparency = 1
    T(n,     { BackgroundTransparency = 0, Position = UDim2.new(0,0,0,0) }, 0.32, Enum.EasingStyle.Back)

    -- Drain + exit
    task.delay(0.3, function()
        T(pfill, { Size = UDim2.new(0,0,1,0) }, dur, Enum.EasingStyle.Linear)
    end)
    task.delay(dur + 0.3, function()
        T(n, { BackgroundTransparency = 1, Position = UDim2.new(1.1,0,0,0) }, 0.28)
        task.delay(0.32, function() pcall(n.Destroy, n) end)
    end)

    return n
end

------------------------------------------------------------------------
-- CINEMATIC LOADER
------------------------------------------------------------------------
function VantaLib:ShowLoader(cfg)
    local th       = self.ActiveTheme
    local appName  = cfg.AppName  or "VANTA"
    local sub      = cfg.Subtitle or "PREMIUM INTERFACE"
    local ver      = cfg.Version  or "v1.0.0"
    local onDone   = cfg.OnComplete

    local sg = Instance.new("ScreenGui")
    sg.Name           = "VantaLoader"
    sg.ResetOnSpawn   = false
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    sg.DisplayOrder   = 1000
    sg.IgnoreGuiInset = true
    sg.Parent         = PlayerGui

    local bg = Frame({
        Color = th.Background,
        Size  = UDim2.new(1,0,1,0),
        Name  = "BG", Parent = sg,
    })
    Grad(bg, {
        ColorSequenceKeypoint.new(0,   th.Background),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(
            math.clamp(math.round(th.Background.R*255 + 6), 0, 255),
            math.clamp(math.round(th.Background.G*255 + 6), 0, 255),
            math.clamp(math.round(th.Background.B*255 + 10),0, 255)
        )),
        ColorSequenceKeypoint.new(1,   th.Background),
    }, 130)

    -- Vignette overlay
    local vig = Instance.new("ImageLabel")
    vig.BackgroundTransparency = 1
    vig.Image             = "rbxassetid://1316045217"
    vig.ImageColor3       = Color3.new(0,0,0)
    vig.ImageTransparency = 0.35
    vig.Size              = UDim2.new(1,0,1,0)
    vig.Parent            = bg

    -- Particle container
    local ptc = Frame({ Color = Color3.new(0,0,0), Trans = 1, Size = UDim2.new(1,0,1,0), Parent = bg })
    local ptConns = {}
    for i = 1, 14 do
        local dot = Frame({
            Color = th.Accent, Trans = 0.88,
            Size  = UDim2.new(0,math.random(2,5),0,math.random(2,5)),
            Pos   = UDim2.new(math.random()/1,0, math.random()/1,0),
            Parent = ptc,
        })
        Corner(dot, 4)
        local spd = 0.25 + math.random() * 0.35
        local conn
        conn = RunService.Heartbeat:Connect(function(dt)
            if not dot.Parent then conn:Disconnect() return end
            local p = dot.Position
            local ny = p.Y.Scale - dt * spd * 0.018
            if ny < -0.04 then ny = 1.04 end
            dot.Position = UDim2.new(p.X.Scale, 0, ny, 0)
        end)
        table.insert(ptConns, conn)
    end

    -- Center panel
    local ctr = Frame({
        Color = Color3.new(0,0,0), Trans = 1,
        Size  = UDim2.new(0,380,0,260),
        Pos   = UDim2.new(0.5,-190,0.5,-130),
        Parent = bg,
    })

    -- Logo box
    local logoBx = Frame({
        Color = th.SurfaceElevated,
        Size  = UDim2.new(0,68,0,68),
        Pos   = UDim2.new(0.5,-34,0,0),
        Parent = ctr,
    })
    Corner(logoBx, 16)
    Stroke(logoBx, th.Accent, 1, 0.4)

    Lbl({
        Text  = string.upper(string.sub(appName,1,1)),
        Color = th.Accent,
        Size  = 30,
        Font  = Enum.Font.GothamBlack,
        XA    = Enum.TextXAlignment.Center,
        FSize = UDim2.new(1,0,1,0),
        Parent = logoBx,
    })

    -- Outer ring (animated)
    local ring = Frame({
        Color = Color3.new(0,0,0), Trans = 1,
        Size  = UDim2.new(0,80,0,80),
        Pos   = UDim2.new(0.5,-40,0,-6),
        Parent = ctr,
    })
    Corner(ring, 20)
    local ringS = Stroke(ring, th.Accent, 1, 0.6)

    Lbl({
        Text  = appName,
        Color = th.Text,
        Size  = 26,
        Font  = Enum.Font.GothamBlack,
        XA    = Enum.TextXAlignment.Center,
        FSize = UDim2.new(1,0,0,32),
        Pos   = UDim2.new(0,0,0,84),
        Parent = ctr,
    })
    Lbl({
        Text  = sub,
        Color = th.Accent,
        Size  = 10,
        Font  = Enum.Font.GothamMedium,
        XA    = Enum.TextXAlignment.Center,
        FSize = UDim2.new(1,0,0,14),
        Pos   = UDim2.new(0,0,0,118),
        Parent = ctr,
    })

    local statusLbl = Lbl({
        Text  = "Initializing Interface",
        Color = th.TextMuted,
        Size  = 11,
        Font  = Enum.Font.Gotham,
        XA    = Enum.TextXAlignment.Center,
        FSize = UDim2.new(1,0,0,14),
        Pos   = UDim2.new(0,0,0,148),
        Parent = ctr,
    })

    local barBg = Frame({
        Color = th.SurfaceHigh,
        Size  = UDim2.new(0,300,0,4),
        Pos   = UDim2.new(0.5,-150,0,172),
        Parent = ctr,
    })
    Corner(barBg, 4)

    local barFill = Frame({ Color = th.Accent, Size = UDim2.new(0,0,1,0), Parent = barBg })
    Corner(barFill, 4)

    -- Shimmer on bar
    local shimmer = Frame({
        Color = Color3.new(1,1,1), Trans = 0.72,
        Size  = UDim2.new(0,55,1,0),
        Pos   = UDim2.new(0,-55,0,0),
        Clips = false, Parent = barFill,
    })
    Corner(shimmer, 4)
    Grad(shimmer, {
        ColorSequenceKeypoint.new(0,   Color3.new(1,1,1)),
        ColorSequenceKeypoint.new(0.5, Color3.new(1,1,1)),
        ColorSequenceKeypoint.new(1,   Color3.new(1,1,1)),
    }, 0)
    shimmer.ZIndex = 2

    local pctLbl = Lbl({
        Text  = "0%",
        Color = th.TextMuted,
        Size  = 10,
        Font  = Enum.Font.GothamMedium,
        XA    = Enum.TextXAlignment.Center,
        FSize = UDim2.new(1,0,0,14),
        Pos   = UDim2.new(0,0,0,184),
        Parent = ctr,
    })
    Lbl({
        Text  = ver,
        Color = th.TextSubtle,
        Size  = 9,
        XA    = Enum.TextXAlignment.Center,
        FSize = UDim2.new(1,0,0,12),
        Pos   = UDim2.new(0,0,0,212),
        Parent = ctr,
    })

    -- Entrance fade
    for _, d in ipairs(ctr:GetDescendants()) do
        if d:IsA("TextLabel") then d.TextTransparency = 1
        elseif d:IsA("Frame") and d ~= logoBx then d.BackgroundTransparency = 1 end
    end
    logoBx.BackgroundTransparency = 0

    task.spawn(function()
        task.wait(0.18)
        T(logoBx,    { BackgroundTransparency = 0 }, 0.4, Enum.EasingStyle.Back)
        task.wait(0.08)
        for _, d in ipairs(ctr:GetDescendants()) do
            if d:IsA("TextLabel") then T(d, {TextTransparency = 0}, 0.35) end
        end
        T(barBg,   { BackgroundTransparency = 0 }, 0.3)
        T(ringS,   { Transparency = 0.6 }, 0.4)
    end)

    -- Shimmer loop
    task.spawn(function()
        while sg.Parent do
            local fw = barFill.AbsoluteSize.X
            if fw > 8 then
                shimmer.Position = UDim2.new(0, -60, 0, 0)
                T(shimmer, { Position = UDim2.new(0, fw + 12, 0, 0) }, 1.1, Enum.EasingStyle.Sine)
                task.wait(1.3)
            else
                task.wait(0.2)
            end
        end
    end)

    -- Progress + messages
    local msgs = {
        "Initializing Interface",
        "Loading Visual Assets",
        "Preparing Workspace",
        "Configuring Components",
        "Applying Theme",
        "Almost Ready",
    }
    local function Progress(pct, msg)
        T(barFill, { Size = UDim2.new(pct/100, 0, 1, 0) }, 0.4, Enum.EasingStyle.Quart)
        if msg and statusLbl.Parent then
            T(statusLbl, { TextTransparency = 1 }, 0.1)
            task.delay(0.12, function()
                if statusLbl.Parent then
                    statusLbl.Text = msg
                    T(statusLbl, { TextTransparency = 0 }, 0.12)
                end
            end)
        end
        -- Smooth counter
        local from = tonumber(pctLbl.Text:match("%d+")) or 0
        for s = 1, 16 do
            task.wait(0.025)
            if pctLbl.Parent then
                pctLbl.Text = math.floor(from + (pct - from) * s/16) .. "%"
            end
        end
    end

    task.spawn(function()
        task.wait(0.55) Progress(14, msgs[1])
        task.wait(0.60) Progress(33, msgs[2])
        task.wait(0.50) Progress(54, msgs[3])
        task.wait(0.48) Progress(71, msgs[4])
        task.wait(0.42) Progress(88, msgs[5])
        task.wait(0.36) Progress(100, msgs[6])
        task.wait(0.55)

        for _, c in ipairs(ptConns) do c:Disconnect() end
        T(bg, { BackgroundTransparency = 1 }, 0.55, Enum.EasingStyle.Quart)
        for _, d in ipairs(bg:GetDescendants()) do
            if d:IsA("TextLabel") then T(d, {TextTransparency = 1}, 0.4)
            elseif d:IsA("ImageLabel") then T(d, {ImageTransparency = 1}, 0.4) end
        end
        task.wait(0.6)
        sg:Destroy()
        if onDone then pcall(onDone) end
    end)

    return sg
end

------------------------------------------------------------------------
-- WINDOW
------------------------------------------------------------------------
function VantaLib:CreateWindow(cfg)
    Load()  -- restore persisted prefs

    local th         = self.ActiveTheme
    local title      = cfg.Title     or "VANTA"
    local subtitle   = cfg.Subtitle  or "Premium Interface"
    local winW       = cfg.Width     or 720
    local winH       = cfg.Height    or 500
    local toggleKey  = cfg.ToggleKey or Enum.KeyCode.RightShift
    local ver        = cfg.Version   or "v1.0.0"

    local SBW  = 210   -- sidebar expanded width
    local SBWC = 60    -- sidebar collapsed width

    local Win = {}
    Win._Tabs         = {}
    Win._ActiveTab    = nil
    Win._Open         = true
    Win._Expanded     = self.Settings.SidebarExpanded

    ------------------------------------------------ ScreenGui
    local sg = Instance.new("ScreenGui")
    sg.Name           = "VantaLib_" .. title
    sg.ResetOnSpawn   = false
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    sg.DisplayOrder   = 100
    sg.IgnoreGuiInset = true
    sg.Parent         = PlayerGui
    Win._Gui = sg

    ------------------------------------------------ Main frame
    local mf = Frame({
        Color = th.Background,
        Size  = UDim2.new(0,winW,0,winH),
        Pos   = UDim2.new(0.5,-winW/2, 0.5,-winH/2),
        Clips = true,
        Name  = "Main", Parent = sg,
    })
    Corner(mf, 12)
    Stroke(mf, th.BorderSubtle, 1)
    Win._MF = mf

    -- Entrance animation (scale-in)
    mf.BackgroundTransparency = 1
    mf.Size     = UDim2.new(0, winW*0.94, 0, winH*0.94)
    mf.Position = UDim2.new(0.5, -winW*0.94/2, 0.5, -winH*0.94/2)
    task.spawn(function()
        task.wait(0.04)
        T(mf, {
            BackgroundTransparency = 0,
            Size     = UDim2.new(0,winW,0,winH),
            Position = UDim2.new(0.5,-winW/2,0.5,-winH/2),
        }, 0.42, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    end)

    ------------------------------------------------ Sidebar
    local sbW = Win._Expanded and SBW or SBWC
    local sb  = Frame({
        Color = th.Surface,
        Size  = UDim2.new(0,sbW,1,0),
        Clips = true,
        Name  = "Sidebar", Parent = mf,
    })
    Win._SB = sb

    -- Sidebar right edge
    Frame({ Color=th.BorderSubtle, Size=UDim2.new(0,1,1,0), Pos=UDim2.new(1,0,0,0), Parent=sb })

    ------------------------------------------------ Sidebar header
    local sbHdr = Frame({ Color=Color3.new(0,0,0), Trans=1, Size=UDim2.new(1,0,0,64), Parent=sb })

    local logoBox = Frame({
        Color = th.SurfaceElevated,
        Size  = UDim2.new(0,34,0,34),
        Pos   = UDim2.new(0,13,0,15),
        Parent = sbHdr,
    })
    Corner(logoBox, 9)
    Stroke(logoBox, th.Accent, 1, 0.55)
    Lbl({
        Text  = string.upper(string.sub(title,1,1)),
        Color = th.Accent,
        Size  = 15,
        Font  = Enum.Font.GothamBlack,
        XA    = Enum.TextXAlignment.Center,
        FSize = UDim2.new(1,0,1,0),
        Parent = logoBox,
    })

    local sbAppName = Lbl({
        Text  = title,
        Color = th.Text,
        Size  = 13,
        Font  = Enum.Font.GothamBold,
        FSize = UDim2.new(1,-60,0,17),
        Pos   = UDim2.new(0,56,0,14),
        Parent = sbHdr,
    })
    local sbSubName = Lbl({
        Text  = subtitle,
        Color = th.Accent,
        Size  = 9,
        Font  = Enum.Font.GothamMedium,
        FSize = UDim2.new(1,-60,0,13),
        Pos   = UDim2.new(0,56,0,33),
        Parent = sbHdr,
    })
    sbAppName.TextTransparency = Win._Expanded and 0 or 1
    sbSubName.TextTransparency = Win._Expanded and 0 or 1

    Frame({ Color=th.BorderSubtle, Size=UDim2.new(1,-20,0,1), Pos=UDim2.new(0,10,0,62), Parent=sb })

    ------------------------------------------------ Tab nav list
    local tabList = Frame({
        Color = Color3.new(0,0,0), Trans=1,
        Size  = UDim2.new(1,0,1,-150),
        Pos   = UDim2.new(0,0,0,70),
        Clips = true, Name="TabList", Parent=sb,
    })
    ListLayout(tabList, 2)
    Padding(tabList, 6, 8, 6, 8)
    Win._TabList = tabList

    ------------------------------------------------ Sidebar footer
    local sbFoot = Frame({
        Color = Color3.new(0,0,0), Trans=1,
        Size  = UDim2.new(1,0,0,80),
        Pos   = UDim2.new(0,0,1,-80),
        Parent = sb,
    })
    Frame({ Color=th.BorderSubtle, Size=UDim2.new(1,-20,0,1), Pos=UDim2.new(0,10,0,0), Parent=sbFoot })

    -- Avatar + username
    local avBox = Frame({
        Color = th.SurfaceHigh,
        Size  = UDim2.new(0,30,0,30),
        Pos   = UDim2.new(0,12,0,16),
        Parent = sbFoot,
    })
    Corner(avBox, 8)
    local avImg = Img({ Size=UDim2.new(1,0,1,0), Parent=avBox })
    Corner(avImg, 8)
    task.spawn(function()
        local ok,img = pcall(Players.GetUserThumbnailAsync, Players,
            LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
        if ok and avImg.Parent then avImg.Image = img end
    end)

    local sbUname = Lbl({
        Text  = LocalPlayer.DisplayName,
        Color = th.Text,
        Size  = 11,
        Font  = Enum.Font.GothamBold,
        FSize = UDim2.new(1,-55,0,15),
        Pos   = UDim2.new(0,50,0,14),
        Parent = sbFoot,
    })
    local sbMember = Lbl({
        Text  = "VIP Member",
        Color = th.Accent,
        Size  = 9,
        FSize = UDim2.new(1,-55,0,13),
        Pos   = UDim2.new(0,50,0,30),
        Parent = sbFoot,
    })
    sbUname.TextTransparency  = Win._Expanded and 0 or 1
    sbMember.TextTransparency = Win._Expanded and 0 or 1

    -- Collapse toggle
    local colBtn = Btn({
        Color = Color3.new(0,0,0), Trans=1,
        Size  = UDim2.new(0,24,0,24),
        Pos   = UDim2.new(1,-32,0,16),
        Parent = sbFoot,
    })
    Corner(colBtn, 6)
    local colLbl = Lbl({
        Text  = Win._Expanded and "◂" or "▸",
        Color = th.TextMuted,
        Size  = 12,
        XA    = Enum.TextXAlignment.Center,
        FSize = UDim2.new(1,0,1,0),
        Parent = colBtn,
    })

    ------------------------------------------------ Content area
    local curSBW = Win._Expanded and SBW or SBWC
    local ca = Frame({
        Color = th.Background,
        Size  = UDim2.new(1,-curSBW,1,0),
        Pos   = UDim2.new(0,curSBW,0,0),
        Clips = true,
        Name  = "Content", Parent = mf,
    })
    Win._CA = ca

    -- Header bar
    local hdr = Frame({
        Color = th.Surface,
        Size  = UDim2.new(1,0,0,52),
        Name  = "Header", Parent = ca,
    })
    -- Draggable from header
    Frame({ Color=th.BorderSubtle, Size=UDim2.new(1,0,0,1), Pos=UDim2.new(0,0,1,-1), Parent=hdr })

    local pageTitleLbl = Lbl({
        Text  = "Dashboard",
        Color = th.Text,
        Size  = 15,
        Font  = Enum.Font.GothamBold,
        FSize = UDim2.new(1,-110,0,52),
        Pos   = UDim2.new(0,20,0,0),
        Parent = hdr,
    })
    Win._PageTitle = pageTitleLbl

    Lbl({
        Text  = ver,
        Color = th.TextSubtle,
        Size  = 9,
        XA    = Enum.TextXAlignment.Right,
        FSize = UDim2.new(0,72,0,52),
        Pos   = UDim2.new(1,-120,0,0),
        Parent = hdr,
    })

    -- Close button
    local closeBtn = Btn({
        Color = Color3.new(0,0,0), Trans=1,
        Size  = UDim2.new(0,34,0,34),
        Pos   = UDim2.new(1,-42,0,9),
        Parent = hdr,
    })
    Corner(closeBtn, 8)
    local closeX = Lbl({
        Text  = "✕",
        Color = th.TextMuted,
        Size  = 12,
        Font  = Enum.Font.GothamBold,
        XA    = Enum.TextXAlignment.Center,
        FSize = UDim2.new(1,0,1,0),
        Parent = closeBtn,
    })

    -- Tab content host
    local tch = Frame({
        Color = Color3.new(0,0,0), Trans=1,
        Size  = UDim2.new(1,0,1,-53),
        Pos   = UDim2.new(0,0,0,53),
        Clips = true,
        Name  = "TabContent", Parent = ca,
    })
    Win._TCH = tch

    ------------------------------------------------ Drag logic
    local dragging, dragStart, dragBase = false, nil, nil
    hdr.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging  = true
            dragStart = inp.Position
            dragBase  = mf.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
            local d = inp.Position - dragStart
            mf.Position = UDim2.new(dragBase.X.Scale, dragBase.X.Offset+d.X, dragBase.Y.Scale, dragBase.Y.Offset+d.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)

    ------------------------------------------------ Open / Close
    local basePos = mf.Position

    local function Close()
        Win._Open = false
        T(mf, {
            BackgroundTransparency = 1,
            Size = UDim2.new(0,winW*0.96,0,winH*0.96),
        }, 0.26, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
        task.delay(0.28, function() mf.Visible = false end)
    end

    local function Open()
        Win._Open = true
        mf.Visible = true
        T(mf, {
            BackgroundTransparency = 0,
            Size = UDim2.new(0,winW,0,winH),
        }, 0.34, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    end

    Win.Close  = Close
    Win.Open   = Open
    Win.Toggle = function() if Win._Open then Close() else Open() end end

    closeBtn.MouseButton1Click:Connect(Close)
    closeBtn.MouseEnter:Connect(function()
        T(closeBtn, {BackgroundTransparency=0, BackgroundColor3=Color3.fromRGB(239,68,68)}, 0.15)
        T(closeX,   {TextColor3 = Color3.new(1,1,1)}, 0.15)
    end)
    closeBtn.MouseLeave:Connect(function()
        T(closeBtn, {BackgroundTransparency=1}, 0.15)
        T(closeX,   {TextColor3 = th.TextMuted}, 0.15)
    end)

    -- Global toggle keybind
    UserInputService.InputBegan:Connect(function(inp, proc)
        if not proc and inp.KeyCode == toggleKey then Win:Toggle() end
    end)

    ------------------------------------------------ Sidebar collapse
    local function SetExpanded(exp)
        Win._Expanded = exp
        VantaLib.Settings.SidebarExpanded = exp
        local tw = exp and SBW or SBWC
        T(sb, { Size = UDim2.new(0,tw,1,0) }, 0.32, Enum.EasingStyle.Quart)
        T(ca, {
            Size     = UDim2.new(1,-tw,1,0),
            Position = UDim2.new(0,tw,0,0),
        }, 0.32, Enum.EasingStyle.Quart)
        local txtT = exp and 0 or 1
        T(sbAppName,  {TextTransparency=txtT}, 0.18)
        T(sbSubName,  {TextTransparency=txtT}, 0.18)
        T(sbUname,    {TextTransparency=txtT}, 0.18)
        T(sbMember,   {TextTransparency=txtT}, 0.18)
        colLbl.Text = exp and "◂" or "▸"
        for _, td in ipairs(Win._Tabs) do
            T(td._Lbl, {TextTransparency=txtT}, 0.18)
        end
        Save()
    end

    colBtn.MouseButton1Click:Connect(function() SetExpanded(not Win._Expanded) end)
    colBtn.MouseEnter:Connect(function() T(colBtn,{BackgroundTransparency=0,BackgroundColor3=th.SurfaceHigh},0.15) end)
    colBtn.MouseLeave:Connect(function() T(colBtn,{BackgroundTransparency=1},0.15) end)

    ------------------------------------------------ Theme propagation
    VantaLib:OnThemeChange(function(nT)
        T(mf, {BackgroundColor3=nT.Background}, 0.3)
        T(sb,  {BackgroundColor3=nT.Surface},   0.3)
        T(ca,  {BackgroundColor3=nT.Background},0.3)
        T(hdr, {BackgroundColor3=nT.Surface},   0.3)
    end)

    ------------------------------------------------
    -- CreateTab
    ------------------------------------------------
    function Win:CreateTab(tc)
        local tabTitle = tc.Title or "Tab"
        local tabIcon  = tc.Icon  or "rbxassetid://7072706796"
        local order    = #self._Tabs + 1

        local td = { _Secs={} }

        -- Sidebar nav button
        local nb = Btn({
            Color=Color3.new(0,0,0), Trans=1,
            Size =UDim2.new(1,0,0,38),
            Parent = tabList,
        })
        nb.LayoutOrder = order
        Corner(nb, 8)

        local indicator = Frame({
            Color = th.Accent,
            Size  = UDim2.new(0,3,0.65,0),
            Pos   = UDim2.new(0,0,0.175,0),
            Parent = nb,
        })
        indicator.Visible = false
        Corner(indicator, 4)

        local ni = Img({
            Image = tabIcon,
            Color = th.TextMuted,
            Size  = UDim2.new(0,15,0,15),
            Pos   = UDim2.new(0,13,0.5,-7.5),
            Parent = nb,
        })
        local nl = Lbl({
            Text  = tabTitle,
            Color = th.TextMuted,
            Size  = 12,
            Font  = Enum.Font.GothamMedium,
            FSize = UDim2.new(1,-40,0,38),
            Pos   = UDim2.new(0,38,0,0),
            Parent = nb,
        })
        nl.TextTransparency = Win._Expanded and 0 or 1

        td._Lbl  = nl
        td._Icon = ni
        td._Btn  = nb
        td._Ind  = indicator

        -- Content page
        local page = Frame({
            Color=Color3.new(0,0,0),Trans=1,
            Size=UDim2.new(1,0,1,0),
            Clips=true, Parent=tch,
        })
        page.Visible = false

        local scroll = Instance.new("ScrollingFrame")
        scroll.BackgroundTransparency = 1
        scroll.Size                   = UDim2.new(1,0,1,0)
        scroll.BorderSizePixel        = 0
        scroll.ScrollBarThickness     = 3
        scroll.ScrollBarImageColor3   = th.Border
        scroll.CanvasSize             = UDim2.new(0,0,0,0)
        scroll.AutomaticCanvasSize    = Enum.AutomaticSize.Y
        scroll.ScrollingDirection     = Enum.ScrollingDirection.Y
        scroll.Parent                 = page
        ListLayout(scroll, 12)
        Padding(scroll, 16, 16, 16, 16)

        td._Page   = page
        td._Scroll = scroll

        local function Select()
            -- Deactivate old
            if Win._ActiveTab then
                local pt = Win._ActiveTab
                T(pt._Btn, {BackgroundTransparency=1},  0.18)
                T(pt._Icon,{ImageColor3=th.TextMuted},  0.18)
                T(pt._Lbl, {TextColor3 =th.TextMuted},  0.18)
                pt._Ind.Visible  = false
                pt._Page.Visible = false
            end

            Win._ActiveTab = td
            T(nb,  {BackgroundTransparency=0,BackgroundColor3=th.SurfaceElevated}, 0.2)
            T(ni,  {ImageColor3=th.Accent},  0.2)
            T(nl,  {TextColor3 =th.Text},    0.2)
            indicator.Visible = true
            pageTitleLbl.Text = tabTitle
            page.Visible      = true

            -- Stagger section entrance
            local kids = scroll:GetChildren()
            table.sort(kids, function(a,b) return a.LayoutOrder < b.LayoutOrder end)
            for i, ch in ipairs(kids) do
                if ch:IsA("Frame") then
                    ch.BackgroundTransparency = 1
                    task.delay((i-1)*0.035, function()
                        if ch.Parent then T(ch,{BackgroundTransparency=0},0.22) end
                    end)
                end
            end
        end

        td.Select = Select
        nb.MouseButton1Click:Connect(Select)
        nb.MouseEnter:Connect(function()
            if Win._ActiveTab ~= td then
                T(nb,{BackgroundTransparency=0,BackgroundColor3=th.SurfaceHigh},0.15)
            end
        end)
        nb.MouseLeave:Connect(function()
            if Win._ActiveTab ~= td then T(nb,{BackgroundTransparency=1},0.15) end
        end)

        table.insert(Win._Tabs, td)
        if #Win._Tabs == 1 then task.spawn(Select) end

        ----------------------------------------------
        -- CreateSection
        ----------------------------------------------
        function td:CreateSection(sc)
            local secTitle = sc.Title or ""
            local secOrder = #self._Secs + 1
            local sec = {}
            sec._Ord = 1

            local sf = Frame({
                Color  = th.Surface,
                Size   = UDim2.new(1,0,0,0),
                Clips  = false,
                Parent = scroll,
            })
            sf.AutomaticSize = Enum.AutomaticSize.Y
            sf.LayoutOrder   = secOrder
            Corner(sf, 10)
            Stroke(sf, th.BorderSubtle, 1)

            local inner = Frame({
                Color=Color3.new(0,0,0),Trans=1,
                Size=UDim2.new(1,0,0,0),
                Parent=sf,
            })
            inner.AutomaticSize = Enum.AutomaticSize.Y
            ListLayout(inner, 0)
            Padding(inner, 0, 0, 10, 0)

            if secTitle ~= "" then
                local sh = Frame({
                    Color=Color3.new(0,0,0),Trans=1,
                    Size=UDim2.new(1,0,0,36),
                    Parent=inner,
                })
                sh.LayoutOrder = 0
                local acBar = Frame({
                    Color=th.Accent,Trans=0.55,
                    Size=UDim2.new(0,2,0,14),
                    Pos=UDim2.new(0,8,0.5,-7),
                    Parent=sh,
                })
                Corner(acBar,2)
                Lbl({
                    Text  = secTitle,
                    Color = th.TextMuted,
                    Size  = 10,
                    Font  = Enum.Font.GothamBold,
                    FSize = UDim2.new(1,-28,0,36),
                    Pos   = UDim2.new(0,18,0,0),
                    Parent = sh,
                })
                Frame({Color=th.BorderSubtle,Size=UDim2.new(1,-28,0,1),Pos=UDim2.new(0,14,1,-1),Parent=sh})
            end

            sec._Inner = inner
            sec._SF    = sf

            local function NextOrd()
                local o = sec._Ord; sec._Ord=o+1; return o+1
            end

            -- Row helper: padded container for a component
            local function Row(h)
                local r = Frame({
                    Color=Color3.new(0,0,0),Trans=1,
                    Size=UDim2.new(1,0,0,h or 54),
                    Parent=inner,
                })
                r.LayoutOrder = NextOrd()
                return r
            end

            -- Element helper: the styled panel inside the row
            local function El(parent, h)
                local e = Frame({
                    Color = th.SurfaceElevated,
                    Size  = UDim2.new(1,-24,0,h or 38),
                    Pos   = UDim2.new(0,12,0.5,-(h or 38)/2),
                    Parent= parent,
                })
                Corner(e,8)
                Stroke(e, th.BorderSubtle, 1)
                return e
            end

            --------------------------------------------
            -- BUTTON
            --------------------------------------------
            function sec:CreateButton(bc)
                local lbl  = bc.Title       or "Button"
                local desc = bc.Description or ""
                local cb   = bc.Callback    or function() end

                local row  = Row(desc~="" and 60 or 54)
                local el   = El(row, desc~="" and 44 or 36)

                Lbl({
                    Text=lbl, Color=th.Text, Size=13, Font=Enum.Font.GothamMedium,
                    FSize=UDim2.new(1,-20,0,18), Pos=UDim2.new(0,12,desc~=""and 0 or 0.5,desc~=""and 8 or -9),
                    Parent=el,
                })
                if desc~="" then
                    Lbl({Text=desc,Color=th.TextSubtle,Size=10,FSize=UDim2.new(1,-20,0,14),Pos=UDim2.new(0,12,0,28),Parent=el})
                end

                local bOvr = Btn({Color=Color3.new(0,0,0),Trans=1,Size=UDim2.new(1,0,1,0),Parent=el})
                bOvr.MouseEnter:Connect(function() T(el,{BackgroundColor3=th.SurfaceHigh},0.14) end)
                bOvr.MouseLeave:Connect(function() T(el,{BackgroundColor3=th.SurfaceElevated},0.14) end)
                bOvr.MouseButton1Down:Connect(function()
                    T(el,{BackgroundColor3=th.AccentDim,Size=UDim2.new(1,-26,0,el.Size.Y.Offset-2)},0.1)
                end)
                bOvr.MouseButton1Up:Connect(function()
                    T(el,{BackgroundColor3=th.SurfaceHigh,Size=UDim2.new(1,-24,0,el.Size.Y.Offset+2)},0.14)
                end)
                bOvr.MouseButton1Click:Connect(function() pcall(cb) end)
            end

            --------------------------------------------
            -- TOGGLE
            --------------------------------------------
            function sec:CreateToggle(tc2)
                local lbl = tc2.Title    or "Toggle"
                local def = tc2.Default  or false
                local cb  = tc2.Callback or function() end

                local row  = Row(52)
                local el   = El(row, 36)
                local data = {Value=def}

                Lbl({Text=lbl,Color=th.Text,Size=13,Font=Enum.Font.GothamMedium,
                    FSize=UDim2.new(1,-64,1,0),Pos=UDim2.new(0,12,0,0),Parent=el})

                -- Track
                local track = Frame({
                    Color = def and th.Accent or th.SurfaceHigh,
                    Size  = UDim2.new(0,36,0,20),
                    Pos   = UDim2.new(1,-48,0.5,-10),
                    Parent= el,
                })
                Corner(track, 10)
                local trS = Stroke(track, def and th.Accent or th.Border, 1)

                local thumb = Frame({
                    Color = Color3.new(1,1,1),
                    Size  = UDim2.new(0,14,0,14),
                    Pos   = def and UDim2.new(0,18,0.5,-7) or UDim2.new(0,4,0.5,-7),
                    Parent= track,
                })
                Corner(thumb, 7)

                local function Set(v, silent)
                    data.Value = v
                    T(track, {BackgroundColor3 = v and th.Accent or th.SurfaceHigh}, 0.22)
                    T(trS,   {Color = v and th.Accent or th.Border}, 0.22)
                    T(thumb, {Position = v and UDim2.new(0,18,0.5,-7) or UDim2.new(0,4,0.5,-7)}, 0.22, Enum.EasingStyle.Back)
                    if not silent then pcall(cb, v) end
                end

                local ov = Btn({Color=Color3.new(0,0,0),Trans=1,Size=UDim2.new(1,0,1,0),Parent=el})
                ov.MouseButton1Click:Connect(function() Set(not data.Value) end)
                el.MouseEnter:Connect(function() T(el,{BackgroundColor3=th.SurfaceHigh},0.14) end)
                el.MouseLeave:Connect(function() T(el,{BackgroundColor3=th.SurfaceElevated},0.14) end)

                data.Set = Set
                data.Get = function() return data.Value end
                return data
            end

            --------------------------------------------
            -- SLIDER
            --------------------------------------------
            function sec:CreateSlider(sc2)
                local lbl  = sc2.Title    or "Slider"
                local min_ = sc2.Min      or 0
                local max_ = sc2.Max      or 100
                local def  = sc2.Default  or min_
                local step = sc2.Step     or 1
                local cb   = sc2.Callback or function() end
                local fmt  = sc2.Format   or function(v) return tostring(v) end

                local row  = Row(64)
                local el   = El(row, 50)
                local data = {Value=def}

                Lbl({Text=lbl,Color=th.Text,Size=13,Font=Enum.Font.GothamMedium,
                    FSize=UDim2.new(1,-90,0,18),Pos=UDim2.new(0,12,0,8),Parent=el})

                local valLbl = Lbl({
                    Text=fmt(def),Color=th.Accent,Size=11,Font=Enum.Font.GothamBold,
                    XA=Enum.TextXAlignment.Right,
                    FSize=UDim2.new(0,72,0,18),Pos=UDim2.new(1,-82,0,8),Parent=el,
                })

                local trBg = Frame({
                    Color=th.SurfaceHigh,
                    Size=UDim2.new(1,-24,0,4),
                    Pos=UDim2.new(0,12,0,33),
                    Parent=el,
                })
                Corner(trBg,4)

                local initPct = (def-min_)/(max_-min_)
                local trFill = Frame({Color=th.Accent,Size=UDim2.new(initPct,0,1,0),Parent=trBg})
                Corner(trFill,4)

                local handle = Frame({
                    Color=Color3.new(1,1,1),
                    Size=UDim2.new(0,14,0,14),
                    Pos=UDim2.new(initPct,-7,0.5,-7),
                    Parent=trBg,
                })
                Corner(handle,7)
                Stroke(handle,th.Accent,2)

                local draggingS = false

                local function Update(ix)
                    local ap = trBg.AbsolutePosition.X
                    local as = trBg.AbsoluteSize.X
                    local p  = math.clamp((ix-ap)/as, 0, 1)
                    local raw= min_ + (max_-min_)*p
                    local sv = math.clamp(math.round(raw/step)*step, min_, max_)
                    data.Value = sv
                    local fp = (sv-min_)/(max_-min_)
                    T(trFill, {Size=UDim2.new(fp,0,1,0)},   0.04)
                    T(handle, {Position=UDim2.new(fp,-7,0.5,-7)}, 0.04)
                    valLbl.Text = fmt(sv)
                    pcall(cb, sv)
                end

                trBg.InputBegan:Connect(function(inp)
                    if inp.UserInputType==Enum.UserInputType.MouseButton1 then
                        draggingS=true; Update(inp.Position.X)
                    end
                end)
                UserInputService.InputChanged:Connect(function(inp)
                    if draggingS and inp.UserInputType==Enum.UserInputType.MouseMovement then Update(inp.Position.X) end
                end)
                UserInputService.InputEnded:Connect(function(inp)
                    if inp.UserInputType==Enum.UserInputType.MouseButton1 then draggingS=false end
                end)

                data.Set = function(v)
                    v = math.clamp(v,min_,max_)
                    data.Value = v
                    local fp = (v-min_)/(max_-min_)
                    T(trFill,{Size=UDim2.new(fp,0,1,0)},0.2)
                    T(handle,{Position=UDim2.new(fp,-7,0.5,-7)},0.2)
                    valLbl.Text = fmt(v)
                end
                return data
            end

            --------------------------------------------
            -- DROPDOWN
            --------------------------------------------
            function sec:CreateDropdown(dc)
                local lbl  = dc.Title    or "Dropdown"
                local opts = dc.Options  or {}
                local def  = dc.Default  or (opts[1] or "")
                local cb   = dc.Callback or function() end

                local row  = Row(52)
                row.AutomaticSize = Enum.AutomaticSize.Y
                row.ClipsDescendants = false

                local el   = El(row, 36)
                el.ClipsDescendants = false
                local data = {Value=def, _Open=false}

                Lbl({Text=lbl,Color=th.TextMuted,Size=10,FSize=UDim2.new(0.45,0,0,36),Pos=UDim2.new(0,12,0,0),Parent=el})
                local valLbl = Lbl({
                    Text=tostring(def),Color=th.Text,Size=12,Font=Enum.Font.GothamMedium,
                    XA=Enum.TextXAlignment.Right,
                    FSize=UDim2.new(0.5,-30,0,36),Pos=UDim2.new(0.48,0,0,0),Parent=el,
                })
                local arrow = Lbl({
                    Text="▾",Color=th.TextMuted,Size=11,XA=Enum.TextXAlignment.Center,
                    FSize=UDim2.new(0,22,0,36),Pos=UDim2.new(1,-28,0,0),Parent=el,
                })

                -- List panel
                local list = Frame({
                    Color=th.SurfaceElevated,
                    Size=UDim2.new(1,0,0,0),
                    Pos=UDim2.new(0,0,1,5),
                    Clips=true,
                })
                list.ZIndex = 12
                list.Visible= false
                list.Parent = el
                Corner(list,8)
                Stroke(list,th.Border,1)
                ListLayout(list,2)
                Padding(list,4,4,4,4)

                local function Populate()
                    for _, ch in ipairs(list:GetChildren()) do
                        if ch:IsA("TextButton") then ch:Destroy() end
                    end
                    for i, opt in ipairs(opts) do
                        local ob = Btn({
                            Color=Color3.new(0,0,0),Trans=1,
                            Text=opt, TC=opt==data.Value and th.Accent or th.Text,
                            TS=12, Font=Enum.Font.GothamMedium,
                            Size=UDim2.new(1,0,0,28),
                            Z=13, Parent=list,
                        })
                        ob.LayoutOrder = i
                        ob.TextXAlignment = Enum.TextXAlignment.Left
                        Corner(ob,6)
                        Padding(ob,0,8,0,8)
                        ob.MouseEnter:Connect(function() T(ob,{BackgroundTransparency=0,BackgroundColor3=th.SurfaceHigh},0.12) end)
                        ob.MouseLeave:Connect(function() T(ob,{BackgroundTransparency=1},0.12) end)
                        ob.MouseButton1Click:Connect(function()
                            data.Value = opt
                            valLbl.Text= opt
                            for _,c in ipairs(list:GetChildren()) do
                                if c:IsA("TextButton") then
                                    T(c,{TextColor3=c.Text==opt and th.Accent or th.Text},0.12)
                                end
                            end
                            pcall(cb, opt)
                        end)
                    end
                    return math.min(#opts*30+10, 172)
                end

                local function Toggle()
                    data._Open = not data._Open
                    if data._Open then
                        local h = Populate()
                        list.Visible = true
                        list.Size    = UDim2.new(1,0,0,0)
                        T(list,  {Size=UDim2.new(1,0,0,h)}, 0.22, Enum.EasingStyle.Back)
                        T(arrow, {Rotation=180}, 0.18)
                    else
                        T(list,  {Size=UDim2.new(1,0,0,0)}, 0.18)
                        T(arrow, {Rotation=0},   0.18)
                        task.delay(0.2, function()
                            if not data._Open and list.Parent then list.Visible=false end
                        end)
                    end
                end

                local ov = Btn({Color=Color3.new(0,0,0),Trans=1,Size=UDim2.new(1,0,1,0),Z=11,Parent=el})
                ov.MouseButton1Click:Connect(Toggle)
                el.MouseEnter:Connect(function() T(el,{BackgroundColor3=th.SurfaceHigh},0.14) end)
                el.MouseLeave:Connect(function() T(el,{BackgroundColor3=th.SurfaceElevated},0.14) end)

                -- Outside-click close
                UserInputService.InputBegan:Connect(function(inp)
                    if inp.UserInputType==Enum.UserInputType.MouseButton1 and data._Open then
                        local mp  = UserInputService:GetMouseLocation()
                        local lp  = list.AbsolutePosition
                        local ls  = list.AbsoluteSize
                        local ep  = el.AbsolutePosition
                        local es  = el.AbsoluteSize
                        local inL = mp.X>=lp.X and mp.X<=lp.X+ls.X and mp.Y>=lp.Y and mp.Y<=lp.Y+ls.Y
                        local inE = mp.X>=ep.X and mp.X<=ep.X+es.X and mp.Y>=ep.Y and mp.Y<=ep.Y+es.Y
                        if not inL and not inE then data._Open=true; Toggle() end
                    end
                end)

                data.Set        = function(v) data.Value=v; valLbl.Text=tostring(v) end
                data.SetOptions = function(o) opts=o; if data._Open then Populate() end end
                return data
            end

            --------------------------------------------
            -- TEXTBOX
            --------------------------------------------
            function sec:CreateTextbox(tbc)
                local lbl  = tbc.Title       or "Input"
                local ph   = tbc.Placeholder or "Enter value..."
                local def  = tbc.Default     or ""
                local cb   = tbc.Callback    or function() end
                local clf  = tbc.ClearOnFocus or false

                local row  = Row(64)
                local el   = El(row, 50)
                local eS   = Stroke(el, th.BorderSubtle, 1)
                local data = {Value=def}

                Lbl({Text=lbl,Color=th.TextMuted,Size=9,FSize=UDim2.new(1,-20,0,13),Pos=UDim2.new(0,12,0,8),Parent=el})

                local tb = Instance.new("TextBox")
                tb.BackgroundTransparency = 1
                tb.Size              = UDim2.new(1,-24,0,22)
                tb.Position          = UDim2.new(0,12,0,24)
                tb.Text              = def
                tb.PlaceholderText   = ph
                tb.PlaceholderColor3 = th.TextSubtle
                tb.TextColor3        = th.Text
                tb.TextSize          = 13
                tb.Font              = Enum.Font.GothamMedium
                tb.TextXAlignment    = Enum.TextXAlignment.Left
                tb.ClearTextOnFocus  = clf
                tb.BorderSizePixel   = 0
                tb.Parent            = el

                tb.Focused:Connect(function()
                    T(eS, {Color=th.Accent,Thickness=2}, 0.18)
                end)
                tb.FocusLost:Connect(function(enter)
                    T(eS, {Color=th.BorderSubtle,Thickness=1}, 0.18)
                    data.Value = tb.Text
                    pcall(cb, tb.Text, enter)
                end)

                data.Set = function(v) tb.Text=tostring(v); data.Value=v end
                data.Get = function() return data.Value end
                return data
            end

            --------------------------------------------
            -- KEYBIND
            --------------------------------------------
            function sec:CreateKeybind(kbc)
                local lbl  = kbc.Title    or "Keybind"
                local def  = kbc.Default  or Enum.KeyCode.Unknown
                local cb   = kbc.Callback or function() end

                local row  = Row(52)
                local el   = El(row, 36)
                local eS   = Stroke(el, th.BorderSubtle, 1)
                local data = {Value=def, _Listening=false}

                Lbl({Text=lbl,Color=th.Text,Size=13,Font=Enum.Font.GothamMedium,
                    FSize=UDim2.new(1,-100,1,0),Pos=UDim2.new(0,12,0,0),Parent=el})

                local kdisp = Frame({
                    Color=th.SurfaceHigh,
                    Size=UDim2.new(0,80,0,24),
                    Pos=UDim2.new(1,-90,0.5,-12),
                    Parent=el,
                })
                Corner(kdisp,6)
                Stroke(kdisp,th.Border,1)

                local kLbl = Lbl({
                    Text=def.Name,Color=th.Accent,Size=10,Font=Enum.Font.GothamBold,
                    XA=Enum.TextXAlignment.Center,FSize=UDim2.new(1,0,1,0),Parent=kdisp,
                })

                local function StartListen()
                    data._Listening=true
                    kLbl.Text="..."
                    T(kdisp,{BackgroundColor3=th.AccentDim},0.15)
                    T(eS,   {Color=th.Accent,Thickness=2},  0.15)
                end
                local function StopListen(key)
                    data._Listening=false
                    if key then
                        data.Value=key
                        kLbl.Text=key.Name
                        VantaLib._Keybinds[lbl]=key
                        pcall(cb,key)
                    else
                        kLbl.Text=data.Value.Name
                    end
                    T(kdisp,{BackgroundColor3=th.SurfaceHigh},0.15)
                    T(eS,   {Color=th.BorderSubtle,Thickness=1},0.15)
                end

                local ov=Btn({Color=Color3.new(0,0,0),Trans=1,Size=UDim2.new(1,0,1,0),Parent=el})
                ov.MouseButton1Click:Connect(function()
                    if data._Listening then StopListen(nil) else StartListen() end
                end)

                UserInputService.InputBegan:Connect(function(inp,proc)
                    if data._Listening then
                        if inp.KeyCode==Enum.KeyCode.Escape then StopListen(nil)
                        elseif inp.UserInputType==Enum.UserInputType.Keyboard then StopListen(inp.KeyCode) end
                    end
                end)

                data.Set = function(k) data.Value=k; kLbl.Text=k.Name end
                return data
            end

            --------------------------------------------
            -- LABEL (informational)
            --------------------------------------------
            function sec:CreateLabel(lc)
                local row = Row(36)
                local l   = Lbl({
                    Text=lc.Text or "",
                    Color=lc.Color or th.TextMuted,
                    Size=11,Wrap=true,
                    FSize=UDim2.new(1,-24,1,0),
                    Pos=UDim2.new(0,12,0,0),
                    Parent=row,
                })
                return { SetText=function(t) l.Text=t end, SetColor=function(c) l.TextColor3=c end }
            end

            table.insert(td._Secs, sec)
            return sec
        end

        return td
    end

    ------------------------------------------------
    -- Built-in Settings Tab
    ------------------------------------------------
    local settingsTab = Win:CreateTab({ Title="Settings", Icon="rbxassetid://7072725342" })
    settingsTab._Btn.LayoutOrder = 999  -- pin to bottom

    local appSec = settingsTab:CreateSection({ Title="Appearance" })

    local themeNames, themeMap = {}, {}
    for _, v in pairs(VantaLib.Themes) do
        table.insert(themeNames, v.Name)
        themeMap[v.Name] = v
    end
    table.sort(themeNames)

    appSec:CreateDropdown({
        Title   = "Theme",
        Options = themeNames,
        Default = VantaLib.ActiveTheme.Name,
        Callback = function(v)
            if themeMap[v] then
                VantaLib:SetTheme(themeMap[v])
                VantaLib:Notify({Title="Theme Changed",Description=v,Type="success"})
            end
        end,
    })

    local perfSec = settingsTab:CreateSection({ Title="Performance" })

    perfSec:CreateSlider({
        Title="Animation Speed", Min=0.5, Max=3, Default=VantaLib.Settings.AnimationSpeed,
        Step=0.5, Format=function(v) return v.."x" end,
        Callback=function(v) VantaLib.Settings.AnimationSpeed=v; Save() end,
    })
    perfSec:CreateSlider({
        Title="Notification Duration", Min=1, Max=10, Default=VantaLib.Settings.NotificationDuration,
        Step=0.5, Format=function(v) return v.."s" end,
        Callback=function(v) VantaLib.Settings.NotificationDuration=v; Save() end,
    })
    perfSec:CreateToggle({
        Title="Reduced Motion", Default=VantaLib.Settings.ReducedMotion,
        Callback=function(v) VantaLib.Settings.ReducedMotion=v; Save() end,
    })

    local aboutSec = settingsTab:CreateSection({ Title="About" })
    aboutSec:CreateLabel({Text=title.." "..ver.." — VantaLib Premium UI Framework"})
    aboutSec:CreateButton({
        Title="Save Settings", Description="Persist preferences to disk",
        Callback=function()
            Save()
            VantaLib:Notify({Title="Saved",Description="Settings written to VantaLib.json",Type="success"})
        end,
    })

    table.insert(VantaLib._Windows, Win)
    return Win
end

return VantaLib
