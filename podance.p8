pico-8 cartridge // http://www.pico-8.com
version 43
__lua__
function _init()
	poke(0x5f2e,1)
	pal(9,9+128,1)
	palt(0,false)
	palt(14,true)
	big,style=
	"\^w\^t","\^o016"
	state="main" --[[
		main,tut,hold,quit,rdy,go,fin
	]]
	f=0
	stage,round,step,score,total=
	0,0,0,0,0
	moves,movesets,movesp,movenum=
	{},{},nil,1 --[[
		moves={sp,x,y}
		movesets={d,hide,flep}
	]]
	instage,correct,sounded=
	false,nil,false
	rotanim,animend=
	{2,3,1,0},24 --#moves*2+8
	csp,csp0=65,65	--curtain anim
	fmap={3,0,1,0,7,0,5}
	spd=10
	spdl,spdh=spd\2-1,spd\2+1
	smoke={}
end


function _update()
	if state=="main" then
		f=0
		csp=csp0
		if (btnp(🅾️)) state="rdy"
		if (btnp(❎)) state="tut"
		
	elseif state=="tut" then
		if (f%spd==0) sfx(0)
		f+=1
		if f>=spd*4
		and csp<csp0+8 then
			csp+=2
		end
		if f==spd*8 then
			f=0
			csp=csp0
		end
		if (btnp(❎)) state="main"
		
	elseif state=="hold" then
		f+=1
		if f<spd*2
		and csp>csp0 then
			csp-=2
		end
		if f>=spd*2
		and csp<csp0+8 then
			csp+=2
		end
		if (f==spd*4)	f=0
		if (btnp(🅾️)) then
			f=0
			state="rdy"
		end
		if (btnp(❎)) state="quit"
		
	elseif state=="quit" then
		if (btnp(🅾️)) state="hold"
		if (btnp(❎)) state="main"
		
	elseif state=="rdy" then
		if f<spd*8 then
			f+=1
		else
			moves,movesets,movesp,
			movenum,round,step,score,f=
			{},{},nil,1,1,0,0,0
			stage+=1
			initmovesets()
			state="go"
			instage=true
		end
		
		if f==1
		or f==spd*2+1
		or f==spd*4+1 then
			sfx(5)
		elseif f==spd*6+1 then
			sfx(6)
		end
		
	elseif state=="go" then
		updategame()
		
	elseif state=="fin" then
		if (btnp(🅾️)) state="main"
		if (btnp(❎)) state="main"
	end
end


