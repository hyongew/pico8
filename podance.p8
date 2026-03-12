pico-8 cartridge // http://www.pico-8.com
version 43
__lua__
function _init()
 poke(0x5f2e, 1)
 pal(9,9+128,1)
 palt(0,false)
 palt(14,true)
 state="go"--main,rdy,go
 sps={} --{spr,x,y}
 stage,round,step,score,f=1,0,0,0,0
 movesp,checkstep=nil,1
 moves={
  {⬅️,⬆️,➡️,⬇️,➡️,➡️,⬇️,⬇️},
  {⬆️,➡️,⬆️,⬅️,⬇️,⬆️,➡️,⬇️},
  {⬅️,⬅️,➡️,⬆️,⬅️,⬇️,⬆️,➡️},
  {⬆️,⬇️,⬅️,⬆️,⬇️,⬆️,➡️,➡️},
  {➡️,⬅️,⬇️,⬅️,⬆️,⬅️,➡️,⬇️}
 }
 correct=nil
end

function _update()
	if state=="main" then
	elseif state=="rdy" then
	elseif state=="go" then
		if round<6 then
			gameloop()
		end
	else
	end
end

function _draw()
	cls()
	print(step)
	print("round "..round)
	print(score.."/40")
	if state=="main" then
	elseif state=="rdy" then
	elseif state=="go" then
		--draw base 2x4 grid
		for i=1,8 do
			local c=7
			if (ceil(step%8.1)==i) c=12
			drawsq(getx(i),gety(i),c)
		end
	
		--draw steps
		for i,sp in pairs(sps) do
			--rectfill(sp[2]-1,sp[3]-2,sp[2]+15,sp[3]+16,6)
			--rect(sp[2]-1,sp[3]-2,sp[2]+15,sp[3]+16,13)
			spr(sp[1],sp[2],sp[3],2,2)
			--spr(11,sp[2],sp[3],2,2)
		end
		
		--draw player
		drawsq(57,88,7)
		if f%10<4 and step>=9 and movesp then
			local c = movesp==9 and 8 or 11 --ternary
			drawsq(57,88,c)
		end
		if movesp then
			spr(movesp,57,88,2,2)
		end
	end
end
-->8
--utils
function drawsq(x,y,c)
	rect(x-2,y+8,x+16,y+17,c)
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
-->8
--main game loop

function gameloop()		
	if step>0 and step<9 then --demo move
		add(sps,
						{
							moves[round][step]*2+1,
							getx(step),
							gety(step)
						})
	end
		
	if step>=9 then --user move
	 if checktime() then
	 	if correct==nil then
	 		movesp=checkmove(moves[round][checkstep]) or movesp
	 	end
 	else
 		checkstep=step-7
 		if (correct==true and f%10==4) score+=1
 		if (checkstep==9) checkstep=1
 		if (correct!=true) movesp=9
	 end
	end
	
	f+=1
	if f\10!=step then
		if (step==0) round+=1
		sfx(0)
		step+=1
 	correct=nil
		if step==17 then
			round+=1
			step=1
			f=11
			sps={}
		end
	end
end

function checkmove(m)
	if btnp()>0 then
		correct=btnp(m)
		if not btnp(m) then
	 	return 9
	 else
	 	return m*2+1
	 end
	end
end
__gfx__
00000000eeee11411eeeeeeeeeeeee11411eeeeeeeeee114111eeeeeeeeee111411eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee000000000000000000000000
00000000eee19999411eeeeeeeee11999941eeeeeeee19999941eeeeeeee19999941eeeeeeeeeee555e11eeeeeeeeeeeeeeeeeee000000000000000000000000
00700700ee1999999401eeeeeee1099999941eeeeee1999999941eeeeee1999999941eeee5555eeee55541eeeeeedeeeeeeeeeee000000000000000000000000
00077000ee19999994001eeeee10099999991eeeee19990499991eeeee19999999991eee555ee11110041eeeeeedeeeeeeeeedee000000000000000000000000
00077000e199999999401eeeee109999999941eeee199004999941eeee199999999941eeeee11009909661eeeedeeeeeeeeedeee000000000000000000000000
00700700e199909999401eeeee109999909941eee1999004999941eee1990999990991eeee1770007799761eeeeeeeeeeeedeeee000000000000000000000000
00000000e100999999441eeeee199999999001eee1999904999941eee1999900099991eee19990999979961eeeeeeeeeeeeeeeee000000000000000000000000
00000000e199999999941eeeee199999999941eee1999999999941eee1999999999991ee199999999997941eeeeeeeeeeeeeeeee000000000000000000000000
00000000e177999999761eeeee177999999761eee1779999999761eee1779999999771ee199449955597941eeeeeeeeeeeeeeeee000000000000000000000000
00000000e191777777401eeeee109777777141eee19977777779441ee1997777777991ee199499999555741eeeeeeeeeeeeeeeee000000000000000000000000
00000000e1199999994001eee1009999999911eee1999904999941eee1191999991911ee199999999999741eeeedeeeeeeeeeeee000000000000000000000000
00000000e19919999971941e19417999991941eeee179004999961eee1611999991161ee199999999999741eeedeeeeeeeeedeee000000000000000000000000
00000000ee1177777799941e1999977777711eeeee197706777741eeee146777776441eee15599990997941eedeeeeeeeeedeeee000000000000000000000000
00000000e1499999994111eee1119999999941eeeee1119419991eeee1941999991941ee555999999915541eeeeeeeeeeedeeeee000000000000000000000000
00000000ee111111111eeeeeeeee111111111eeeeee199411111eeeeee11111111111eeeeee1111111ee555eeeeeeeeeeeeeeeee000000000000000000000000
00000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee111eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee000000000000000000000000
__sfx__
000100003302000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
