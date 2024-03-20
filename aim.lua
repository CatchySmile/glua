hook.Add("Think", "LookAtVisiblePlayer", function()
    if input.IsKeyDown(KEY_H) then
        local ply = LocalPlayer()
        local nearestPlayer = nil
        local nearestDist = math.huge

        for _, v in ipairs(player.GetAll()) do
            if v ~= ply then
                local dist = ply:GetPos():Distance(v:GetPos())
                if dist < nearestDist then
                    nearestDist = dist
                    nearestPlayer = v
                end
            end
        end

        if IsValid(nearestPlayer) then
            local headPos = nearestPlayer:GetBonePosition(nearestPlayer:LookupBone("ValveBiped.Bip01_Head1")) -- Adjust the bone name according to your player model
            if headPos then
                local hasLineOfSight = true

                -- Check line of sight for each player
                for _, playerToCheck in ipairs(player.GetAll()) do
                    if playerToCheck ~= ply and playerToCheck ~= nearestPlayer then
                        local tr = util.TraceLine({
                            start = ply:GetShootPos(),
                            endpos = playerToCheck:EyePos(),
                            filter = {ply, playerToCheck, nearestPlayer}
                        })
                        
                        -- If there's an obstruction, set flag to false and break the loop
                        if tr.Hit then
                            hasLineOfSight = false
                            break
                        end
                    end
                end

                if hasLineOfSight then
                    local lookDir = (headPos - ply:GetShootPos()):GetNormalized()
                    local angles = lookDir:Angle()
                    ply:SetEyeAngles(angles)
                end
            end
        end
    end
end)
