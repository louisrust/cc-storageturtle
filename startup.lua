os.loadAPI("chestconfig")
nChests = chestconfig.nChests
layout = chestconfig.layout

inventoryTemp = {}
useThreeChests = false

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
function canSortChestTemp(index)
    canSort = false
    for i=1,16 do
        item = inventoryTemp[i]
        if (item and itemIsInChest(index,item)) then
            canSort = true
        end
    end

    return canSort
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
                    if (useThreeChests and (not turtle.drop())) then
                        turtle.up()
                        turtle.drop()
                        turtle.down()
                    end
                    turtle.down()
                end

                inventoryTemp[i] = nil
            end
        end
    end
    turtle.turnRight()
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

    canSort,sum = canSortAny()
    if (sum==0) then
        return
    end
    turtle.turnRight()
    turtle.forward()
    turtle.forward()
    -- create temp inventory
    inventoryTemp = {}
    for i=1,16 do
        turtle.select(i)
        b = turtle.getItemDetail()
        if (b and b.name) then
            inventoryTemp[i] = b.name
        else
            inventoryTemp[i] = nil
        end
    end
    
    -- begin sorting
    for i = 1,nChests do
        canSort = canSortChestTemp(i)
        if (canSort) then
            dropItems(i)
        end
        itemsRemaining = false
        for i=1,16 do
            if (inventoryTemp[i]) then
                itemsRemaining = true
            end
        end
        if (not itemsRemaining) then
            break
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