function _draw()
	cls()
	color(15) --bg
	rectfill(0,0,128,128) --bg
	color(7)
	if state=="main" then
		print(big..style..
			"podance"
		)
		print(style..
			"🅾️ start       ❎ tut",
			21,106
		)
	
	elseif state=="tut" then
		local ms={⬅️,⬆️,➡️,⬇️}
		local tstep=f\spd+1
		
		--basics
		for i=1,4 do
			local c=
				tstep==i and 7 or 12
			drawsq(getx(i),gety(i)-28,c)
			spr(
				getsp(ms[i]),
				getx(i),
				gety(i)-28,
				2,2
			)
			local off=
				tstep-4==i and 57 or 41
			spr(ms[i]+off,
				getx(i)+4,
				gety(i)-8)
		end
		
		line(
			getx(1)-4,
			gety(5)-12,
			getx(4)+18,
			gety(5)-12,
			13
		)
		line(
			getx(2)+18,
			gety(5)-8,
			getx(2)+18,
			gety(5)+26,
			13
		)
		
		--curtain
		local x,y=
			getx(5)+11,gety(5)
		drawsq(x,y,7)
		spr(getsp(⬇️),x,y,2,2)
		drawcurtain(x,y)
		print(style..
			"❎ main",
			49,106,7
		)
		off=
			tstep==8 and 57 or 41
		spr(
			⬇️+off,
			getx(5)+15,
			gety(5)+18
		)
		
		--mirror
		local x,y=
			getx(7)+11,gety(7)
		local tstep2=f\(spd*2)+1
		off=
			tstep%2==0 and 57 or 41
		drawsq(x,y,7)
		rectfill(x-1,y-1,x+15,y+16,6)
		spr(
			fmap[getsp(ms[tstep2])]+32,
			x,y,2,2
		)
		spr(ms[tstep2]+off,x+4,y+18)
		rect(x-1,y-1,x+15,y+16,7)
		spr(13,x,y,2,2)
		
		print(style..
			"❎ main",
			49,106,7
		)
	
	elseif state=="hold" then
		local ns=stage+1
		local titleset={
			"",
			"memorise",
			"practice",
			"all together!"
		}
		local x=29
		if (ns==4) x=21
		print(style..
			"stage "..ns..
			": "..titleset[ns],
			x,25
		)
		
		spr(getsp(⬇️),62,54,2,2)
		drawcurtain(62,54)
		spr(getsp(⬆️),54,62,2,2)
		
		print(style..
			"🅾️ start      ❎ quit",
			21,106
		)
	
	elseif state=="quit" then
		print("quit")
		print(style..
			"🅾️ back      ❎ quit",
			22,106
		)
	
	elseif state=="rdy" then
		if f<spd*6 then
			print(big..style..
				3-f\(spd*2),
				60,40
			)
		else
			print(big..style..
				"go!",
				54,40
			)	
		end
	
	elseif state=="go" then
		drawgame()
		
	elseif state=="fin" then
		print("fin")
		print("total: "..total)
		print(style..
			"🅾️ main",
			50,106
		)
	end
end
-->8
--main game loop
function updategame()
	--gameplay
	if instage then
		--update step
		if f%spd==0 then
 		correct=nil
 		sounded=false
			step+=1
			
			--next round
			if step==17 then
				round+=1
				step,f=1,0
				csp=csp0
			end
			
 		if round==#movesets+1 then
 			instage=false
 			return
 		end
 		
			if (step==1) moves={}
 		
			sfx(0)
			
			--demo move
			if step<9 then
				local moveinfo=
					movesets[round][step]
				
				add(moves,
								{
									sp=getsp(
										moveinfo.d
									),
									x=getx(step),
									y=gety(step),
									hide=moveinfo.hide,
									flep=moveinfo.flep,
								})
			end
		end
		
		--user move
		if step>=9 then
			--input timeframe
			if f%spd>spdh
			or f%spd<spdl then
	 			if correct==nil then
	 				movesp=checkmove(
	 					movesets[round]
	 					[movenum].d
	 				)
	 			end
	 		--check input
 			else
 				if correct==true
 				and f%spd==spdl then
 					score+=1
 				end
 			
 				if correct!=true then
 					checkerr()
 					movesp=9
 				end
 			
 				movenum=step-7
 				if (movenum==9) movenum=1
			end
		 
			--animate curtains
			if (csp<csp0+8)	csp+=2
		end
		
	--stage end
	else
		--init end sequence
		if f==0 then
			step=1
			for move in all(moves) do
				move.sp=7
			end
			movesp=7
			sfx(3)
			sfx(4)
		end
		
		local g=42
		local fspd=3
		
		--rotate the potate
		if f%fspd==0 then
			for i,move in pairs(moves)
			do
				if (step==i*2)	move.dy=-g
				
				if step>animend then
					move.sp=7
				else
					move.sp=getsp(
						rotanim[(move.sp-1)/2+1]
					)
				end
			end
			
			step+=1
		end
		
		--jump for joy
		for move in all(moves) do
			if move.dy
			and move.dy<=g do
				--[[	doing it this way
						because getting strange
						0.001 or 0.999 values
						when using decimals	]]
				local y=move.y*10
				y+=move.dy
				move.dy+=fspd*2
				move.y=ceil(y)/10
			end
		end
		
		--wrap up
		if f==150 then
			if stage==#movesets then
				state="fin"
			else
				total+=score
				state="hold"
				f=0
			end
		end
	end
	
	--update smoke
	local mult=
		instage and 0.8 or 0.2
	for p in all(smoke) do
		p.x+=p.dx*mult
  	p.y+=p.dy*mult
  	p.act-=
  		instage and 1 or 0.2
  	if (p.act<0) del(smoke,p)
	end
 
	f+=1
