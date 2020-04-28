
local world = {}

function world.sprite(x, y, tex)
    return {
        x = x,
        y = y,
        tex = tex,
    }
end

function world.draw(sprites)
    lib.fill_screen_with_color(0, 0, 0)

    print(sprites)
    for i, s in pairs(sprites) do
        print(i)
        print(s)
        lib.draw_texture(s.x, s.y, s.tex)
    end
end

return world