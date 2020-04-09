-- This game is a simple proof of concept for the Tadpole framework

json = lib.require("scripts/json.lua")

icons = {
    windows = lib.load_image("images/icon-windows.png"),
    mac = lib.load_image("images/icon-macos.png"),
    linux = lib.load_image("images/icon-linux.png"),
    browser = lib.load_image("images/icon-browser.png"),
    ios = lib.load_image("images/icon-ios.png"),
    android = lib.load_image("images/icon-android.png"),
}

runtime = {
    platform = lib.get_platform(),
}

player = {
    x = 0,
    y = 0,
    x_velocity = 0,
    y_velocity = 0,
    speed = .1,
    max_velocity = 10,
    icon = icons[runtime.platform],
}

world = {
    friction = .99,
    width = lib.SCREEN_WIDTH,
    height = lib.SCREEN_HEIGHT,
    enemies = {},
}

song = lib.load_music("sounds/rick_astley.ogg")
lib.play_music(song, -1)

-- this function runs every frame
function update()

    -- adjust the player's velocity according to mouse/tap input
    x, y = lib.get_touch_coordinates()
    if x and y then
        if math.abs(player.x_velocity) < player.max_velocity then
            x_diff = x - player.x
            x_change = player.speed * x_diff / (math.abs(x_diff))
            player.x_velocity = player.x_velocity + x_change
        end
        if math.abs(player.y_velocity) < player.max_velocity then
            y_diff = y - player.y
            y_change = player.speed * y_diff / (math.abs(y_diff))
            player.y_velocity = player.y_velocity + y_change
        end
    end

    -- basic physics
    player.x = player.x + player.x_velocity
    player.y = player.y + player.y_velocity
    player.x_velocity = player.x_velocity * world.friction
    player.y_velocity = player.y_velocity * world.friction

    -- wrap around the edge of the screen
    if player.x < 0 then
        player.x = world.width
    elseif player.x > world.width then
        player.x = 0
    end
    if player.y < 0 then
        player.y = world.height
    elseif player.y > world.height then
        player.y = 0
    end

    -- clear the screen
    lib.fill_screen_with_color(255, 255, 255)

    -- draw the player
    lib.draw_texture(player.x, player.y, player.icon)

    -- draw the enemies
    for platform, position in pairs(world.enemies) do
        if platform ~= runtime.platform then
            lib.draw_texture(position.x, position.y, icons[platform])
        end
    end

    lib.render()

    -- send our information to the server
    lib.send_message(json.encode({
        platform = runtime.platform,
        position = { x = player.x, y = player.y },
    }))
end

-- tell tadpole to call update() every frame
lib.set_frame_function(update)

-- parse the server's message as JSON
-- it contains our enemies' positions, which we store for later use
lib.on_receive_message(function (msg)
    world.enemies = json.decode(msg)
end)

-- create the websocket
lib.create_websocket({
    host = "pollywog.games",
    path = "/",
    port = 8080,
    secure = true,
})
