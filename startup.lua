os.loadAPI("chestconfig")
nChests = chestconfig.nChests
layout = chestconfig.layout

function collectItems()
    canSuck = true
    for i = 1,16 do
        if (not turtle.suck()) then
            canSuck = false
        end
    end
    return canSuck
end

function itemIsInChest(index,item)
    valid = false
    for k,v in pairs(layout[index]) do
        if string.match(item,v)==item then
            valid = true
        end
    end
    return valid
end

function canSortAny() -- return boolean can sort, int total number of items in inventory
    canSort = false
    sum = 0
    for i=1,16 do
        turtle.select(i)
        sum = sum+turtle.getItemCount()
        if (canSortSlot()) then
            canSort = true
        end
    end
    turtle.select(1)

    return canSort,sum
end

function canSortChest(index)
    canSort = false
    sum = 0
    for i=1,16 do
        turtle.select(i)
        sum = sum+turtle.getItemCount()
        item = turtle.getItemDetail()
        if (item and itemIsInChest(index,item.name)) then
            canSort = true
        end
    end
    turtle.select(1)

    return canSort,sum
end

function canSortSlot()
    item = turtle.getItemDetail()
    if (not item) then return false end
    for chestIndex=1,nChests do
        if itemIsInChest(chestIndex,item.name) then
            return true
        end
    end
    
    return false
end
function filterItems()
    turtle.up()
    for i=1,16 do
        turtle.select(i)
        itemCount = turtle.getItemCount()
        if (itemCount>0 and (not canSortSlot())) then
            turtle.drop()
        end
    end
    turtle.down()
end
function dropItems(index)
    if (layout[index]==nil) then
        return
    end

    turtle.turnLeft()
    for i = 1,16 do
        turtle.select(i)
        b = turtle.getItemDetail()
        if (b) then
            if (itemIsInChest(index,b.name)) then
                if not (turtle.drop()) then
                    turtle.up()
                    turtle.drop()
                    turtle.down()
                end
            end
        end        
    end
    turtle.turnRight()
end

function getCountTotal()
    sum = 0
    for i = 1,16 do
        turtle.select(i)
        sum = sum+turtle.getItemCount()
    end
    return sum
end

function sort()
    collecting = true
    turtle.select(1)
    while collecting do
        canSuck = collectItems()
        canSort,sum = canSortAny()
        if (sum>0) then
            filterItems()
        end
        if (not canSuck) then
            collecting = false
        end
    end
    if (getCountTotal()==0) then
        return
    end
    turtle.turnRight()
    turtle.forward()
    turtle.forward()
    
    -- begin sorting
    for i = 1,nChests do
        canSort,sum = canSortChest(i)
        if (sum==0) then
            break
        end
        if (canSort) then
            dropItems(i)
        end
        turtle.forward()
    end
    
    -- return home
    turtle.turnLeft()
    turtle.turnLeft()
    while turtle.forward() do end
    turtle.turnRight()
end

while true do
    sort()
end

