pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
-- dig game (wip)
-- by hakler

function _init() end

function _update60()
	plr_update()
	
	gen_load(plr_x,plr_y)
	gen_update()
end

function _draw()
	cls()
	gen_draw(plr_x,plr_y)
	plr_draw()
	
	---[[ chunk map
	rectfill(0,0,31,31,1)
	clip(0,0,32,32)
	for _,c in pairs(chunks) do
		pset(
			16+c.cx-plr_x\chk_size,
			16+c.cy-plr_y\chk_size,
			((c.cx+c.cy) % 2 == 0) and 11 or 3
		)
	end
	pset(16,16,10)
	clip()
	--]]
	
	---[[ memory map (broken)
	rectfill(
		128-(127)\chk_size,
		0,
		127,
		64\chk_size-1,
		1)
	for _,c in pairs(chunks) do
		pset(
			128-(127-c.mx)\chk_size,
			c.my\chk_size,
			13
		)
	end
	--]]
end
-->8
-- chunk

-- globals
chunks = {}
chk_size = 4

-- gets the value of a chunk
function chk_get(cx,cy)
	return chunks[cx..","..cy]
end

-- sets the value of a chunk
function chk_set(cx,cy,c)
	chunks[cx..","..cy] = c
end

-- allocates a chunk
function chk_alloc(cx,cy)
	if chk_get(cx,cy) != nil then
		return false
	end
	
	local mx,my = 0,0
	while mget(mx,my) != 0 do
		mx += chk_size
		
		if mx >= 128-chk_size then
			mx = 0
			my += ch_size
		end
		
		if my >= 64-ch_size then
			return false
		end
	end
	
	chk_set(cx,cy,{
		cx = cx,
		cy = cy,
		mx = mx,
		my = my
	})
	return true
end

-- tries to free a chunk
function chk_free(cx,cy)
	local c = chk_get(cx,cy)
	if (c == nil) return
	
	mset(c.mx,c.my,0)
	chk_set(cx,cy,nil)
end

-- draws a chunk
function chk_draw(cx,cy)
	local c = chk_get(cx,cy)
	if (c == nil) return
	
	local rx, ry =
		64 + (chk_size*c.cx - plr_x) * 8,
		64 + (chk_size*c.cy - plr_y) * 8
	
	map(
		c.mx, c.my,
		rx, ry,
		chk_size, chk_size
	)
end

-- depricated
function ch_load(cx, cy)
	if (chunks[cx..","..cy] != nil) return false
	local mx,my = 0,0
	while mget(mx,my) != 0 do
		mx += chk_size
		if mx >= 128-chk_size then
			mx = 0
			my += chk_size
		end
		if my >= 64-chk_size then
		 return true
		end
	end
	mset(mx, my, 1)
	chunks[cx..","..cy] = {
	 cx = cx,
	 cy = cy,
		mx = mx,
		my = my,
		state = 0
	}
	return true
end
-->8
-- world gen

gen_load_dist = 2
gen_unload_dist = 4

function gen_spiral(x,y)
	local s = x + y
	if (s> 0 and x> y) return x,y+1
	if (s> 0 and x<=y) return x-1,y
	if (s<=0 and x< y) return x,y-1
	if (s<=0 and x>=y) return x+1,y
end

-- request chunks to be loaded
function gen_load(cx,cy)
	local camcx, camcy = plr_x\chk_size, plr_y\chk_size
	
	local spiralx, spiraly = 0,0
	while spiralx < 3
		and not ch_load(camcx+spiralx,camcy+spiraly) do
 	spiralx, spiraly =
 		gen_spiral(spiralx,spiraly)
 end
end

-- update loaded chunks
function gen_update()
	
end

-- draw loaded chunks
function gen_draw(x,y)
	local cx,cy = x\chk_size,y\chk_size
	for ox = -3,3 do
		for oy = -3,3 do
			chk_draw(cx+ox,cy+oy)
		end
	end
end





-->8
-- player

plr_x = 0
plr_y = 0

asqrt2 = 0.5 * sqrt(2)

function plr_update()
	local b = btn()
	
	local dx, dy =
		((b&2)>>1) - (b&1),
		((b&8)>>3) - ((b&4)>>2)
	
	---[[
	if abs(dx) + abs(dy) > 1 then
		dx *= asqrt2
		dy *= asqrt2
	end
	--]]
	
	plr_x += dx / 2
	plr_y += dy / 2
end

function plr_draw()
	pset(64,64,8)
end
__gfx__
00000000030003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000030030030000b0b000000a00000000000001111000000000000000000000000000000000000000000000000000000000000000000000000000000000
007007000300330300000b0000a00000000000000001dd1000000000000000000000000000000000000000000000000000000000000000000000000000000000
0007700000303003000000000a9a0000001567000011111000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000300330300b0b000000a00a00015555600011111000000000000000000000000000000000000000000000000000000000000000000000000000000000
007007003303003000b000000000a9a0011555500011111000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000030300300000000000000a00001155000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000030000300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
