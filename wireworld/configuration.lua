-- Settings


-- TIMESTEP is the simulation timestep for wireworld.
--
-- Don't set it too low, or you might get odd behavior. Maybe I am only saying
-- this because I don't quite understand how guaranteed the timings of
-- minetest.after and abms are.

TIMESTEP = 0.5

Config = {}

Config.timestep = TIMESTEP

return Config
