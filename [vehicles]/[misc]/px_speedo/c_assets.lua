--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

-- variables

sw, sh = guiGetScreenSize()
zoom = 1920/sw

SPEEDO = {}

--blurs={}

-- tables

SPEEDO.gear="1"

SPEEDO.types={
    [2]={
      "Banshee",
      "Sultan",
      "Police SF",
      "Buffalo",
      "Bullet",
      "Cheetah",
      "Comet",
      "Elegy",
      "Infernus",
      "Jester",
      "Super GT",
      "Turismo",
      "ZR-350",
    },
  
    [1]={
      "Alpha",
      "Euros",
      "Blista Compact",
      "Premier",
      "Sentinel",
      "Taxi",
      "FBI Rancher",
      "Patriot",
      "News Van",
      "Huntley",
      "Flash",
      "Hotring Racer",
      "Hotring Racer 2",
      "Hotring Racer 3",
      "Stratum",
      "Uranus",
      "Windsor",
      "BF Injection",
      "Sandking",
      "Merit",
      "Fortune",
      "Elegant",
      "Washington",
      "Boxville Mission",
    },
  
    [6]={
      "Baggage",
      "Bus",
      "Coach",
      "Sweeper",
      "Towtruck",
      "Trashmaster",
      "Ambulance",
      "Barracks",
      "Enforcer",
      "FBI Truck",
      "Fire Truck",
      "Fire Truck Ladder",
      "S.W.A.T.",
      "Securicar",
      "Benson",
      "Black Boxville",
      "Boxville",
      "Cement Truck",
      "DFT-30",
      "Dozer",
      "Dumper",
      "Dune",
      "Flatbed",
      "Hotdog",
      "Linerunner",
      "Mr. Whoopee",
      "Mule",
      "Packer",
      "Roadtrain",
      "Tanker",
      "Tractor",
      "Yankee",
    },

    [4]={
        "Buccaneer",
        "Savanna",
        "Hustler",
        "Hermes",
        "Blade",
        "Remington",
        "Broadway",
        "Slamvan",
        "Tornado",
        "Voodoo",
        "Sabre",
        "Phoenix",
        "Clover",
        "Hotknife",
    },

    [3]={
        "BF-400",
        "Faggio",
        "FCR-900",
        "Freeway",
        "NRG-500",
        "Pizza Boy",
        "Sanchez",
        "Wayfarer",
        "Quadbike",
    },

    ["none"]={
        "Bike",
        "BMX",
        "Mountain Bike",
        "Combine Harvester",
        "Forklift",
        "Mower",
        "Kart",
        "Vortex",
    },

    [5]={
        "Bravura",
        "Cadrona",
        "Club",
        "Esperanto",
        "Feltzer",
        "Majestic",
        "Manana",
        "Picador",
        "Previon",
        "Stallion",
        "Tampa",
        "Virgo",
        "Admiral",
        "Damaged Glendale",
        "Emperor",
        "Glendale",
        "Greenwood",
        "Intruder",
        "Nebula",
        "Oceanic",
        "Primo",
        "Stafford",
        "Stretch",
        "Sunrise",
        "Tahoma",
        "Vincent",
        "Willard",
        "Cabbie",
        "Utility Van",
        "Police Ranger",
        "Berkley's RC Van",
        "Bobcat",
        "Burrito",
        "Damaged Sadler",
        "Moonbeam",
        "Pony",
        "Newsvan",
        "Rumpo",
        "Sadler",
        "Tug",
        "Walton",
        "Yosemite",
        "Landstalker",
        "Perennial",
        "Rancher",
        "Rancher",
        "Regina",
        "Romero",
        "Solair",
        "Bandito",
        "Bloodring Banger",
        "Caddy",
        "Camper",
        "Journey",
        "Mesa",
        "Monster",
        "Monster 2",
        "Monster 3",
        "Journey",
        "Mesa",
        "Journey",
        "Mesa",
        "Police LS",
        "Police LV",
    },

    [7]={
        "Andromada",
        "AT-400",
        "Beagle",
        "Cropduster",
        "Dodo",
        "Hydra",
        "Nevada",
        "Rustler",
        "Shamal",
        "Skimmer",
        "Stuntplane"
    },

    [8]={
        "Rhino"
    }
}

