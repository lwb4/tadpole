-- Basic platformer

worldlib = lib.require("scripts/world.lua")

icons = {
    guy = lib.load_image("images/guy.png"),
}

player = {
    x = 0,
    y = 0,
    x_velocity = 0,
    y_velocity = 0,
    speed = .1,
    max_velocity = 10,
}

world = {
    friction = .99,
    width = 640,
    height = 480,
    enemies = {},
}

-- this function runs every frame
function update()
    -- -- adjust the player's velocity according to mouse/tap input
    -- x, y = lib.get_touch_coordinates()
    -- if x and y then
    --     if math.abs(player.x_velocity) < player.max_velocity then
    --         x_diff = x - player.x
    --         x_change = player.speed * x_diff / (math.abs(x_diff))
    --         player.x_velocity = player.x_velocity + x_change
    --     end
    --     if math.abs(player.y_velocity) < player.max_velocity then
    --         y_diff = y - player.y
    --         y_change = player.speed * y_diff / (math.abs(y_diff))
    --         player.y_velocity = player.y_velocity + y_change
    --     end
    -- end

    -- -- basic physics
    -- player.x = player.x + player.x_velocity
    -- player.y = player.y + player.y_velocity
    -- player.x_velocity = player.x_velocity * world.friction
    -- player.y_velocity = player.y_velocity * world.friction

    -- -- wrap around the edge of the screen
    -- if player.x < 0 then
    --     player.x = world.width
    -- elseif player.x > world.width then
    --     player.x = 0
    -- end
    -- if player.y < 0 then
    --     player.y = world.height
    -- elseif player.y > world.height then
    --     player.y = 0
    -- end

    worldlib.draw({worldlib.sprite(player.x, player.y, icons.guy)})

    lib.render()
end

-- tell tadpole to call update() every frame
lib.set_frame_function(update)
