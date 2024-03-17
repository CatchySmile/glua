-- Version 4.0
notification.AddLegacy( "ESP Loaded!", NOTIFY_UNDO, 2 )

surface.PlaySound( "buttons/button15.wav" )

Msg( "Load Successful\n" )

local function DrawESP()
    local localPlayer = LocalPlayer()
    local localPos = localPlayer:GetPos()
    local centerScrPos = Vector(ScrW() / 2, ScrH() / 2) -- Center of the screen

    local players = player.GetAll()

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
            local distanceColor = Color(0, 255, 0) -- Default color is green for close distance

            -- Adjust color based on distance
            if distance <= 3 then
                distanceColor = Color(255, 255, 255) -- White
            elseif distance <= 9 then
                distanceColor = Color(220, 255, 220) -- White-ish green
            elseif distance <= 24 then
                distanceColor = Color(0, 255, 0) -- Green
            elseif distance <= 44 then
                distanceColor = Color(255, 255, 0) -- Yellow
            elseif distance <= 78 then
                distanceColor = Color(255, 165, 0) -- Orange
            else
                distanceColor = Color(255, 0, 0) -- Red
            end

            surface.SetFont("DermaDefault")
            local distTextW, distTextH = surface.GetTextSize(distanceText)
            draw.RoundedBox(4, scrPos.x - distTextW / 2 - 2, scrPos.y + 2, distTextW + 4, distTextH + 4, Color(0, 0, 0, 100))
            draw.SimpleText(distanceText, "DermaDefault", scrPos.x, scrPos.y + 4, distanceColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
        end
    end
end
hook.Add("HUDPaint", "DrawESP", DrawESP)

hook.Add("PreDrawOpaqueRenderables", "DrawPlayerBoxesAndLines", function()
    local players = player.GetAll()
    local localPos = LocalPlayer():GetPos()

    -- Change the wireframe material to a blue wireframe material
    local blueWireframeMaterial = Material("models/wireframe")
    blueWireframeMaterial:SetVector("$color", Vector(0, 0, 1)) -- Set color to blue

    for _, ply in ipairs(players) do
        if IsValid(ply) and ply:IsPlayer() and ply:Alive() and ply ~= LocalPlayer() then -- Skip drawing wireframe box for local player
            local min, max = ply:GetCollisionBounds()
            local center = ply:GetPos()
            local size = (max - min) / 2

            -- Draw the wireframe around players
            cam.IgnoreZ(true)
            render.SetMaterial(blueWireframeMaterial) -- Use the blue wireframe material

            -- Draw lines between the current player and other players
            local pos1 = LocalPlayer():GetPos()
            for _, ply2 in ipairs(players) do
                if IsValid(ply2) and ply2:IsPlayer() and ply2:Alive() and ply ~= ply2 then
                    local pos2 = ply2:GetPos()

                    -- Calculate distance
                    local distance = localPos:Distance(ply2:GetPos()) / 50 -- Convert units to meters

                    -- Adjust color based on distance
                    local lineColor = Color(255, 255, 255, 255) -- Default color is white
                    if distance <= 3 then
                        lineColor = Color(255, 255, 255, 255) -- White
                    elseif distance <= 9 then
                        lineColor = Color(220, 255, 220, 255) -- White-ish green
                    elseif distance <= 24 then
                        lineColor = Color(0, 255, 0, 255) -- Green
                    elseif distance <= 44 then
                        lineColor = Color(255, 255, 0, 255) -- Yellow
                    elseif distance <= 78 then
                        lineColor = Color(255, 165, 0, 255) -- Orange
                    else
                        lineColor = Color(255, 0, 0, 255) -- Red
                    end

                    render.DrawLine(pos1, pos2, lineColor, true)
                end
            end

            render.DrawBox(center, ply:GetAngles(), min, max, lineColor, true)
            cam.IgnoreZ(false)
        end
    end
end)
