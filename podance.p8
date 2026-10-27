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
	stg,rd,stp,sc,tot=
	0,0,0,0,0
	mvs,mvsets,mvsp,mvnum=
	{},{},nil,1 --[[
		mvs={sp,x,y}{}
		mvsets={d,hide,flep}{}
	]]
	instage,correct,sounded=
	false,nil,false
	rotanim,animend=
	{2,3,1,0},24 --#mvs*2+8
	csp,csp0=65,65	--curtain anim
	fmap={3,0,1,0,7,0,5}
	spd=12
	spdl,spdh=spd\2-1,spd\2+1
	smoke={}
	clouds={}
	grass={}
	flwrs={}
	msc=false
	cy=130
	cx=128
	initfield()
end


function _update()
	if state=="main" then
		f+=1
		if (f==spd*4)	f=0
		if cy!=121 then
			cy-=1
		elseif cx!=-128 then
			cx-=1
		else
			cx=128
		end
		if not msc then
			music(16)
			msc=true
		end
		if (btnp(🅾️)) state="rdy"
		if (btnp(❎)) state="tut"
		if btnp(🅾️) or btnp(❎) then
			sfx(51)
			f=0
			csp=csp0
			cx=128
			cy=130
			music(-1)
			msc=false
		end
		
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
		if btnp(🅾️) or btnp(❎) then
			sfx(51)
			state="main"
		end
		
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
		if btnp(🅾️) then
			sfx(51)
			state="main"
			f=0
			state="rdy"
		end
		if btnp(❎) then
			sfx(51)
			state="quit"
		end
		
	elseif state=="quit" then
		if btnp(🅾️) then
			sfx(51)
			state="hold"
		end
		if btnp(❎) then
			sfx(51)
			state="main"
		end
		
	elseif state=="rdy" then
		if f<spd*8 then
			f+=1
		else
			mvs,mvsets,mvsp,
			mvnum,rd,stp,sc,f,csp=
			{},{},nil,1,1,0,0,0,csp0
			stg+=1
			initmvsets()
			state="go"
			instage=true
			music((stg-1)*4)
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
		f+=1
		if f==30*spd then
			f=0
			music(-1)
		end
		if not msc then
			music(34)
			msc=true
		end
		if btnp(🅾️) or btnp(❎) then
			sfx(51)
			state="main"
			music(-1)
			msc=false
		end
	end
end


function _draw()
	cls()
	color(15) --bg
	rectfill(0,0,128,128) --bg
	color(7)
	if state=="main" then
		local ms={⬅️,⬆️,➡️,⬇️}
		local tstp=f\spd
		for i=0,5 do
			for j=-7,4 do
			local off=i%2*10
				spr(getsp(
				ms[(tstp+i)%4+1]),
				i*23,j*23+f\2+off,2,2)
			end
		end
		rrectfill(28,24,71,21,2,5)
		rrect(28,24,71,21,2,0)
		rrectfill(16,101,43,14,2,5)
		rrect(16,101,43,14,2,0)
		rrectfill(65,101,52,14,2,5)
		rrect(65,101,52,14,2,0)
		local c=tstp%2==0 and 1 or 10
		print(big..style..
			"podance",36,30,c)
		print(style..
			"🅾️ start    ❎ tutorial",
			21,106,9)
		rectfill(0,cy-3,127,cy+8,2,5)
		print(style..
			"♪alan gogoll - "..
			"goldfish ocean",
			cx,cy,7)
	
	elseif state=="tut" then
		drawtut()
		rrectfill(38,109,52,14,2,5)
		rrect(38,109,52,14,2,0)
		print(style..
			"🅾️/❎ main",
			44,114,9)
	
	elseif state=="hold" then
		drawhold()
		rrectfill(16,101,43,14,2,5)
		rrect(16,101,43,14,2,0)
		rrectfill(71,101,40,14,2,5)
		rrect(71,101,40,14,2,0)
		print(style..
			"🅾️ start      ❎ quit",
			21,106,9)
	
	elseif state=="quit" then
		print("quit")
		rrectfill(16,101,36,14,2,5)
		rrect(16,101,36,14,2,0)
		rrectfill(72,101,37,14,2,5)
		rrect(72,101,37,14,2,0)
		print(style..
			"🅾️ no",
			23,106,9)
		print(style..
			"❎ yes",
			78,106,8)
			
			
	
	elseif state=="rdy" then
		rrectfill(50,35,27,19,2,5)
		rrect(50,35,27,19,2,0)
		if f<spd*6 then
			print(big..style..
				3-f\(spd*2),
				60,40,8)
		else
			print(big..style..
				"go!",
				53,40,11)	
		end
	
	elseif state=="go" then
		drawgame()
		
	elseif state=="fin" then
		drawfield()
		print("fin")
		print("total: "..tot)
		rrectfill(38,101,52,14,2,5)
		rrect(38,101,52,14,2,0)
		print(style..
			"🅾️/❎ main",
			44,106,9)
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
			stp+=1
			
			--next round
			if stp==17 then
				rd+=1
				stp,f=1,1
				csp=csp0
			end
			
 		if rd==#mvsets+1 then
 			instage=false
 			return
 		end
 		
			if (stp==1) mvs={}
 		
			sfx(0)
			
			--demo move
			if stp<9 then
				local mvinfo=
					mvsets[rd][stp]
				
				add(mvs,
								{
									sp=getsp(mvinfo.d),
									x=getx(stp),
									y=gety(stp),
									hide=mvinfo.hide,
									flep=mvinfo.flep,
								})
			end
		end
		
		--user move
		if stp>=9 then
			--input timeframe
			if f%spd>spdh
			or f%spd<spdl then
	 			if correct==nil then
	 				mvsp=checkmv(
	 					mvsets[rd][mvnum].d)
	 			end
	 		--check input
 			else
 				if correct==true
 				and f%spd==spdl then
 					sc+=1
 				end
 			
 				if correct!=true then
 					checkerr()
 					mvsp=9
 				end
 			
 				mvnum=stp-7
 				if (mvnum==9) mvnum=1
			end
		 
			--animate curtains
			if (csp<csp0+8)	csp+=2
		end
		
	--stage end
	else
		--init end sequence
		if f==1 then
			stp=1
			for mv in all(mvs) do
				mv.sp=7
			end
			mvsp=7
			sfx(3)
			sfx(4)
		end
		
		local g=42
		local fspd=3
		
		--rotate the potate
		if f%fspd==0 then
			for i,mv in pairs(mvs)
			do
				if (stp==i*2)	mv.dy=-g
				
				if stp>animend then
					mv.sp=7
				else
					mv.sp=getsp(
						rotanim[(mv.sp-1)/2+1])
				end
			end
			
			stp+=1
		end
		
		--jump for joy
		for mv in all(mvs) do
			if mv.dy
			and mv.dy<=g do
				--[[	doing it this way
						because getting strange
						0.001 or 0.999 values
						when using decimals	]]
				local y=mv.y*10
				y+=mv.dy
				mv.dy+=fspd*2
				mv.y=ceil(y)/10
			end
		end
		
		--wrap up
		if f==150 then
			if stg==#mvsets then
				state="fin"
				f=0
			else
				tot+=sc
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
	drawbg(stg)
	print(style..
		"stage "..stg,
		3,4,7)
	print(style..
		sc.."/32",
		3,12,7)
	
	--draw base 2x4 grid
	for i=1,8 do
		local c=7
		if instage
		and ceil(stp%8.1)==i then
			c=12
		end
		drawsq(getx(i),gety(i),c)
	end
	
	--draw steps
	for mv in all(mvs) do
		local x,y,sp,spshft=
			mv.x,mv.y,mv.sp,0
		
		--flipped sprite
		if mv.flep then
			sp=fmap[sp]
			spshft=32
			--mirror base
			rectfill(
				x-1,y-1,x+15,y+16,6)
		end
		
		--demo move
		spr(sp+spshft,x,y,2,2)
		
		--curtain
		if mv.hide then
			drawcurtain(x,y,spshft!=0)
		end
		
		--mirror surface
		if mv.flep then
			rect(x-1,y-1,x+15,y+16,7)
			spr(13,x,y,2,2)
		end
	end
	
	--draw player
	local px,py=57,87
	drawsq(px,py,7)
	if instage
	and stp>=9
	and mvsp then
		local c=7
		if correct==nil then
			c=7
		elseif correct then
			c=11
		else
			c=8
		end
		drawsq(px,py,c)
	end
	if mvsp then
		spr(mvsp,px,py,2,2)
	end
	
	--draw smoke
	for p in all(smoke) do
		circfill(p.x,p.y,p.r,p.c)
	end
 
 --wrap up
	if not instage
	and stp>animend then
		rrectfill(12,22,103,23,2,5)
		rrect(12,22,103,23,2,0)
		print(big..style..
			"stage clear!",
			17,29,10)
	end
