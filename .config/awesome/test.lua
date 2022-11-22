-- Used for testing

local debug_print = function(message)
    require("naughty").notify({
        title = "Debug",
        text = tostring(message),
    })
end

return {
    debug_print = debug_print,
}
