-- Version 4.2
notification.AddLegacy("Press `Home` Key to customize ESP", NOTIFY_GENERIC, 5)
surface.PlaySound("buttons/button15.wav")
Msg("Press `Home` Key to customize ESP\n")

local function DrawESP()

    local localPlayer = LocalPlayer()
    local localPos = localPlayer:GetPos()

    local players = player.GetAll()

    -- Adjusted Distance Coloring
    local function GetDistanceColor(distance)
        local gradientValue = math.Clamp((distance - 3) / 100, 0, 1) -- Normalize distance between 3 and 100
        local r, g, b = 0, 255, 0 -- Default color is red
    
        -- Smooth gradient from green to red
        r = math.Clamp(gradientValue * 255, 0, 255) -- From green to red
        g = math.Clamp((1 - gradientValue) * 255, 0, 255) -- From red to green
        
        return Color(r, g, b)
    end

    for _, ply in ipairs(players) do
        if IsValid(ply) and ply:IsPlayer() and ply:Alive() and ply ~= localPlayer then -- Skip drawing text for local player
            local scrPos = ply:GetPos():ToScreen()

            -- Draw player health
            local health = ply:Health()
            local healthText = "HP: " .. health
            local healthColor = Color(0, 255, 0) -- Default color is green for high health

            -- Adjust color based on health
            if health <= 20 then
                healthColor = Color(255, 0, 0) -- Red
            elseif health >= 100 then
                healthColor = Color(0, 255, 0) -- Green
            else
                local gradientValue = (health - 20) / (100 - 20) -- Calculate gradient value between 0 and 1
                local r = 255 * (1 - gradientValue) -- Red channel decreases
                local g = 255 * gradientValue -- Green channel increases
                healthColor = Color(r, g, 0) -- Gradient color between red and green
            end

            surface.SetFont("DermaDefault")
            local healthTextW, healthTextH = surface.GetTextSize(healthText)
            draw.RoundedBox(4, scrPos.x - healthTextW / 2 - 2, scrPos.y - healthTextH - 12, healthTextW + 4, healthTextH + 4, Color(0, 0, 0, 100))
            draw.SimpleText(healthText, "DermaDefault", scrPos.x, scrPos.y - healthTextH - 10, healthColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)

            -- Draw player name
            local name = ply:Nick()
            local nameColor = Color(255, 255, 255) -- White

            surface.SetFont("DermaDefault")
            local textW, textH = surface.GetTextSize(name)
            draw.RoundedBox(4, scrPos.x - textW / 2 - 2, scrPos.y - textH - 28, textW + 4, textH + 4, Color(0, 0, 0, 100))
            draw.SimpleText(name, "DermaDefault", scrPos.x, scrPos.y - textH - 26, nameColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)

            -- Draw distance
            local distance = localPos:Distance(ply:GetPos()) / 50 -- Convert units to meters
            local distanceText = "Distance: " .. math.Round(distance) .. " meters"
            local distanceColor = GetDistanceColor(distance)

            surface.SetFont("DermaDefault")
            local distTextW, distTextH = surface.GetTextSize(distanceText)
            draw.RoundedBox(4, scrPos.x - distTextW / 2 - 2, scrPos.y + 2, distTextW + 4, distTextH + 4, Color(0, 0, 0, 100))
            draw.SimpleText(distanceText, "DermaDefault", scrPos.x, scrPos.y + 4, distanceColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
        end
    end
end
hook.Add("HUDPaint", "DrawESP", DrawESP)

-- Adjusted Line Coloring
local function GetLineColor(distance)
    local gradientValue = math.Clamp((distance - 3) / 100, 0, 1) -- Normalize distance between 3 and 100
    local r, g, b = 0, 255, 0 -- Default color is red
    
    -- Smooth gradient from green to red
    r = math.Clamp(gradientValue * 255, 0, 255) -- From green to red
    g = math.Clamp((1 - gradientValue) * 255, 0, 255) -- From red to green
    
    return Color(r, g, b)
end

hook.Add("PreDrawOpaqueRenderables", "DrawPlayerBoxesAndLines", function()
    local players = player.GetAll()
    local localPos = LocalPlayer():GetPos()

    -- Change the wireframe material to a custom wireframe material for coloring purpose
    local WireframeMaterial = Material("models/wireframe")
    local selectedColor = Color(192, 232, 33) -- Default color is prupl ahh
    local frame = nil

    -- Function to change the Wireframe material color
    local function ChangeWireframeColor(color)
        selectedColor = color
        WireframeMaterial:SetVector("$color", Vector(color.r / 255, color.g / 255, color.b / 255))
    end

    local lastMenuOpenTime = 0
    local menuOpenDelay = 300 -- in milliseconds

    -- Function to toggle the GUI menu
    local function ToggleMenu()
        local currentTime = CurTime() * 1000 -- Convert current time to milliseconds

        -- Check if enough time has passed since the last menu open
        if currentTime - lastMenuOpenTime >= menuOpenDelay then
            lastMenuOpenTime = currentTime -- Update the last menu open time

            if IsValid(frame) then
                frame:Remove()
                frame = nil -- Reset frame variable after removal
            else
                frame = vgui.Create("DFrame")
                frame:SetSize(300, 220)
                frame:SetTitle("`Home` To toggle this menu")
                frame:SetVisible(true)
                frame:SetDraggable(true)
                frame:ShowCloseButton(true)
                frame:MakePopup()
                frame:Center()

                -- Set the background color with opacity
                frame.Paint = function(self, w, h)
                    draw.RoundedBox(8, 0, 0, w, h, Color(0, 0, 0, 200)) -- Black background with 200 alpha
                end

                local colorMixer = vgui.Create("DColorMixer", frame)
                colorMixer:SetSize(250, 150)
                colorMixer:SetPos(20, 30)
                colorMixer:SetPalette(true)
                colorMixer:SetAlphaBar(false)
                colorMixer:SetWangs(true)
                colorMixer:SetColor(selectedColor)

                local applyButton = vgui.Create("DButton", frame)
                applyButton:SetText("Apply")
                applyButton:SetSize(80, 30)
                applyButton:SetPos(100, 185)
                applyButton.DoClick = function()
                    notification.AddLegacy("Applied!", NOTIFY_UNDO, 2)
                    surface.PlaySound("buttons/button15.wav")
                    Msg("Successfully Changed Color\n")
                    ChangeWireframeColor(colorMixer:GetColor())
                end
            end
        end
    end


    
    -- Register the toggle menu function to be called when the insert key is pressed
    hook.Add("PlayerButtonDown", "ToggleWireframeMenu", function(ply, key)
        if key == KEY_HOME then
            ToggleMenu()
        end
    end)

    
    for _, ply in ipairs(players) do
        if IsValid(ply) and ply:IsPlayer() and ply:Alive() and ply ~= LocalPlayer() then -- Skip drawing wireframe box for local player
            local min, max = ply:GetCollisionBounds()
            local center = ply:GetPos()
            local size = (max - min) / 2

            -- Draw the wireframe around players
            cam.IgnoreZ(true)
            render.SetMaterial(WireframeMaterial) -- Use the custom wireframe material

            local pos1 = LocalPlayer():GetPos()
            for _, ply2 in ipairs(players) do
                if IsValid(ply2) and ply2:IsPlayer() and ply2:Alive() and ply ~= ply2 then
                    local pos2 = ply2:GetPos()
                    local distance = localPos:Distance(ply2:GetPos()) / 50 -- Convert units to meters
                    local lineColor = GetLineColor(distance)
                    render.DrawLine(pos1, pos2, lineColor, true)
                end
            end

            render.DrawBox(center, ply:GetAngles(), min, max, selectedColor, true)
            cam.IgnoreZ(false)
        end
    end
end)
