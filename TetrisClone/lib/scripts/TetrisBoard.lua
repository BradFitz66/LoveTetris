local board={}
board.__index=board;

TETROMINO_TYPES={
    ["1"]={
        {1,1,1,1},
        {0,0,0,0},
        {0,0,0,0},
        {0,0,0,0}
    },
    ["2"]={
        {0,0,0,0},
        {0,1,1,0},
        {0,1,1,0},
        {0,0,0,0}
    },
    ["3"]={
        {1,1,1,0},
        {1,0,0,0},
        {0,0,0,0},
        {0,0,0,0}
    },
    ["4"]={
        {1,1,1,0},
        {0,1,0,0},
        {0,0,0,0},
        {0,0,0,0}
    },
    ["5"]={
        {1,1,0,0},
        {0,1,1,0},
        {0,0,0,0},
        {0,0,0,0}
    },
    
}
--Table of the lines needed to be cleared
local linesToBeCleared={}

function board.new()
    local b = setmetatable({}, board)
    b.sX=13
    b.sY=20
    b.grid={}
    b.currentTetromino={
        type=1,
        x=0,
        y=0,
        canMove=true,
        tiles={}
    }
    for x=1, b.sX do
        table.insert(b.grid,x,{})
        for y=1, b.sY do 
            table.insert(b.grid[x],y,0)
        end
    end
    return b
end

function board:setCurrentTetromino(type)
    self.currentTetromino.type=type
    self.currentTetromino.x=0
    self.currentTetromino.y=0
    self.currentTetromino.tiles=TETROMINO_TYPES[tostring(type)]
    local canMove,collision=self:checkCanMove(self.currentTetromino.x+horizontal(),self.currentTetromino.y)
    --if we can't move when the block is placed, then we've lost the game
    if(canMove==false) then
        print("Lost!")
        hasLost=true
    end
    self.currentTetromino.canMove=true
end


function col(t)
	local i, h = 0, #t
	return function ()
		i = i + 1
		local column = {}
		for j = 1, h do
			local val = t[j][i]
			if not val then return end
			column[j] = val
		end
		return i, column
	end
end

function rev(t)
	local n = #t
	for i = 1, math.floor(n / 2) do
		local j = n - i + 1
		t[i], t[j] = t[j], t[i]
	end
	return t
end

function rotateCW(t)
	local t2 = {}
	for i, column in col(t) do
		t2[i] = rev(column)
	end
	return t2
end

function rotateCCW(t)
	local t2 = {}
	for i, column in col(t) do
		t2[i] = column
	end
	return rev(t2)
end

--Check if current tetromino can move to position newX newY
function board:checkCanMove(newX,newY)
    --the tiles that make up the tetromino
    local shape = self.currentTetromino.tiles
    --tetromoino shape is a 4x4 'subgrid'. 0 = nothing, 1 or above = tile 
    
    --Loop through a 4x4 area
    for x=1,4 do
        for y=1,4 do
            --check if any of the current tetromino tiles will be blocked by a cell at the new pos
            if shape[x][y]~=0 and ((newX+x>self.sX-3 or newY+y>self.sY) or (x+newX<1 or y+newY<1)) then
                if(newY+y>self.sY) then
                    --hit ground
                    return false,true     
                end
                return false,false
            end
            
            
            if(x+newX>=1) then
                local gridCell=self.grid[x+newX][y+newY]
                if(gridCell~=0 and shape[x][y]~=0) then
                    print("can't move (collision)")
                    return false,true
                end
            end
        end
    end
    return true,false
