function onEvent(name, value1, value2)
    if name == 'animheldcamzoom' then
        setProperty('defaultCamZoom', value1)
        runTimer('wait', value2);

        function onTimerCompleted(tag, loops, loopsleft)
            if tag == 'wait' then
                setProperty('defaultCamZoom', 1)
            end
        end
    end
end