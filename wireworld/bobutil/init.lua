-- Strange name avoids name clashes.
BobUtil = {}

local clone = Church.map(Church.id)

-- For debugging purposes
function print_pos(pos)
	print ("{" .. pos.x .. ", " .. pos.y .. ", " .. pos.z .. "}")
end

-- Puts values from two tables in a new table, erasing key information.
local append = function(tab1, tab2)
	local new_tab = {}
	
	local i = 1
	for key, value in pairs(tab1) do
		new_tab[i] = value
		i = i + 1
	end

	for key, value in pairs(tab2) do
		new_tab[i] = value
		i = i + 1
	end

	return new_tab
end

-- How far away in one axis a neighbor can be
local offsets_comp = {-1, 0, 1}

local build_pos = Church.curry3(function(in_x, in_y, in_z)
		local new_pos = {
			x = in_x,
			y = in_y,
			z = in_z,
		}
		return new_pos
end)

local function not_equals_origin(pos)
	return not (pos.x == 0 and pos.y == 0 and pos.z == 0)
end

local offsets =
	Church.filter(not_equals_origin)(
		Church.cart_with(Church.apply)(
			Church.cart_with(build_pos)(offsets_comp)(offsets_comp))(
			offsets_comp))
	
local apply_offset = Church.curry(function(pos, offset)
		local new_pos = { x = pos.x + offset.x,
			    y = pos.y + offset.y,
			    z = pos.z + offset.z,
		}
		return new_pos
end)
		
BobUtil.pos_neighbors = function(pos)
	return Church.map(apply_offset(pos))(offsets)
end

-- Takes a position and gets all the surrounding nodes.
BobUtil.node_neighbors = function(pos)
	return Church.map(minetest.get_node)(BobUtil.pos_neighbors(pos))
end