end


function drawgame()
	--print(step)
	if instage then
		print(style..
			"round "..round,
			3,4
		)
	else
		print(style..
			"round "..round-1,
			3,4
		)
	end
	print(style..
		score.."/32",
		3,12
	)
	
	--draw base 2x4 grid
	for i=1,8 do
		local c=7
		if instage
		and ceil(step%8.1)==i then
			c=12
		end
		drawsq(getx(i),gety(i),c)
	end
	
	--draw steps
	for move in all(moves) do
		local x,y,sp,spshft=
			move.x,move.y,move.sp,0
		
		--flipped sprite
		if move.flep then
			sp=fmap[sp]
			spshft=32
			--mirror base
			rectfill(
				x-1,y-1,x+15,y+16,6
			)
		end
		
		--demo move
		spr(sp+spshft,x,y,2,2)
		
		--curtain
		if move.hide then
			drawcurtain(x,y,spshft!=0)
		end
		
		--mirror surface
		if move.flep then
			rect(x-1,y-1,x+15,y+16,7)
			spr(13,x,y,2,2)
		end
	end
	
	--draw player
	drawsq(57,92,7)
	if instage
	and step>=9
	and movesp then
		local c=7
		if correct==nil then
			c=7
		elseif correct then
			c=11
		else
			c=8
		end
		drawsq(57,92,c)
	end
	if movesp then
		spr(movesp,57,92,2,2)
	end
	
	--draw smoke
	for p in all(smoke) do
		circfill(p.x,p.y,p.r,p.c)
	end
 
 --wrap up
	if not instage
	and step>animend then
		print(big..style..
			"stage end!",
			25,29
		)
	end
end
-->8
--functions
function initmovesets()
	for i=1,4 do
		local moveset={}
		local repcount=0
		for j=1,8 do
			local sel=getrndmove()
			local prev=moveset[j-1]
			if (prev) prev=prev.d
			
			if sel==prev
			and repcount==1 then
				--lower chance of repeats
				sel=getrndmove()
			end
			
			if repcount==2 then
				--prevent further repeats
				while sel==prev do
					sel=getrndmove()
				end
			end
			
			if sel==prev then
				repcount+=1
			elseif repcount>0 then
				repcount-=1
			end
			
			add(moveset,{d=sel})
		end
		
		--add modifiers
		local hides,fleps={},{}
		if stage==2 or stage==4 then
			hides=getmodmoves(i)
		end
		if stage==3 or stage==4 then
			fleps=getmodmoves(i)
		end
		
		for j=1,8 do
			if intable(hides,j) then
				moveset[j].hide=true
			else
				moveset[j].hide=false
			end
			if intable(fleps,j) then
				moveset[j].flep=true
			else
				moveset[j].flep=false
			end
		end
		
		add(movesets,moveset)
	end
end


function getrndmove()
	local ms={⬅️,➡️,⬆️,⬇️}
	return ms[flr(rnd(4))+1]
end


