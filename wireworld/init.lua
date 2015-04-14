Wireworld = {}

-- Simulation timestep
local timestep = 0.5

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

-- This is a wireworld conductor.
minetest.register_node("wireworld:conductor", {
			       description = "Conductor",
			       drawtype = "normal",
			       tiles = {"wireworld_conductor.png"},
			       diggable = true,
			       drop = "wireworld:conductor",
			       groups = {oddly_breakable_by_hand=3},
})


-- Like set_node, but does not change air
local function change_node(pos, tab)
	if minetest.get_node(pos).name ~= "air" then
		minetest.set_node(pos,tab)
	end
end


-- Node update ABM. Runs one step of wireworld.
minetest.register_abm({
		nodenames = {"wireworld:electron_head",
			     "wireworld:electron_tail",
			     "wireworld:conductor",
		},
		interval = timestep,
		chance = 1,
		action = function(pos, node)
			local new_node_name
			if node.name == "wireworld:electron_head" then
				new_node_name = "wireworld:electron_tail"
			elseif node.name == "wireworld:electron_tail" then
				new_node_name = "wireworld:conductor"
			else
				local neighbors = BobUtil.node_neighbors(pos)
				local head_count = count_heads(neighbors)

				if head_count == 1 or head_count == 2 then
					new_node_name = "wireworld:electron_head"
				else
					return
				end
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
	zap(pos)
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
