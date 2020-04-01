x = 0
y = 0
speed = 5
greenface = lib.load_image("img/greenface.png")
font = lib.load_font("fonts/free-sans.ttf", 20)

platform_text = "you are on " .. lib.get_platform()
w, h = lib.get_screen_dimensions()
screen_text = "w: " .. w .. ", h: " .. h
hello_world_text = lib.load_text(font, platform_text .. "\n" .. screen_text, {r=0, g=0, b=255})

song = lib.load_music("sounds/rick_astley.ogg")
lib.play_music(song, -1)

count = 0
network_message = "numbers from server: "

function on_network_request(msg)
    network_message = network_message.. msg
    network_text = lib.load_text(font, network_message, "black")
end

function frame ()
    count = count + 1
    if count > 50 then
        count = 0
        lib.send_network_request(network_message)
    end
    
    lib.fill_screen_with_color(100, 100, 100)
    if lib.has_keyboard() then
        if lib.is_key_pressed("Left") then
            x = x - speed
        end
        if lib.is_key_pressed("Right") then
            x = x + speed
        end
        if lib.is_key_pressed("Up") then
            y = y - speed
        end
        if lib.is_key_pressed("Down") then
            y = y + speed
        end
    end
    touch_x, touch_y = lib.get_touch_coordinates()
    if touch_x and touch_y then
        lib.draw_texture(touch_x, touch_y, greenface)
    end
    lib.draw_texture(x, y, greenface)
    lib.draw_texture(0, 0, hello_world_text)
    if network_text then
        lib.draw_texture(0, 100, network_text)
    end
    lib.render()
end
