--[[
    VantaLib — Seere Edition
    Compact horizontal-tab UI framework for Roblox.
    Drop-in compatible with the original VantaLib API surface.

    Setup (ModuleScript):
        local VantaLib = require(game.ReplicatedStorage.VantaLib)

    Setup (executor):
        local VantaLib = loadstring(...)()

    Quick start:
        local Win  = VantaLib:CreateWindow({ Title="MyScript", Version="v1.0" })
        local Tab  = Win:CreateTab({ Title="Combat" })
        local Sec  = Tab:CreateSection({ Title="Aimbot", Column=1 })
        Sec:CreateToggle({ Title="Enable", Callback=function(v) end })
--]]

local VantaLib   = {}
VantaLib.__index = VantaLib

------------------------------------------------------------------------
-- SERVICES
------------------------------------------------------------------------
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local Players          = game:GetService("Players")
local HttpService      = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui", 10)

------------------------------------------------------------------------
-- THEMES  (Seere palette + extras)
------------------------------------------------------------------------
VantaLib.Themes = {
    Seere = {
        Name            = "Seere",
        Background      = Color3.fromRGB(13,  13,  13),
        Surface         = Color3.fromRGB(20,  20,  20),
        SurfaceElevated = Color3.fromRGB(26,  26,  26),
        SurfaceHigh     = Color3.fromRGB(34,  34,  34),
        Border          = Color3.fromRGB(44,  44,  44),
        BorderSubtle    = Color3.fromRGB(32,  32,  32),
        Accent          = Color3.fromRGB(235, 75,  120),
        AccentDim       = Color3.fromRGB(148, 40,  72),
        Text            = Color3.fromRGB(215, 215, 215),
        TextMuted       = Color3.fromRGB(128, 128, 128),
        TextSubtle      = Color3.fromRGB(68,  68,  68),
        Success         = Color3.fromRGB(100, 210, 130),
        Warning         = Color3.fromRGB(240, 178, 60),
        Error           = Color3.fromRGB(230, 68,  68),
        Info            = Color3.fromRGB(100, 162, 255),
    },
    Void = {
        Name            = "Void",
        Background      = Color3.fromRGB(8,   8,   12),
        Surface         = Color3.fromRGB(14,  14,  20),
        SurfaceElevated = Color3.fromRGB(20,  20,  28),
        SurfaceHigh     = Color3.fromRGB(28,  28,  38),
        Border          = Color3.fromRGB(44,  44,  58),
        BorderSubtle    = Color3.fromRGB(30,  30,  42),
        Accent          = Color3.fromRGB(158, 80,  255),
        AccentDim       = Color3.fromRGB(88,  40,  158),
        Text            = Color3.fromRGB(220, 215, 235),
        TextMuted       = Color3.fromRGB(128, 124, 148),
        TextSubtle      = Color3.fromRGB(70,  68,  88),
        Success         = Color3.fromRGB(100, 210, 130),
        Warning         = Color3.fromRGB(240, 178, 60),
        Error           = Color3.fromRGB(230, 68,  68),
        Info            = Color3.fromRGB(100, 162, 255),
    },
    Frost = {
        Name            = "Frost",
        Background      = Color3.fromRGB(10,  12,  18),
        Surface         = Color3.fromRGB(16,  19,  28),
        SurfaceElevated = Color3.fromRGB(22,  26,  38),
        SurfaceHigh     = Color3.fromRGB(30,  34,  50),
        Border          = Color3.fromRGB(50,  58,  80),
        BorderSubtle    = Color3.fromRGB(34,  40,  58),
        Accent          = Color3.fromRGB(90,  188, 255),
        AccentDim       = Color3.fromRGB(48,  118, 184),
        Text            = Color3.fromRGB(215, 225, 240),
        TextMuted       = Color3.fromRGB(128, 144, 174),
        TextSubtle      = Color3.fromRGB(70,  80,  108),
        Success         = Color3.fromRGB(100, 210, 130),
        Warning         = Color3.fromRGB(240, 178, 60),
        Error           = Color3.fromRGB(230, 68,  68),
        Info            = Color3.fromRGB(90,  188, 255),
    },
}

-- Backwards-compat aliases from original VantaLib
VantaLib.Themes.Obsidian        = VantaLib.Themes.Seere
VantaLib.Themes.EmeraldElite    = VantaLib.Themes.Frost
VantaLib.Themes.ArcticSilver    = VantaLib.Themes.Frost
VantaLib.Themes.MidnightViolet  = VantaLib.Themes.Void
VantaLib.Themes.CrimsonPrestige = VantaLib.Themes.Seere

------------------------------------------------------------------------
-- GLOBAL STATE
------------------------------------------------------------------------
VantaLib.ActiveTheme     = VantaLib.Themes.Seere
VantaLib.Settings        = {
    AnimationSpeed       = 1,
    NotificationDuration = 4,
    ReducedMotion        = false,
}
VantaLib._ThemeCallbacks = {}
VantaLib._Windows        = {}
VantaLib._NotifCount     = 0
VantaLib._NotifContainer = nil
VantaLib._Keybinds       = {}

------------------------------------------------------------------------
-- UTILITY HELPERS
------------------------------------------------------------------------
local function T(inst, props, dur, style, dir)
    dur   = (dur or 0.18) * (VantaLib.Settings.ReducedMotion and 0.01 or 1)
          / math.max(VantaLib.Settings.AnimationSpeed, 0.1)
    style = style or Enum.EasingStyle.Quart
    dir   = dir   or Enum.EasingDirection.Out
    local tw = TweenService:Create(inst, TweenInfo.new(dur, style, dir), props)
    tw:Play()
    return tw
end

local function Corner(p, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 3)
    c.Parent = p
    return c
end

local function Stroke(p, col, thick, trans)
    local s = Instance.new("UIStroke")
    s.Color           = col   or VantaLib.ActiveTheme.Border
    s.Thickness       = thick or 1
    s.Transparency    = trans or 0
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
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

local function HList(p, gap)
    local l = Instance.new("UIListLayout")
    l.FillDirection    = Enum.FillDirection.Horizontal
    l.SortOrder        = Enum.SortOrder.LayoutOrder
    l.Padding          = UDim.new(0, gap or 0)
    l.VerticalAlignment = Enum.VerticalAlignment.Center
    l.Parent = p
    return l
end

local function VList(p, gap)
    local l = Instance.new("UIListLayout")
    l.FillDirection = Enum.FillDirection.Vertical
    l.SortOrder     = Enum.SortOrder.LayoutOrder
    l.Padding       = UDim.new(0, gap or 0)
    l.Parent = p
    return l
