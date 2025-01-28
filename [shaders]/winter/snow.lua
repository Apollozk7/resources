local snow = {}
local settings = {type = "real", density = 100, wind_direction = {0.01,0.01}, wind_speed = 1, snowflake_min_size = 1, snowflake_max_size = 3, fall_speed_min = 1, fall_speed_max = 2, jitter = true}

local snowflakes = {}
local snowing = false

local box_width, box_depth, box_height, box_width_doubled, box_depth_doubled = 4,4,4,8,8
local position = {0,0,0}
local flake_removal = nil
local snow_fadein = 10
local snow_id = 1

sx,sy = guiGetScreenSize()
sx2,sy2 = sx/2,sy/2
localPlayer = getLocalPlayer()

function random(lower,upper)
	return lower+(math.random()*(upper-lower))
end

function startSnow()
	if not snowing then
		snowflakes = {}

		local lx,ly,lz = getWorldFromScreenPosition(0,0,1)
		local rx,ry,rz = getWorldFromScreenPosition(sx,0,1)
		box_width = getDistanceBetweenPoints3D(lx,ly,lz,rx,ry,rz)+3
		box_depth = box_width

		box_width_doubled = box_width*2
		box_depth_doubled = box_depth*2

		lx,ly,lz = getWorldFromScreenPosition(sx2,sy2,box_depth)
		position = {lx,ly,lz}

		for i=1, settings.density do
			local x,y,z = random(0,box_width*2),random(0,box_depth*2),random(0,box_height*2)
			createFlake(x-box_width,y-box_depth,z-box_height,0)
		end

		addEventHandler("onClientRender",root,drawSnow)
		snowing = true
		return true
	else
		return false
	end
	return false
end

function stopSnow()
	if snowing then
		removeEventHandler("onClientRender",root,drawSnow)

		for i,flake in pairs(snowflakes) do
			snowflakes[i] = nil
		end

		snowflakes = nil
		flake_removal = nil
		snowing = false

		return true
	end
	return false
end
addEventHandler("onClientResourceStop",resourceRoot,stopSnow)

function updateSnowType(type)
	if type then
		settings.type = type
		return true
	end
	return false
end

function updateSnowDensity(dense,blend,speed)
	if dense and tonumber(dense) then
		dense = tonumber(dense)
		if snowing then
			if blend then
				if dense > settings.density then
					if not tonumber(speed) then
						speed = 300
					end
					setTimer(function(old,new)
						for i=1, (new-old)/20, 1 do
							local x,y = random(0,box_width*2),random(0,box_depth*2)
							createFlake(x-box_width,y-box_depth,box_height,0)
						end
					end,tonumber(speed),20,settings.density,dense)

				elseif dense < settings.density then
					if not tonumber(speed) then
						speed = 10
					end
					flake_removal = {settings.density-dense,0,tonumber(speed)}
				end

				if not tonumber(speed) then
					speed = 0
				end
			else
				speed = 0
				if dense > settings.density then
					for i=settings.density+1, dense do
						local x,y = random(0,box_width*2),random(0,box_depth*2)
						createFlake(x-box_width,y-box_depth,box_height,0)
					end
				elseif dense < settings.density then
					for i=density, dense+1, -1 do
						table.remove(snowflakes,i)
					end
				end
			end
		else
			speed = 0
		end

		settings.density = tonumber(dense)
		return true
	end
	return false
end

function updateSnowWindDirection(xdir,ydir)
	if xdir and tonumber(xdir) and ydir and tonumber(ydir) then
		settings.wind_direction = {tonumber(xdir)/100,tonumber(ydir)/100}
		return true
	end
	return false
end

function updateSnowWindSpeed(speed)
	if speed and tonumber(speed) then
		settings.wind_speed = tonumber(speed)
		return true
	end
	return false
end

function updateSnowflakeSize(min,max)
	if min and tonumber(min) and max and tonumber(max) then
		settings.snowflake_min_size = tonumber(min)
		settings.snowflake_max_size = tonumber(max)
		return true
	end
	return false
end

function updateSnowFallSpeed(min,max)
	if min and tonumber(min) and max and tonumber(max) then
		settings.fall_speed_min = tonumber(min)
		settings.fall_speed_max = tonumber(max)
		return true
	end
	return false
end

function updateSnowAlphaFadeIn(alpha)
	if alpha and tonumber(alpha) then
		snow_fadein = tonumber(alpha)
		return true
	end
	return false
end

function updateSnowJitter(jit)
	settings.jitter = jit
end

