pico-8 cartridge // http://www.pico-8.com
version 43
__lua__
function _init()
 poke(0x5f2e, 1)
 pal(9,9+128,1)
 palt(0,false)
 palt(14,true)
 --style,style_l="\^o916","\^w\^t\^o914"
 state="hold" --main,tut,hold,quit,rdy,go
 moves={} --{sp,x,y}
 stage,round,step,score,f=1,1,0,0,0
 movesp,checkstep=nil,1
 movesets={
  --{⬅️,⬆️,➡️,⬇️,➡️,➡️,⬇️,⬇️},
  --{⬆️,➡️,⬆️,⬅️,⬇️,⬆️,➡️,⬇️},
  --{⬅️,⬅️,➡️,⬆️,⬅️,⬇️,⬆️,➡️},
  {⬆️,⬇️,⬅️,⬆️,⬇️,⬆️,➡️,➡️}
 }
 rot_anim_map={2,3,1,0}
 stageend=#movesets+1
 correct,sounded=nil,false
 smoke={}
 anim_end=24 --#moves*2+8
 frame,step2=33,0 --17-25
end

function _update()
	if state=="main" then
		if (btnp(🅾️)) state="go"
		if (btnp(❎)) state="tut"
		
	elseif state=="tut" then
		if (btnp(❎)) state="main"
		
	elseif state=="hold" then
		if (btnp(🅾️)) state="rdy"
		if (btnp(❎)) state="quit"
		
	elseif state=="quit" then
		if step2<6 then
			f+=1
		
			if f\3!=step2-1 then
				if (step2==1) frame=33
				if (step2==2) frame=35
				if (step2==3) frame=37
				if (step2==4) frame=39
				if (step2==5) frame=41
				step2+=1
			end
		end
		
		if (btnp(🅾️)) state="hold"
		if (btnp(❎)) state="main"
		
	elseif state=="rdy" then
		if f<80 then
			f+=1
		else
			round,step,f=1,0,0
			state="go"
		end
		
		if f==1
		or f==21
		or f==41 then
			sfx(5)
		elseif f==61 then
			sfx(6)
		end
		
	elseif state=="go" then
		updategame()
	end
end

function _draw()
	cls()
	color(15)
	rectfill(0,0,128,128)
	color(2)
	if state=="main" then
		print("press 🅾️ to start")
	elseif state=="tut" then
	elseif state=="hold" then
		print("🅾️ start      ❎ quit",22,106)
	elseif state=="quit" then
		spr(frame,60,60,2,2)
	elseif state=="rdy" then
		if f<60 then
			print(3-f\20,60,40)
		else
			print("go!",55,40)
		end
	elseif state=="go" then
		drawgame()
	end
end
-->8
--main game loop

function updategame()
	f+=1
	
	--gameplay
	if round<stageend then
		--update step
		if f\10!=step-1 then
 		correct=nil
 		sounded=false
			step+=1
			
			if step==17 then
				round+=1
				step=1
				f=0
			end
 		
 		if round<stageend then
				sfx(0)
				
				if (step==1) moves={}
				
				--demo move
				if step<9 then
					add(moves,
									{
										sp=getsp(movesets[round][step]),
										x=getx(step),
										y=gety(step)
									})
				end
			end
		end
		
		--user move
		if step>=9 then
			--input timeframe
		 if f%10>6 or f%10<4 then
	 		if correct==nil then
	 			movesp=checkmove(movesets[round][checkstep]) or movesp
	 		end
	 	--check input
 		else
 			checkstep=step-7
 			if (correct==true and f%10==4) score+=1
 			if (checkstep==9) checkstep=1
 			if correct!=true then
 				checkerr()
 				movesp=9
 			end
		 end
		end
		
	--stage end
	elseif f==1 then
		step=0
		for move in all(moves) do
			move.sp=7
		end
		movesp=7
		sfx(3)
		sfx(4)
	elseif f==150 then
		f=0
		stage+=1
		state="hold"
		moves={}
	else
		local spd=42
		local fspd=3
		
		--rotate the potate
		if f\fspd!=step-1 then
			step+=1
			
			for i,move in pairs(moves) do
				if (step==i*2)	move.dy=-spd
				
				if step>anim_end then
					move.sp=7
				else
					move.sp=getsp(rot_anim_map[(move.sp-1)/2+1])
				end
			end
		end
		
		--jump for joy
		for move in all(moves) do
			if move.dy and move.dy<=spd do
				--[[doing it this way because of strange
				behaviour when working with decimals]]
				local y=move.y*10
				y+=move.dy
				move.dy+=fspd*2
				move.y=ceil(y)/10
			end
		end
	end
	
	--update smoke
	local mult= round<stageend and 0.8 or 0.2
	for p in all(smoke) do
  p.x+=p.dx*mult
  p.y+=p.dy*mult
  p.act-= round<stageend and 1 or 0.2
  if (p.act<0) del(smoke,p)
 end
