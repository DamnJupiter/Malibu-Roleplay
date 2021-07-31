function PRP.Core.LoginPlayer(self, args, src, callback)
    TriggerEvent("prp-core:playerAttemptLogin", src)

    local user = PRP.Player:CreatePlayer(src, false)

    if not user then
        user = PRP.Player:CreatePlayer(src, false)

        if not user then DropPlayer(src, "There was an error while creating your player object, if this persists, contact an administrator") return end
    end

    local function fetchData(_err)
        if _err and type(_err) == "string" then
            local errmsg = _err

            _err = {
                err = true,
                msg = errmsg
            }
            
            callback(_err)
            return
        end

        PRP.DB:FetchPlayerData(src, function(data, err)
            if err then
                data = {
                    err = true,
                    msg = "Error fetching player data, there is a problem with the database"
                }
            end

            user:setRank(data.rank)

            callback(data)

            if not err then TriggerEvent("prp-core:playerLoggedIn", user) TriggerClientEvent("prp-core:playerLoggedIn", src) end
        end)
    end


	PRP.DB:PlayerExistsDB(src, function(exists, err)
		if err then
			fetchData("Error checking player existence, there is a problem with the database")
			return -- my stepsister stuck
		end -- my mother stuck

		if not exists then
			PRP.DB:CreateNewPlayer(src, function(created)
				if not created then
					fetchData("Error creating new user, there is a problem with the database")
					return
				end

				if created then fetchData() return end
			end)

			return
		end

		fetchData()
	end)
end
PRP.Events:AddEvent(PRP.Core, PRP.Core.LoginPlayer, "prp-core:loginPlayer")

function PRP.Core.FetchPlayerCharacters(self, args, src, callback)
	local user = PRP.Player:GetUser(src)

	if not user then return end

	PRP.DB:FetchCharacterData(user, function(data, err)
		if err then
			data = {
				err = true,
				msg = "Error fetching player character data, there is a problem with the database"
			}
		else
			user:setCharacters(data)
			user:setVar("charactersLoaded", true)
			TriggerEvent("prp-core:charactersLoaded", user, data)
			TriggerClientEvent("prp-core:charactersLoaded", src, data)
		end

		callback(data)
	end)
end
PRP.Events:AddEvent(PRP.Core, PRP.Core.FetchPlayerCharacters, "prp-core:fetchPlayerCharacters")

function PRP.Core.CreatePhoneNumber(self, src, callback)
	Citizen.CreateThread(function()
		while true do 
			Citizen.Wait(1000)
			math.randomseed(GetGameTimer())

			local areaCode = math.random(50) > 25 and 415 or 628
			local phonenumber = {}
			phoneNumber = math.random(0000000000, 9999999999)
			local querying = true
			local success = false
		

			if phoneNumber then 
				phoneNumber = tostring(phoneNumber)
				if phoneNumber then
					PRP.DB:PhoneNumberExists(src, phoneNumber, function(exists, err)
						if err then callback(false, true) success = true querying = false return end
						if not exists then callback(phoneNumber) success = true end
						querying = false
					end)
				end
			end

			while querying do Citizen.Wait(0) end

			if success then return end
		end 
	end)
end

function PRP.Core.CreateCharacter(self, charData, src, callback)
	local user = PRP.Player:GetUser(src)

	if not user or not user:getVar("charactersLoaded") then return end
	if user:getNumCharacters() >= 8 then return end

	local fn = charData.firstname
	local ln = charData.lastname


	exports.ghmattimysql:execute("SELECT first_name FROM characters WHERE first_name = @fn AND last_name = @ln", 
	{
	["fn"] = fn, 
	["ln"] = ln
	}, function(result)
		if result[1] ~= nil then 
			created = {
				err = true,
				msg = "This name is already in use, pick another."
			}
			callback(created)
			return
		else
			self:CreatePhoneNumber(src, function(phoneNumber, err)
				if err then
					created = {
						err = true,
						msg = "There was an error when trying to create a phone number"
					}

					callback(created)
					return
				end
				local hexId = user:getVar("hexid")
				charData.phonenumber = phoneNumber
				PRP.DB:CreateNewCharacter(user, charData, hexId, phoneNumber, function(created, err)
					if not created or err then
						created = {
							err = true,
							msg = "There was a problem creating your character, contact an administrator if this persists"
						}
					end

					callback(created)
				end)
			end)
		end
	end)
end
PRP.Events:AddEvent(PRP.Core, PRP.Core.CreateCharacter, "prp-core:createCharacter")

function PRP.Core.DeleteCharacter(self, id, src, callback)
	local user = PRP.Player:GetUser(src)

	if not user or not user:getVar("charactersLoaded") then return end

	local ownsCharacter = false
	for k,v in pairs(user:getCharacters()) do
		if v.id == id then ownsCharacter = true break end
	end

	if not ownsCharacter then return end

	PRP.DB:DeleteCharacter(user, id, function(deleted)
		callback(deleted)
	end)
end
PRP.Events:AddEvent(PRP.Core, PRP.Core.DeleteCharacter, "prp-core:deleteCharacter")

function PRP.Core.SelectCharacter(self, id, src, callback)
	local user = PRP.Player:GetUser(src)
	if not user then callback(false) return end
	if not user:getCharacters() or user:getNumCharacters() <= 0 then callback(false) return end

	if not user:ownsCharacter(id) then callback(false) return end

	local selectedCharacter = user:getCharacter(id)
	selectedCharacter.phone_number = selectedCharacter.phone_number
	user:setCharacter(selectedCharacter)
	user:setVar("characterLoaded", true)
	local cid = selectedCharacter.id
	TriggerClientEvent('updatecid', src, cid)
	TriggerClientEvent('updatecids', src, cid)
	TriggerClientEvent('updateNameClient', src, tostring(selectedCharacter.first_name), tostring(selectedCharacter.last_name))
	TriggerClientEvent('banking:updateBalance', src, selectedCharacter.bank, true)
	TriggerClientEvent('banking:updateCash', src, selectedCharacter.cash, true)
	TriggerClientEvent('banking:updateCasino', src, selectedCharacter.casino, true)
	TriggerClientEvent('prp-core:setcontrols', src)
	TriggerClientEvent('updatepasses', src)
	TriggerEvent("prp-core:characterLoaded", user, selectedCharacter)
	TriggerClientEvent("prp-core:characterLoaded", src, selectedCharacter)

	callback({loggedin = true, chardata = selectedCharacter})
end
PRP.Events:AddEvent(PRP.Core, PRP.Core.SelectCharacter, "prp-core:selectCharacter")