--[[

    author: psychol.
    for: Pixel REMAKE

]]


dx={}

local fileName='@:px_auth/data.xml'
local code='djk3h63hsb2387128dhg2'

dx.getPlayerXML=function()    
    local file=xmlLoadFile(fileName)
    if(not file)then return false end

    local xmlLogin=xmlFindChild(file, 'login', 0)
    local xmlPass=xmlFindChild(file, 'password_hash', 0)
    if(not xmlLogin or not xmlPass)then return false end

    local login=xmlFindChild(file, 'login', 0)
    local password_hash=xmlFindChild(file, 'password_hash', 0)
    login=xmlNodeGetValue(login) or ''
    password_hash=xmlNodeGetValue(password_hash) or ''
    
    local password=teaDecode(password_hash, code)

    xmlUnloadFile(file)

    return login, password
end

dx.savePlayerXML=function(login, password, save)
    if(not save or save == 0)then
        dx.destroyPlayerXML()
        return
    end

    local file=xmlLoadFile(fileName)
    if(not file)then
        file=xmlCreateFile(fileName, 'data')
    end

    local xmlLogin=xmlFindChild(file, 'login', 0)
    if(not xmlLogin)then
        xmlLogin=xmlCreateChild(file, 'login')
    end
  
    local xmlPass=xmlFindChild(file, 'password_hash', 0)
    if(not xmlPass)then
        xmlPass=xmlCreateChild(file, 'password_hash')
    end

    xmlNodeSetValue(xmlLogin, login)
    xmlNodeSetValue(xmlPass, teaEncode(password, code))

    xmlSaveFile(file)
    xmlUnloadFile(file)
end
addEvent('ui.saveDates', true)
addEventHandler('ui.saveDates', resourceRoot, dx.savePlayerXML)

dx.destroyPlayerXML=function()
    if(fileExists(fileName))then
        fileDelete(fileName)
        return true
    end
    return false
end