end

local function Frame(props)
    local f = Instance.new("Frame")
    f.BackgroundColor3       = props.Color or Color3.new(0, 0, 0)
    f.BackgroundTransparency = props.Trans or 0
    f.Size                   = props.Size  or UDim2.new(1, 0, 1, 0)
    f.Position               = props.Pos   or UDim2.new(0, 0, 0, 0)
    f.BorderSizePixel        = 0
    f.ClipsDescendants       = props.Clips or false
    f.ZIndex                 = props.Z     or 1
    if props.Name   then f.Name   = props.Name   end
    if props.Parent then f.Parent = props.Parent end
    return f
end

local function Lbl(props)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.Text           = props.Text  or ""
    l.TextColor3     = props.Color or VantaLib.ActiveTheme.Text
    l.TextSize       = props.Size  or 11
    l.Font           = props.Font  or Enum.Font.GothamMedium
    l.TextXAlignment = props.XA    or Enum.TextXAlignment.Left
    l.TextYAlignment = props.YA    or Enum.TextYAlignment.Center
    l.TextWrapped    = props.Wrap  or false
    l.RichText       = props.Rich  or false
    l.Size           = props.FSize or UDim2.new(1, 0, 0, 18)
    l.Position       = props.Pos   or UDim2.new(0, 0, 0, 0)
    l.ZIndex         = props.Z     or 1
    if props.Name   then l.Name   = props.Name   end
    if props.Parent then l.Parent = props.Parent end
    return l
end

local function Btn(props)
    local b = Instance.new("TextButton")
    b.BackgroundColor3       = props.Color or Color3.new(0, 0, 0)
    b.BackgroundTransparency = props.Trans or 1
    b.Text                   = props.Text  or ""
    b.TextColor3             = props.TC    or VantaLib.ActiveTheme.Text
    b.TextSize               = props.TS    or 11
    b.Font                   = props.Font  or Enum.Font.GothamMedium
    b.Size                   = props.Size  or UDim2.new(1, 0, 0, 28)
    b.Position               = props.Pos   or UDim2.new(0, 0, 0, 0)
    b.BorderSizePixel        = 0
    b.AutoButtonColor        = false
    b.ZIndex                 = props.Z     or 1
    if props.Name   then b.Name   = props.Name   end
    if props.Parent then b.Parent = props.Parent end
    return b
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
            if VantaLib.Settings[k] ~= nil then VantaLib.Settings[k] = v end
        end
    end
    if type(data.Theme) == "string" then
        for _, th in pairs(VantaLib.Themes) do
            if th.Name == data.Theme then VantaLib.ActiveTheme = th; break end
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
        Color = Color3.new(0, 0, 0), Trans = 1,
        Size  = UDim2.new(0, 272, 1, 0),
        Pos   = UDim2.new(1, -284, 0, 0),
        Clips = false, Name = "NC", Parent = sg,
    })
    local ll = Instance.new("UIListLayout")
    ll.SortOrder         = Enum.SortOrder.LayoutOrder
    ll.VerticalAlignment = Enum.VerticalAlignment.Bottom
    ll.Padding           = UDim.new(0, 5)
    ll.Parent            = c
    Padding(c, 10, 0, 10, 0)
    VantaLib._NotifContainer = c
end

function VantaLib:Notify(cfg)
    EnsureNotifContainer()
    local th   = self.ActiveTheme
    local dur  = cfg.Duration or self.Settings.NotificationDuration
    local kind = cfg.Type     or "info"
    local kc   = ({info=th.Info,success=th.Success,warning=th.Warning,error=th.Error})[kind] or th.Info

    self._NotifCount += 1
    local n = Frame({
        Color = th.Surface,
        Size  = UDim2.new(1, 0, 0, 60),
        Pos   = UDim2.new(1.1, 0, 0, 0),
        Clips = true,
        Name  = "N"..self._NotifCount,
        Parent = self._NotifContainer,
    })
    n.LayoutOrder = self._NotifCount
    Corner(n, 3)
    Stroke(n, th.Border, 1)

    Frame({ Color=kc, Size=UDim2.new(0,2,1,0), Parent=n })

    Lbl({
        Text  = cfg.Title or "Notification",
        Color = th.Text, Size=11, Font=Enum.Font.GothamBold,
        FSize = UDim2.new(1,-14,0,14), Pos=UDim2.new(0,11,0,9),
        Parent = n,
    })
    Lbl({
        Text  = cfg.Description or "",
        Color = th.TextMuted, Size=9, Wrap=true,
        FSize = UDim2.new(1,-14,0,20), Pos=UDim2.new(0,11,0,25),
        Parent = n,
    })

    local pbg = Frame({Color=th.SurfaceHigh,Size=UDim2.new(1,-12,0,2),Pos=UDim2.new(0,6,1,-4),Parent=n})
    Corner(pbg, 2)
    local pf = Frame({Color=kc,Size=UDim2.new(1,0,1,0),Parent=pbg})
    Corner(pf, 2)

    n.BackgroundTransparency = 1
    T(n, {BackgroundTransparency=0,Position=UDim2.new(0,0,0,0)}, 0.22, Enum.EasingStyle.Quart)
    task.delay(0.16, function() T(pf,{Size=UDim2.new(0,0,1,0)},dur,Enum.EasingStyle.Linear) end)
    task.delay(dur+0.16, function()
        T(n, {BackgroundTransparency=1,Position=UDim2.new(1.1,0,0,0)}, 0.2)
        task.delay(0.22, function() pcall(n.Destroy, n) end)
    end)
    return n
end

