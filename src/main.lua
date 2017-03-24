
cc.FileUtils:getInstance():setPopupNotify(false)
cc.FileUtils:getInstance():addSearchPath("src/")
cc.FileUtils:getInstance():addSearchPath("res/")
cc.FileUtils:getInstance():addSearchPath("res/customPng")
cc.FileUtils:getInstance():addSearchPath("res/cardPng")
cc.FileUtils:getInstance():addSearchPath("res/csbLobby")
cc.FileUtils:getInstance():addSearchPath("res/csbPlay")
cc.FileUtils:getInstance():addSearchPath("res/actionsCsb")

require "config"
require "cocos.init"

require "app.views.Constants"
require "app.Extends"
require "app.Functions"
require "app.views.Strings"
--cgp test
local function main()
    require("app.MyApp"):create():run()
end

local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    print(msg)
end
