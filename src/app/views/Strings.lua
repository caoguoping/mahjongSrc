
cc.exports.Strings = Strings or { }

Strings.dismissRoom         = "开局前解散房间不会消耗房卡，是否解散房间"
Strings.roomNotExist		= "您输入的房间号不存在，请重新输入，谢谢！"
Strings.funcNotOpen 			= "亲，功能暂未开放，请耐心等待"
--Strings.noRoomCard 			= "您的房卡不足，请联系代理"
Strings.noRoomCard 			= "您的房卡不足，请充值"
Strings.createRoomFail 			= "创建房间失败"
Strings.logingRoomFail 			= "登录失败"
Strings.joinRoomFail			 = "加入房间失败"
Strings.backRoomFangzhu          = "是否离开房间？（如果30分钟内没有正式开始游戏，系统将解散房间并退回房卡）"
Strings.backRoomJoin          = "是否退出房间"
Strings.connectGameFail        = "连接游戏服务器失败"
Strings.connectLoginFail       = "连接登录服务器失败"



-- 服务器错误码
Strings.RESULTCODE={
	["0"]="成功",
	["1"]="系统错误",
	["2"]="数据库错误",
	["3"]="参数错误",
	["4"]="数据不存在",
	["5"]="session 超时",
	["6"]="静态数据不同步",
	["100"]="玩家已经从其他设备登陆",
	["101"]="玩家密码错误",
	["102"]="session 超时，请重新登陆",
	["103"]="玩家已经注册",
	["104"]="玩家没有注册",
	["105"]="服务器人数已满",
	["200"]="金钱不足",
}
