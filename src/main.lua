-- 游戏基本信息
GAME_BASE_INFO = {
    gameID = "com.ccplaying.d1",
    name = "gcgame",
    channel = "2400",
    SDK = nil,
}

local function initSearchPath()
	local fileUtils = cc.FileUtils:getInstance()
	local versionPathFilePath = fileUtils:getWritablePath() .. "ApplicationPatchPaths.txt"
	local f, err = io.open(versionPathFilePath, "rb")
	if f then
		local patchPaths = {}
		while true do 
			local path = f:read("*l")
			if path then
				table.insert(patchPaths, path)
			else				
				break
			end
		end

		local searchPaths = fileUtils:getSearchPaths()
		while #patchPaths > 0 do
			table.insert(searchPaths, 1, table.remove(patchPaths))
		end
		fileUtils:setSearchPaths(searchPaths)
	end
end

print("searchPaths:", table.concat(cc.FileUtils:getInstance():getSearchPaths(), ", "))
initSearchPath()

-- 游戏入口
THE_GAME_ENTRY = "src/game"
require(THE_GAME_ENTRY)