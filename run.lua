-- Modified into using fixed timestep
function love.run()
 
    if love.math then
        love.math.setRandomSeed(os.time())
    end
 
    if love.load then love.load(arg) end
 
    -- We don't want the first frame's dt to include time taken by love.load.
    if love.timer then love.timer.step() end

    -- frame_time will be set to one second/logic_per_second
    local logic_per_second = 60
    local frame_time = 1 / logic_per_second

    local time_since_last_update = 0
 
    -- Main loop time.
    while true do
        -- Process events.
        if love.event then
            love.event.pump()
            for name, a,b,c,d,e,f in love.event.poll() do
                if name == "quit" then
                    if not love.quit or not love.quit() then
                        return a
                    end
                end
                love.handlers[name](a,b,c,d,e,f)
            end
        end
 
        -- Update dt, as we'll be passing it to update
        if love.timer then
            love.timer.step()
            time_since_last_update = time_since_last_update + love.timer.getDelta()
        end
 
        -- Call update and draw
        while time_since_last_update > frame_time do
            if love.update then love.update(frame_time) end -- will pass 0 if love.timer is disabled
            time_since_last_update = time_since_last_update - frame_time
        end
 
        if love.graphics and love.graphics.isActive() then
            love.graphics.clear(love.graphics.getBackgroundColor())
            love.graphics.origin()
            if love.draw then love.draw() end
            love.graphics.present()
        end
 
        if love.timer then love.timer.sleep(0.001) end
    end
 
end