cc.exports.girl            = girl or {}
cc.exports.netTb       = netTb or {}
cc.exports.fxString       = fxString or {}
cc.exports.fxValue       = fxValue or {}

netTb.SocketType = 
{
	Login  = 0,
	Game   = 1,
}
netTb.ip = "192.168.3.15"
--netTb.ip = "101.66.251.195"
netTb.port =
{
    login = 5050,
    game = 5010,
    jinyunzi = 5010,
    changkaihuan = 5011,
}

--未缩小的原始尺寸
girl.cardHeight = 130
girl.cardWidth = 92

girl.posy = 0
girl.posx = {}
	for i=1,13 do
		girl.posx[i] = 640 - 564 + 92 * (i - 1) * 0.93
	end
girl.posx[14] = 564 + 640

fxString[1 ] = "胡牌"
fxString[2 ] = "胡牌"
fxString[3 ] = "包牌"
fxString[4 ] = "对对胡"
fxString[5 ] = "清一色"
fxString[6 ] = "混一色"
fxString[7 ] = "天胡"
fxString[8 ] = "地胡"
fxString[9 ] = "独钓"
fxString[10] = "压绝"
fxString[11] = "七对"
fxString[12] = "海底捞月"
fxString[13] = "小杠后开花"
fxString[14] = "大杠后开花"
fxString[15] = "豪华七对"
fxString[16] = "无花果"
fxString[17] = "门清"

--与上面的翻型一一对应
fxValue[1 ] = 10
fxValue[2 ] = 10
fxValue[3 ] = 0
fxValue[4 ] = 80
fxValue[5 ] = 30
fxValue[6 ] = 30
fxValue[7 ] = 100
fxValue[8 ] = 100
fxValue[9 ] = 40
fxValue[10] = 20
fxValue[11] = 30
fxValue[12] = 40
fxValue[13] = 20
fxValue[14] = 20
fxValue[15] = 40
fxValue[16] = 20
fxValue[17] = 10


