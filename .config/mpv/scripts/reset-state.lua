local mp = require "mp"

local options = {
    "vo",
    "gpu-api",
    "hwdec",
    "scale",
    "scale-antiring",
    "cscale",
    "dscale",
    "deband",
    "dither",
    "interpolation",
    "video-sync",
    "glsl-shaders",

    "audio-device",
    "audio-channels",
    "audio-normalize-downmix",
    "af",
    "audio-format",

    "target-peak",
    "tone-mapping-param",
}

local defaults = {}

local function snapshot()
    defaults = {}

    for _, name in ipairs(options) do
        defaults[name] = mp.get_property_native(name)
    end
end

local function reset()
    for name, value in pairs(defaults) do
        mp.set_property_native(name, value)
    end

    mp.osd_message("Playback settings reset")
end

mp.register_event("file-loaded", snapshot)
mp.add_key_binding(nil, "reset-state", reset)
