-- title:  Flag
-- author: Peter Sterling
-- desc:   Get the Flag
-- script: lua


-- VARIABLES

grass = 1
red = 2
dirt = 3
water = 4
wall = 5
guy = 6
flag = 7

minX = 1
maxX = 28
minY = 1
maxY = 15

u  = {x = 0, y =-1} -- UP
ne = {x = 1, y=-1} -- NORTH EAST
d  = {x = 0, y = 1} -- DOWN
se = {x = 1, y = 1} -- SOUTH EAST
l = {x =-1, y = 0} -- LEFT
nw = {x = -1, y = 1} -- NORTH WEST 
r = {x = 1, y = 0} -- RIGHT
sw = {x = 1, y = 1} -- SOUTH WEST

dirs = {u,d,l,r,ne,se,nw,sw} -- DIRECTIONS 
enemys = {}
bullets = {}

function init()

solids = {[5] = true}

player = 
	{
		x = 8,
		y = 10,
		vx = 0,
		vy = 0,
		height = 8,
		width = 8,
		score = 0,
		level = 0,
		vulnerable = true,
		lives = 3,
	}
	
pole = 
{
	x = math.random(1,28) * 8,
	y = math.random(1,15) * 8,
	height = 8,
	width = 8,
}

t = 0
gameOver = false
mode = "menu"
end
	