SPEEDO.TEXTURES = {
    [1]={
        create=function()
            SPEEDO.TEXTURES[1][1]=dxCreateTexture("textures/1/bg.png", "argb", true, "clamp")

            SPEEDO.TEXTURES[1][2]=dxCreateTexture("textures/1/speed_bg.png", "argb", true, "clamp")
            SPEEDO.TEXTURES[1][3]=dxCreateTexture("textures/1/speed.png", "argb", true, "clamp")

            SPEEDO.TEXTURES[1][4]=dxCreateTexture("textures/1/speed_2.png", "argb", true, "clamp")
            SPEEDO.TEXTURES[1][5]=dxCreateTexture("textures/1/speed_3.png", "argb", true, "clamp")

            SPEEDO.TEXTURES[1][6]=dxCreateTexture("textures/1/speed_bg_mask.png", "argb", true, "clamp")

            SPEEDO.TEXTURES[1][7]=dxCreateTexture("textures/1/fuel_bg.png", "argb", true, "clamp")
            SPEEDO.TEXTURES[1][8]=dxCreateTexture("textures/1/fuel.png", "argb", true, "clamp")
            SPEEDO.TEXTURES[1][9]=dxCreateTexture("textures/1/nitro_bg.png", "argb", true, "clamp")
            SPEEDO.TEXTURES[1][10]=dxCreateTexture("textures/1/nitro.png", "argb", true, "clamp")

            SPEEDO.TEXTURES[1][11]=dxCreateTexture("textures/1/elipses.png", "argb", true, "clamp")
        end
    },

    [2]={
        create=function()
            SPEEDO.TEXTURES[2][1]=dxCreateTexture("textures/2/bg.png", "argb", true, "clamp")

            SPEEDO.TEXTURES[2][2]=dxCreateTexture("textures/2/speed.png", "argb", true, "clamp")
            SPEEDO.TEXTURES[2][3]=dxCreateTexture("textures/2/speed-bg.png", "argb", true, "clamp")

            SPEEDO.TEXTURES[2][4]=dxCreateTexture("textures/2/speed-small.png", "argb", true, "clamp")
            SPEEDO.TEXTURES[2][5]=dxCreateTexture("textures/2/speed-bg-small.png", "argb", true, "clamp")

            SPEEDO.TEXTURES[2][6]=dxCreateTexture("textures/2/car-light.png", "argb", true, "clamp")
            SPEEDO.TEXTURES[2][7]=dxCreateTexture("textures/2/car-light-on.png", "argb", true, "clamp")

            SPEEDO.TEXTURES[2][8]=dxCreateTexture("textures/2/engine.png", "argb", true, "clamp")
            SPEEDO.TEXTURES[2][9]=dxCreateTexture("textures/2/engine-on.png", "argb", true, "clamp")

            SPEEDO.TEXTURES[2][10]=dxCreateTexture("textures/2/handbrake.png", "argb", true, "clamp")
            SPEEDO.TEXTURES[2][11]=dxCreateTexture("textures/2/handbrake-on.png", "argb", true, "clamp")

            SPEEDO.TEXTURES[2][12]=dxCreateTexture("textures/2/fuel-bg.png", "argb", true, "clamp")
            SPEEDO.TEXTURES[2][13]=dxCreateTexture("textures/2/fuel.png", "argb", true, "clamp")

            SPEEDO.TEXTURES[2][14]=dxCreateTexture("textures/2/speed2.png", "argb", true, "clamp")
            SPEEDO.TEXTURES[2][15]=dxCreateTexture("textures/2/speed3.png", "argb", true, "clamp")
            SPEEDO.TEXTURES[2][16]=dxCreateTexture("textures/2/speed4.png", "argb", true, "clamp")

            SPEEDO.TEXTURES[2][17]=dxCreateTexture("textures/2/distance.png", "argb", true, "clamp")

            SPEEDO.TEXTURES[2][18]=dxCreateTexture("textures/2/nitro_bg.png", "argb", true, "clamp")
            SPEEDO.TEXTURES[2][19]=dxCreateTexture("textures/2/nitro.png", "argb", true, "clamp")

            SPEEDO.TEXTURES[2][20]=dxCreateTexture("textures/2/lines.png", "argb", true, "clamp")
        end
    },

    [3]={
        create=function()
            SPEEDO.TEXTURES[3][1]=dxCreateTexture("textures/3/bg.png", "argb", true, "clamp") 
        end
    },

    [4]={
        create=function()
            SPEEDO.TEXTURES[4][1]=dxCreateTexture("textures/4/tarcza.png", "argb", true, "clamp") 
            SPEEDO.TEXTURES[4][2]=dxCreateTexture("textures/4/center.png", "argb", true, "clamp")  
            SPEEDO.TEXTURES[4][3]=dxCreateTexture("textures/4/arrow.png", "argb", true, "clamp")

            SPEEDO.TEXTURES[4][4]=dxCreateTexture("textures/4/rpm_tarcza.png", "argb", true, "clamp")  
            SPEEDO.TEXTURES[4][5]=dxCreateTexture("textures/4/rpm_center.png", "argb", true, "clamp")  
            SPEEDO.TEXTURES[4][6]=dxCreateTexture("textures/4/rpm_arrow.png", "argb", true, "clamp") 
            
            SPEEDO.TEXTURES[4][7]=dxCreateTexture("textures/4/fuel_tarcza.png", "argb", true, "clamp")  
            SPEEDO.TEXTURES[4][8]=dxCreateTexture("textures/4/fuel_center.png", "argb", true, "clamp")  
            SPEEDO.TEXTURES[4][9]=dxCreateTexture("textures/4/fuel_arrow.png", "argb", true, "clamp") 
        end
    },

    [5]={
        create=function()
            SPEEDO.TEXTURES[5][1]=dxCreateTexture("textures/5/bg-speed.png", "argb", true, "clamp") 
            SPEEDO.TEXTURES[5][2]=dxCreateTexture("textures/5/arrow.png", "argb", true, "clamp") 
            SPEEDO.TEXTURES[5][3]=dxCreateTexture("textures/5/mileage.png", "argb", true, "clamp") 
            SPEEDO.TEXTURES[5][4]=dxCreateTexture("textures/5/fuel-bg.png", "argb", true, "clamp") 
            SPEEDO.TEXTURES[5][5]=dxCreateTexture("textures/5/fuel.png", "argb", true, "clamp") 
            SPEEDO.TEXTURES[5][6]=dxCreateTexture("textures/5/bg-tachto.png", "argb", true, "clamp") 
            SPEEDO.TEXTURES[5][7]=dxCreateTexture("textures/5/arrow-small.png", "argb", true, "clamp") 
            SPEEDO.TEXTURES[5][8]=dxCreateTexture("textures/5/gear.png", "argb", true, "clamp") 
            SPEEDO.TEXTURES[5][9]=dxCreateTexture("textures/5/nitro-bg.png", "argb", true, "clamp") 
            SPEEDO.TEXTURES[5][10]=dxCreateTexture("textures/5/nitro.png", "argb", true, "clamp") 
            SPEEDO.TEXTURES[5][11]=dxCreateTexture("textures/5/outline-tachto.png", "argb", true, "clamp") 
            SPEEDO.TEXTURES[5][12]=dxCreateTexture("textures/5/outline-speed.png", "argb", true, "clamp") 
        end,
    },

    [6]={
        create=function()
            SPEEDO.TEXTURES[6][1]=dxCreateTexture("textures/6/bg-speed.png", "argb", true, "clamp") 
            SPEEDO.TEXTURES[6][2]=dxCreateTexture("textures/6/arrow.png", "argb", true, "clamp") 
            SPEEDO.TEXTURES[6][3]=dxCreateTexture("textures/6/car-light.png", "argb", true, "clamp") 
            SPEEDO.TEXTURES[6][4]=dxCreateTexture("textures/6/car-light-glow.png", "argb", true, "clamp") 
            SPEEDO.TEXTURES[6][5]=dxCreateTexture("textures/6/engine.png", "argb", true, "clamp") 
            SPEEDO.TEXTURES[6][6]=dxCreateTexture("textures/6/engine-glow.png", "argb", true, "clamp") 
            SPEEDO.TEXTURES[6][7]=dxCreateTexture("textures/6/handbrake.png", "argb", true, "clamp") 
            SPEEDO.TEXTURES[6][8]=dxCreateTexture("textures/6/handbrake-glow.png", "argb", true, "clamp") 
            SPEEDO.TEXTURES[6][9]=dxCreateTexture("textures/6/trailer.png", "argb", true, "clamp") 
            SPEEDO.TEXTURES[6][10]=dxCreateTexture("textures/6/trailer-glow.png", "argb", true, "clamp") 
            SPEEDO.TEXTURES[6][11]=dxCreateTexture("textures/6/bg-fuel.png", "argb", true, "clamp") 
            SPEEDO.TEXTURES[6][12]=dxCreateTexture("textures/6/arrow-small.png", "argb", true, "clamp") 
            SPEEDO.TEXTURES[6][13]=dxCreateTexture("textures/6/bg-tachto.png", "argb", true, "clamp") 
            SPEEDO.TEXTURES[6][14]=dxCreateTexture("textures/6/gear.png", "argb", true, "clamp") 
            SPEEDO.TEXTURES[6][15]=dxCreateTexture("textures/6/circle.png", "argb", true, "clamp") 
        end,
    },

    [7]={
        create=function()
            local texs={
                "textures/7/cockpit.png",

                "textures/7/destruction_level.png",

                "textures/7/fuel_pointer.png",

                "textures/7/switch_banner_down.png",
                "textures/7/switch_banner_up.png",
                "textures/7/switch_down.png",
                "textures/7/switch_up.png",

                "textures/7/button_banner.png",
                "textures/7/button_banner_light.png",

                "textures/7/button_engine.png",
                "textures/7/button_engine_light.png",
            }
            for i,v in pairs(texs) do
                SPEEDO.TEXTURES[7][i]=dxCreateTexture(v, "argb", true, "clamp")
            end
        end,

        positions={
            cockpit={sw/2-902/2/zoom, sh-164/zoom, 902/zoom, 164/zoom},
            destruction={sw/2-791/2/zoom, sh-95/zoom, 791/zoom, 64/zoom, 20/zoom, 791, 64},
            fuel={sw/2-902/2/zoom+127/zoom, sh-31/zoom, 17/zoom, 15/zoom},
            fuel_pointer=625/zoom,
            speed={sw/2-902/2/zoom+357/zoom, sh-164/zoom+52/zoom, sw/2-902/2/zoom+357/zoom+189/zoom},
            engine={sw/2-902/2/zoom+290/zoom, sh-82/zoom-44/zoom, 25/zoom, 44/zoom},
            banner={sw/2-902/2/zoom+677/zoom, sh-78/zoom-44/zoom, 25/zoom, 44/zoom},
            info={sw/2-902/2/zoom, sh-55/zoom, sw/2-902/2/zoom+902/zoom, 0},
            buttonMinus={39/zoom, 30/zoom, 50/zoom},
        }
    }
}

