Wireworld = {}

-- Simulation timestep
local timestep = 0.5

-- Tracks the number of electron heads near a conductor
local neighbor_heads = {}

-- Has the neighbor_heads been cleared yet?
local already_cleared = false

local function add_neighbor(pos)
	local x = pos.x
	local y = pos.y
	local z = pos.z
	
	-- Handle nils
	if not neighbor_heads[x] then
		neighbor_heads[x] = {}
	end

	if not neighbor_heads[x][y] then
		neighbor_heads[x][y] = {}
	end

	if not neighbor_heads[x][y][z] then
		neighbor_heads[x][y][z] = 0
	end
	
	neighbor_heads[x][y][z] = neighbor_heads[x][y][z] + 1
end

local function clear_neighbor_count(pos)
	neighbor_heads = {}
end

local function get_neighbor_count(pos)
	local x = pos.x
	local y = pos.y
	local z = pos.z
	
	if neighbor_heads[x] and neighbor_heads[x][y] and neighbor_heads[x][y][z] then
		return neighbor_heads[x][y][z]
	else
		return 0
	end
end

-- Count accumulator for a specific predicate.
local function count_accumulator(p)
	return Church.fold(Church.curry(function(acc, x)
					   if p(x) then
						   return acc + 1
					   else
						   return acc
					   end
	end))(0)
end

local count_heads = count_accumulator(function(node)
		return node.name == "wireworld:electron_head"
end)

-- This is a wireworld electron head.
minetest.register_node("wireworld:electron_head", {
			       description = "Electron Head",
			       drawtype = "normal",
			       tiles = {"wireworld_elec_head.png"},
			       diggable = true,
			       drop = "wireworld:conductor",
			       light_source = 14,
			       groups = {oddly_breakable_by_hand=3},
})

-- This is a wireworld electron tail.
minetest.register_node("wireworld:electron_tail", {
			       description = "Electron Tail",
			       drawtype = "normal",
			       tiles = {"wireworld_elec_tail.png"},
			       diggable = true,
			       drop = "wireworld:conductor",
			       light_source = 10,
			       groups = {oddly_breakable_by_hand=3},
})


-- Like set_node, but does not change air
local function change_node(pos, tab)
	if minetest.get_node(pos).name ~= "air" then
		minetest.set_node(pos,tab)
	end
end


local function conductor_update(pos)
	local neighbor_count = get_neighbor_count(pos)

	if neighbor_count == 1 or neighbor_count == 2 then
		change_node(pos, {name="wireworld:electron_head"})
	end
end


-- This is a wireworld conductor.
minetest.register_node("wireworld:conductor", {
			       description = "Conductor",
			       drawtype = "normal",
			       tiles = {"wireworld_conductor.png"},
			       diggable = true,
			       drop = "wireworld:conductor",
			       groups = {oddly_breakable_by_hand=3},
			       on_timer = conductor_update
})

-- Node update ABM. Runs one step of wireworld.
minetest.register_abm({
		nodenames = {"wireworld:electron_head",
			     "wireworld:electron_tail",
			     "wireworld:conductor",
		},
		interval = timestep,
		chance = 1,
		action = function(pos, node)

			-- Flush electron head counts
			if not already_cleared then
				clear_neighbor_count()
				already_cleared = true
				minetest.after(0.05, function()
						already_cleared = false
				end)
			end
			
			local new_node_name
			if node.name == "wireworld:electron_head" then
				local neighbors = BobUtil.pos_neighbors(pos)
				Church.map(add_neighbor)(neighbors)
				new_node_name = "wireworld:electron_tail"
			elseif node.name == "wireworld:electron_tail" then
				new_node_name = "wireworld:conductor"
			else
				minetest.after(0.1, conductor_update, pos)
				return -- We don't want to set the node automagically
			end

			minetest.after(0.1, change_node,
				       pos, {name=new_node_name})
		end,
})


-- Turns any conductor on the space into an electron head
local function zap(pos)
	if minetest.get_node(pos).name == "wireworld:conductor" then
		minetest.set_node(pos, {name = "wireworld:electron_head"})
	end
end

local function zapper_action(itemstack, user, pointed_thing)
	pos = minetest.get_pointed_thing_position(pointed_thing, false)
	if pos ~= nil then
		zap(pos)
	end
end

minetest.register_craftitem("wireworld:zapper", {
				    description = "Zapper",
				    inventory_image = "wireworld_zapper.png",
				    wield_image = "wireworld_zapper.png",
				    stack_max = 1,
				    on_use = zapper_action,
})


-- Crafting Recipes


-- Conductor
minetest.register_craft({
	output = "wireworld:conductor 16",
	recipe = {
		{"default:steel_ingot", "default:mese_crystal", "default:steel_ingot"},
		{"default:mese_crystal", "default:mese_crystal", "default:mese_crystal"},
		{"default:steel_ingot", "default:mese_crystal", "default:steel_ingot"},
	}
})