function getmodmoves(n)
	local nums={1,2,3,4,5,6,7}
	local modmoves={}
	for i=1,n do
		local sel=flr(rnd(#nums))+1
		add(modmoves,nums[sel])
		deli(nums,sel)
	end
	return modmoves
end


function intable(table,item)
	for x in all(table) do
		if x==item then
			--[[	bad practice but
					should be fine here	]]
			del(table,item)
			return true
		end
	end
	return false
end


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
 return (step\4.1+1)*16+38
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
	return movesp
end


function checkerr()
	if not sounded then
		sfx(1)
		sounded=true
		--draw smoke
  for i=1,20 do
  	add(smoke,{x=64,y=100,
      	dx=rnd(3)-1.5,
      	dy=rnd(2)-1,
      	r=rnd(2),act=15,
      	c=rnd({5,6,2,0})})
  end
	end
end


function drawcurtain(x,y,shft)
	local spshft=shft and 32 or 0
	local x1,y1,x2,y2=
		x-1,y-1,x+15,y+15
	local cf=csp-csp0
	--curtain top,left,right
	line(x1,y1,x2,y1,1)
	line(x1,y1,x1,y2,1)
	line(x2,y1,x2,y2,1)
	--curtain bottom
	line(x1,y2,x1+cf,y2,1)
	line(x2,y2,x2-cf,y2,1)
	spr(csp+spshft,x,y,2,2)
	line(x1,y2+1,x2,y2+1,7)
end
-->8
--debugger
function log(x)
	printh(p(x))
end

function p(x)
	local o=""
	for i=1,select("#",x)	do
		o..=_r(select(i,x),4).." "
	end
	return o
end

function _r(t,c)
	if	type(t)~="table"
	or c<=0 then
	return tostr(t)
	end
	local s="{"
	for k,v in next,t do
	s..=tostr(k).."="..
					_r(v,c-1)..","
	end
	return s.."}"
end
__gfx__
00000000eeee11411eeeeeeeeeeeee11411eeeeeeeeee114111eeeeeeeeee111411eeeeeeeeeeeeeeeeeeeeeeee111111111eeeeeeeeeeeeeeeeeeee00000000
00000000eee19999411eeeeeeeee11999941eeeeeeee19999941eeeeeeee19999941eeeeeeeeeeeeeee11eeeee12222222221eeeeee7eeeeeeeeeeee00000000
00700700ee1999999401eeeeeee1099999941eeeeee1999999941eeeeee1999999941eeeeeeeeeeeee1941eee1244444444221eeee7eeeeeeeeeeeee00000000
00077000ee19999994001eeeee10099999991eeeee19990499991eeeee19999999991eeeeeeee11110041eee144444444444421ee7eeeeeeeeeeeeee00000000
00077000e199999999401eeeee109999999941eeee199004999941eeee199999999941eeeee11009909661ee114440000044411eeeeeeeeeeeeeeeee00000000
00700700e199909999401eeeee109999909941eee1999004999941eee1990999990991eeee1770007799761e121100999001121eeeeeeeeeeeeeeeee00000000
00000000e100999999441eeeee199999999001eee1999904999941eee1999900099991eee19990999979961e142109000901221eeeeeeeeeeeeeeeee00000000
00000000e199999999941eeeee199999999941eee1999999999941eee1999999999991ee199999999997941e1d41090009014d1eeeeeeeeeeeeeeeee00000000
00000000e177999999761eeeee177999999761eee1779999999761eee1779999999771ee199449999997941e14d100009001d21eeeeeeeeeeeeeeeee00000000
00000000e191777777401eeeee109777777141eee19977777779441ee1997777777991ee199499999999741e144ddd0900dd421eeeeeeeeeeeeeeeee00000000
00000000e1199999994001eee1009999999911eee1999904999941eee1191999991911ee199999999999741e144144090441421eeeeeeeeeeeeeeeee00000000
00000000e19919999971941e19417999991941eeee179004999961eee1611999991161ee199999999999741e1d41440004414d1eeeeeeeeeeeeeeeee00000000
00000000ee1177777799941e1999977777711eeeee197706777741eee1146777776441eee19999990c97941e14d144090441d21eeeeeeeeeeeeeeeee00000000
00000000e1499999994111eee1119999999941eeeee1119419991eeee1941999991941eeee1999999911941ee14ddd000ddd41eeeeeeeeeeeeeee7ee00000000
00000000ee111111111eeeeeeeee111111111eeeeee199411111eeeeee11111111111eeeeee1111111ee11eee1441444441421eeeeeeeeeeeeee7eee00000000
00000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee111eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee11111111111eeeeeeeeeeeeeeeeeee00000000
00000000eeee11211eeeeeeeeeeeee11211eeeeeeeeee112111eeeeeeeeee111211eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee000000000000000000000000
00000000eee14444211eeeeeeeee11444421eeeeeeee14444421eeeeeeee14444421eeeee77777eee77777eee77777eee77777ee000000000000000000000000
00000000ee1444444201eeeeeee1044444421eeeeee1444444421eeeeee1444444421eee7771177e7711777e7771777e7711177e000000000000000000000000
00000000ee14444442001eeeee10044444441eeeee14440244441eeeee14444444441eee7711177e7711177e7711177e7711177e000000000000000000000000
00000000e144444444201eeeee104444444421eeee144002444421eeee144444444421ee7771177e7711777e7711177e7771777e000000000000000000000000
00000000e144404444201eeeee104444404421eee1444002444421eee1440444440441eed77777ded77777ded77777ded77777de000000000000000000000000
00000000e100444444221eeeee144444444001eee1444402444421eee1444400044441eeedddddeeedddddeeedddddeeedddddee000000000000000000000000
00000000e144444444421eeeee144444444421eee1444444444421eee1444444444441eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee000000000000000000000000
00000000e1664444446d1eeeee1664444446d1eee16644444446d1eee1664444444661eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee000000000000000000000000
00000000e141666666201eeeee104666666121eee14466666664221ee1446666666441eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee000000000000000000000000
00000000e1144444442001eee1004444444411eee1444402444421eee1141444441411eee66666eee66666eee66666eee66666ee000000000000000000000000
00000000e14414444461421e14216444441421eeee1640024444d1eee1d114444411d1ee6661166e6611666e6661666e6611166e000000000000000000000000
00000000ee1166666644421e1444466666611eeeee14660d666621eee112d66666d221ee6611166e6611166e6611166e6611166e000000000000000000000000
00000000e1244444442111eee1114444444421eeeee1114214441eeee1421444441421ee6661166e6611666e6611166e6661666e000000000000000000000000
00000000ee111111111eeeeeeeee111111111eeeeee144211111eeeeee11111111111eeee66666eee66666eee66666eee66666ee000000000000000000000000
00000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee111eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee000000000000000000000000
00000000818181818181818e818181818181818e818181818181818e818181818181818e818181818181818e0000000000000000000000000000000000000000
0000000011111e111e11111e12111e111e11121e121112111211121e121112111211121e121112111211121e0000000000000000000000000000000000000000
0000000081eeeeeeeeeee18e8881eeeeeee1888e8888881e1888888e888888818888888e888888818888888e0000000000000000000000000000000000000000
0000000081eeeeeeeeeee18e8881eeeeeee1288e8888881e1888888e888888818888888e888888818888888e0000000000000000000000000000000000000000
0000000081eeeeeeeeeee18e8281eeeeeee1288e888881ee1828888e888888818888888e888888818888888e0000000000000000000000000000000000000000
0000000081eeeeeeeeeee18e8281eeeeeee1282e888881eee128888e888888818888888e888888818882888e0000000000000000000000000000000000000000
0000000081eeeeeeeeeee18e821eeeeeeeee182e888821eee128888e888888818888888e882888818882888e0000000000000000000000000000000000000000
0000000081eeeeeeeeeee18e821eeeeeeeee182e888821eee128288e888888218882888e882882818882888e0000000000000000000000000000000000000000
0000000081eeeeeeeeeee12e821eeeeeeeee182e88881eeeee18288e882888212882888e882812818282888e0000000000000000000000000000000000000000
0000000021eeeeeeeeeee12e821eeeeeeeee188e88281eeeee12288e882888212882828e882812818212882e0000000000000000000000000000000000000000
0000000021eeeeeeeeeee12e821eeeeeeeee188e88281eeeee12288e8828821e1882821e882812118212812e0000000000000000000000000000000000000000
0000000021eeeeeeeeeeee1e81eeeeeeeeeee18e88221eeeee12288e8821821e1282121e812212118212812e0000000000000000000000000000000000000000
000000001eeeeeeeeeeeee1e21eeeeeeeeeee18e2821eeeeeee1282e1821811e1282121e812212118212812e0000000000000000000000000000000000000000
000000001eeeeeeeeeeeee1e21eeeeeeeeeee12e2821eeeeeee1282e182121eee182121e812212118212812e0000000000000000000000000000000000000000
000000001eeeeeeeeeeeeeee21eeeeeeeeeee12e2221eeeeeee1222e122121eee122121e212212112212212e0000000000000000000000000000000000000000
00000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000000000000000000000000000
00000000212121212121212e212121212121212e212121212121212e212121212121212e212121212121212e0000000000000000000000000000000000000000
0000000011111e111e11111e11111e111e11111e111111111111111e111111111111111e111111111111111e0000000000000000000000000000000000000000
0000000021eeeeeeeeeee12e2221eeeeeee1222e2222221e1222222e222222212222222e222222212222222e0000000000000000000000000000000000000000
0000000021eeeeeeeeeee12e2221eeeeeee1122e2222221e1222222e222222212222222e222222212222222e0000000000000000000000000000000000000000
0000000021eeeeeeeeeee12e2121eeeeeee1122e222221ee1212222e222222212222222e222222212222222e0000000000000000000000000000000000000000
0000000021eeeeeeeeeee12e2121eeeeeee1121e222221eee112222e222222212222222e222222212221222e0000000000000000000000000000000000000000
0000000021eeeeeeeeeee12e211eeeeeeeee121e222211eee112222e222222212222222e221222212221222e0000000000000000000000000000000000000000
0000000021eeeeeeeeeee12e211eeeeeeeee121e222211eee112122e222222112221222e221221212221222e0000000000000000000000000000000000000000
0000000021eeeeeeeeeee11e211eeeeeeeee121e22221eeeee12122e221222111221222e221211212121222e0000000000000000000000000000000000000000
0000000011eeeeeeeeeee11e211eeeeeeeee122e22121eeeee11122e221222111221212e221211212111221e0000000000000000000000000000000000000000
0000000011eeeeeeeeeee11e211eeeeeeeee122e22121eeeee11122e2212211e1221211e221211112111211e0000000000000000000000000000000000000000
0000000011eeeeeeeeeeee1e21eeeeeeeeeee12e22111eeeee11122e2211211e1121111e211111112111211e0000000000000000000000000000000000000000
000000001eeeeeeeeeeeee1e11eeeeeeeeeee12e1211eeeeeee1121e1211211e1121111e211111112111211e0000000000000000000000000000000000000000
000000001eeeeeeeeeeeee1e11eeeeeeeeeee11e1211eeeeeee1121e121111eee121111e211111112111211e0000000000000000000000000000000000000000
000000001eeeeeeeeeeeeeee11eeeeeeeeeee11e1111eeeeeee1111e111111eee111111e111111111111111e0000000000000000000000000000000000000000
00000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000000000000000000000000000
__sfx__
010100003303000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0105000014051110530d0530d05300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000000000000000
011000001d0551a0550000515055110550c0550805504055000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005
010800002d3302d3302d3302d330003002d330003002d330003002d330243002e3302e330243002e3302e330243002e3302e330243002d3302d3302d330003000030000300003000030000300003000030000300
010800002d4202d4202d4202d4200040018420004001d4200040018420004001b4201b420004001b4201b420004001c4201c420004001d4201d4201d420004000040000400004000040000400004000040000400
011600001f0501f050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001600002405024050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
