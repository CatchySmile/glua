-- Version 3.2
notification.AddLegacy( "ESP Loaded!", NOTIFY_UNDO, 2 )

surface.PlaySound( "buttons/button15.wav" )

Msg( "Load Successful\n" )


local function DrawESP()
    local localPlayer = LocalPlayer()
    local localPos = localPlayer:GetPos()
    local centerScrPos = Vector(ScrW() / 2, ScrH() / 2) -- Center of the screen

    for _, ply in pairs(player.GetAll()) do
        if ply ~= localPlayer and ply:Alive() and ply:ShouldDrawLocalPlayer() == false then
            local plyPos = ply:GetPos()
            local distance = math.floor(localPos:Distance(plyPos) * 0.0254) -- Convert units to meters

            local pos = plyPos + Vector(0, 0, 80) -- Adjust the offset to position the ESP correctly
            local scrPos = pos:ToScreen()

            -- Calculate the hitbox coordinates
            local mins, maxs = ply:GetCollisionBounds()
            local hitboxMins = plyPos + mins
            local hitboxMaxs = plyPos + maxs
            local hitboxMinScrPos = hitboxMins:ToScreen()
            local hitboxMaxScrPos = hitboxMaxs:ToScreen()

            -- Check if the player is visible on the screen
            local isVisible = plyPos:ToScreen().visible

            -- Default values for topY and bottomY
            local topY = 0
            local bottomY = 0

            if isVisible then
                -- Draw filled gray box inside the hitbox outline from top to bottom
                topY = math.min(hitboxMinScrPos.y, hitboxMaxScrPos.y)
                bottomY = math.max(hitboxMinScrPos.y, hitboxMaxScrPos.y)

                -- Draw gray box outline
                surface.SetDrawColor(255, 255, 255) -- White outline color
                surface.DrawOutlinedRect(hitboxMinScrPos.x, topY, hitboxMaxScrPos.x - hitboxMinScrPos.x, bottomY - topY)

                -- Draw filled gray box
                surface.SetDrawColor(100, 100, 100, 89) -- Gray color at 35% opacity
                surface.DrawRect(hitboxMinScrPos.x + 1, topY + 1, hitboxMaxScrPos.x - hitboxMinScrPos.x - 2, bottomY - topY - 2)

                local boxCenterX = (hitboxMinScrPos.x + hitboxMaxScrPos.x) / 2 -- X coordinate of the box center
                local boxCenterY = (topY + bottomY) / 2 -- Y coordinate of the box center

                -- Calculate line color based on distance
                local lineColor = Color(0, 255, 0) -- Default color is green for close distance

                if distance <= 3 then
                    lineColor = Color(255, 255, 255) -- White
                elseif distance <= 9 then
                    lineColor = Color(220, 255, 220) -- White-ish green
                elseif distance <= 24 then
                    lineColor = Color(0, 255, 0) -- Green
                elseif distance <= 44 then
                    lineColor = Color(255, 255, 0) -- Yellow
                elseif distance <= 78 then
                    lineColor = Color(255, 165, 0) -- Orange
                else
                    lineColor = Color(255, 0, 0) -- Red
                end

                -- Draw lines leading to the middle of the gray box
                surface.SetDrawColor(lineColor.r, lineColor.g, lineColor.b) -- Set the color of the lines
                surface.DrawLine(boxCenterX, boxCenterY, centerScrPos.x, centerScrPos.y)
            end

            if scrPos.visible then
                -- Draw player health, name, distance

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
                draw.RoundedBox(4, scrPos.x - healthTextW / 2 - 2, scrPos.y - healthTextH - 22, healthTextW + 4, healthTextH + 4, Color(0, 0, 0, 100))
                draw.SimpleText(healthText, "DermaDefault", scrPos.x, scrPos.y - healthTextH - 20, healthColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)

                -- Draw player name
                local name = ply:Nick()
                local nameColor = Color(255, 255, 255) -- White

                surface.SetFont("DermaDefault")
                local textW, textH = surface.GetTextSize(name)
                draw.RoundedBox(4, scrPos.x - textW / 2 - 2, scrPos.y - textH - 6, textW + 4, textH + 4, Color(0, 0, 0, 100))
                draw.SimpleText(name, "DermaDefault", scrPos.x, scrPos.y - textH - 4, nameColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)

                -- Draw distance
                local distanceText = "Distance: " .. distance .. " meters"
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
end

hook.Add("HUDPaint", "DrawESP", DrawESP)