function createFlake(x,y,z,alpha,i)
	if flake_removal then
		if (flake_removal[2] % flake_removal[3]) == 0 then
			flake_removal[1] = flake_removal[1] - 1
			if flake_removal[1] == 0 then
				flake_removal = nil
			end
			table.remove(snowflakes,i)
			return
		else
			flake_removal[2] = flake_removal[2] + 1
		end
	end

	snow_id = (snow_id % 4) + 1

	if i then
		local randy = math.random(0,180)
		snowflakes[i] = {x = x, y = y, z = z,
						 speed = math.random(settings.fall_speed_min,settings.fall_speed_max)/100,
						 size = 2^math.random(settings.snowflake_min_size,settings.snowflake_max_size),
						 section = {(snow_id % 2 == 1) and 0 or 32,  (snow_id < 3) and 0 or 32},
						 rot = randy,
						 alpha = alpha,
						 jitter_direction = {math.cos(math.rad(randy*2)), -math.sin(math.rad(math.random(0,360)))},
						 jitter_cycle = randy*2,
						 jitter_speed = 8
						}
	else
		local randy = math.random(0,180)
		table.insert(snowflakes,{x = x, y = y, z = z,
								 speed = math.random(settings.fall_speed_min,settings.fall_speed_max)/100,
								 size = 2^math.random(settings.snowflake_min_size,settings.snowflake_max_size),
								 section = {(snow_id % 2 == 1) and 0 or 32,  (snow_id < 3) and 0 or 32},
								 rot = randy,
								 alpha = alpha,
								 jitter_direction = {math.cos(math.rad(randy*2)), -math.sin(math.rad(math.random(0,360)))},
								 jitter_cycle = randy*2,
								 jitter_speed = 8
								}
					)
	end
end

function drawSnow()
	local tick = getTickCount()

	local cx,cy,cz = getCameraMatrix()

	local lx,ly,lz = getWorldFromScreenPosition(sx2,sy2,box_depth)

	if (isLineOfSightClear(cx,cy,cz,cx,cy,cz+20,true,false,false,true,false,true,false,localPlayer) or
		isLineOfSightClear(lx,ly,lz,lx,ly,lz+20,true,false,false,true,false,true,false,localPlayer)) then

		local check = getGroundPosition
		if testLineAgainstWater(cx,cy,cz,cx,cy,cz+20) then
			check = getWaterLevel
		end

		local gpx,gpy,gpz = lx+(-box_width),ly+(-box_depth),lz+15

		local ground = {}

		for i=1, 3 do
			local it = box_width_doubled*(i*0.25)
			ground[i] = {
				check(gpx+(it), gpy+(box_depth_doubled*0.25), gpz),
				check(gpx+(it), gpy+(box_depth_doubled*0.5), gpz),
				check(gpx+(it), gpy+(box_depth_doubled*0.75), gpz)
			}
		end

		local dx,dy,dz = position[1]-lx,position[2]-ly,position[3]-lz
		for i,flake in pairs(snowflakes) do
			if flake then
				if flake.z < (-box_height) then
					createFlake(random(0,box_width*2) - box_width, random(0,box_depth*2) - box_depth, box_height, 0, i)
				else
					local gx,gy = 2,2
					if flake.x <= (box_width_doubled*0.33)-box_width then gx = 1
					elseif flake.x >= (box_width_doubled*0.66)-box_width then gx = 3
					end

					if flake.y <= (box_depth_doubled*0.33)-box_depth then gy = 1
					elseif flake.y >= (box_depth_doubled*0.66)-box_depth then gy = 3
					end

					-- check it hasnt moved past the ground
					if ground[gx][gy] and (flake.z+lz) > ground[gx][gy] then
						local draw_x, draw_y, jitter_x, jitter_y = nil,nil,0,0

						-- draw all onscreen flakes
						if settings.jitter then
							local jitter_cycle = math.cos(flake.jitter_cycle) / flake.jitter_speed

							jitter_x = (flake.jitter_direction[1] * jitter_cycle )
							jitter_y = (flake.jitter_direction[2] * jitter_cycle )
						end

						draw_x,draw_y = getScreenFromWorldPosition(flake.x + lx + jitter_x, flake.y + ly + jitter_y ,flake.z + lz, 15, false)

						if draw_x and draw_y then
							dxDrawImageSection(draw_x, draw_y, flake.size, flake.size, flake.section[1], flake.section[2], 32, 32, "flakes/".. settings.type .. "_tile.png", flake.rot, 0, 0, tocolor(222,235,255,flake.alpha))
							flake.rot = flake.rot + settings.wind_speed

							if flake.alpha < 255 then
								flake.alpha = flake.alpha + snow_fadein
								if flake.alpha > 255 then flake.alpha = 255 end
							end
						end
					end


					if settings.jitter then
						flake.jitter_cycle = (flake.jitter_cycle % 360) + 0.1
					end

					flake.x = flake.x + (settings.wind_direction[1] * settings.wind_speed)
					flake.y = flake.y + (settings.wind_direction[2] * settings.wind_speed)

					flake.z = flake.z - flake.speed

					flake.x = flake.x + dx
					flake.y = flake.y + dy
					flake.z = flake.z + dz

					if flake.x < -box_width or flake.x > box_width or
						flake.y < -box_depth or flake.y > box_depth or
						flake.z > box_height then

						flake.x = flake.x - dx
						flake.y = flake.y - dy
						local x,y,z = (flake.x > 0 and -flake.x or math.abs(flake.x)),(flake.y > 0 and -flake.y or math.abs(flake.y)),random(0,box_height*2)

						createFlake(x, y, z - box_height, 255, i)
					end
				end
			end
		end
	end
	position = {lx,ly,lz}