SPEEDO.fonts={
    [1]={
        create=function()
            SPEEDO.fonts[1][1]=dxCreateFont(":px_assets/fonts/Font-Bold.ttf", 25/zoom)
            SPEEDO.fonts[1][2]=dxCreateFont(":px_assets/fonts/Font-Light.ttf", 10/zoom)
            SPEEDO.fonts[1][3]=dxCreateFont(":px_assets/fonts/Font-Bold.ttf", 20/zoom)
            SPEEDO.fonts[1][4]=dxCreateFont(":px_assets/fonts/Font-Regular.ttf", 10/zoom)
        end,
    },

    [2]={
        create=function()
            SPEEDO.fonts[2][1]=dxCreateFont("fonts/digital-7.ttf", 30/zoom)
            SPEEDO.fonts[2][2]=dxCreateFont("fonts/digital-7.ttf", 23/zoom)
            SPEEDO.fonts[2][3]=dxCreateFont(":px_assets/fonts/Font-Regular.ttf", 11/zoom)
            SPEEDO.fonts[2][4]=dxCreateFont(":px_assets/fonts/Font-Regular.ttf", 9/zoom)
            SPEEDO.fonts[2][5]=dxCreateFont("fonts/digital-7.ttf", 18/zoom)
            SPEEDO.fonts[2][6]=dxCreateFont(":px_assets/fonts/Font-Medium.ttf", 11/zoom)
            SPEEDO.fonts[2][7]=dxCreateFont("fonts/digital-7.ttf", 9/zoom)
            SPEEDO.fonts[2][8]=dxCreateFont("fonts/digital-7.ttf", 11/zoom)
            SPEEDO.fonts[2][9]=dxCreateFont(":px_assets/fonts/Font-Bold.ttf", 25/zoom)
        end
    },

    [3]={
        create=function()
            SPEEDO.fonts[3][1]=dxCreateFont(":px_assets/fonts/Font-Light.ttf", 25/zoom)
            SPEEDO.fonts[3][2]=dxCreateFont(":px_assets/fonts/Font-Light.ttf", 10/zoom)
            SPEEDO.fonts[3][3]=dxCreateFont(":px_assets/fonts/Font-Regular.ttf", 11/zoom)
            SPEEDO.fonts[3][4]=dxCreateFont(":px_assets/fonts/Font-Regular.ttf", 8/zoom)
        end
    },

    [4]={
        create=function()
            SPEEDO.fonts[4][1]=dxCreateFont(":px_assets/fonts/Font-ExtraBold.ttf", 7/zoom)
            SPEEDO.fonts[4][2]=dxCreateFont(":px_assets/fonts/Font-SemiBold.ttf", 9/zoom)
        end
    },

    [5]={
        create=function()
            SPEEDO.fonts[5][1]=dxCreateFont("fonts/digital-7.ttf", 10/zoom)
            SPEEDO.fonts[5][2]=dxCreateFont(":px_assets/fonts/Font-ExtraBold.ttf", 7/zoom)
            SPEEDO.fonts[5][3]=dxCreateFont("fonts/digital-7.ttf", 12/zoom)
        end,
    },

    [6]={
        create=function()
            SPEEDO.fonts[6][1]=dxCreateFont(":px_assets/fonts/Font-ExtraBold.ttf", 10/zoom)
            SPEEDO.fonts[6][2]=dxCreateFont(":px_assets/fonts/Font-Regular.ttf", 10/zoom)
        end,
    },

    [7]={
        create=function()
            SPEEDO.fonts[7][1]=dxCreateFont("fonts/LCDM2N__.ttf", 10/zoom)
            SPEEDO.fonts[7][2]=dxCreateFont(":px_assets/fonts/Font-Regular.ttf", 11/zoom)
            SPEEDO.fonts[7][3]=dxCreateFont(":px_assets/fonts/Font-Regular.ttf", 15/zoom)
        end,
    }
}