end
--[[
    Basically the same as checkCanRotate. We created a copy of the current tetrominoes tiles and rotate them in place 
    and then check to see if any of the tiles are in incorrect places (out of bounds or inside other tiles). If they are,
    don't rotate the shape.
]]
function board:checkCanRotate()
    local curShape=self.currentTetromino.tiles
    local rotatedShape=Rotate(self.currentTetromino.tiles,90)

    for x=1,4 do
        for y=1,4 do
            --check if any of the current tetromino tiles will be blocked by a cell at the new rotation
            if rotatedShape[x][y]~=0 and ((self.currentTetromino.x+x>self.sX-3 or self.currentTetromino.y+y>self.sY) or (self.currentTetromino.x+x<1 or self.currentTetromino.y+y<1)) then
                if(self.currentTetromino.y+y>self.sY) then
                    --hit ground
                    return false     
                end
                return false
            end
            
            if(x+self.currentTetromino.x>=1) then
                local gridCell=self.grid[x+self.currentTetromino.x][y+self.currentTetromino.y]
                if(gridCell~=0 and rotatedShape[x][y]~=0) then
                    print("can't move (collision)")
                    return false
                end
            end
        end
    end
    return true
end

function board:updateCurrentTetromino(movement)  
    local canMove,collision=self:checkCanMove(self.currentTetromino.x+movement,self.currentTetromino.y+1)
    if(canMove==true and collision==false and self.currentTetromino.canMove==true) then
        self.currentTetromino.y=self.currentTetromino.y+1
        self.currentTetromino.x=self.currentTetromino.x+movement
    else
        if(collision==true) then
            self.currentTetromino.canMove=false 
        else
            --Move tetromino anyway. Stops player from stop the tetromino by hugging the walls constantly 
            self.currentTetromino.y=self.currentTetromino.y+1
            self.currentTetromino.x=self.currentTetromino.x
        end
    end
end

function Rotate(t, r)
    assert(r%90==0, "rotation must be multiple of 90")

    local function rotate(t,r)
        local t = t
        if r ~= 90 then 
            t = rotate(t, r-90)
        end
        local output = {{}, {}, {},{}}
        for x, v1 in pairs(t) do
            for y, v2 in pairs(v1) do
            output[y][x] = v2
            end
        end
        return output
    end 
    return rotate(t, r)
end
function board:drawCurrentTetromino()
    for x=1,4 do
        for y=1,4 do
            local xPos=self.currentTetromino.x+x-1
            local yPos=self.currentTetromino.y+y-1
            if(self.currentTetromino.tiles[x][y]~=0) then
                love.graphics.rectangle("fill",xPos*40,yPos*40,40,40)
            end
        end
    end
end

function board:newCell(x,y)
    self.grid[x][y]=1
end

function board:update(dt,movement)
    

    if(love.keyboard.isDown('r')==true and self:checkCanRotate()) then        
        self.currentTetromino.tiles=rotateCW(self.currentTetromino.tiles)
    end
    --Place currentTetromino into grid
    if(self.currentTetromino.canMove==false)then
        self.currentTetromino.canMove=true
        for x=1,4 do
            for y=1,4 do
                local xPos=self.currentTetromino.x+x
                local yPos=self.currentTetromino.y+y
                if(self.currentTetromino.tiles[x][y]~=0) then
                    self.grid[xPos][yPos]=self.currentTetromino.type
                end                
            end
        end
        self:setCurrentTetromino(mtwister:random(1,5))
    end
    local t=0;
    
    for y=1,self.sY do
        for x=1,self.sX do
            --Count amount of cells with a shape in them
            if(self.grid[x][y]~=0) then
                t=t+1
            end
        end
        if(t==10) then -- Is the line full (10 shapes)?
            --Clear line
            local line = y;
            print(line)
            for x=1, self.sX do
                self.grid[x][y]=0
            end

            --Move all lines above cleared line down 1(naive gravity)
            for y2=line, 1,-1 do
                print(y2)
                for x=1, self.sX do
                    if(y2>1) then
                        self.grid[x][y2]=self.grid[x][y2-1]
                    end
                end
            end
            points=points+100
        end
        t=0;
    end       
    
    

    self:updateCurrentTetromino(movement)

end

return board;