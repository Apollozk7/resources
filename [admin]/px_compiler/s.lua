local _writeScript = function ( responseData, errno, filepath )
	if errno > 0 then
		return
	end
	
	local file = fileCreate ( filepath )
	if file then
		fileWrite ( file, responseData )
		fileClose ( file )
	end
end

function compileScript ( filepath , compiled)
	local filename = gettok ( filepath, 1, 46 )
	if compiled then 
		filepath = string.sub(filepath, 0, #filepath-1)
	end
	
	local file = fileOpen ( filepath, true )
	if file then
		local content = fileRead ( file, fileGetSize ( file ) )
		fileClose ( file )	
		fetchRemote ( "https://luac.mtasa.com/?compile=1&debug=0&obfuscate=3", _writeScript, content, true, filename .. ".luac" )
	end
end

function compileAllScriptsInResource(resource)
	local xml = xmlLoadFile ( ":"..resource.."/meta.xml"  )
	if xml == false then
		return
	end
	
	local node
	local index = 0
	local _next = function ( )
		node = xmlFindChild ( xml, "script", index )
		index = index + 1
		return node
	end
	
	local num = 0
	while _next ( ) do
		if xmlNodeGetAttribute ( node, "special" ) == false then
			local filepath = xmlNodeGetAttribute ( node, "src" )
			local isClient = xmlNodeGetAttribute ( node, "type" )
			if isClient == "client" or isClient == "server" then 
				local compiled = false 
				if string.find(filepath, "luac") then 
					compiled = true 
				end

				iprint("Kompiluje: "..filepath)
				
				compileScript ( ":"..resource.."/"..filepath, compiled)
				num = num + 1
			end
		end
	end
end

function compileAllScripts()
	for k,v in ipairs(getResources()) do 
		local name = getResourceName(v)
		if string.find(name, "px") then 
			compileAllScriptsInResource(name)
		end
	end
end

--addEventHandler("onResourceStart", resourceRoot, compileAllScripts)

function compileMSScript(resourceName)
	local res = getResourceFromName(resourceName)
	if res then 
		compileAllScriptsInResource(resourceName)
		return true 
	end
	
	return false 
end 

function compileCMD(player, cmd, arg1)
	if getElementData(player, "user:admin") == 4 then
		if compileMSScript(arg1 or "") then 
			exports.px_noti:noti("Kompilowanie zasobu "..arg1..".", player, "info")
		else 
			exports.px_noti:noti("Nie znaleziono takiego zasobu.", player, "info")
		end
	end
end 
addCommandHandler("compile", compileCMD)