SPEEDO.TEXTURES["f_circle"]=dxCreateTexture("textures/f_circle.png", "argb", true, "clamp")

SPEEDO.TEXTURES["lpg_circle_1"]=dxCreateTexture("textures/circle_1.png", "argb", true, "clamp")
SPEEDO.TEXTURES["lpg_circle_2"]=dxCreateTexture("textures/circle_2.png", "argb", true, "clamp")
SPEEDO.TEXTURES["lpg_bg"]=dxCreateTexture("textures/bg.png", "argb", true, "clamp")
SPEEDO.TEXTURES["lpg_bg2"]=dxCreateTexture("textures/bg2.png", "argb", true, "clamp")

SPEEDO.getFuel=function(v)
    local fuel=getElementData(v, "vehicle:fuel") or 25
    local bak=getElementData(v, "vehicle:fuelTank") or 25

    fuel=fuel < 0 and 0 or fuel
    fuel=fuel > bak and bak or fuel

    return fuel,bak
end

function RGBToHex(red, green, blue, alpha)
	
	-- Make sure RGB values passed to this function are correct
	if( ( red < 0 or red > 255 or green < 0 or green > 255 or blue < 0 or blue > 255 ) or ( alpha and ( alpha < 0 or alpha > 255 ) ) ) then
		return nil
	end

	-- Alpha check
	if alpha then
		return string.format("#%.2X%.2X%.2X%.2X", red, green, blue, alpha)
	else
		return string.format("#%.2X%.2X%.2X", red, green, blue)
	end

end