-- Settings


-- TIMESTEP is the simulation timestep for wireworld.
--
-- Don't set it too low, or you might get odd behavior. Anything below 0.15
-- is probably guaranteed to break.
TIMESTEP = 0.5

Config = {}

Config.timestep = TIMESTEP

return Config
