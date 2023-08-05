local LightingModeChanged = false

hook.Add( "PreRender", "fullbright", function()

	render.SetLightingMode( 1 )

	LightingModeChanged = true

end )


local function EndOfLightingMod()

	if LightingModeChanged then

		render.SetLightingMode( 0 )

		LightingModeChanged = false

	end

end

hook.Add( "PostRender", "fullbright", EndOfLightingMod )

hook.Add( "PreDrawHUD", "fullbright", EndOfLightingMod )

-- if enabled then alert --

if LightingModeChanged == false then 

	notification.AddLegacy( "Fullbright Loaded Successfully", NOTIFY_UNDO, 2 )
	
	surface.PlaySound( "buttons/button14.wav" )
end
if LightingModeChanged == true then 

	notification.AddLegacy( "Fullbright Loader Failed", NOTIFY_UNDO, 2 )
	
	surface.PlaySound( "buttons/button10.wav" )
end