end
-->8
--animations
function drawtut()
	local ms={⬅️,⬆️,➡️,⬇️}
	local tstp=f\spd+1
	local off=0

	--basics
	rrectfill(30,9,67,12,2,5)
	rrect(30,9,67,12,2,0)
	print(style..
			"match the beat!",
			34,13,10)
	for i=1,4 do
		local c=
			(tstp-1)%4+1==i and 12 or 7
		drawsq(getx(i),gety(i)-28,c)
		spr(
			getsp(ms[i]),
			getx(i),
			gety(i)-28,
			2,2)
		local pressed=tstp-4==i
		off=pressed and 57 or 41
		spr(
			ms[i]+off,
			getx(i)+4,
			gety(i)-8)
		if pressed then
			oval(getx(i)+3,
								gety(i)-7,
								getx(i)+11,
								gety(i)-1,
								10)
		end
	end
	
	line(
		getx(1)-4,gety(5)-12,
		getx(4)+18,gety(5)-12,
		13)
	line(
		getx(2)+18,gety(5)-8,
		getx(2)+18,gety(5)+26,
		13)
	
	--curtain
	local x,y=
		getx(5)+8,gety(5)+8
	rrectfill(x-13,61,41,12,2,5)
	rrect(x-13,61,41,12,2,0)
	print(style..
			"remember!",
			x-10,65,10)
	local c=
		tstp%4==0 and 12 or 7
	drawsq(x,y,c)
	spr(getsp(⬇️),x,y,2,2)
	drawcurtain(x,y)
	local pressed=tstp==8
	off=pressed and 57 or 41
	spr(⬇️+off,x+4,y+18)
	if pressed then
			oval(x+3,
								y+19,
								x+11,
								y+25,
								10)
	end
	
	--mirror
	local x,y=
		getx(7)+13,gety(7)+8
	rrectfill(x-12,61,41,12,2,5)
	rrect(x-12,61,41,12,2,0)
	print(style..
			"opposite!",
			x-9,65,10)
	local tstp2=f\(spd*2)+1
	local pressed=tstp%2==0
	off=pressed and 57 or 41
	drawsq(x,y,7)
	rectfill(x-1,y-1,x+15,y+16,6)
	spr(
		fmap[getsp(ms[tstp2])]+32,
		x,y,2,2)
	rect(x-1,y-1,x+15,y+16,7)
	spr(13,x,y,2,2)
	spr(ms[tstp2]+off,x+4,y+18)
	
	if pressed then
			oval(x+3,
								y+19,
								x+11,
								y+25,
								10)
	end
end


function drawhold()
	local ns=stg+1
	local titleset={
		"",
		"learning",
		"memorise",
		"perform!"
	}
	local x=29
	rrectfill(22,20,82,14,2,5)
	rrect(22,20,82,14,2,0)
	print(style..
		"stage "..ns..
		": "..titleset[ns],
		x,25,10)
	
	if ns==3 then
		spr(getsp(⬇️),58,56,2,2)
		drawcurtain(58,56)
		spr(getsp(⬆️),50,64,2,2)
		if csp==csp0+8 then
			print("?",60,63,15)
		end
	
	elseif ns==2 then
		local ms={⬅️,⬆️,➡️,⬇️}
		local fs={➡️,⬇️,⬅️,⬆️}
		local x,y=58,56
		local tstp=f\spd+1
		drawsq(x,y,7)
		rectfill(x-1,y-1,x+15,y+16,6)
		spr(
			getsp(fs[tstp])+32,
			x,y,2,2)
		rect(x-1,y-1,x+15,y+16,7)
		spr(13,x,y,2,2)
		spr(
			getsp(ms[tstp]),
			50,64,2,2)
	
	elseif ns==4 then
		local x,y=58,56
		drawsq(x,y,7)
		rectfill(x-1,y-1,x+15,y+16,6)
		spr(getsp(⬇️)+32,x,y,2,2)
		drawcurtain(x,y,true)
		rect(x-1,y-1,x+15,y+16,7)
		spr(13,x,y,2,2)
		spr(getsp(⬆️),50,64,2,2)
		if csp==csp0+8 then
			print("!",60,63,15)
		end
	end
