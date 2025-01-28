-- Autor: aventez (devgaming.pl), Toffy.

local mysql = {
    database = {
        server = nil,
        forum = nil,
    },
    dates = {
        server = {
            host = "localhost",
            name = "db_101578",
            user = "root",
            hash = ""
        },
        --[[forum = {
            host = "135.181.0.247",
            name = "s11_pforum",
            user = "u11_JmuQdp66xX",
            hash = "7KxfvAnx2+jkwDbXJN.+cgD4" 
        }]]
    }
}

local classCode = [[
DBQuery = {
    connectionHandler = false,
    queryString = "",
    queryArgs = {},
}
function DBQuery:new(str, ...)
	local database_handler = (str[1] == "forum" and "forum" or "serwer")

	if(str[1] == "forum")then
		table.remove(str, 1)
	end

    local obj = {}
    setmetatable(obj, self)
    self.__index = self
    self.connectionHandler = exports.px_connect:dbGetConnectionHandler(database_handler)
    self.queryString = dbPrepareString(self.connectionHandler, unpack(str))
    self.args = {...}
    return obj
end
function DBQuery:execute(callback)
    dbQuery(
        function(queryHandler)
            local result = {dbPoll(queryHandler, 0)}
            if callback then
                callback(unpack(result))
            end
        end
    , self.connectionHandler, self.queryString, unpack(self.args))
end]]

function dbGetClass()
    return classCode
end

function dbGetConnectionHandler(dbType)
	return dbType == "forum" and mysql.database.forum or mysql.database.server
end

local function mysql_connect()
    mysql.database.server = dbConnect("mysql", "dbname="..mysql.dates.server.name..";host="..mysql.dates.server.host..";unix_socket=/var/run/mysqld/mysqld.sock;charset=utf8;", mysql.dates.server.user, mysql.dates.server.hash, "share=1")
    print("[px_connect] [SERWER] "..(mysql.database.server and "Pomyślnie nawiązano połączenie z bazą danych." or "Wystąpił błąd podczas łączenia z bazą danych"))

    --mysql.database.forum = dbConnect("mysql", "dbname="..mysql.dates.forum.name..";host="..mysql.dates.forum.host..";unix_socket=/var/run/mysqld/mysqld.sock;charset=utf8;", mysql.dates.forum.user, mysql.dates.forum.hash, "share=1")
    --print("[px_connect] [FORUM] "..(mysql.database.forum and "Pomyślnie nawiązano połączenie z bazą danych." or "Wystąpił błąd podczas łączenia z bazą danych"))
end

addEventHandler("onResourceStart", resourceRoot, function()
	mysql_connect()
end)

function query(...)
	local extractedArgs = {...}
	local database_handler = (extractedArgs[1] == "forum" and mysql.database.forum or mysql.database.server)

	if(extractedArgs[1] == "forum")then
		table.remove(extractedArgs, 1)
	end
	
	local safeString = dbPrepareString(database_handler, unpack(extractedArgs))
	if safeString then
		local query = dbQuery(database_handler, safeString)
	  	local result, last_insert_id, rows = dbPoll(query, -1)
	  	if not result then
			outputDebugString( "[px_connect]: skrypt: "..getResourceName(sourceResource)..", blad w zapytaniu: ".. select( 1, extractedArgs ), 1 )
			dbFree(query)
			return false
		end
		return result, last_insert_id, rows
	else 
		return false
	end
	return false
end