-- FUNCTIONS
function spawnBullet() -- UNFINISHED
	
	local b = {
		x = player.x+1,
		y = player.y,
		height = 2,
		width = 8,
		d = r,
	}
	
	table.insert(bullets, #bullets+1,b)
end

-- UNFINISHED
function shoot()
if btn(4) then
	spawnBullet()
	for id, bullet in pairs(bullets) do
		if mget(bullet.x,bullet.y) == wall then
			table.remove(bullets,id)
		end
			if btn(2) then 
				bullet.d = u
			elseif btn(3) then
				bullet.d = d
			else
				bullet.d = {x = 0, y = 0}
			end
	
			if btn(0) then 
				bullet.d = l
				elseif btn(1) then
					bullet.d = r
			else
				bullet.d = {x = 0, y = 0}
			end
	
			local tx = bullet.x + bullet.d.x
			local ty = bullet.y + bullet.d.y
	
			if mget(bullet.x,bullet.y) == wall then
				table.remove(bullets,id)
			else
				bullet.x = tx
				bullet.y = ty
			end
		end
	end
end

function spawn()

	local tx = math.random(minX,maxX)
	local ty = math.random(minY,maxY)
	if mget(tx,ty) >= wall then
		spawn()
	end
	
	local z = {
		x = tx,
		y = ty,
		height = 8,
		width = 8,
		d = dirs[math.random(1,8)]
	}
	table.insert(enemys,#enemys+1,z)
end

function moveEnemy()
	for id, enemy in pairs(enemys) do
		if mget(enemy.x,enemy.y) >= wall then
			table.remove(enemys,id)
		end
	
		local tx = enemy.x + enemy.d.x
		local ty = enemy.y + enemy.d.y
	
		if mget(tx,ty) >= wall then
			enemy.d = dirs[math.random(1,8)]
		else
			enemy.x = tx
			enemy.y = ty
		end
	end 
end

function draw(x,y)
	cls()
	map(x,y,30,17)
	print("LIVES:" .. " " .. tostring(player.lives), 10, 12)
	if #enemys > 0 then
		for id, enemy in pairs(enemys) do
			spr(18, enemy.x * 8, enemy.y * 8, 11)
		end
	end
	spr(guy, player.x, player.y, 11)
	spr(flag, pole.x, pole.y, 11)
	if #bullets > 0 and #bullets < 3 then -- only appears once
		for id, bullet in pairs(bullets) do
			spr(17, bullet.x * 8, bullet.y * 8, 11)
		end
	end
	sync()
end

function solid(x,y)
	return solids[mget((x)//8, (y)//8+(17*player.level))]
end

function moveplayer()

	if btn(2) then 
		player.vx = -1
	elseif btn(3) then
		player.vx = 1
	else
		player.vx = 0
	end
	
	if btn(0) then 
		player.vy = -1
	elseif btn(1) then
		player.vy = 1
	else
		player.vy = 0
	end
	
	if solid(player.x+player.vx,player.y+player.vy) or solid(player.x+7+player.vx,player.y+player.vy) or solid(player.x+player.vx,player.y+7+player.vy) or solid(player.x+7+player.vx,player.y+7+player.vy) then
    player.vx=0
	end
	
	if solid(player.x+player.vx,player.y+8+player.vy) or solid(player.x+7+player.vx,player.y+8+player.vy) or solid(player.x + player.vx, player.y + player.vy) or solid(player.x + 7 + player.vx, player.y + player.vy) then
    player.vy=0
	end
	
	player.x=player.x+player.vx
 player.y=player.y+player.vy

end	

function collision(a,b)
 -- get parameters from a and b
 local ax = a.x
 local ay = a.y
 local aw = a.width
 local ah = a.height
 local bx = b.x
 local by = b.y
 local bw = b.width
 local bh = b.height

 -- check collision
 if ax < bx+bw and
    ax+aw > bx and
    ay < by+bh and
    ah+ay > by then
     -- collision
     return true
 end
 -- no collision
 return false
end

function collisionE(a,b)
 -- get parameters from a and b
 local ax = a.x
 local ay = a.y
 local aw = a.width
 local ah = a.height
 local bx = b.x*8
 local by = b.y*8
 local bw = b.width
 local bh = b.height

 -- check collision
 if ax < bx+bw and
    ax+aw > bx and
    ay < by+bh and
    ah+ay > by then
     -- collision
     return true
 end
 -- no collision
 return false
end

function poleCollision()
	if collision(player, pole) then
		player.score = player.score + 1
		pole.x = math.random(1,28) * 8
		pole.y = math.random(1,15) * 8
	end
end

function enemyCollision()
--enemy collision
	if #enemys > 0 then
		for k,v in pairs(enemys) do
			if collisionE(player,v) and player.vulnerable then
				player.lives = player.lives - 1
				if player.lives == 0 then
					gameOver = true
				end
				player.vulnerable = false
			end
		end	
	end
	--end enemy collision
end

function menu()
	cls()
	map(30,17,30,17)
	print("Press Z to Start", 8*8, 12*8, 2)
	if btn(4)then 
		mode = "game"
	end
end

function level1()
	moveplayer()
	shoot()
	cls()
	--draw(0,0)
	if #enemys < 5 then
		spawn()
	end
	if t % 20 == 0 and #enemys > 0  then
			moveEnemy()
			player.vulnerable = not player.vulnerable
	end
	sync()
	draw(0,0)
	poleCollision()
	enemyCollision()
	if player.score == 3 then
		player.level = 1
		enemys = {}
		player.x = 15
		player.y = 21
	end
end

function level2()
	cls()
	--draw(0,17)
	if #enemys < 10 then
		spawn()
	end
	if t % 20 == 0 and #enemys > 0  then
			moveEnemy()
			player.vulnerable = not player.vulnerable
	end
	sync()
	draw(0,17)
	moveplayer()
	spr(guy, player.x, player.y, 11)
	spr(flag, pole.x, pole.y, 11)
	sync()
	poleCollision()
	enemyCollision()
	if player.score == 6 then
		player.level = 2
	end
end

function over()
	restart = "Press Z to Restart"
	if player.lives == 0 then
		cls()
		title = "Game Over"
		print(title, (24*8)//2, 130//2)
		print(restart, (18*8)//2, 9*8)
		if btn(4) then
			reset()
		end
	else
		cls()
		map(30,0,30,17)
		string = "Congratulations"
		print(string, (20*8)//2, 130//2, 1)
		print(restart, (18*8)//2, 9*8, 1)
		if btn(4) then
			reset()
		end
	end
end


init()
function TIC()
t = t + 1
	if mode == "game" then
		if not gameOver then
			if player.level == 0 then
				level1()
			elseif player.level == 1 then
				level2()
			else
				gameOver = true
			end
		else
			over()
		end
	elseif mode == "menu" then
		menu()
	end
end

