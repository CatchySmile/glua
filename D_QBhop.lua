notification.AddLegacy( "Bhop Load Successful!", NOTIFY_UNDO, 2 )

surface.PlaySound( "buttons/button15.wav" )

Msg( "Bhop Load Successful\n" )


CreateClientConVar("lenny_bunnyhop", 1, true, false)

local function Bunnyhop()
    if GetConVar("lenny_bunnyhop"):GetInt() == 1 then
        if input.IsKeyDown(KEY_SPACE) then
            if LocalPlayer():IsOnGround() then
                RunConsoleCommand("+jump")
                timer.Simple(0.1, function()
                    RunConsoleCommand("-jump")
                end)
            else
                local velocity = LocalPlayer():GetVelocity()
                local forward = LocalPlayer():EyeAngles():Forward()
                local speed = velocity:Length2D()

                if speed > 30 then
                    local addSpeed = math.max(0, 30 - speed)
                    local pushVel = forward * (addSpeed + 100) * 10
                    LocalPlayer():SetVelocity(velocity + pushVel)
                end
            end
        end
    end
end

hook.Add("Think", "Bunnyhop", Bunnyhop)