end


function drawgame()
	color(2)
	--print(step)
	if round!=stageend then
		print("round "..round,3,3)
	else
		print("round "..round-1,3,3)
	end
	print(score.."/32",3,11)
	
	--draw base 2x4 grid
	for i=1,8 do
		local c=7
		if (round<stageend and ceil(step%8.1)==i) c=12
		drawsq(getx(i),gety(i),c)
	end
	
	--draw steps
	for move in all(moves) do
		--rectfill(move.x-1,move.y-2,move.x+15,move.y+16,6)
		--rect(move.x-1,move.y-2,move.x+15,move.y+16,13)
		spr(move.sp,move.x,move.y,2,2)
		--spr(11,move.x,move.y,2,2)
	end
	
	--draw player
	drawsq(57,88,7)
	if round<stageend
	and f%10<4
	and step>=9
	and movesp then
		local c= movesp==9 and 8 or 11
		drawsq(57,88,c)
	end
	if movesp then
		spr(movesp,57,88,2,2)
	end
	
	--draw smoke
	for p in all(smoke) do
  circfill(p.x,p.y,p.r,p.c)
 end
 
	if round==stageend and step>anim_end then
		print("stage end!",26,24,2)
	end
end
-->8
--utils
function drawsq(x,y,c)
	rect(x-2,y+8,x+16,y+17,c)
end

function getsp(m)
	return m*2+1
end

function getx(step)
 return ceil(step%4.1)*21+4
end

function gety(step)
 return (step\4.1+1)*16+32
end

function checkmove(m)
	if btnp()>0 then
		correct=btnp(m)
		if not btnp(m) then
			checkerr()
	 	return 9
	 else
	 	return getsp(m)
	 end
	end
end

function checkerr()
	if not sounded then
		sfx(1)
		sounded=true
		--draw smoke
  for i=1,20 do
   add(smoke,{x=64,y=100,
       dx=rnd(3)-1.5,dy=rnd(2)-1,
       r=rnd(2),act=15,
       c=rnd({5,6,2,0})})
  end
	end
