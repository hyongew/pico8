pico-8 cartridge // http://www.pico-8.com
version 43
__lua__
function _init()
 poke(0x5f2e, 1)
 pal(9,9+128,1)
 palt(0,false)
 palt(14,true)
 state="rdy" --main,rdy,go
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
 countdown=false
 anim_end=24 --#moves*2+8
end

function _update()
	if state=="main" then
		if (btnp(🅾️)) state="go"
	elseif state=="rdy" then
		updaterdy()
	elseif state=="go" then
		updategame()
	else
	end
end

function _draw()
	cls()
	color(15)
	rectfill(0,0,128,128)
	color(2)
	if state=="main" then
		print("press 🅾️ to start")
	elseif state=="rdy" then
		drawrdy()
	elseif state=="go" then
		drawgame()
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

function checktime()
	return f%10>6 or f%10<4
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
		 if checktime() then
	 		if correct==nil then
	 			movesp=checkmove(movesets[round][checkstep]) or movesp
	 		end
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
		state="rdy"
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
			--if step>anim_end then
			--	movesp=getsp(rot_anim_map[(movesp-1)/2+1])
			--end
		end
		
		--jump for joy
		for move in all(moves) do
			if move.dy and move.dy<=spd do
				--doing it this way because of strange decimal shenanigans when working directly with decimals
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
	color(7)
	--print(step)
	print("round "..round)
	print(score.."/32")
	if (round==stageend) print("done!")
	
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
		print("\^w\^t\^o014".."stage end!",25,24,7)
	end
end
-->8
--intermissions

function updaterdy()
	if not countdown then
		countdown=btnp(🅾️)
	else
		if f<80 then
			f+=1
		else
			countdown=false
			round,step,f=1,0,0
			state="go"
		end
	end
end

function drawrdy()
	if not countdown then
		print("press 🅾️ to start")
	else
		if f<60 then
			print(3-f\20)
		else
			print("go!")
		end
	end
end
-->8
--main menu

function updatemenu()

end

function drawmenu()

end
__gfx__
00000000eeee11411eeeeeeeeeeeee11411eeeeeeeeee114111eeeeeeeeee111411eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee000000000000000000000000
00000000eee19999411eeeeeeeee11999941eeeeeeee19999941eeeeeeee19999941eeeeeeeeeeeeeee11eeeeeeeeeeeeeeeeeee000000000000000000000000
00700700ee1999999401eeeeeee1099999941eeeeee1999999941eeeeee1999999941eeeeeeeeeeeee1941eeeeeedeeeeeeeeeee000000000000000000000000
00077000ee19999994001eeeee10099999991eeeee19990499991eeeee19999999991eeeeeeee11110041eeeeeedeeeeeeeeedee000000000000000000000000
00077000e199999999401eeeee109999999941eeee199004999941eeee199999999941eeeee11009909661eeeedeeeeeeeeedeee000000000000000000000000
00700700e199909999401eeeee109999909941eee1999004999941eee1990999990991eeee1770007799761eeeeeeeeeeeedeeee000000000000000000000000
00000000e100999999441eeeee199999999001eee1999904999941eee1999900099991eee19990999979961eeeeeeeeeeeeeeeee000000000000000000000000
00000000e199999999941eeeee199999999941eee1999999999941eee1999999999991ee199999999997941eeeeeeeeeeeeeeeee000000000000000000000000
00000000e177999999761eeeee177999999761eee1779999999761eee1779999999771ee199449999997941eeeeeeeeeeeeeeeee000000000000000000000000
00000000e191777777401eeeee109777777141eee19977777779441ee1997777777991ee199499999999741eeeeeeeeeeeeeeeee000000000000000000000000
00000000e1199999994001eee1009999999911eee1999904999941eee1191999991911ee199999999999741eeeedeeeeeeeeeeee000000000000000000000000
00000000e19919999971941e19417999991941eeee179004999961eee1611999991161ee199999999999741eeedeeeeeeeeedeee000000000000000000000000
00000000ee1177777799941e1999977777711eeeee197706777741eeee146777776441eee19999990c97941eedeeeeeeeeedeeee000000000000000000000000
00000000e1499999994111eee1119999999941eeeee1119419991eeee1941999991941eeee1999999911941eeeeeeeeeeedeeeee000000000000000000000000
00000000ee111111111eeeeeeeee111111111eeeeee199411111eeeeee11111111111eeeeee1111111ee11eeeeeeeeeeeeeeeeee000000000000000000000000
00000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee111eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee000000000000000000000000
__sfx__
010100003303000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0105000014051110530d0530d05300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000000000000000
011000001d0551a0550000515055110550c0550805504055000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005
010800002d3502d3502d3502d350003002d340003002d340003002d340243002e3402e340243002e3402e340243002e3402e340243002d3402d3402d340003000030000300003000030000300003000030000300
010800002d4302d4302d4302d4300040018420004001d4200040018420004001b4201b420004001b4201b420004001c4201c420004001d4201d4201d420004000040000400004000040000400004000040000400
