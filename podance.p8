pico-8 cartridge // http://www.pico-8.com
version 43
__lua__
function _init()
 	poke(0x5f2e, 1)
	pal(9,9+128,1)
	palt(0,false)
	palt(14,true)
	big,style=
	"\^w\^t","\^o016"
	state="main" --[[
		main,tut,hold,quit,rdy,go,fin
	]]
	stage,round,step,score,f=
	1,1,0,0,0
	moves,movesets,movesp,movenum=
	{},{},nil,1 --[[
		moves={sp,x,y}
		movesets={d,hide,flep}
	]]
	inround,correct,sounded=
	false,nil,false
	rotanim,animend=
	{2,3,1,0},24 --#moves*2+8
	csp=33	--curtain anim
	smoke={}
end


function _update()
	if state=="main" then
		if (btnp(🅾️)) state="rdy"
		if (btnp(❎)) state="tut"
		
	elseif state=="tut" then
		if (btnp(❎)) state="main"
		
	elseif state=="hold" then
		if (btnp(🅾️))	state="rdy"
		if (btnp(❎)) state="quit"
		
	elseif state=="quit" then
		if (btnp(🅾️)) state="hold"
		if (btnp(❎)) state="main"
		
	elseif state=="rdy" then
		if f<80 then
			f+=1
		else
			initmovesets()
			round,step,f=1,0,0
			inround=true
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
		print("tut")
		print(style..
			"❎ main",
			49,106
		)
	
	elseif state=="hold" then
		print("hold")
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
		if f<60 then
			print(big..style..
				3-f\20,
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
	if inround then
		--update step
		if f%10==0 then
 		correct=nil
 		sounded=false
			step+=1
			
			--next round
			if step==17 then
				round+=1
				step,f=1,0
				csp=33
			end
			
 		if round==#movesets+1 then
 			inround=false
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
			if f%10>6 or f%10<4 then
	 			if correct==nil then
	 				movesp=checkmove(
	 					movesets[round]
	 					[movenum].d
	 				)
	 			end
	 		--check input
 			else
 				if correct==true
 				and f%10==4 then
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
			if (csp<41)	csp+=2
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
		
		local spd=42
		local fspd=3
		
		--rotate the potate
		if f%fspd==0 then
			for i,move in pairs(moves)
			do
				if (step==i*2)	move.dy=-spd
				
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
			and move.dy<=spd do
				--[[doing it this way
				because getting strange
				0.001 or 0.999 values
				when using decimals]]
				local y=move.y*10
				y+=move.dy
				move.dy+=fspd*2
				move.y=ceil(y)/10
			end
		end
		
		--wrap up
		if f==150 then
			f=0
			stage+=1
			moves={}
			if stage==#movesets+1 then
				state="main"
			else
				state="hold"
			end
		end
	end
	
	--update smoke
	local mult=
	inround and 0.8 or 0.2
	for p in all(smoke) do
		p.x+=p.dx*mult
  	p.y+=p.dy*mult
  	p.act-=
  	inround and 1 or 0.2
  	if (p.act<0) del(smoke,p)
	end
 
	f+=1
end


function drawgame()
	--print(step)
	if inround then
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
		if inround
		and ceil(step%8.1)==i then
			c=12
		end
		drawsq(getx(i),gety(i),c)
	end
	
	--draw steps
	for move in all(moves) do
		local x,y=move.x,move.y
		local bx1,by1,bx2,by2=
								x-1,y-1,x+15,y+15
								
		if move.flep then
			local flmap={3,0,1,0,7,0,5}
			rectfill(bx1,by1,bx2,by2,6)
			rect(bx1,by1,bx2,by2,13)
			spr(flmap[move.sp],x,y,2,2)
			spr(11,x,y,2,2)
		else
			spr(move.sp,x,y,2,2)
		end
		
		if move.hide then
			local cf=csp-33
			--curtain top,left,right
			line(bx1,by1,bx2,by1,1)
			line(bx1,by1,bx1,by2,1)
			line(bx2,by1,bx2,by2,1)
			--curtain bottom
			line(bx1,by2,bx1+cf,by2,1)
			line(bx2,by2,bx2-cf,by2,1)
			spr(csp,x,y,2,2)
		end
	end
	
	--draw player
	drawsq(57,92,7)
	if inround
	and f%10<4
	and step>=9
	and movesp then
		local c=movesp==9 and 8 or 11
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
	if not inround
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
	for i=1,1 do
		local moveset={}
		local repcount=0
		for j=1,8 do
			local sel=getrndmove()
			local prev=moveset[j]
			
			if sel==prev then
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
		
		add(movesets,moveset)
	end
end


function getrndmove()
	local allmoves={⬅️,➡️,⬆️,⬇️}
	return allmoves[flr(rnd(4))+1]
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
__gfx__
00000000eeee11411eeeeeeeeeeeee11411eeeeeeeeee114111eeeeeeeeee111411eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee111111111eeee00000000
00000000eee19999411eeeeeeeee11999941eeeeeeee19999941eeeeeeee19999941eeeeeeeeeeeeeee11eeeeeeeeeeeeeeeeeeeee12222222221eee00000000
00700700ee1999999401eeeeeee1099999941eeeeee1999999941eeeeee1999999941eeeeeeeeeeeee1941eeeeeedeeeeeeeeeeee1244444444221ee00000000
00077000ee19999994001eeeee10099999991eeeee19990499991eeeee19999999991eeeeeeee11110041eeeeeedeeeeeeeeedee144444444444421e00000000
00077000e199999999401eeeee109999999941eeee199004999941eeee199999999941eeeee11009909661eeeedeeeeeeeeedeee114440000044411e00000000
00700700e199909999401eeeee109999909941eee1999004999941eee1990999990991eeee1770007799761eeeeeeeeeeeedeeee121100999001121e00000000
00000000e100999999441eeeee199999999001eee1999904999941eee1999900099991eee19990999979961eeeeeeeeeeeeeeeee142109000901221e00000000
00000000e199999999941eeeee199999999941eee1999999999941eee1999999999991ee199999999997941eeeeeeeeeeeeeeeee1d41090009014d1e00000000
00000000e177999999761eeeee177999999761eee1779999999761eee1779999999771ee199449999997941eeeeeeeeeeeeeeeee14d100009001d21e00000000
00000000e191777777401eeeee109777777141eee19977777779441ee1997777777991ee199499999999741eeeeeeeeeeeeeeeee144ddd0900dd421e00000000
00000000e1199999994001eee1009999999911eee1999904999941eee1191999991911ee199999999999741eeeedeeeeeeeeeeee144144090441421e00000000
00000000e19919999971941e19417999991941eeee179004999961eee1611999991161ee199999999999741eeedeeeeeeeeedeee1d41440004414d1e00000000
00000000ee1177777799941e1999977777711eeeee197706777741eeee146777776441eee19999990c97941eedeeeeeeeeedeeee14d144090441d21e00000000
00000000e1499999994111eee1119999999941eeeee1119419991eeee1941999991941eeee1999999911941eeeeeeeeeeedeeeeee14ddd000ddd41ee00000000
00000000ee111111111eeeeeeeee111111111eeeeee199411111eeeeee11111111111eeeeee1111111ee11eeeeeeeeeeeeeeeeeee1441444441421ee00000000
00000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee111eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee11111111111eee00000000
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
__sfx__
010100003303000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0105000014051110530d0530d05300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000000000000000
011000001d0551a0550000515055110550c0550805504055000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005
010800002d3302d3302d3302d330003002d330003002d330003002d330243002e3302e330243002e3302e330243002e3302e330243002d3302d3302d330003000030000300003000030000300003000030000300
010800002d4202d4202d4202d4200040018420004001d4200040018420004001b4201b420004001b4201b420004001c4201c420004001d4201d4201d420004000040000400004000040000400004000040000400
011600001f0501f050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001600002405024050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