end
__gfx__
00000000eeee11411eeeeeeeeeeeee11411eeeeeeeeee114111eeeeeeeeee111411eeeeeeeeeeeeeeeeeeeeeeee111111111eeeeeeeeeeeeeeeeeeee00000000
00000000eee19999411eeeeeeeee11999941eeeeeeee19999941eeeeeeee19999941eeeeeeeeeeeeeee11eeeee12222222221eeeeeeeeeeeeeeeeeee00000000
00700700ee1999999401eeeeeee1099999941eeeeee1999999941eeeeee1999999941eeeeeeeeeeeee1941eee1244444444221eeeeeedeeeeeeeeeee00000000
00077000ee19999994001eeeee10099999991eeeee19990499991eeeee19999999991eeeeeeee11110041eee144444444444421eeeedeeeeeeeeedee00000000
00077000e199999999401eeeee109999999941eeee199004999941eeee199999999941eeeee11009909661ee114440000044411eeedeeeeeeeeedeee00000000
00700700e199909999401eeeee109999909941eee1999004999941eee1990999990991eeee1770007799761e121100999001121eeeeeeeeeeeedeeee00000000
00000000e100999999441eeeee199999999001eee1999904999941eee1999900099991eee19990999979961e142109000901221eeeeeeeeeeeeeeeee00000000
00000000e199999999941eeeee199999999941eee1999999999941eee1999999999991ee199999999997941e1d41090009014d1eeeeeeeeeeeeeeeee00000000
00000000e177999999761eeeee177999999761eee1779999999761eee1779999999771ee199449999997941e14d100009001d21eeeeeeeeeeeeeeeee00000000
00000000e191777777401eeeee109777777141eee19977777779441ee1997777777991ee199499999999741e144ddd0900dd421eeeeeeeeeeeeeeeee00000000
00000000e1199999994001eee1009999999911eee1999904999941eee1191999991911ee199999999999741e144144090441421eeeedeeeeeeeeeeee00000000
00000000e19919999971941e19417999991941eeee179004999961eee1611999991161ee199999999999741e1d41440004414d1eeedeeeeeeeeedeee00000000
00000000ee1177777799941e1999977777711eeeee197706777741eeee146777776441eee19999990c97941e14d144090441d21eedeeeeeeeeedeeee00000000
00000000e1499999994111eee1119999999941eeeee1119419991eeee1941999991941eeee1999999911941ee14ddd000ddd41eeeeeeeeeeeedeeeee00000000
00000000ee111111111eeeeeeeee111111111eeeeee199411111eeeeee11111111111eeeeee1111111ee11eee1441444441421eeeeeeeeeeeeeeeeee00000000
00000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee111eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee11111111111eeeeeeeeeeeeeeeeeee00000000
00000000d11111111111111dd11111111111111dd11111111111111dd11111111111111dd11111111111111d0000000000000000000000000000000000000000
00000000181818181818181118181818181818111818181818181811181818181818181118181818181818110000000000000000000000000000000000000000
000000001111e111e111e11111111111e111811111118111e1118111111181111111811111118111111181110000000000000000000000000000000000000000
00000000181eeeeeeeeee18118881eeeeee188811888881ee1888881188888888188888118888888188888810000000000000000000000000000000000000000
00000000181eeeeeeeeee18118881eeeeee188811888821ee1288881188888888188888118888888188888810000000000000000000000000000000000000000
00000000181eeeeeeeeee18118881eeeeee188211888821ee1288881188888828188888118888888188888810000000000000000000000000000000000000000
00000000181eeeeeeeeee1811881eeeeeeee1821188881eeee188881188888828188888118888888188888810000000000000000000000000000000000000000
00000000181eeeeeeeeee1811821eeeeeeee1821188881eeee188881188828821888888118882888188828810000000000000000000000000000000000000000
00000000181eeeeeeeeee1811821eeeeeeee1881188281eeee182881188828821888288118882828182828810000000000000000000000000000000000000000
00000000181eeeeeeeeee1211821eeeeeeee188118821eeeee182881188828881888288118882828182828810000000000000000000000000000000000000000
00000000181eeeeeeeeee1211821eeeeeeee188118821eeeeee12881188828881888282118882128182128210000000000000000000000000000000000000000
00000000121eeeeeeeeeee11181eeeeeeeeee18112821eeeeee1288112882181e188282112882121182121210000000000000000000000000000000000000000
00000000121eeeeeeeeeee11181eeeeeeeeee12112821eeeeeee182112882181e118212112182121182121210000000000000000000000000000000000000000
0000000011eeeeeeeeeeee11121eeeeeeeeeee111281eeeeeeee18211218211ee118212112182121182121210000000000000000000000000000000000000000
0000000011eeeeeeeeeeeee111eeeeeeeeeeee111221eeeeeeee1221121221eeee12212112122121122121210000000000000000000000000000000000000000
000000001eeeeeeeeeeeeee111eeeeeeeeeeeee1111eeeeeeeeee111111111eeee11111111111111111111110000000000000000000000000000000000000000
__sfx__
010100003303000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0105000014051110530d0530d05300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000000000000000
011000001d0551a0550000515055110550c0550805504055000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005
010800002d3302d3302d3302d330003002d330003002d330003002d330243002e3302e330243002e3302e330243002e3302e330243002d3302d3302d330003000030000300003000030000300003000030000300
010800002d4202d4202d4202d4200040018420004001d4200040018420004001b4201b420004001b4201b420004001c4201c420004001d4201d4201d420004000040000400004000040000400004000040000400
011600001f0501f050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001600002405024050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