end
-->8
--functions
function initmvsets()
	for i=1,4 do
		local mvset={}
		local repcount=0
		for j=1,8 do
			local sel=getrndmv()
			local prev=mvset[j-1]
			if (prev) prev=prev.d
			
			if sel==prev
			and repcount==1 then
				--lower chance of repeats
				sel=getrndmv()
			end
			
			if repcount==2 then
				--prevent further repeats
				while sel==prev do
					sel=getrndmv()
				end
			end
			
			if sel==prev then
				repcount+=1
			elseif repcount>0 then
				repcount-=1
			end
			
			add(mvset,{d=sel})
		end
		
		--add modifiers
		local hides,fleps={},{}
		if stg==3 or stg==4 then
			hides=getmodmvs(i)
		end
		if stg==2 or stg==4 then
			fleps=getmodmvs(i)
		end
		
		for j=1,8 do
			if intable(hides,j) then
				mvset[j].hide=true
			else
				mvset[j].hide=false
			end
			if intable(fleps,j) then
				mvset[j].flep=true
			else
				mvset[j].flep=false
			end
		end
		
		add(mvsets,mvset)
	end
end


function getrndmv()
	local ms={⬅️,➡️,⬆️,⬇️}
	return ms[flr(rnd(4))+1]
end


function getmodmvs(n)
	local nums={1,2,3,4,5,6,7}
	local modmvs={}
	for i=1,n do
		local sel=flr(rnd(#nums))+1
		add(modmvs,nums[sel])
		deli(nums,sel)
	end
	return modmvs
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


function getx(stp)
 return ceil(stp%4.1)*21+4
end


function gety(stp)
 return (stp\4.1+1)*16+38
end


function checkmv(m)
	if btnp()>0 then
		correct=btnp(m)
		if not correct then
			checkerr()
			return 9
		elseif m then
			return getsp(m)
		else --fallback
			return 11
		end
	end
	return mvsp
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


function initfield()
	--grass
	for i=0,9 do
		for j=0,2 do
			rndx=rnd(8)-4
			rndy=rnd(12)-6
			add(grass,{x=rndx+13*i,
														y=rndy+90+12*j})
		end
	end
	--flowers
	for i=0,15 do
		for j=0,2 do
			rndx=rnd(8)-4
			rndy=rnd(12)-6
			add(flwrs,{x=rndx+8*i,
														y=rndy+98+12*j,
														p=rnd(
																{2,8,12,14}),
														m=rnd({7,10})})
		end
	end
	--clouds
	add(clouds,{x=rnd(12)+24,
													y=rnd(8)+4,
													sp=137,
													sz=2,
													dir=1})
	add(clouds,{x=rnd(12)+90,
													y=rnd(8)+8,
													sp=137,
													sz=2,
													dir=-1})
	add(clouds,{x=rnd(8)+8,
													y=rnd(8)+12,
													sp=139,
													sz=2,
													dir=-1})
	add(clouds,{x=rnd(32)+64,
														y=rnd(8)+8,
														sp=141,
														sz=2,
														dir=1})
	add(clouds,{x=rnd(16)+48,
														y=rnd(4)+8,
														sp=133,
														sz=4,
														dir=-1})
	add(clouds,{x=rnd(8)+16,
														y=rnd(4)+20,
														sp=133,
														sz=4,
														dir=1})
	add(clouds,{x=rnd(8)+104,
													y=rnd(8)+24,
													sp=139,
													sz=2,
													dir=1})
end
-->8
--backgrounds
function drawbg(stage)
	if stage==1 then
		drawvideo()
	elseif stage==2 then
		drawstudio()
	elseif stage==3 then
		drawbed()
	elseif stage==4 then
		drawhall()
	else
		drawhall()
	end
end


function drawfield()
	local t=f%(2*spd)>spd
							and 1 or 0
	--sky
	rectfill(0,0,127,127,12)
	--grass
	rectfill(0,95,127,127,3)
	for g in all(grass) do
		spr(129+2*t,g.x,g.y,2,2)
	end
	--flowers
	for fl in all(flwrs) do
		circ(fl.x-t,fl.y,1,fl.p)
		circ(fl.x-t,fl.y,0,fl.m)
	end
	--clouds
	for cl in all(clouds) do
		spr(cl.sp,cl.x,cl.y+cl.dir*t,
						cl.sz,cl.sz)
	end
end


function drawvideo()
	--wallpaper
	rectfill(0,0,128,128,12)
	spr(133,50,-4,4,4)
	spr(137,95,2,2,2)
	spr(133,100,4,4,4)
	--window
	rrectfill(0,23,128,12,1,1)
	rrectfill(2,25,30,7,1,6)
	rrectfill(34,25,30,7,1,13)
	line(108,28,111,28,13)
	rect(115,25,118,28,13)
	line(122,25,125,28,13)
	line(125,25,122,28,13)
	--website
	rectfill(0,31,127,127,7)
	rectfill(0,44,127,119,15)
	--header
	spr(161,1,31,2,2)
	print("potube",18,35,6)
	rrect(54,34,40,8,100,6)
	line(84,34,84,41,6)
	spr(163,82,31,2,2)
	--video controls
	local linex=min(120,
							7+f/7+(rd-1)*28)
	line(7,112,120,112,7)
	line(7,112,
						max(7,linex),112,8)
	line(linex,111,linex,113,8)
end


function drawstudio()
	--studio wall
	rectfill(0,0,127,48,5)
	--studio floor
	line(0,48,127,48,1)
	rectfill(0,49,127,127,15)
	--l door frame
	rectfill(0,18,16,47,5)
	--l door glass outer
	rectfill(0,19,15,47,6)
	--l door glass shadow
	rectfill(0,20,11,47,13)
	--l door glass inner
	rectfill(0,20,10,46,1)
	--l door handle
	line(7,32,8,32,13)
	line(8,32,8,35,13)
	line(7,35,8,35,13)
	--r door frame
	rectfill(12,18,30,47,5)
	--r door glass outer
	rectfill(13,19,29,47,6)
	--r door glass shadow
	rectfill(13,20,25,47,13)
	--r door glass inner
	rectfill(14,20,28,46,1)
	--r glass reflection
	line(26,22,26,24,7)
	line(26,27,26,30,7)
	--r door handle
	line(15,32,16,32,13)
	line(15,32,15,35,13)
	line(15,35,16,35,13)
	--mirror
	rectfill(57,3,127,43,6)
	--mirror light
	for i=0,1 do
		line(110+i,43,136+i,3,7)
	end
	for i=0,5 do
		line(102+i,43,128+i,3,7)
	end
	for i=0,50 do
		line(40+i,43,66+i,3,7)
	end
	--mirror border
	rect(56,2,127,44,1)
	--wall patch
	rectfill(35,0,55,47,5)
	--ballet bar
	rect(53,35,127,36,5)
	line(54,35,127,35,4)
	line(109,35,127,35,15)
	--radio
	local rx,ry=17,104
	line(rx,ry+2,rx+2,ry,5)
	rectfill(rx+2,ry,rx+12,ry+8,13)
	oval(rx+2,ry-3,rx+12,ry+5,13)
	circfill(rx+2,ry+4,4,13)
	circfill(rx+12,ry+4,4,13)
	circfill(rx+2,ry+4,2,6)
	circfill(rx+12,ry+4,2,6)
	--speaker highlight
	line(rx+3,ry+2,rx+4,ry+4,7)
	line(rx+13,ry+2,rx+14,ry+4,7)
	--radio buttons
	circ(rx+6,ry+4,0,11)
	circ(rx+8,ry+4,0,8)
end


function drawbed()
	--wall
	rectfill(0,0,127,47,13)
	--window
	rect(33,-1,120,30,7)
	rectfill(34,0,119,29,0)
	--stars
	circ(110,23,0,7)
	circ(110,23,1,7)
	circ(114,11,0,7)
	circ(81,2,0,7)
	circ(70,23,0,7)
	circ(56,8,0,7)
	circ(48,13,0,7)
	circ(43,3,0,7)
	circ(43,3,1,7)
	spr(169,90,-3,2,2)
	--floor
	rectfill(0,48,127,127,1)
	--table
	rectfill(31,43,33,54,4)
	rrectfill(-3,33,40,14,1,5)
	rrectfill(-3,33,40,13,1,4)
	--chair
	rrectfill(2,45,19,9,1,5)
	rrectfill(3,46,17,7,1,4)
	rrectfill(1,35,19,16,1,5)
	rrectfill(2,36,17,14,1,4)
	rectfill(4,54,5,54,4)
	rectfill(16,54,17,54,4)
	--bed outline
	rrectfill(0,57,126,68,2,1)
	--bedlegs
	circfill(14,123,2,4)
	rectfill(15,123,16,125,5)
	circ(14,123,3,1)
	circfill(111,123,2,4)
	rectfill(109,123,111,125,5)
	circ(111,123,3,1)
	--bed
	rrectfill(1,58,124,66,2,13)
	rrectfill(1,58,124,54,2,13)
	rectfill(1,110,124,112,13)
	line(1,112,124,112,6)
	--blanket
	rrectfill(31,58,94,66,2,15)
	rrectfill(31,58,94,54,2,15)
	rectfill(31,110,124,111,15)
	rectfill(31,58,43,111,4)
	rectfill(31,112,43,123,4)
	line(31,112,44,112,5)
	line(44,112,124,112,13)
	line(44,58,44,123,5)
	--pillow
	rrectfill(1,56,32,50,2,13)
	rrectfill(1,56,32,48,2,6)
	line(3,56,1,58,13)
	line(30,56,32,58,13)
end


function drawhall()
	function inside_oval(x,y)
		local ox=(ox1+ox2)/2
		local oy=(oy1+oy2)/2
		local rx=(ox2-ox1)/2
		local ry=(oy2-oy1)/2
  return ((x-ox)^2)/(rx^2)+
  ((y-oy)^2)/(ry^2)<=1
	end

	function light_line(x1,y1,
										x2,y2,c_out,c_in)
  local dx,dy=x2-x1,y2-y1
  local steps=max(
  abs(dx),abs(dy))

  for i=0,steps do
    local t=i/steps
    local x,y=flr(x1+dx*t+0.5),
	    									flr(y1+dy*t+0.5)

    if inside_oval(x,y) then
      pset(x,y,c_in)
    else
      pset(x,y,c_out)
    end
  end
	end
	
	--stage
	rectfill(0,0,127,49,1)
	rectfill(0,50,127,114,4)
	rectfill(0,115,127,127,4)
	ox1,oy1,ox2,oy2=3,54,125,109
	ovalfill(ox1,oy1,ox2,oy2,15)
	--stage lines
	light_line(12,50,-40,115,5,15)
	light_line(24,50,-16,115,5,15)
	light_line(36,50,8,115,5,15)
	light_line(48,50,32,115,5,15)
	light_line(60,50,56,115,5,15)
	light_line(72,50,80,115,5,15)
	light_line(84,50,104,115,5,15)
	light_line(96,50,128,115,5,15)
	light_line(108,50,152,115,5,15)
	light_line(120,50,176,115,5,15)
	line(0,115,127,115,15)
	for i=0,12 do
		local lx=2+i*10
		rectfill(lx,116,lx+3,127,5)
	end
	--seats
	for i=0,6 do
		local lx=-5+i*20
		rrectfill(lx,119,20,20,4,8)
		rrectfill(lx,120,19,20,4,2)
	end
	--left curtains
	ovalfill(-30,-60,20,61,8)
	ovalfill(-30,-60,15,62,2)
	ovalfill(-30,-60,11,63,8)
	ovalfill(-30,-60,8,65,2)
	ovalfill(-30,-60,4,73,8)
	ovalfill(-30,-60,2,75,2)
	
	line(1,60,8,102,8)
	for i=1,10 do
		local x=10-i
		local y=102+flr((i+1)/3)
		local c=8
		if i>2 and i<6 or i>8 then
			c=2
		end
	
		line(0,60,x,y,c)
	end
	
	--right curtains
	ovalfill(156,-60,106,61,8)
	ovalfill(156,-60,111,62,2)
	ovalfill(156,-60,115,63,8)
	ovalfill(156,-60,118,65,2)
	ovalfill(156,-60,122,73,8)
	ovalfill(156,-60,124,75,2)
	line(126,60,119,102,8)
	for i=1,10 do
		local x=117+i
		local y=102+flr((i+1)/3)
		local c=8
		if i>2 and i<6 or i>8 then
			c=2
		end
	
		line(127,60,x,y,c)
	end
	
	--curtain bindings
	rrectfill(-3,59,6,2,6,13)
	rrectfill(125,60,6,2,6,13)
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
00000000eeee11111eeeeeeeeeeeee11111eeeeeeeeee111111eeeeeeeeee111111eeeeeeeeeeeeeeeeeeeeeeee111111111eeeeeeeeeeeeeeeeeeee00000000
00000000eee19999411eeeeeeeee11999941eeeeeeee19999941eeeeeeee19999941eeeeeeeeeeeeeee11eeeee12222222221eeeeee7eeeeeeeeeeee00000000
00700700ee1999999401eeeeeee1099999941eeeeee1999999941eeeeee1999999941eeeeeeeeeeeee1941eee1244444444221eeee7eeeeeeeeeeeee00000000
00077000ee19999994001eeeee10099999991eeeee19990499991eeeee19999999991eeeeeeee11110041eee144444444444421ee7eeeeeeeeeeeeee00000000
00077000e199999999401eeeee109999999941eeee199004999941eeee199999999941eeeee1100990961eee114440000044411eeeeeeeeeeeeeeeee00000000
00700700e199909999401eeeee109999909941eee1999004999941eee1990999990991eeee177000779971ee121100999001121eeeeeeeeeeeeeeeee00000000
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
00000000eeee11111eeeeeeeeeeeee11111eeeeeeeeee111111eeeeeeeeee111111eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee000000000000000000000000
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
00000000eeeeeeeeeeeeebeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeedd666666eeeeeeeeeeeee
00000000eeeeeeeeeeeebbeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeedd777766eeeeeeeddeee
00000000eeeeeeeeeeeeb3eeeeeeeeeeeeeeeeebeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeed677777766eeeeed6666e
00000000eeeeeeeeeeebb3eeeeeeeeeeeeeeeebbeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee666eeeeeeeeeeeeeeeeeeeeeeeeeeed6777777776eeeee6d66de
00000000eeeeeebeeeebb3beeeeeeeeeeeeeebb3eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee666666eeeeeeeeeeee6766777eeeeeeed67777776766eeed66666e
00000000ebbeebbeeeeb3bbeeeeeeeeebeeebb3deeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee666666666eeeeeee67776677777eeeed667767777776eeed66dd66
00000000edbee3bbeebb3bbeeeebeeebbeebbbbeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee666dd66dd666eeeee676667667777eeed667777776776eeeddd66dd
00000000eebeeb3beeb3bbdeeedbeeeb3eeb3bdeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee66666d6666666666ee666676666777eeddd66776667776eeeeddddde
00000000eedbeb3bebb3bdeeeedbeeeb3ebb3beeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeddd666666666ddd6ee6666666777777e66d66677777766ee00000000
00000000eedbebbbebbbbeeeeedbbeebbebbbbeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeddddedddd6eeeee6666666776667777766dd6677766766e00000000
00000000eeebbe3beb3bbeeeeeedbeebbbb3bdeeeeeeeee66666eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee666666777777777edd666d666677767600000000
00000000eeedbb3bbb3bdeeeeeedbbebbb3bbeeeeeeeee666667777eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeedd766677777ddeedd6666777777667700000000
00000000eeebbb33bb3beeeeeeeedb33bb3bdeeeeeeee66666677777eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeedddd66ddddddeeeddd6666777766d7d00000000
00000000eeeedbb3b3bbeeeeeeeeedb3b3bbdeeeeeeee66666776d77ee666eeeeeeeeeeeeeeeeeeeeeeeeeeeeeedddddeeeeeeeeed6dd6666667ddde00000000
00000000eeeeedbbb3bdeeeeeeeeeebbb3bbeeeeeeeee6666676dd77e6677eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeedddddddddddeee00000000
00000000eeeeeedb3bdeeeeeeeeeeedb3bbdeeeeeee666666666d777667777eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00000000
00000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6666666dd77777777777777eeeeeeeeeeeeeeeeeeeeeee0000000000000000000000000000000000000000
00000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee66666666776777777777777777eeeeeeeeeeeeee7eeeeee0000000000000000000000000000000000000000
00000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee66d66666666666777777766d7777eeeeeeeeeeeee77eeee0000000000000000000000000000000000000000
00000000eeee888888888eeeeeeeeeeeeeeeeeeee666dd666666677d677776ddd7777777eeeeeeeeee77eeee0000000000000000000000000000000000000000
00000000eee88888888888eeeee666666eeeeeeeee666666d6666ddd7777dd6d7777ddddeeeeeeeeeee77eee0000000000000000000000000000000000000000
00000000eee88887788888eeeee6777666eeeeeeeedd666ddd666dddddddddedddddeeeeeeeeeeeeeee77eee0000000000000000000000000000000000000000
00000000eee88887778888eeeee67676666eeeeeeedd66ddddddddeedddddeeddeeeeeeeeeeeeeeeeee77eee0000000000000000000000000000000000000000
00000000eee88887788888eeeee67777666eeeeeeeedddddeeedddeeeeeeeeeeeeeeeeeeeeeeeeeeeee777ee0000000000000000000000000000000000000000
00000000eee88888888888eeeee6666766eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee7777ee0000000000000000000000000000000000000000
00000000eeee888888888eeeeee666666eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee7777ee0000000000000000000000000000000000000000
00000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee7777eee0000000000000000000000000000000000000000
00000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee77777eee0000000000000000000000000000000000000000
00000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee7eeee777777eeee0000000000000000000000000000000000000000
00000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee777777777eeeee0000000000000000000000000000000000000000
00000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee77777eeeeeee0000000000000000000000000000000000000000
00000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000000000000000000000000000
__label__
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
88888eeeeee888eeeeee888eeeeee888eeeeee888777777888eeeeee888888888888888888888888888ff8ff8888228822888222822888888822888888228888
8888ee888ee88ee88eee88ee888ee88ee888ee88778787788ee888ee88888888888888888888888888ff888ff888222222888222822888882282888888222888
888eee8e8ee8eeee8eee8eeeee8ee8eeeee8ee8777878778eee8eeee88888e88888888888888888888ff888ff888282282888222888888228882888888288888
888eee8e8ee8eeee8eee8eee888ee8eeee88ee8777888778eee888ee8888eee8888888888888888888ff888ff888222222888888222888228882888822288888
888eee8e8ee8eeee8eee8eee8eeee8eeeee8ee8777778778eeeee8ee88888e88888888888888888888ff888ff888822228888228222888882282888222288888
888eee888ee8eee888ee8eee888ee8eee888ee8777778778eee888ee888888888888888888888888888ff8ff8888828828888228222888888822888222888888
888eeeeeeee8eeeeeeee8eeeeeeee8eeeeeeee8777777778eeeeeeee888888888888888888888888888888888888888888888888888888888888888888888888
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1eee1ee11ee111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1e111e1e1e1e11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1ee11e1e1e1e11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1e111e1e1e1e11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1eee1e1e1eee11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1eee1e1e1ee111ee1eee1eee11ee1ee1111116611666166616161616166616611171117111111111111111111111111111111111111111111111111111111111
1e111e1e1e1e1e1111e111e11e1e1e1e111116161616161616161616116116161711111711111111111111111111111111111111111111111111111111111111
1ee11e1e1e1e1e1111e111e11e1e1e1e111116161661166616161616116116161711111711111111111111111111111111111111111111111111111111111111
1e111e1e1e1e1e1111e111e11e1e1e1e111116161616161616661666116116161711111711111111111111111111111111111111111111111111111111111111
1e1111ee1e1e11ee11e11eee1ee11e1e111116661616161616661161166616661171117111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1111111111111d1d1ddd1ddd11dd1ddd1ddd1ddd1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1111111111111d1d1d111d1d1d1111d111d11d111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111ddd1ddd1d1d1dd11dd11ddd11d111d11dd11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1111111111111ddd1d111d1d111d11d111d11d111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1111111111111ddd1ddd1ddd1dd11ddd11d11ddd1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111bbb1bbb11bb1bbb1bbb1bbb1b111b1111711ccc11111ccc1cc111111cc11ccc1ccc11111cc11ccc1ccc11111ccc11711111111111111111111111111111
11111b1b1b111b1111b11b1111b11b111b1117111c1c1111111c11c1111111c1111c111c111111c1111c111c1111111c11171111111111111111111111111111
11111bb11bb11b1111b11bb111b11b111b1117111c1c111111cc11c1111111c11ccc111c111111c11ccc111c1111111c11171111111111111111111111111111
11111b1b1b111b1111b11b1111b11b111b1117111c1c1171111c11c1117111c11c11111c117111c11c11111c1171111c11171111111111111111111111111111
11111b1b1bbb11bb11b11b111bbb1bbb1bbb11711ccc17111ccc1ccc17111ccc1ccc111c17111ccc1ccc111c1711111c11711111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111bbb1bbb11bb1bbb1bbb1bbb1b111b1111711ccc11111c1c1c1c11111cc11ccc1ccc11111cc11ccc1ccc11111c1111711111111111111111111111111111
11111b1b1b111b1111b11b1111b11b111b1117111c1c11111c1c1c1c111111c1111c111c111111c1111c1c1c11111c1111171111111111111111111111111111
11111bb11bb11b1111b11bb111b11b111b1117111c1c11111ccc1ccc111111c11ccc111c111111c11ccc1c1c11111ccc11171111111111111111111111111111
11111b1b1b111b1111b11b1111b11b111b1117111c1c1171111c111c117111c11c11111c117111c11c111c1c11711c1c11171111111111111111111111111111
11111b1b1bbb11bb11b11b111bbb1bbb1bbb11711ccc1711111c111c17111ccc1ccc111c17111ccc1ccc1ccc17111ccc11711111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1111111111111d1d1ddd1ddd1dd11ddd1ddd11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1111111111111d1d1d111d1d1d1d1d111d1d11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111ddd1ddd1ddd1dd11ddd1d1d1dd11dd111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1111111111111d1d1d111d1d1d1d1d111d1d11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1111111111111d1d1ddd1d1d1ddd1ddd1d1d11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111111bb1bbb1bbb11711cc11c111cc111111ccc11111ccc1cc111111ccc11111ccc117111111111111111111111111111111111111111111111111111111111
11111b111b1b1b1b171111c11c1111c11111111c1111111c11c11111111c1111111c111711111111111111111111111111111111111111111111111111111111
11111bbb1bbb1bb1171111c11ccc11c1111111cc111111cc11c111111ccc11111ccc111711111111111111111111111111111111111111111111111111111111
1111111b1b111b1b171111c11c1c11c11171111c1171111c11c111711c1111711c11111711111111111111111111111111111111111111111111111111111111
11111bb11b111b1b11711ccc1ccc1ccc17111ccc17111ccc1ccc17111ccc17111ccc117111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111bbb1bbb1bbb1bb11bbb11711c1c1ccc11cc1ccc1c1c1ccc1ccc1c1c11111ccc1ccc11111ccc1ccc11111ccc117111111111111111111111111111111111
11111b1b1b1b11b11b1b11b117111c1c1c1c1c1c11c11c1c1c1c1c111c1c1111111c1c1c1111111c1c1111111c1c111711111111111111111111111111111111
11111bbb1bb111b11b1b11b1171111111ccc1c1c11c11c1c1cc11cc1111111111ccc1c1c111111cc1ccc11111c1c111711111111111111111111111111111111
11111b111b1b11b11b1b11b1171111111c111c1c11c11c1c1c1c1c11111111711c111c1c1171111c111c11711c1c111711111111111111111111111111111111
11111b111b1b1bbb1b1b11b1117111111c111cc111c111cc1ccc1ccc111117111ccc1ccc17111ccc1ccc17111ccc117111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111118888811111111111111111111111111111111111111111111111111111111111
11111bbb1bbb1bbb11bb1bbb11711c111ccc11111ccc1c1c11111ccc1ccc111188888cc11ccc1ccc11111c111171111111111111111111111111111111111111
11111b1b1b1b1b111b1111b117111c111c1c1111111c1c1c1111111c1c1c1111888881c11c1c1c1c11111c111117111111111111111111111111111111111111
11111bb11bb11bb11b1111b117111ccc1c1c111111cc1ccc111111cc1c1c1111888881c11c1c1c1c11111ccc1117111111111111111111111111111111111111
11111b1b1b1b1b111b1111b117111c1c1c1c1171111c111c1171111c1c1c1171887881c11c1c1c1c11711c1c1117111111111111111111111111111111111111
11111b1b1b1b1bbb11bb11b111711ccc1ccc17111ccc111c17111ccc1ccc171187888ccc1ccc1ccc17111ccc1171111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1111111111111d1d1ddd1dd11ddd11dd111111dd11dd1dd11ddd1ddd11dd1d1111dd111111111111111111111111111111111111111111111111111111111111
1111111111111d1d11d11d1d1d111d1d11111d111d1d1d1d11d11d1d1d1d1d111d11111111111111111111111111111111111111111111111111111111111111
11111ddd1ddd1d1d11d11d1d1dd11d1d11111d111d1d1d1d11d11dd11d1d1d111ddd111111111111111111111111111111111111111111111111111111111111
1111111111111ddd11d11d1d1d111d1d11111d111d1d1d1d11d11d1d1d1d1d11111d111111111111111111111111111111111111111111111111111111111111
11111111111111d11ddd1ddd1ddd1dd1111111dd1dd11d1d11d11d1d1dd11ddd1dd1111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111e1111ee11ee1eee1e1111111611166616611666161611111bbb1bbb1bb111711cc11ccc1ccc111111111111111111111111111111111111111111111111
11111e111e1e1e111e1e1e1111111611116116161611161617771bbb11b11b1b171111c1111c1c1c111111111111111111111111111111111111111111111111
11111e111e1e1e111eee1e1111111611116116161661116111111b1b11b11b1b171111c11ccc1c1c111111111111111111111111111111111111111111111111
11111e111e1e1e111e1e1e1111111611116116161611161617771b1b11b11b1b171111c11c111c1c117111111111111111111111111111111111111111111111
11111eee1ee111ee1e1e1eee11111666166616161666161611111b1b1bbb1b1b11711ccc1ccc1ccc171111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111ccc1111166611171ccc111111711666166111111cc1117117171ccc1ccc1171111111111111111111111111111111111111
1111111111111111111111111111111c117116111171111c1171171116161616111111c111171171111c1c1c1117111111111111111111111111111111111111
1111111111111111111111111111111c177716611171111c1777171116611616177711c1111717771ccc1ccc1117111111111111111111111111111111111111
1111111111111111111111111111111c117116111171111c1171171116161616111111c1111711711c111c1c1117111111111111111111111111111111111111
1111111111111111111111111111111c111116111711111c111111711616166611111ccc117117171ccc1ccc1171111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111b111bbb1bb11bbb11711ccc11111cc11cc11ccc11111cc11ccc1ccc11111cc11cc11ccc11111ccc11711111111111111111111111111111111111111111
11111b1111b11b1b1b111711111c111111c111c1111c111111c1111c1c1c111111c111c1111c1111111c11171111111111111111111111111111111111111111
11111b1111b11b1b1bb11711111c111111c111c11ccc111111c11ccc1c1c111111c111c11ccc1111111c11171111111111111111111111111111111111111111
11111b1111b11b1b1b111711111c117111c111c11c11117111c11c111c1c117111c111c11c111171111c11171111111111111111111111111111111111111111
11111bbb1bbb1b1b1bbb1171111c17111ccc1ccc1ccc17111ccc1ccc1ccc17111ccc1ccc1ccc1711111c11711111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111b111bbb1bb11bbb11711ccc11111cc11cc11ccc111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111b1111b11b1b1b111711111c111111c111c1111c111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111b1111b11b1b1bb11711111c111111c111c11ccc111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111b1111b11b1b1b111711111c117111c111c11c11117111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111bbb1bbb1b1b1bbb1171111c17111ccc1ccc1ccc171111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1111111111111111111111111bbb1bbb1b1b11711ccc111116111666166116661616117111111cc11cc11ccc11111ccc11711111111111111111111111111111
1111111111111111111111111bbb1b1b1b1b1711111c1111161111611616161116161117111111c111c1111c11111c1c11171111111111111111111111111111
1111111111111111111111111b1b1bbb11b11711111c1111161111611616166111611117111111c111c11ccc11111ccc11171111111111111111111111111111
1111111111111111111111111b1b1b1b1b1b1711111c1171161111611616161116161117117111c111c11c1111711c1c11171111111111111111111111111111
1111111111111111111111111b1b1b1b1b1b1171111c171116661666161616661616117117111ccc1ccc1ccc17111ccc11711111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111b111bbb1bb11bbb11711611166616611666161611111cc11cc11cc111111611166616611666161611111cc11cc11ccc11111ccc11711111111111111111
11111b1111b11b1b1b11171116111161161616111616111111c111c111c1111116111161161616111616111111c111c1111c11111c1c11171111111111111111
11111b1111b11b1b1bb1171116111161161616611161111111c111c111c1111116111161161616611161111111c111c111cc11111ccc11171111111111111111
11111b1111b11b1b1b11171116111161161616111616117111c111c111c1117116111161161616111616117111c111c1111c11711c1c11171111111111111111
11111bbb1bbb1b1b1bbb11711666166616161666161617111ccc1ccc1ccc17111666166616161666161617111ccc1ccc1ccc17111ccc11711111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1eee1ee11ee111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1e111e1e1e1e11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1ee11e1e1e1e11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1e111e1e1e1e11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
82888222822882228888828282228882822882228288888888888888888888888888888888888888888882228222822282888882822282288222822288866688
82888828828282888888828288828828882888828288888888888888888888888888888888888888888888828882888282888828828288288282888288888888
82888828828282288888822288828828882882228222888888888888888888888888888888888888888888228822822282228828822288288222822288822288
82888828828282888888888288828828882882888282888888888888888888888888888888888888888888828882828882828828828288288882828888888888
82228222828282228888888288828288822282228222888888888888888888888888888888888888888882228222822282228288822282228882822288822288
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888

__sfx__
010100003303000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0105000014051110530d0530d05300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000000000000000
011000001d0551a0550000515055110550c0550805504055000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005
010800002d3302d3302d3302d330003002d330003002d330003002d330243002e3302e330243002e3302e330243002e3302e330243002d3302d3302d330003000030000300003000030000300003000030000300
010800002d4202d4202d4202d4200040018420004001d4200040018420004001b4201b420004001b4201b420004001c4201c420004001d4201d4201d420004000040000400004000040000400004000040000400
011800001f0501f050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011800002405024050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011800001a0451c04518045000051f04500005000051a0451c04518045000051f045000051a04500000180451a0451c04518045000051f04500005000051a0451c04518045000051f045000051a0450000018045
c51800000000000000000001502015025000001502015025000000000015035000001503500000000000000013040130450000013040130450000013040130450000000000130450000013045000000000000000
011800001a0451c04518045000051f04500005000051a0451c04518045000051f045000051a04500000180401a0451c04518045000001f0451a045000001a0450000000000000000000000000000000000000000
011800001104011045000001104011045000001104011045000000000011045000001104500000000000000011040110450000011040110450000011040110450000000000000000000000000000000000000000
01180000230451f04500000000001f0451c045000001a000210451f045000001c045000001a04500000180451a0001c0001a000000001f00000000000001a0001c0001a0000000021000000001f0000000000000
011800001500015000000001500015000000001500015000000001300010000130000000013000100001300013000130000000013000130000000013000130000000013000100001300000000130001000013000
011800001a0451c04518045000051f04500005000051a0451c045180450000523045000051f04500000000001a0451c04518045000001f04500000000001a0451c045180450000021045000051f0450000000000
011800001504015045000001504015045000001504015045000001304510045130450000013045100451304513040130450000013040130450000013040130450000013045100451304500000130451004513045
011800001a0451c04518045000051f04511000000001a0451c045180450000021045000051f04500000180451a0451c04518045000051f0451a045000001c045000001a0450000018045000001a0450000018045
011800001104011045000001104011045000001104011045000000000011045000050000000000110450000011040110450000011040110450000011045000001104500000110450000011045000001104500000
011800001a0451c04518045000051f04511000000001c0401c04500000000001f045000001d04500000110001f0401f0451a045000001f0451a045000001a0401a0451a045000001f045000001d0450000000000
011800001504015045000001504015045000001504015045150450000015045000001504500000150401504517040170450000017040170450000017040170450000000000170450000017045000001704500000
01180000240402404500000000001f045230451d04500000210402104500000000001f0451f0451c045000001f0401f04500000000001a0401a04500000000001a0001d00018000000001f00011000000001d000
011800001504015045130451504500000000000c040180451104011045130451304500000000000c0400c04510040100450000000000130401304500000000001500015000000001500015000000001500015000
011800001a0451d04518045000051f04511000000001d0401d04518045000001f045000051c04500000180451a0401a04518045000001f0401f045000001a0401a04518045000001f045000051d0450000000000
0118000015040150450000015040150450000015040150450000000000150450000015045000001504500000130401304500000130401f0050000013040130450000000000130450000013045000001004513045
01180000240402404500000000001f0401f04500000240402404500000000002104500000230451804500000210402104500000000001f0451f04500000000001f0401f04500000000001a0401a0450000000000
011800001504015045130451504500000000001504015045000001504513045000000c04500000000000c0451104500000130450c04500000000000c0400c045100401004500000000000c045000000000000000
010c000023040230401f0401f040000000000000000000001f0401f0401c0401c0400000000000000000000021040210401f0401f04000000000001c0401c04500000000001a0401a04500000000001804018045
011800000350003500035000350003500007000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011800001a0451c04518045000051f0451100000000230450000023045000001f045000001f0451c045000001a0451c04518045000051f0451100000000210450000021045000001c045000001a0451a04518045
011800001504015045000001504015045000001004513045000001304500000130450000013045130451304513040130450000013040130450000010045130450000013045000001304500000130451304513045
011800001a0401a04518045000051f0401f045000001c045000001f045000001c045000001a04500000180051a0401a04518045000051f0401f045000001c045000001f045000001c045000001a0450000000000
0118000011040110451800511040110451f000110452400511045240051104521000110451f005110450000011040110451800511040110451f00011045240051104524005110450000011045240051104500000
011800001a0451c04518045000051f0401f045000002404523045240452304521045000001f04500000180051a0451c04518045000051f0401f04500000230452104523045210451f045000001c0450000018045
011800001504015045000001504015045000001004513045000001304500000130401304500000130450000013040130450000013040130450000010045130450000013045000001304013045000001304500000
011800001a0401a04518045000051f040000001c0051f045000001c045000001a0450000018045000001f0451a0401a04518045000051f0401f0451c005180451f0451c045000001a04500000180450000000000
0118000011040110450000011040110450e045100450c005110450000011045000001104500000110450000011040110450000011040110450e045100450c0051104500000110450000011045000000c0400c045
011800000c14300000000000c1430c645000000c1430c000000000c14300000000000c6450c14300000000000c14300000000000c1430c645000000c14300000000000c14300000000000c645000000000000000
011800000c14300000000000c1430c645000000c14300000000000c14300000000000c6450c14300700000000c14300000000000c1430c645000000c143000000000000000000000000000000000000000000000
011800000c14300000000000c1430c6450c1430c000000000c143000000c143000000c6450c14300000000000c14300000000000c1430c6450c14300000000000c103000000c143000000c6450c1430000000000
011800000c14300000000000c1430c6450c143000000c103000000c10300000000000c6450c143000000c6050c14300000000000c1430c6450c1430000000000000000000000000000000c6450c1430000000000
01180000240402404500000000001f045230451d04500000210402104500000000001f0451f0451c045000001f0401f04500000000001a0401a04500000000001a0451d04518045000051f04511000000001d040
011800001504015045130451504500000000000c040180451104011045130451304500000000000c0400c04510040100450000000000130401304500000000001504015045000001504015045000001504015045
011800001d04518045000001f045000051c04500000180451a0401a04518045000001f0401f045000001a0401a04518045000001f045000051d0450000000000240402404500000000001f0401f0450000024040
011800000000000000150450000015045000001504500000130401304500000130401f00500000130401304500000000001304500000130450000010045130451504015045130451504500000000001504015045
011800002404500000000002104500000230451804500000210402104500000000001f0451f04500000000001f0401f04500000000001a0401a0450000000000230401f04000000000001f0401c0400000000000
01180000000001504513045000000c04500000000000c0451104500000130450c04500000000000c0400c045100401004500000000000c045000000000000000100001000500000000000c005000000000000000
01060000210402104021040210401f0401f0401f0401f040210051f005000001c0051c0401c0401c0401c0401a0001c0001a000000001a0401a0401a0401a0401c0001a000000002100018040180401804018040
011800000c14300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011800001a0451c04518045000001f04500000000001c045000001a045180451f045000001a04500000180451a0401a0450e000180451f04500000000001a045000001a045180451f04500000180451a0401a045
011800001504015045000001504015045000001504015045000001500015040150001504000000150400000013040130450000013040130450000013040130450000000000130400000013040000000c0400e040
011800001a0450000018045000001f04500000000001a045000001a045180451f045000001a045000001a0001f0401f0400000000000000000000000000000000000000000000000000000000000000000000000
01180000110401104500000110401104500000110401104500000000001104000000000000000011040100400c0400c0400000000000000000000000000000000000000000000000000000000000000000000000
01030000215250000026535000000000000000000000000000000000000000000000000000000000000000001a000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
00 07084344
00 090a4344
00 07082344
04 090a2444
00 0d0e2344
00 0f102344
00 0d0e2344
04 0f102344
00 11124344
00 13144344
00 15164344
04 17184344
00 1b1c2544
00 1d1e2644
00 1f202544
04 21222644
01 07084344
00 090a4344
00 07082344
00 090a2444
00 19424344
00 0d0e2344
00 0f102344
00 0d0e2344
00 0f102344
00 11124344
00 27284344
00 292a4344
00 2b2c4344
00 2d424344
00 1b1c2544
00 1d1e2644
00 1f202544
00 21222644
00 2f302e44
02 31324344

