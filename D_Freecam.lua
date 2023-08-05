notification.AddLegacy( "Freecam Loaded Successfully!", NOTIFY_UNDO, 2 )

surface.PlaySound( "buttons/button15.wav" )

Msg( "Freecam Load Successful\n" )


freecamAngles = Angle()
freecamAngles2 = Angle()
freecamPos = Vector()
freecamEnabled = false
freecamSpeed = 3
keyPressed = false
hook.Add("CreateMove", "lock_movement", function(ucmd)
    if(freecamEnabled) then
        ucmd:SetSideMove(0)
        ucmd:SetForwardMove(0)
        ucmd:SetViewAngles(freecamAngles2)
        ucmd:RemoveKey(IN_JUMP)
        ucmd:RemoveKey(IN_DUCK)
        freecamAngles = (freecamAngles + Angle(ucmd:GetMouseY() * .023, ucmd:GetMouseX() * -.023, 0));
        freecamAngles.p, freecamAngles.y, freecamAngles.x = math.Clamp(freecamAngles.p, -89, 89), math.NormalizeAngle(freecamAngles.y), math.NormalizeAngle(freecamAngles.x);
        local curFreecamSpeed = freecamSpeed
        if(input.IsKeyDown(KEY_LSHIFT)) then
            curFreecamSpeed = freecamSpeed * 2
        end
        if(input.IsKeyDown(KEY_W)) then
            freecamPos = freecamPos + (freecamAngles:Forward() * curFreecamSpeed)
        end
        if(input.IsKeyDown(KEY_S)) then
            freecamPos = freecamPos - (freecamAngles:Forward() * curFreecamSpeed)
        end
        if(input.IsKeyDown(KEY_A)) then
            freecamPos = freecamPos - (freecamAngles:Right() * curFreecamSpeed)
        end
        if(input.IsKeyDown(KEY_D)) then
            freecamPos = freecamPos + (freecamAngles:Right() * curFreecamSpeed)
        end
        if(input.IsKeyDown(KEY_SPACE)) then
            freecamPos = freecamPos + Vector(0,0,curFreecamSpeed)
        end
        if(input.IsKeyDown(KEY_LCONTROL)) then
            freecamPos = freecamPos - Vector(0,0,curFreecamSpeed)
        end
    end
end)
hook.Add("Tick", "checkKeybind", function()
    if(input.IsKeyDown(KEY_LALT)) then
        if(!keyPressed) then
            print("enable freecam")
            freecamEnabled = !freecamEnabled
            freecamAngles = LocalPlayer():EyeAngles()
            freecamAngles2 = LocalPlayer():EyeAngles()
            freecamPos = LocalPlayer():EyePos()
            keyPressed = true
        end
    else
        keyPressed = false
    end
end)
hook.Add("CalcView", "freeCam", function(ply, pos, angles, fov)
    local view = {}
    if(freecamEnabled) then
        view = {
            origin = freecamPos,
            angles = freecamAngles,
            fov = fov,
            drawviewer = true
        }
    else
        view = {
            origin = pos,
            angles = angles,
            fov = fov,
            drawviewer = false
        }
    end
	return view
end)
