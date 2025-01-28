--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

local dc={}

function showtime ()
	local time = getRealTime()
	local hours = time.hour
	local minutes = time.minute
	local seconds = time.second

    local monthday = time.monthday
	local month = time.month
	local year = time.year

    return string.format("%04d-%02d-%02d %02d:%02d:%02d", year + 1900, month + 1, monthday, hours, minutes, seconds)
end

dc.api={
    chat={
        info={"LOGI CHAT", "https://discord.com/api/webhooks/1290716061360066633/LibISldOEFulEeBT9Q-Ly8NOHq3QnPvPJMKztGWAxSbZyLvbcTCF-3HRvN5YYx5KfK6g"},
    },

    ban={
        info={"LOGI BAN", "https://discord.com/api/webhooks/1290716297159774292/Sx_XmYbUJFANVO5NDiB2nf54dzb2K8yi1XoScDRmwDXyzmyO2KTmCQo9bpY3cecziswZ"},
    },

    mute={
        info={"LOGI MUTE", "https://discord.com/api/webhooks/1290716414209949828/RD3ihgyHdNogASNv_godSbGaNXovObL7ldYpZeFiJgWjhHrrFeJzPTpTZQcEz7uBvcQf"},
    },

    kick={
        info={"LOGI KICK", "https://discord.com/api/webhooks/1290716580165976159/4gF7eRsWKplUEUVbBBRBuxPeZ1vc_NeoMQ-KcumzmV5jSxf9GryO_cxh4t91aJG8XR9l"},
    },

    hajs={
        info={"LOGI PIENIADZE", "https://discord.com/api/webhooks/1290716711112282176/elh6qGSUgZXlMaJywzRmCZh3o5dh2fj7kGesY19kiC5mRAoOC2YEm0ltm3DqFIxQ_57B"},
    },

    admincmd={
        info={"LOGI ADMINCMD", "https://discord.com/api/webhooks/1290717005535514775/q8jIjJ6w89uxQt5YB4uJnCPf038x0i8140bnkax8AnMNkeiXc6tzj56-0ewxv-axG7yH"},
    },

    frakcje={
        info={"LOGI FRAKCJE", "https://discord.com/api/webhooks/1290717114998718567/x2iERogq6oQzCP8QwUNQOEII1MG4IFaskerCjPkdZmC6qc2ISm_44SBIXREVdnwlt7b1"},
    },

    prawojazdy={
        info={"LOGI PRAWO JAZDY", "https://discord.com/api/webhooks/1290717318397300756/iyaY8iGrMBYlsJ34HjU8hhTmsANWwfZDN_dAY55n0zY_gXqhD4tepTZ2xGTiEDDKsEwV"},
    },

    wymiany={
        info={"LOGI WYMIANY", "https://discord.com/api/webhooks/1290717452795121758/u87gwlPaAbfFRffPHLgKxvS6UjFeVVz89zIN-EUE1YpcXnlO2-x83HXSohX65we9p_4J"},
    },

    ogloszenia={
        info={"LOGI OGLOSZENIA", "https://discord.com/api/webhooks/1290717573146480760/gkUSjww7vIOHE7jOJJDEdxj6HmrVTwGz-sW3NjUl2h2kTsm7mPLo47ZDMLbZnG01yp1Q"},
    },

    przelewy={
        info={"LOGI PRZELEWY", "https://discord.com/api/webhooks/1290717696362811402/mwZKxcPvASCWAWuTvZAN6jL9hLq5286KGeLe4WYcMLFNR-fJl7Zpyax146QuNib1CWPL"},
    },

    chatpremium={
        info={"LOGI CHATPREMIUM", "https://discord.com/api/webhooks/1290717798582194218/SqBVuNlCy19FLhRnFSRH0F_dHVTjki9FoYCfvzOTgAt8UP735UT-kb5v7uqYC83Kfxaa"},
    },

    races={
        info={"LOGI WYŚCIGI", "https://discord.com/api/webhooks/993097240690302986/yrRuqL2RemXzFmHfxSYxdoLOeG0ZLzby0hRz3cUkW_tqrapsUb_Y79oKRvzLUwLdZGJO"},
    },
}

dc.sendLog=function(text, type, player)
    local v=dc.api[type]

    local send=""
    if(player)then
        local info={
            UID=getElementData(player, "user:uid") or 0,
            ID=getElementData(player, "user:id") or 0,
            NICK=getPlayerName(player) or "???"
        }
        for i,v in pairs(info) do
            send=send.." [ "..i..": "..v.." ]"
        end
    end
    send=send.." [ "..showtime().." ]"

    local sendOptions = {
        formFields = {
            username=v.info[1],
            content=send..": "..text,
            avatar_url="https://media.discordapp.net/attachments/940365895803494500/986695154847055913/avatar.png"
        },
        method = "POST",
    }
    fetchRemote(v.info[2], sendOptions, function() end)
end

function sendDiscordLogs(...) dc.sendLog(...) end