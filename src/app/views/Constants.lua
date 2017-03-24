cc.exports.girl            = girl or {}
cc.exports.netTb       = netTb or {}

netTb.SocketType = 
{
	Login  = 0,
	Game   = 1,
}
netTb.ip = "192.168.3.15"
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

girl.Message                =
{
	 SOULWASH1                = "花费10000金币洗点将使强化次数和所有已强化的效果清空，确认要洗点吗？",
	 SOULWASH2                = "所持金币不足10000，无法洗点",
	 SOULWASH3                = "当前强化次数为0，不需要洗点",
	 PASSWORD_ERROR           = "密码错误",
	 PASSWORD_NOTEQUAL        = "密码不一致",
	 FUNC_NOTOPEN             = "暂未开放",

}

