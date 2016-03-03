if __preloadPackages__ == nil then
	__preloadPackages__ = {}

	for name, package in pairs(package.loaded) do
		__preloadPackages__[name] = true
	end
end

cc.FileUtils:getInstance():setPopupNotify(false)
cc.FileUtils:getInstance():addSearchPath(cc.FileUtils:getInstance():getWritablePath() .. "res/")
cc.FileUtils:getInstance():addSearchPath("src/")
cc.FileUtils:getInstance():addSearchPath("res/")


require "config"
require "cocos.init"

require "app.ServerConfig"

require "app.config"

cc.Director:getInstance():getConsole():listenOnTCP(6010)

--local function test()
--	local bitarray2d = require("bitarray2d")
--	local bitmap = bitarray2d.new(11, 11)
--	for x = 0, 10 do
--		bitmap:set(x, 5, true)
--	end
--
--	for y = 0, 10 do
--		bitmap:set(5, y, true)
--	end
--
--	for x = 0, 10 do
--		bitmap:set(x, x, true)
--		bitmap:set(10 - x, x, true)
--	end
--
--	bitmap:setRect(3, 1, 5, 2)
--
--	print(bitmap:tostring())
--	print(hex(bitmap:tobytes()))
--
--	for x = 1, 10 do
--		for y = 1, 10 do
--			--local newmap = bitarray2d.new(11, 11)
--			--newmap:frombytes(bitmap:tobytes())
--
--			local newmap = bitarray2d.new(bitmap:tobytes())
--			newmap:move(x, y)
--			print(string.format("bitmap:clone():move(%d, %d):tostring()", x, y), newmap:tostring())
--
--			newmap:flipX()
--			print(string.format("bitmap:clone():move(%d, %d):flipX():tostring()", x, y), newmap:tostring())
--
----			local newmap = bitmap:clone()
----			newmap:move(-x, -y)
----			print(string.format("bitmap:clone():move(%d, %d):tostring()", -x, -y), newmap:tostring())
--		end
--	end
--
--end

function RestartGame()
	print("RestartGame", debug.traceback())
	if THE_GAME_ENTRY then
		package.loaded[THE_GAME_ENTRY] = nil
	end

	local director = cc.Director:getInstance()

	local loadedPackageList = table.keys(package.loaded)
	for _, name in ipairs(loadedPackageList) do
		if not __preloadPackages__[name] then
			package.loaded[name] = nil
		end
	end

	director:restart()
end

function GetAppVersion()
	local appVer = cc.Application:getInstance():getApplicationVersion()
	if REBASE_MAJOR_VERSION ~= nil and REBASE_MAJOR_VERSION ~= "" then
        return REBASE_MAJOR_VERSION
    end
	return appVer
end

function GetUpdatedVersion()	
	if REBASE_PATCH_VERSION ~= nil and REBASE_PATCH_VERSION ~= "" then
        return REBASE_PATCH_VERSION
    end

	local lpath = require("tool.lib.path")
	local json = require("tool.lib.json")

	local fileUtils = cc.FileUtils:getInstance()

	local appVer = GetAppVersion()
	local major, minor, build = string.match(appVer, "(%d+)%.(%d+)%.(%d+)")

	local lastUpdatedPkgInfoFile = lpath.join(fileUtils:getWritablePath(), "update/package.json")
	local data = fileUtils:getStringFromFile(lastUpdatedPkgInfoFile)
	print("lastUpdatedPkgInfoFile:", lastUpdatedPkgInfoFile, data)
	if data then
		local info = json.decode(data)
		if info then
			if info.Build then
				build = info.Build
				appVer = string.format("%s.%s.%s", major, minor, build)
			else
				local version = info.Version
				_, _, build = string.match(version, "(%d+)%.(%d+)%.(%d+)")
				appVer = string.format("%s.%s.%s", major, minor, build)
			end			
		end
	end

	return appVer
end

