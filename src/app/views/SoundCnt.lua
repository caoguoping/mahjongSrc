cc.exports.soundCnt      = soundCnt or {}
--[[
命名：  nan(nv) + _牌值 + _中年（青年) + _随机.mp3
1：青年， 2：中年

例：nan_9_1_2.mp3     青年男子九万的第二个音效
	nv_11_2_1.mp3     中年女子碰的第一个音效
]]

--[性别][青年][牌值]

soundCnt[1] = {} --男
soundCnt[2] = {} --女
soundCnt[1][1] = {}   --男 青年
soundCnt[1][2] = {}   --男 中年
soundCnt[2][1] = {}   --女 青年
soundCnt[2][2] = {}   --女 中年
--男声1每种声音的个数
--万
soundCnt[1][1][1 ] = 2
soundCnt[1][1][2 ] = 4
soundCnt[1][1][3 ] = 1
soundCnt[1][1][4 ] = 1
soundCnt[1][1][5 ] = 1
soundCnt[1][1][6 ] = 2
soundCnt[1][1][7 ] = 1
soundCnt[1][1][8 ] = 3
soundCnt[1][1][9 ] = 1
--补花(10)， 碰(11)，杠(12），胡（13）， 杠开（14）， 天胡（15）， 地胡（16）
soundCnt[1][1][10] =4
soundCnt[1][1][11] =4 
soundCnt[1][1][12] =1
soundCnt[1][1][13] =1
soundCnt[1][1][14] =1 
soundCnt[1][1][15] =1 
soundCnt[1][1][16] =1 
--条
soundCnt[1][1][17] =3 
soundCnt[1][1][18] =2 
soundCnt[1][1][19] =2 
soundCnt[1][1][20] =2 
soundCnt[1][1][21] =3 
soundCnt[1][1][22] =2 
soundCnt[1][1][23] =2 
soundCnt[1][1][24] =2 
soundCnt[1][1][25] =1 
--饼
soundCnt[1][1][33] =2 
soundCnt[1][1][34] =3 
soundCnt[1][1][35] =2 
soundCnt[1][1][36] =3 
soundCnt[1][1][37] =2 
soundCnt[1][1][38] =1 
soundCnt[1][1][39] =2 
soundCnt[1][1][40] =4 
soundCnt[1][1][41] =2 
--东南西北
soundCnt[1][1][49] =2 
soundCnt[1][1][51] =3 
soundCnt[1][1][53] =4 
soundCnt[1][1][55] =2 
--女声1每种声音的个数
--万
soundCnt[2][1][1 ] =2 
soundCnt[2][1][2 ] =3 
soundCnt[2][1][3 ] =1 
soundCnt[2][1][4 ] =1 
soundCnt[2][1][5 ] =1
soundCnt[2][1][6 ] =2 
soundCnt[2][1][7 ] =1 
soundCnt[2][1][8 ] =3 
soundCnt[2][1][9 ] =1 
--补花， 碰，杠，胡， 杠开， 天胡， 地胡
soundCnt[2][1][10] =4 
soundCnt[2][1][11] =3 
soundCnt[2][1][12] =1 
soundCnt[2][1][13] =1 
soundCnt[2][1][14] =1 
soundCnt[2][1][15] =1 
soundCnt[2][1][16] =1 
--条
soundCnt[2][1][17] =3 
soundCnt[2][1][18] =2 
soundCnt[2][1][19] =2 
soundCnt[2][1][20] =2 
soundCnt[2][1][21] =3 
soundCnt[2][1][22] =2 
soundCnt[2][1][23] =2 
soundCnt[2][1][24] =2 
soundCnt[2][1][25] =1 
--饼
soundCnt[2][1][33] =2 
soundCnt[2][1][34] =3 
soundCnt[2][1][35] =2 
soundCnt[2][1][36] =3 
soundCnt[2][1][37] =2 
soundCnt[2][1][38] =1 
soundCnt[2][1][39] =2 
soundCnt[2][1][40] =4 
soundCnt[2][1][41] =2 
--东南西北
soundCnt[2][1][49] =3 
soundCnt[2][1][51] =3 
soundCnt[2][1][53] =4 
soundCnt[2][1][55] =2 

--男声2每种声音的个数
--万
soundCnt[1][2][1 ] =2 
soundCnt[1][2][2 ] =3 
soundCnt[1][2][3 ] =1 
soundCnt[1][2][4 ] =1 
soundCnt[1][2][5 ] =1 
soundCnt[1][2][6 ] =2 
soundCnt[1][2][7 ] =1 
soundCnt[1][2][8 ] =3 
soundCnt[1][2][9 ] =1 
--补花， 碰，杠，胡， 杠开， 天胡， 地胡
soundCnt[1][2][10] =4 
soundCnt[1][2][11] =3 
soundCnt[1][2][12] =1 
soundCnt[1][2][13] =1 
soundCnt[1][2][14] =1 
soundCnt[1][2][15] =1 
soundCnt[1][2][16] =1 
--条
soundCnt[1][2][17] =3 
soundCnt[1][2][18] =2 
soundCnt[1][2][19] =2 
soundCnt[1][2][20] =2 
soundCnt[1][2][21] =3 
soundCnt[1][2][22] =2 
soundCnt[1][2][23] =2 
soundCnt[1][2][24] =2 
soundCnt[1][2][25] =1 
--饼
soundCnt[1][2][33] =2 
soundCnt[1][2][34] =3 
soundCnt[1][2][35] =2 
soundCnt[1][2][36] =3 
soundCnt[1][2][37] =2 
soundCnt[1][2][38] =1 
soundCnt[1][2][39] =2 
soundCnt[1][2][40] =4 
soundCnt[1][2][41] =2 
--东南西北
soundCnt[1][2][49] =2 
soundCnt[1][2][51] =3 
soundCnt[1][2][53] =3 
soundCnt[1][2][55] =2 

--女声2每种声音的个数
--万
soundCnt[2][2][1 ] =2 
soundCnt[2][2][2 ] =3 
soundCnt[2][2][3 ] =1 
soundCnt[2][2][4 ] =1 
soundCnt[2][2][5 ] =1 
soundCnt[2][2][6 ] =2 
soundCnt[2][2][7 ] =1 
soundCnt[2][2][8 ] =3 
soundCnt[2][2][9 ] =1 
--补花， 碰，杠，胡， 杠开， 天胡， 地胡
soundCnt[2][2][10] =4 
soundCnt[2][2][11] =3 
soundCnt[2][2][12] =1 
soundCnt[2][2][13] =1 
soundCnt[2][2][14] =1
soundCnt[2][2][15] =1 
soundCnt[2][2][16] =1 
--条
soundCnt[2][2][17] =3 
soundCnt[2][2][18] =2 
soundCnt[2][2][19] =2 
soundCnt[2][2][20] =2 
soundCnt[2][2][21] =3 
soundCnt[2][2][22] =2 
soundCnt[2][2][23] =2 
soundCnt[2][2][24] =2 
soundCnt[2][2][25] =1 
--饼
soundCnt[2][2][33] =2 
soundCnt[2][2][34] =3 
soundCnt[2][2][35] =2 
soundCnt[2][2][36] =3 
soundCnt[2][2][37] =2 
soundCnt[2][2][38] =1 
soundCnt[2][2][39] =2 
soundCnt[2][2][40] =4 
soundCnt[2][2][41] =2 
--东南西北
soundCnt[2][2][49] =2 
soundCnt[2][2][51] =3 
soundCnt[2][2][53] =4 
soundCnt[2][2][55] =2 


