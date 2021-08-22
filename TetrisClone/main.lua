local board=require 'lib/scripts/TetrisBoard'.new()
require 'lib/scripts/randomlua'
mtwister=lcg(os.time(), 'mvc') 
local updateTick=0
local ticksToUpdate=.25;


hasLost=false
local tactile=require 'lib/scripts/tactile'
horizontal=tactile.newControl():addAxis(tactile.gamepadAxis(1, 'leftx')):addButtonPair(tactile.keys 'left', tactile.keys 'right'):addButtonPair(tactile.keys 'a', tactile.keys 'd')
rotate=tactile.newControl():addButton(tactile.keys,'n')

points=0;

local COLOUR_TABLE={
    {3/255,65/255,174/255},
    {144/255,203/255,59/255},
    {255/255,213/255,0/255},
    {255/255,151/255,28/255},
    {1,50/255,19/255}
}


function love.load()
    board:setCurrentTetromino(mtwister:random(1,5))
    love.graphics.setDefaultFilter("nearest","nearest",0)
end

function love.draw()
    love.graphics.setColor(1,1,1,1)
    love.graphics.line(10*40,0,10*40,20*40)
    love.graphics.print("Points: "..points,400,10,0,2,2)
    love.graphics.setColor(not hasLost and COLOUR_TABLE[board.currentTetromino.type] or {1,0,0,1})
    board:drawCurrentTetromino()
    for x=1, board.sX do
        for y=1, board.sY do
            
            if(board.grid[x][y]~=0) then
                love.graphics.setColor(not hasLost and COLOUR_TABLE[board.grid[x][y]] or {1,0,0,1})
                love.graphics.rectangle("fill",(x-1)*40,(y-1)*40,40,40)
            end
        end
    end
end

function love.update(dt)
    if(hasLost) then
        return
    end
    horizontal:update()
    rotate:update()
    updateTick=updateTick+1*dt
    if(updateTick>=ticksToUpdate) then
        board:update(dt,horizontal())
        updateTick=0;
    end
end