local function checkAppVersion()
	local json = require("tool.lib.json")
	local lfs = require("lfs")
	local inspect = require("tool.lib.inspect")
	local lpath = require("tool.lib.path")

	local needRemoveUpdateDir = false
	local curAppVer = GetAppVersion()
	print("Application.Version:", curAppVer)
	local appVerFile = lpath.join(cc.FileUtils:getInstance():getWritablePath(), "ApplicationVersion.json")
	if cc.FileUtils:getInstance():isFileExist(appVerFile) then
		local content = cc.FileUtils:getInstance():getStringFromFile(appVerFile)
		local appVerInfo = json.decode(content)
		if curAppVer ~= appVerInfo.Version then
			needRemoveUpdateDir = true
		end
	else
		needRemoveUpdateDir = true
	end

	if needRemoveUpdateDir then
		local file = io.open(appVerFile, "wb")
		file:write(json.encode({Version = curAppVer}))
		file:close()
		
		local updateDir = lpath.join(cc.FileUtils:getInstance():getWritablePath(), "update/")
		print("remove dir:", updateDir)
		cc.FileUtils:getInstance():removeDirectory(updateDir)
	end
end

function RemoveOverflowPatch(correctVersion)
	local json = require("tool.lib.json")
	local lfs = require("lfs")
	local inspect = require("tool.lib.inspect")
	local lpath = require("tool.lib.path")

	local version = GetUpdatedVersion()
	local major, minor, build = string.match(version, "(%d+)%.(%d+)%.(%d+)")

	local cmajor, cminor, cbuild = string.match(correctVersion, "(%d+)%.(%d+)%.(%d+)")

	if cmajor == major and cminor == cminor then
		if tonumber(cbuild) < tonumber(build) then
			local fromBuild = tonumber(cbuild) + 1
			local toBuild = tonumber(build)
			local patchDir = lpath.join(cc.FileUtils:getInstance():getWritablePath(), "update", string.format("%s.%s", major, minor))

			print("remove pathc from", fromBuild, "to", toBuild)
			for buildNum = fromBuild, toBuild + 1 do
				local buildDir = lpath.join(patchDir, string.format("%d/", buildNum))
				print("remove dir", buildDir)
				cc.FileUtils:getInstance():removeDirectory(buildDir)
			end
		else
			print("当前Build:", build, "期待Build:", cbuild)
		end
	else
		print("主版本不符合，不能删除溢出更新包")
	end
end

function CheckPatchPaths()
	local searchPathChanged = false

	local json = require("tool.lib.json")
	local lfs = require("lfs")
	local inspect = require("tool.lib.inspect")
	local lpath = require("tool.lib.path")

	local function listDir(path)
	    local dirList = {}

	    for item in lfs.dir(path) do
	        if item ~= "." and item ~= ".." then
	            local attr = lfs.attributes(lpath.join(path, item))
	            if attr and attr.mode == "directory" then
	                table.insert(dirList, item)
	            end
	        end
	    end

	    return dirList
	end

	local fileUtils = cc.FileUtils:getInstance()

	local version = GetUpdatedVersion()
	local rootPath =  lpath.join(cc.FileUtils:getInstance():getWritablePath(), "update")
    local rootAttrs = lfs.attributes(rootPath)
    if rootAttrs  then
        local major, minor, build = string.match(version, "(%d+)%.(%d+)%.(%d+)")
        local path = lpath.join(rootPath, string.format("%s.%s", major, minor), build)
        print("last update path:", path)
        local pathAttrs = lfs.attributes(path)
        if pathAttrs and pathAttrs.mode == "directory" then	                
            --local searchPaths = fileUtils:getSearchPaths()
            local patchPaths = {}

            local minorPath = lpath.join(rootPath, string.format("%s.%s", major, minor))
            local dirList = listDir(minorPath)
            table.sort(dirList, function(a, b) return tonumber(a) < tonumber(b) end)
            
            for _, path in ipairs(dirList) do
                local fullPath = lpath.join(minorPath, path)
                -- table.insert(searchPaths, 1, fullPath .. "/res")
                -- table.insert(searchPaths, 1, fullPath .. "/src")
                -- table.insert(searchPaths, 1, fullPath)

                table.insert(patchPaths, 1, fullPath .. "/res")
                table.insert(patchPaths, 1, fullPath .. "/src")
                table.insert(patchPaths, 1, fullPath)
            end
            --fileUtils:setSearchPaths(searchPaths)

            local patchPathStr = table.concat(patchPaths, "\n")

            print("patch paths:\n========== BEGIN =========\n" .. patchPathStr .. "\n ========== END =========\n")
			local versionPathFilePath = lpath.join(cc.FileUtils:getInstance():getWritablePath(), "ApplicationPatchPaths.txt")

			local prePatchPathStr = ""
			local f, err = io.open(versionPathFilePath, "rb")
			if f then
				prePatchPathStr = f:read("*all")
				f:close()
			end

			if prePatchPathStr ~= patchPathStr then
				print("Update Search Paths")
				local f = io.open(versionPathFilePath, "wb")
				f:write(patchPathStr)
				f:close()

				searchPathChanged = true
			end
        end
    end

    print("search paths", inspect(fileUtils:getSearchPaths()))

    return searchPathChanged