------------------------------------------------------------------------
-- LOADER  (Seere-themed)
------------------------------------------------------------------------
function VantaLib:ShowLoader(cfg)
    local th      = self.ActiveTheme
    local appName = cfg.AppName   or "VANTA"
    local sub     = cfg.Subtitle  or "PREMIUM"
    local ver     = cfg.Version   or "v1.0.0"
    local onDone  = cfg.OnComplete

    local sg = Instance.new("ScreenGui")
    sg.Name="VantaLoader"; sg.ResetOnSpawn=false
    sg.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
    sg.DisplayOrder=1000; sg.IgnoreGuiInset=true; sg.Parent=PlayerGui

    local bg = Frame({Color=th.Background,Size=UDim2.new(1,0,1,0),Parent=sg})

    -- Scanline overlay
    local sl = Instance.new("ImageLabel")
    sl.BackgroundTransparency=1
    sl.Image="rbxassetid://2592362371"
    sl.ImageColor3=Color3.new(0,0,0)
    sl.ImageTransparency=0.9
    sl.Size=UDim2.new(1,0,1,0)
    sl.Parent=bg

    -- Card
    local card = Frame({
        Color=th.Surface,
        Size=UDim2.new(0,290,0,184),
        Pos=UDim2.new(0.5,-145,0.5,-92),
        Clips=false, Parent=bg,
    })
    Corner(card, 3)
    Stroke(card, th.Border, 1)

    -- Top accent strip
    Frame({Color=th.Accent,Size=UDim2.new(1,0,0,2),Parent=card})

    -- Monogram box
    local lb = Frame({
        Color=th.SurfaceElevated,
        Size=UDim2.new(0,38,0,38),
        Pos=UDim2.new(0.5,-19,0,18),
        Parent=card,
    })
    Corner(lb, 3)
    Stroke(lb, th.Accent, 1, 0.5)
    Lbl({
        Text=string.upper(string.sub(appName,1,1)),
        Color=th.Accent, Size=18, Font=Enum.Font.GothamBlack,
        XA=Enum.TextXAlignment.Center,
        FSize=UDim2.new(1,0,1,0), Parent=lb,
    })

    Lbl({
        Text=appName, Color=th.Text, Size=13, Font=Enum.Font.GothamBlack,
        XA=Enum.TextXAlignment.Center,
        FSize=UDim2.new(1,0,0,16), Pos=UDim2.new(0,0,0,66), Parent=card,
    })
    Lbl({
        Text=sub, Color=th.Accent, Size=8,
        XA=Enum.TextXAlignment.Center,
        FSize=UDim2.new(1,0,0,12), Pos=UDim2.new(0,0,0,84), Parent=card,
    })

    local statusLbl = Lbl({
        Text="Initializing...", Color=th.TextMuted, Size=9,
        XA=Enum.TextXAlignment.Center,
        FSize=UDim2.new(1,0,0,12), Pos=UDim2.new(0,0,0,106), Parent=card,
    })

    local barBg = Frame({
        Color=th.SurfaceHigh,
        Size=UDim2.new(1,-28,0,2),
        Pos=UDim2.new(0,14,0,128), Parent=card,
    })
    local barFill = Frame({Color=th.Accent,Size=UDim2.new(0,0,1,0),Parent=barBg})

    local pctLbl = Lbl({
        Text="0%", Color=th.Accent, Size=9, Font=Enum.Font.GothamBold,
        XA=Enum.TextXAlignment.Center,
        FSize=UDim2.new(1,0,0,12), Pos=UDim2.new(0,0,0,139), Parent=card,
    })
    Lbl({
        Text=ver, Color=th.TextSubtle, Size=8,
        XA=Enum.TextXAlignment.Center,
        FSize=UDim2.new(1,0,0,12), Pos=UDim2.new(0,0,0,157), Parent=card,
    })

    -- Entrance
    card.BackgroundTransparency=1
    card.Position=UDim2.new(0.5,-145,0.5,-82)
    task.spawn(function()
        task.wait(0.1)
        T(card,{BackgroundTransparency=0,Position=UDim2.new(0.5,-145,0.5,-92)},0.3,Enum.EasingStyle.Back)
    end)

    local msgs={"Initializing...","Loading assets...","Preparing workspace...","Configuring...","Almost ready...","Done"}
    local function Progress(pct, msg)
        T(barFill,{Size=UDim2.new(pct/100,0,1,0)},0.32,Enum.EasingStyle.Quart)
        if msg and statusLbl.Parent then
            T(statusLbl,{TextTransparency=1},0.07)
            task.delay(0.1,function()
                if statusLbl.Parent then statusLbl.Text=msg; T(statusLbl,{TextTransparency=0},0.08) end
            end)
        end
        local from=tonumber(pctLbl.Text:match("%d+")) or 0
        for s=1,10 do
            task.wait(0.022)
            if pctLbl.Parent then pctLbl.Text=math.floor(from+(pct-from)*s/10).."%" end
        end
    end

    task.spawn(function()
        task.wait(0.52);  Progress(16,msgs[1])
        task.wait(0.55);  Progress(36,msgs[2])
        task.wait(0.5);   Progress(56,msgs[3])
        task.wait(0.45);  Progress(74,msgs[4])
        task.wait(0.4);   Progress(92,msgs[5])
        task.wait(0.35);  Progress(100,msgs[6])
        task.wait(0.5)
        T(bg,{BackgroundTransparency=1},0.4)
        task.wait(0.44)
        sg:Destroy()
        if onDone then pcall(onDone) end
    end)

    return sg
end

