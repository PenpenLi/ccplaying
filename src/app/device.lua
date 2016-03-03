local function getIDFA()
	local idfa = cc.Native:getDeviceInfo("IDFA")

	if type(idfa) == "string" and #idfa == 0 then
		idfa = nil
	end

	return idfa
end

local function getIDFV()
	local idfv = cc.Native:getDeviceInfo("IDFV")

	if type(idfv) == "string" and #idfv == 0 then
		idfv = nil
	end

	return idfv
end

local function getDeviceID()
	if device.platform == "android" then
		local devID = cc.Native:getOpenUDID()
		if type(devID) == "string" and #devID == 0 then
			devID = "unknown"
		end

		return devID
	else
		local devID = "unknown"
		local idfv = getIDFV()
		local idfa = getIDFA()
		if idfv then
			return idfv
		elseif idfa then
			return idfa
		end

		return devID
	end
end

local currentDevice = {}
currentDevice.deviceId = getDeviceID() or "unknown"
currentDevice.idfa = getIDFA() or "unknown"
currentDevice.idfv =  getIDFV() or "unknown"
currentDevice.model =  cc.Native:getDeviceInfo("MODEL") or "unknown"
currentDevice.system = device.platform or "unknown"
currentDevice.version =  cc.Native:getDeviceInfo("VERSION") or "unknown"
currentDevice.resolution =  "" .. cc.Native:getDeviceInfo("SCREEN_HEIGHT") .. "x" .. cc.Native:getDeviceInfo("SCREEN_WIDTH")
CCLog("currentDevice:", vardump(currentDevice))
return currentDevice
