-- from xyzzyrp - edited by psychol.

local factions={
	["SAPD"]=true,
	["SACC"]=true,
	["PSP"]=true,
	["SARA"]=true,
}

function math.round(number, decimals, method)
    decimals = decimals or 0
    local factor = 10 ^ decimals
    if (method == "ceil" or method == "floor") then return math[method](number * factor) / factor
    else return tonumber(("%."..decimals.."f"):format(number)) end
end

local function kosztNaprawySilnika(v)
	local cost=math.random(120,140)
	local health=getElementHealth(v)
	local hp=(1-((health-200)/800))
	return (cost*hp)
end

local function kosztNaprawyElementu(v)
	return math.random(40,60)
end

local panele={
	[4]="Szyba przednia",
	[5]="Zderzak z przodu",
	[6]="Zderzak z tyłu"
}

local nazwyDrzwi={
	[0]="Maska",
	[1]="Bagażnik",
	[2]="Drzwi lewy przód",
	[3]="Drzwi prawy przód",
	[4]="Drzwi lewy tył",
	[5]="Drzwi prawy tył"
}

local nazwySwiatel={
	[0]="Światło lewy przód",
	[1]="Światło prawy przód",
	[2]="Światło lewy tył",
	[3]="Światło prawy tył"
}

local stanyPaneli={
	[0]=100,
	[1]=66,
	[2]=33,
	[3]=0,
}

function math.percent(percent,maxvalue)
    if tonumber(percent) and tonumber(maxvalue) then
        return (maxvalue*percent)/100
    end
    return false
end

function setCost(cost, discount)
	if(discount)then
		discount=50*((100-discount)/100)
		discount=math.percent(discount,cost)
		cost=cost+discount
		return math.floor(cost), math.floor(discount)
	end
	return math.floor(cost+math.percent(cost,20)), 0
end

function fillVehicleData(v, discount)
    local items = {}
        
	if getElementHealth(v) ~= 1000 then
		local cost,discount=setCost(math.round(math.abs(kosztNaprawySilnika(v))), discount)
        items[#items+1] = {id=-1, name="Silnik", cost=cost, discount=discount, stan=math.round(getElementHealth(v)/10)}
	end
    
    for i,panel in pairs(panele) do
        local stan = getVehiclePanelState(v, i)
        if stan ~= 0 then
            local koszt=kosztNaprawyElementu(v)*(stan)/6
			local cost,discount=setCost(math.round(koszt+2), discount)
            items[#items+1] = {id=i, name=panel, cost=cost, discount=discount, stan=stanyPaneli[stan]}
        end
    end
    
	for i=0,5 do
		local stan=getVehicleDoorState(v, i)
		if stan==2 or stan==3 or stan==4 then
			local koszt=kosztNaprawyElementu(v)*2/6
			local cost,discount=setCost(math.round(koszt+2), discount)
            items[#items+1] = {id=i+10, name=nazwyDrzwi[i], cost=cost, discount=discount, stan=0}
		end
    end
    
	for i=0,3 do
		local stan=getVehicleLightState(v, i)
		if stan==1 then
			local koszt=kosztNaprawyElementu(v)*2/6
			local cost,discount=setCost(math.round(koszt+2), discount)
            items[#items+1] = {id=i+20, name=nazwySwiatel[i], cost=cost, discount=discount, stan=0}
		end
	end

	local data=getElementData(v,"vehicle:group_ownerName")
	if(data and factions[data])then
		for i,v in pairs(items) do
			v.cost=math.random(5,20)
		end
	end
    
    return items
end