------------------------------------------------------------------------
-- WINDOW
------------------------------------------------------------------------
function VantaLib:CreateWindow(cfg)
    Load()
    local th       = self.ActiveTheme
    local title    = cfg.Title     or "VANTA"
    local subtitle = cfg.Subtitle  or ""
    local winW     = cfg.Width     or 700
    local winH     = cfg.Height    or 448
    local toggleK  = cfg.ToggleKey or Enum.KeyCode.RightShift
    local ver      = cfg.Version   or "v1.0.0"

    local TITLEH   = 32
    local TABH     = 30
    local CONTENTY = TITLEH + TABH

    local Win = { _Tabs={}, _ActiveTab=nil, _Open=true }

    -- ScreenGui
    local sg = Instance.new("ScreenGui")
    sg.Name="VantaLib_"..title; sg.ResetOnSpawn=false
    sg.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
    sg.DisplayOrder=100; sg.IgnoreGuiInset=true; sg.Parent=PlayerGui
    Win._Gui=sg

    -- Main frame
    local mf = Frame({
        Color=th.Background,
        Size=UDim2.new(0,winW,0,winH),
        Pos=UDim2.new(0.5,-winW/2,0.5,-winH/2),
        Clips=true, Name="Main", Parent=sg,
    })
    Corner(mf, 4)
    Stroke(mf, th.Border, 1)
    Win._MF = mf

    -- Entrance scale-in
    mf.BackgroundTransparency=1
    mf.Size=UDim2.new(0,winW*0.97,0,winH*0.97)
    mf.Position=UDim2.new(0.5,-winW*0.97/2,0.5,-winH*0.97/2)
    task.spawn(function()
        task.wait(0.04)
        T(mf,{
            BackgroundTransparency=0,
            Size=UDim2.new(0,winW,0,winH),
            Position=UDim2.new(0.5,-winW/2,0.5,-winH/2),
        },0.28,Enum.EasingStyle.Quart)
    end)

    ----------------------------------------------------------------
    -- TITLE BAR
    ----------------------------------------------------------------
    local tbar = Frame({
        Color=th.Surface,
        Size=UDim2.new(1,0,0,TITLEH),
        Name="TitleBar", Parent=mf,
    })
    -- bottom border
    Frame({Color=th.Border,Size=UDim2.new(1,0,0,1),Pos=UDim2.new(0,0,1,-1),Parent=tbar})

    -- Title
    Lbl({
        Text=title, Color=th.Text, Size=12, Font=Enum.Font.GothamBold,
        FSize=UDim2.new(0,180,1,0), Pos=UDim2.new(0,10,0,0),
        Parent=tbar,
    })

    -- Subtitle (optional)
    if subtitle ~= "" then
        Lbl({
            Text=subtitle, Color=th.TextSubtle, Size=9,
            FSize=UDim2.new(0,140,1,0), Pos=UDim2.new(0,118,0,1),
            Parent=tbar,
        })
    end

    -- Version label (right side)
    Lbl({
        Text=ver, Color=th.TextSubtle, Size=9,
        XA=Enum.TextXAlignment.Right,
        FSize=UDim2.new(0,60,1,0), Pos=UDim2.new(1,-94,0,0),
        Parent=tbar,
    })

    -- Close button
    local closeBtn = Btn({
        Color=Color3.new(0,0,0), Trans=1,
        Size=UDim2.new(0,26,0,17),
        Pos=UDim2.new(1,-30,0.5,-8.5),
        Parent=tbar,
    })
    Corner(closeBtn, 3)
    local closeL = Lbl({
        Text="✕", Color=th.TextMuted, Size=10, Font=Enum.Font.GothamBold,
        XA=Enum.TextXAlignment.Center,
        FSize=UDim2.new(1,0,1,0), Parent=closeBtn,
    })
    closeBtn.MouseEnter:Connect(function()
        T(closeBtn,{BackgroundTransparency=0,BackgroundColor3=Color3.fromRGB(200,50,50)},0.1)
        T(closeL,{TextColor3=Color3.new(1,1,1)},0.1)
    end)
    closeBtn.MouseLeave:Connect(function()
        T(closeBtn,{BackgroundTransparency=1},0.1)
        T(closeL,{TextColor3=th.TextMuted},0.1)
    end)

    ----------------------------------------------------------------
    -- TAB BAR
    ----------------------------------------------------------------
    local tabBar = Frame({
        Color=th.Surface,
        Size=UDim2.new(1,0,0,TABH),
        Pos=UDim2.new(0,0,0,TITLEH),
        Name="TabBar", Parent=mf,
    })
    -- bottom border
    Frame({Color=th.Border,Size=UDim2.new(1,0,0,1),Pos=UDim2.new(0,0,1,-1),Parent=tabBar})

    -- Container for tab buttons (UIListLayout horizontal)
    local btnCont = Frame({
        Color=Color3.new(0,0,0), Trans=1,
        Size=UDim2.new(1,0,1,-1),
        Clips=false, Parent=tabBar,
    })
    HList(btnCont, 0)

    -- Sliding underline (sibling of btnCont inside tabBar,
    -- NOT in the horizontal layout because it's positioned absolutely
    -- relative to tabBar, not btnCont)
    local underline = Frame({
        Color=th.Accent,
        Size=UDim2.new(0,0,0,2),
        Pos=UDim2.new(0,0,1,-1),
        Parent=tabBar,
    })
    Win._Underline = underline

    ----------------------------------------------------------------
    -- CONTENT HOST  (fills the rest below titlebar + tabbar)
    ----------------------------------------------------------------
    local ch = Frame({
        Color=th.Background,
        Size=UDim2.new(1,0,1,-CONTENTY),
        Pos=UDim2.new(0,0,0,CONTENTY),
        Clips=true, Name="ContentHost", Parent=mf,
    })
    Win._CH = ch

    ----------------------------------------------------------------
    -- DRAG
    ----------------------------------------------------------------
    local dragging, dragStart, dragBase = false, nil, nil
    tbar.InputBegan:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1 then
            dragging=true; dragStart=inp.Position; dragBase=mf.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if dragging and inp.UserInputType==Enum.UserInputType.MouseMovement then
            local d=inp.Position-dragStart
            mf.Position=UDim2.new(
                dragBase.X.Scale, dragBase.X.Offset+d.X,
                dragBase.Y.Scale, dragBase.Y.Offset+d.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end
    end)

    ----------------------------------------------------------------
    -- OPEN / CLOSE
    ----------------------------------------------------------------
    local function Close()
        Win._Open=false
        T(mf,{BackgroundTransparency=1,Size=UDim2.new(0,winW*0.97,0,winH*0.97)},0.2,
            Enum.EasingStyle.Quart,Enum.EasingDirection.In)
        task.delay(0.22,function() mf.Visible=false end)
    end
    local function Open()
        Win._Open=true; mf.Visible=true
        T(mf,{BackgroundTransparency=0,Size=UDim2.new(0,winW,0,winH)},0.25,Enum.EasingStyle.Back)
    end
    Win.Close=Close; Win.Open=Open
    Win.Toggle=function() if Win._Open then Close() else Open() end end

    closeBtn.MouseButton1Click:Connect(Close)
    UserInputService.InputBegan:Connect(function(inp,proc)
        if not proc and inp.KeyCode==toggleK then Win:Toggle() end
    end)

    ----------------------------------------------------------------
    -- THEME PROPAGATION
    ----------------------------------------------------------------
    VantaLib:OnThemeChange(function(nT)
        T(mf,        {BackgroundColor3=nT.Background}, 0.22)
        T(tbar,      {BackgroundColor3=nT.Surface},    0.22)
        T(tabBar,    {BackgroundColor3=nT.Surface},    0.22)
        T(ch,        {BackgroundColor3=nT.Background}, 0.22)
        T(underline, {BackgroundColor3=nT.Accent},     0.22)
    end)

    ----------------------------------------------------------------
    -- CreateTab
    ----------------------------------------------------------------
    function Win:CreateTab(tc)
        local tabTitle = tc.Title or "Tab"
        local order    = #self._Tabs + 1
        local td       = { _Secs={} }

        -- Tab button (auto-width via AutomaticSize)
        local tb = Instance.new("TextButton")
        tb.BackgroundColor3       = Color3.new(0,0,0)
        tb.BackgroundTransparency = 1
        tb.Text                   = ""
        tb.Size                   = UDim2.new(0,0,1,0)
        tb.AutomaticSize          = Enum.AutomaticSize.X
        tb.BorderSizePixel        = 0
        tb.AutoButtonColor        = false
        tb.LayoutOrder            = order
        tb.Parent                 = btnCont

        -- Inner label with horizontal padding for hit area
        local tl = Instance.new("TextLabel")
        tl.BackgroundTransparency = 1
        tl.Text           = tabTitle
        tl.TextColor3     = th.TextMuted
        tl.TextSize       = 11
        tl.Font           = Enum.Font.GothamMedium
        tl.Size           = UDim2.new(0,0,1,0)
        tl.AutomaticSize  = Enum.AutomaticSize.X
        tl.TextXAlignment = Enum.TextXAlignment.Center
        tl.Parent         = tb
        Padding(tl, 0, 18, 0, 18)

        td._TBtn = tb; td._TLbl = tl

        -- Content page
        local page = Frame({
            Color=Color3.new(0,0,0), Trans=1,
            Size=UDim2.new(1,0,1,0),
            Clips=false, Parent=ch,
        })
        page.Visible = false

        -- Two-column layout  (Column=1 → left, Column=2 → right)
        local colL = Frame({
            Color=Color3.new(0,0,0), Trans=1,
            Size=UDim2.new(0.5,-7,1,0),
            Pos=UDim2.new(0,6,0,0),
            Clips=false, Parent=page,
        })
        local colR = Frame({
            Color=Color3.new(0,0,0), Trans=1,
            Size=UDim2.new(0.5,-7,1,0),
            Pos=UDim2.new(0.5,1,0,0),
            Clips=false, Parent=page,
        })

        local function MakeScroll(parent)
            local sc = Instance.new("ScrollingFrame")
            sc.BackgroundTransparency = 1
            sc.Size                   = UDim2.new(1,0,1,0)
            sc.BorderSizePixel        = 0
            sc.ScrollBarThickness     = 2
            sc.ScrollBarImageColor3   = th.Border
            sc.CanvasSize             = UDim2.new(0,0,0,0)
            sc.AutomaticCanvasSize    = Enum.AutomaticSize.Y
            sc.ScrollingDirection     = Enum.ScrollingDirection.Y
            sc.Parent                 = parent
            VList(sc, 5)
            Padding(sc, 6, 4, 8, 4)
            return sc
        end

        td._Page = page
        td._ColL = MakeScroll(colL)
        td._ColR = MakeScroll(colR)

        -- Select this tab
        local function Select()
            if Win._ActiveTab then
                local pt = Win._ActiveTab
                T(pt._TLbl, {TextColor3=th.TextMuted}, 0.14)
                pt._Page.Visible = false
            end
            Win._ActiveTab = td
            T(tl, {TextColor3=th.Text}, 0.14)
            page.Visible = true

            -- Slide underline to this tab's position
            task.spawn(function()
                task.wait()
                local ap = tb.AbsolutePosition.X
                local as = tb.AbsoluteSize.X
                local bp = tabBar.AbsolutePosition.X
                T(underline, {
                    Position = UDim2.new(0, ap-bp, 1, -1),
                    Size     = UDim2.new(0, as,    0,  2),
                }, 0.18, Enum.EasingStyle.Quart)
            end)
        end

        td.Select = Select
        tb.MouseButton1Click:Connect(Select)
        tb.MouseEnter:Connect(function()
            if Win._ActiveTab ~= td then
                T(tl, {TextColor3=Color3.fromRGB(175,175,175)}, 0.1)
            end
        end)
        tb.MouseLeave:Connect(function()
            if Win._ActiveTab ~= td then
                T(tl, {TextColor3=th.TextMuted}, 0.1)
            end
        end)

        table.insert(Win._Tabs, td)
        if #Win._Tabs == 1 then task.spawn(Select) end

        ------------------------------------------------------------
        -- CreateSection
        ------------------------------------------------------------
        function td:CreateSection(sc)
            local secTitle = sc.Title  or ""
            local col      = sc.Column or 1
            local scroll   = (col == 2) and self._ColR or self._ColL
            local secOrder = #self._Secs + 1
            local sec      = { _Ord = 0 }

            -- Section frame
            local sf = Frame({
                Color=th.Surface,
                Size=UDim2.new(1,0,0,0),
                Clips=false, Parent=scroll,
            })
            sf.AutomaticSize = Enum.AutomaticSize.Y
            sf.LayoutOrder   = secOrder
            Corner(sf, 3)
            Stroke(sf, th.Border, 1)

            -- Inner content container (vertical list)
            local inner = Frame({
                Color=Color3.new(0,0,0), Trans=1,
                Size=UDim2.new(1,0,0,0),
                Clips=false, Parent=sf,
            })
            inner.AutomaticSize = Enum.AutomaticSize.Y
            VList(inner, 0)
            -- no horizontal padding on inner — rows handle their own inset

            -- Section header
            if secTitle ~= "" then
                local sh = Frame({
                    Color=Color3.new(0,0,0), Trans=1,
                    Size=UDim2.new(1,0,0,24),
                    Parent=inner,
                })
                sh.LayoutOrder = 0
                Frame({Color=th.Accent,Trans=0.5,Size=UDim2.new(0,2,0,9),Pos=UDim2.new(0,8,0.5,-4.5),Parent=sh})
                Lbl({
                    Text=secTitle, Color=th.TextMuted, Size=9, Font=Enum.Font.GothamBold,
                    FSize=UDim2.new(1,-14,1,0), Pos=UDim2.new(0,14,0,0),
                    Parent=sh,
                })
                Frame({Color=th.Border,Size=UDim2.new(1,0,0,1),Pos=UDim2.new(0,0,1,-1),Parent=sh})
            end

            sec._Inner = inner; sec._SF = sf

            -- Row order counter (title = 0, rows ≥ 1)
            local function NextOrd()
                sec._Ord = sec._Ord + 1
                return sec._Ord
            end

            -- Transparent row container (matches section width)
            local function Row(h)
                local r = Frame({
                    Color=Color3.new(0,0,0), Trans=1,
                    Size=UDim2.new(1,0,0,h or 32),
                    Parent=inner,
                })
                r.LayoutOrder = NextOrd()
                return r
            end

            -- Element panel (inset 8px each side inside the row)
            local function El(parent, h)
                h = h or 28
                local e = Frame({
                    Color=th.SurfaceElevated,
                    Size=UDim2.new(1,-16,0,h),
                    Pos=UDim2.new(0,8,0.5,-h/2),
                    Parent=parent,
                })
                Corner(e, 3)
                Stroke(e, th.BorderSubtle, 1)
                return e
            end

            --------------------------------------------------------
            -- BUTTON
            --------------------------------------------------------
            function sec:CreateButton(bc)
                local lbl  = bc.Title       or "Button"
                local desc = bc.Description or ""
                local cb   = bc.Callback    or function() end
                local h    = desc~="" and 40 or 28
                local row  = Row(h+5)
                local el   = El(row, h)

                Lbl({
                    Text=lbl, Color=th.Text, Size=11, Font=Enum.Font.GothamMedium,
                    FSize=UDim2.new(1,-16,0,14),
                    Pos=UDim2.new(0,8,0,desc~=""and 5 or 7),
                    Parent=el,
                })
                if desc~="" then
                    Lbl({
                        Text=desc, Color=th.TextSubtle, Size=9,
                        FSize=UDim2.new(1,-16,0,12),
                        Pos=UDim2.new(0,8,0,20),
                        Parent=el,
                    })
                end
                local ov = Btn({Color=Color3.new(0,0,0),Trans=1,Size=UDim2.new(1,0,1,0),Parent=el})
                ov.MouseEnter:Connect(function()    T(el,{BackgroundColor3=th.SurfaceHigh},0.1) end)
                ov.MouseLeave:Connect(function()    T(el,{BackgroundColor3=th.SurfaceElevated},0.1) end)
                ov.MouseButton1Down:Connect(function() T(el,{BackgroundColor3=th.AccentDim},0.08) end)
                ov.MouseButton1Up:Connect(function()   T(el,{BackgroundColor3=th.SurfaceHigh},0.1) end)
                ov.MouseButton1Click:Connect(function() pcall(cb) end)
            end

            --------------------------------------------------------
            -- TOGGLE
            --------------------------------------------------------
            function sec:CreateToggle(tc2)
                local lbl  = tc2.Title    or "Toggle"
                local def  = tc2.Default  or false
                local cb   = tc2.Callback or function() end
                local row  = Row(34)
                local el   = El(row, 28)
                local data = { Value=def }

                Lbl({Text=lbl,Color=th.Text,Size=11,Font=Enum.Font.GothamMedium,
                    FSize=UDim2.new(1,-48,1,0),Pos=UDim2.new(0,8,0,0),Parent=el})

                local track = Frame({
                    Color=def and th.Accent or th.SurfaceHigh,
                    Size=UDim2.new(0,28,0,15),
                    Pos=UDim2.new(1,-34,0.5,-7.5),
                    Parent=el,
                })
                Corner(track, 8)
                local trkS = Stroke(track, def and th.Accent or th.Border, 1)

                local thumb = Frame({
                    Color=Color3.new(1,1,1),
                    Size=UDim2.new(0,10,0,10),
                    Pos=def and UDim2.new(0,15,0.5,-5) or UDim2.new(0,3,0.5,-5),
                    Parent=track,
                })
                Corner(thumb, 5)

                local function Set(v, silent)
                    data.Value = v
                    T(track, {BackgroundColor3=v and th.Accent or th.SurfaceHigh},  0.16)
                    T(trkS,  {Color=v and th.Accent or th.Border},                  0.16)
                    T(thumb, {Position=v and UDim2.new(0,15,0.5,-5) or UDim2.new(0,3,0.5,-5)},
                             0.16, Enum.EasingStyle.Back)
                    if not silent then pcall(cb, v) end
                end

                local ov = Btn({Color=Color3.new(0,0,0),Trans=1,Size=UDim2.new(1,0,1,0),Parent=el})
                ov.MouseButton1Click:Connect(function() Set(not data.Value) end)
                el.MouseEnter:Connect(function() T(el,{BackgroundColor3=th.SurfaceHigh},0.1) end)
                el.MouseLeave:Connect(function() T(el,{BackgroundColor3=th.SurfaceElevated},0.1) end)

                data.Set = Set
                data.Get = function() return data.Value end
                return data
            end

            --------------------------------------------------------
            -- SLIDER
            --------------------------------------------------------
            function sec:CreateSlider(sc2)
                local lbl  = sc2.Title    or "Slider"
                local min_ = sc2.Min      or 0
                local max_ = sc2.Max      or 100
                local def  = sc2.Default  or min_
                local step = sc2.Step     or 1
                local cb   = sc2.Callback or function() end
                local fmt  = sc2.Format   or function(v) return tostring(v) end
                local row  = Row(48)
                local el   = El(row, 42)
                local data = { Value=def }

                Lbl({Text=lbl,Color=th.Text,Size=11,Font=Enum.Font.GothamMedium,
                    FSize=UDim2.new(1,-72,0,14),Pos=UDim2.new(0,8,0,6),Parent=el})

                local valLbl = Lbl({
                    Text=fmt(def), Color=th.Accent, Size=10, Font=Enum.Font.GothamBold,
                    XA=Enum.TextXAlignment.Right,
                    FSize=UDim2.new(0,56,0,14), Pos=UDim2.new(1,-62,0,6), Parent=el,
                })

                local trBg = Frame({
                    Color=th.SurfaceHigh,
                    Size=UDim2.new(1,-16,0,3),
                    Pos=UDim2.new(0,8,0,27),
                    Parent=el,
                })
                Corner(trBg, 3)

                local initP = math.clamp((def-min_)/(max_==min_ and 1 or max_-min_),0,1)
                local trFill = Frame({Color=th.Accent,Size=UDim2.new(initP,0,1,0),Parent=trBg})
                Corner(trFill, 3)

                local handle = Frame({
                    Color=Color3.new(1,1,1),
                    Size=UDim2.new(0,9,0,9),
                    Pos=UDim2.new(initP,-4.5,0.5,-4.5),
                    Parent=trBg,
                })
                Corner(handle, 5)
                Stroke(handle, th.Accent, 1)

                local dragS = false
                local function Update(ix)
                    local ap = trBg.AbsolutePosition.X
                    local as = trBg.AbsoluteSize.X
                    if as==0 then return end
                    local p  = math.clamp((ix-ap)/as,0,1)
                    local sv = math.clamp(math.round((min_+(max_-min_)*p)/step)*step,min_,max_)
                    data.Value = sv
                    local fp = math.clamp((sv-min_)/(max_==min_ and 1 or max_-min_),0,1)
                    T(trFill,{Size=UDim2.new(fp,0,1,0)},0.04)
                    T(handle,{Position=UDim2.new(fp,-4.5,0.5,-4.5)},0.04)
                    valLbl.Text = fmt(sv)
                    pcall(cb,sv)
                end

                trBg.InputBegan:Connect(function(inp)
                    if inp.UserInputType==Enum.UserInputType.MouseButton1 then
                        dragS=true; Update(inp.Position.X)
                    end
                end)
                UserInputService.InputChanged:Connect(function(inp)
                    if dragS and inp.UserInputType==Enum.UserInputType.MouseMovement then
                        Update(inp.Position.X)
                    end
                end)
                UserInputService.InputEnded:Connect(function(inp)
                    if inp.UserInputType==Enum.UserInputType.MouseButton1 then dragS=false end
                end)

                data.Set = function(v)
                    v=math.clamp(v,min_,max_); data.Value=v
                    local fp=math.clamp((v-min_)/(max_==min_ and 1 or max_-min_),0,1)
                    T(trFill,{Size=UDim2.new(fp,0,1,0)},0.16)
                    T(handle,{Position=UDim2.new(fp,-4.5,0.5,-4.5)},0.16)
                    valLbl.Text=fmt(v)
                end
                return data
            end

            --------------------------------------------------------
            -- DROPDOWN
            --------------------------------------------------------
            function sec:CreateDropdown(dc)
                local lbl  = dc.Title    or "Dropdown"
                local opts = dc.Options  or {}
                local def  = dc.Default  or (opts[1] or "")
                local cb   = dc.Callback or function() end

                local row = Row(32)
                row.ClipsDescendants = false

                local el = Frame({
                    Color=th.SurfaceElevated,
                    Size=UDim2.new(1,-16,0,26),
                    Pos=UDim2.new(0,8,0,3),
                    Clips=false, Parent=row,
                })
                Corner(el, 3)
                Stroke(el, th.BorderSubtle, 1)
                local data = { Value=def, _Open=false }

                Lbl({Text=lbl,Color=th.TextMuted,Size=9,
                    FSize=UDim2.new(0.46,-4,1,0),Pos=UDim2.new(0,8,0,0),Parent=el})
                local valLbl = Lbl({
                    Text=tostring(def),Color=th.Text,Size=10,Font=Enum.Font.GothamMedium,
                    XA=Enum.TextXAlignment.Right,
                    FSize=UDim2.new(0.52,-22,1,0),Pos=UDim2.new(0.46,0,0,0),Parent=el,
                })
                local arrow = Lbl({
                    Text="▾",Color=th.Accent,Size=10,XA=Enum.TextXAlignment.Center,
                    FSize=UDim2.new(0,18,1,0),Pos=UDim2.new(1,-20,0,0),Parent=el,
                })

                local list = Frame({
                    Color=th.Surface,
                    Size=UDim2.new(1,0,0,0),
                    Pos=UDim2.new(0,0,1,2),
                    Clips=true, Parent=el,
                })
                list.ZIndex=12; list.Visible=false
                Corner(list,3); Stroke(list,th.Border,1)
                VList(list, 1); Padding(list, 3, 3, 3, 3)

                local function Populate()
                    for _,c in ipairs(list:GetChildren()) do
                        if c:IsA("TextButton") then c:Destroy() end
                    end
                    for i,opt in ipairs(opts) do
                        local ob = Btn({
                            Color=Color3.new(0,0,0),Trans=1,
                            Text=opt,TC=opt==data.Value and th.Accent or th.Text,
                            TS=10,Font=Enum.Font.GothamMedium,
                            Size=UDim2.new(1,0,0,20),Z=13,Parent=list,
                        })
                        ob.LayoutOrder=i
                        ob.TextXAlignment=Enum.TextXAlignment.Left
                        Corner(ob,2); Padding(ob,0,6,0,6)
                        ob.MouseEnter:Connect(function()
                            T(ob,{BackgroundTransparency=0,BackgroundColor3=th.SurfaceHigh},0.1)
                        end)
                        ob.MouseLeave:Connect(function()
                            T(ob,{BackgroundTransparency=1},0.1)
                        end)
                        ob.MouseButton1Click:Connect(function()
                            data.Value=opt; valLbl.Text=opt
                            for _,c2 in ipairs(list:GetChildren()) do
                                if c2:IsA("TextButton") then
                                    T(c2,{TextColor3=c2.Text==opt and th.Accent or th.Text},0.1)
                                end
                            end
                            pcall(cb,opt)
                        end)
                    end
                    return math.min(#opts*21+8,148)
                end

                local function Toggle()
                    data._Open = not data._Open
                    if data._Open then
                        local h=Populate(); list.Visible=true; list.Size=UDim2.new(1,0,0,0)
                        T(list,{Size=UDim2.new(1,0,0,h)},0.16,Enum.EasingStyle.Back)
                        T(arrow,{Rotation=180},0.12)
                    else
                        T(list,{Size=UDim2.new(1,0,0,0)},0.14)
                        T(arrow,{Rotation=0},0.12)
                        task.delay(0.15,function()
                            if not data._Open then list.Visible=false end
                        end)
                    end
                end

                local ov=Btn({Color=Color3.new(0,0,0),Trans=1,Size=UDim2.new(1,0,1,0),Z=11,Parent=el})
                ov.MouseButton1Click:Connect(Toggle)
                el.MouseEnter:Connect(function() T(el,{BackgroundColor3=th.SurfaceHigh},0.1) end)
                el.MouseLeave:Connect(function() T(el,{BackgroundColor3=th.SurfaceElevated},0.1) end)

                UserInputService.InputBegan:Connect(function(inp)
                    if inp.UserInputType==Enum.UserInputType.MouseButton1 and data._Open then
                        local mp=UserInputService:GetMouseLocation()
                        local lp=list.AbsolutePosition; local ls=list.AbsoluteSize
                        local ep=el.AbsolutePosition;   local es=el.AbsoluteSize
                        local inL=mp.X>=lp.X and mp.X<=lp.X+ls.X and mp.Y>=lp.Y and mp.Y<=lp.Y+ls.Y
                        local inE=mp.X>=ep.X and mp.X<=ep.X+es.X and mp.Y>=ep.Y and mp.Y<=ep.Y+es.Y
                        if not inL and not inE then data._Open=true; Toggle() end
                    end
                end)

                data.Set        = function(v) data.Value=v; valLbl.Text=tostring(v) end
                data.SetOptions = function(o) opts=o; if data._Open then Populate() end end
                return data
            end

            --------------------------------------------------------
            -- TEXTBOX
            --------------------------------------------------------
            function sec:CreateTextbox(tbc)
                local lbl  = tbc.Title        or "Input"
                local ph   = tbc.Placeholder  or "Enter value..."
                local def  = tbc.Default      or ""
                local cb   = tbc.Callback     or function() end
                local clf  = tbc.ClearOnFocus or false

                local row  = Row(48)
                local el   = El(row, 42)
                local eS   = Stroke(el, th.BorderSubtle, 1)
                local data = { Value=def }

                Lbl({Text=lbl,Color=th.TextMuted,Size=9,
                    FSize=UDim2.new(1,-16,0,12),Pos=UDim2.new(0,8,0,5),Parent=el})

                local tb = Instance.new("TextBox")
                tb.BackgroundTransparency = 1
                tb.Size              = UDim2.new(1,-16,0,17)
                tb.Position          = UDim2.new(0,8,0,20)
                tb.Text              = def
                tb.PlaceholderText   = ph
                tb.PlaceholderColor3 = th.TextSubtle
                tb.TextColor3        = th.Text
                tb.TextSize          = 11
                tb.Font              = Enum.Font.GothamMedium
                tb.TextXAlignment    = Enum.TextXAlignment.Left
                tb.ClearTextOnFocus  = clf
                tb.BorderSizePixel   = 0
                tb.Parent            = el

                tb.Focused:Connect(function()   T(eS,{Color=th.Accent},0.14) end)
                tb.FocusLost:Connect(function(enter)
                    T(eS,{Color=th.BorderSubtle},0.14)
                    data.Value=tb.Text; pcall(cb,tb.Text,enter)
                end)

                data.Set = function(v) tb.Text=tostring(v); data.Value=v end
                data.Get = function() return data.Value end
                return data
            end

            --------------------------------------------------------
            -- KEYBIND
            --------------------------------------------------------
            function sec:CreateKeybind(kbc)
                local lbl  = kbc.Title    or "Keybind"
                local def  = kbc.Default  or Enum.KeyCode.Unknown
                local cb   = kbc.Callback or function() end
                local row  = Row(34)
                local el   = El(row, 28)
                local eS   = Stroke(el, th.BorderSubtle, 1)
                local data = { Value=def, _Listening=false }

                Lbl({Text=lbl,Color=th.Text,Size=11,Font=Enum.Font.GothamMedium,
                    FSize=UDim2.new(1,-90,1,0),Pos=UDim2.new(0,8,0,0),Parent=el})

                local kBx = Frame({
                    Color=th.SurfaceHigh,
                    Size=UDim2.new(0,70,0,17),
                    Pos=UDim2.new(1,-76,0.5,-8.5),
                    Parent=el,
                })
                Corner(kBx,3); Stroke(kBx,th.Border,1)
                local kL = Lbl({
                    Text=def.Name, Color=th.Accent, Size=9, Font=Enum.Font.GothamBold,
                    XA=Enum.TextXAlignment.Center,
                    FSize=UDim2.new(1,0,1,0), Parent=kBx,
                })

                local function StartListen()
                    data._Listening=true; kL.Text="..."
                    T(kBx,{BackgroundColor3=th.AccentDim},0.12)
                    T(eS,{Color=th.Accent},0.12)
                end
                local function StopListen(key)
                    data._Listening=false
                    if key then
                        data.Value=key; kL.Text=key.Name
                        VantaLib._Keybinds[lbl]=key; pcall(cb,key)
                    else
                        kL.Text=data.Value.Name
                    end
                    T(kBx,{BackgroundColor3=th.SurfaceHigh},0.12)
                    T(eS,{Color=th.BorderSubtle},0.12)
                end

                local ov = Btn({Color=Color3.new(0,0,0),Trans=1,Size=UDim2.new(1,0,1,0),Parent=el})
                ov.MouseButton1Click:Connect(function()
                    if data._Listening then StopListen(nil) else StartListen() end
                end)
                UserInputService.InputBegan:Connect(function(inp,proc)
                    if data._Listening then
                        if inp.KeyCode==Enum.KeyCode.Escape then StopListen(nil)
                        elseif inp.UserInputType==Enum.UserInputType.Keyboard then StopListen(inp.KeyCode) end
                    end
                end)

                data.Set = function(k) data.Value=k; kL.Text=k.Name end
                return data
            end

            --------------------------------------------------------
            -- LABEL
            --------------------------------------------------------
            function sec:CreateLabel(lc)
                local row = Row(26)
                local l = Lbl({
                    Text=lc.Text or "", Color=lc.Color or th.TextMuted,
                    Size=10, Wrap=true,
                    FSize=UDim2.new(1,-16,1,0), Pos=UDim2.new(0,8,0,0),
                    Parent=row,
                })
                return {
                    SetText  = function(t) l.Text=t end,
                    SetColor = function(c) l.TextColor3=c end,
                }
            end

            --------------------------------------------------------
            -- SEPARATOR
            --------------------------------------------------------
            function sec:CreateSeparator()
                local row = Row(12)
                Frame({
                    Color=th.Border,
                    Size=UDim2.new(1,-16,0,1),
                    Pos=UDim2.new(0,8,0.5,0),
                    Parent=row,
                })
            end

            table.insert(td._Secs, sec)
            return sec
        end  -- end CreateSection

        return td
    end  -- end CreateTab

    ----------------------------------------------------------------
    -- Built-in Settings Tab
    ----------------------------------------------------------------
    local stab = Win:CreateTab({Title="Settings"})
    stab._TBtn.LayoutOrder = 999

    local appSec = stab:CreateSection({Title="Appearance",Column=1})
    local thNames, thMap = {}, {}
    for _,v in pairs(VantaLib.Themes) do
        if not thMap[v.Name] then thMap[v.Name]=v; table.insert(thNames,v.Name) end
    end
    table.sort(thNames)

    appSec:CreateDropdown({
        Title="Theme", Options=thNames, Default=VantaLib.ActiveTheme.Name,
        Callback=function(v)
            if thMap[v] then
                VantaLib:SetTheme(thMap[v])
                VantaLib:Notify({Title="Theme",Description=v,Type="success"})
            end
        end,
    })

    local perfSec = stab:CreateSection({Title="Performance",Column=2})
    perfSec:CreateSlider({
        Title="Anim Speed", Min=0.5, Max=3, Default=VantaLib.Settings.AnimationSpeed,
        Step=0.5, Format=function(v) return v.."x" end,
        Callback=function(v) VantaLib.Settings.AnimationSpeed=v; Save() end,
    })
    perfSec:CreateToggle({
        Title="Reduced Motion", Default=VantaLib.Settings.ReducedMotion,
        Callback=function(v) VantaLib.Settings.ReducedMotion=v; Save() end,
    })
    perfSec:CreateButton({
        Title="Save Settings",
        Callback=function() Save(); VantaLib:Notify({Title="Saved",Type="success"}) end,
    })

    table.insert(VantaLib._Windows, Win)
    return Win
end

return VantaLib