end


local bEffectEnabled
local noiseTexture
local snowShader
local treeShader
local naughtyTreeShader
local maxEffectDistance = 250
local snowApplyList = {
						"*",
				}

local snowRemoveList = {
						"",												-- unnamed

						"vehicle*", "?emap*", "?hite*",					-- vehicles
						"*92*", "*wheel*", "*interior*",				-- vehicles
						"*handle*", "*body*", "*decal*",				-- vehicles
						"*8bit*", "*logos*", "*badge*",					-- vehicles
						"*plate*", "*sign*",							-- vehicles
						"headlight", "headlight1",						-- vehicles

						"shad*",										-- shadows
						"coronastar",									-- coronas
						"tx*",											-- grass effect
						"lod*",											-- lod models
						"cj_w_grad",									-- checkpoint texture
						"*cloud*",										-- clouds
						"*smoke*",										-- smoke
						"sphere_cj",									-- nitro heat haze mask
						"particle*",									-- particle skid and maybe others
						"*water*", "sw_sand", "coral",					-- sea
					}

local treeApplyList = {
						"sm_des_bush*", "*tree*", "*ivy*", "*pine*",	-- trees and shrubs
						"veg_*", "*largefur*", "hazelbr*", "weeelm",
						"*branch*", "cypress*",
						"*bark*", "gen_log", "trunk5",
						"bchamae", "vegaspalm01_128",

	}

local naughtyTreeApplyList = {
						"planta256", "sm_josh_leaf", "kbtree4_test", "trunk3",					-- naughty trees and shrubs
						"newtreeleaves128", "ashbrnch", "pinelo128", "tree19mi",
						"lod_largefurs07", "veg_largefurs05","veg_largefurs06",
						"fuzzyplant256", "foliage256", "cypress1", "cypress2",
	}


function enableGoundSnow()

	snowShader = dxCreateShader ( "snow_ground.fx", 0, maxEffectDistance )
	treeShader = dxCreateShader( "snow_trees.fx" )
	naughtyTreeShader = dxCreateShader( "snow_naughty_trees.fx" )
	sNoiseTexture = dxCreateTexture( "smallnoise3d.dds" )

	if not snowShader or not treeShader or not naughtyTreeShader or not sNoiseTexture then
		return nil
	end

	-- Setup shaders
	dxSetShaderValue( treeShader, "sNoiseTexture", sNoiseTexture )
	dxSetShaderValue( naughtyTreeShader, "sNoiseTexture", sNoiseTexture )
	dxSetShaderValue( snowShader, "sNoiseTexture", sNoiseTexture )
	dxSetShaderValue( snowShader, "sFadeEnd", maxEffectDistance )
	dxSetShaderValue( snowShader, "sFadeStart", maxEffectDistance/2 )

	for _,applyMatch in ipairs(snowApplyList) do
		engineApplyShaderToWorldTexture ( snowShader, applyMatch )
	end

	for _,removeMatch in ipairs(snowRemoveList) do
		engineRemoveShaderFromWorldTexture ( snowShader, removeMatch )
	end

	for _,applyMatch in ipairs(treeApplyList) do
		engineApplyShaderToWorldTexture ( treeShader, applyMatch )
	end

	for _,applyMatch in ipairs(naughtyTreeApplyList) do
		engineApplyShaderToWorldTexture ( naughtyTreeShader, applyMatch )
	end

	bEffectEnabled = true

end

function disableGoundSnow()
	if not bEffectEnabled then return end

	destroyElement( sNoiseTexture  )
	destroyElement( treeShader )
	destroyElement( naughtyTreeShader )
	destroyElement( snowShader )

	killTimer( vehTimer )

	bEffectEnabled = false
end

_dxCreateShader = dxCreateShader
function dxCreateShader( filepath, priority, maxDistance, bDebug )
	priority = priority or 0
	maxDistance = maxDistance or 0
	bDebug = bDebug or false

	local build = getVersion ().sortable:sub(9)
	local fullscreen = not dxGetStatus ().SettingWindowed
	if build < "03236" and fullscreen then
		maxDistance = 0
	end

	return _dxCreateShader ( filepath, priority, maxDistance, bDebug )
end

stopSnow()
disableGoundSnow()