end

function CodeVersion()
    print("CodeVersion")
    local versionFile = "src/version"
    if cc.FileUtils:getInstance():isFileExist(versionFile) then
        local content = cc.FileUtils:getInstance():getStringFromFile(versionFile)
        return content
    end

    print("version file not exists!")
    return ""
end

-- print("deviceID:", cc.Native:getOpenUDID())
-- print("deviceName:", cc.Native:getDeviceName())
-- print("OS:", cc.Native:getDeviceInfo("OS"))
-- print("MODEL:", cc.Native:getDeviceInfo("MODEL"))
-- print("MANUFACTURER:", cc.Native:getDeviceInfo("MANUFACTURER"))
-- print("SCREEN_WIDTH:", cc.Native:getDeviceInfo("SCREEN_WIDTH"))
-- print("SCREEN_HEIGHT:", cc.Native:getDeviceInfo("SCREEN_HEIGHT"))
-- print("SPN:", cc.Native:getDeviceInfo("SPN"))
-- print("SIM:", cc.Native:getDeviceInfo("SIM"))
-- print("SIMOP:", cc.Native:getDeviceInfo("SIMOP"))
-- print("NetTypeName:", cc.Native:getDeviceInfo("NetTypeName"))
-- print("NetOPName:", cc.Native:getDeviceInfo("NetOPName"))
-- print("SIMOP:", cc.Native:getDeviceInfo("SIMOP"))


local function main()
	-- local lfs = require("lfs")
	-- local lpath = require("tool.lib.path")
	-- local skinPath = lpath.join(cc.FileUtils:getInstance():getWritablePath(), "skins")
	-- lfs.mkdir(skinPath)
	-- cc.FileUtils:getInstance():addSearchPath(skinPath)

	--require('tool.lib.mobdebug').start() 
	xpcall(checkAppVersion, __G__TRACKBACK__);

	local isInstalled = cc.UserDefault:getInstance():getBoolForKey("install")
	if not isInstalled then
		cc.UserDefault:getInstance():setBoolForKey("install", true)
		-- 第一次启动
		print("install game")
		ReyunLog.install()
	end

	print("startup game...")
	ReyunLog.startUp()
	
	if CheckPatchPaths() then
		print("RestartGame")
		RestartGame()
	end

	local App = require("app.App")
	
	local searchPaths = cc.FileUtils:getInstance():getSearchPaths()

	print(vardump(searchPaths, "search paths"))
        CodeVersion()

	if application and not tolua.isnull(application) then
		application:release()
	end

	application = App.new("Game")
	application:run()
end

local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    print(msg)
end
