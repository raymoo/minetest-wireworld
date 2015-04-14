Church = {}

Church.id = function(x)
	return x
end

-- Curries functions of two arguments
Church.curry = function(f)
	local curried = function(x)

		local partial = function(y)
			return f(x,y)
		end

		return partial
	end

	return curried
end

-- Uncurries functions
Church.uncurry = function(f)
	local uncurried = function(x, y)
		return f(x)(y)
	end
	
	return uncurried
end

-- Curry with three inputs.
Church.curry3 = function(f)
	local curried = function(x)

		local partial = function(y)

			local partial2 = function(z)
				return f(x, y, z)
			end

			return partial2
		end

		return partial
	end
	
	return curried
end

Church.uncurry3 = function(f)
	local uncurried = function(x, y, z)
		return f(x)(y)
	end

	return uncurried
end

-- Applies a function
Church.apply = Church.curry(function(f, x)
		return f(x)
end)

Church.compose = Church.curry3(function(f,g,x)
		return f(g(x))
end)

-- Takes a function f and a table tab, then returns a new table with each
-- element from tab having f applied.
Church.map = function(f)
	local mapper = function(tab)

		local new_tab = {}
		
		for key, value in pairs(tab) do
			new_tab[key] = f(value)
		end

		return new_tab
	end

	return mapper
end

-- Takes a predicate and a table, and returns a new table with only the elements
-- satisfying the predicate.
Church.filter = Church.curry(function(p, tab)

		local new_tab = {}
		
		for key, value in pairs(tab) do
			if p(value) then
				new_tab[key] = value
			end
		end

		return new_tab
end)

-- f is a function that takes an accumulator, and a new value, then returns
-- the new accumulator. fold takes that function, an initial accumulator, and
-- a table to reduce.
-- This is a left fold.
Church.fold = function(f)
	
	local folder = function(acc)
		
		local final_folder = function(tab)
			local final_acc = acc

			for key, value in pairs(tab) do
				final_acc = f(final_acc)(value)
			end

			return final_acc
		end

		return final_folder
	end

	return folder
end

-- Constructs a pair
Church.pair = Church.curry(function(x,y)
		local new_pair = {
			fst = x,
			snd = y,
		}

		return new_pair
end)

-- Takes a function and two tables, then returns a new table containing the
-- results of applying the function to each value with the same keys.
Church.zip_with = Church.curry3(function(f, tab1, tab2)

		local new_tab = {}

		for key, value in pairs(tab1) do
			if (tab2[key] ~= nil) then
				new_tab[key] = f(value)(tab2[key])
			end
		end

		return new_tab
end)


Church.zip = Church.zip_with(Church.pair)


-- Takes the cartesian product of two tables, using a provided function. Erases
-- key information.
Church.cart_with = Church.curry3(function(f, tab1, tab2)
		local new_tab = {}

		local i = 1

		for key1, value1 in pairs(tab1) do
			for key2, value2 in pairs(tab2) do
				new_tab[i] = f(value1)(value2)
				i = i + 1
			end
		end

		return new_tab
end)


-- Takes a function that takes x and y, then gives a function that takes y and
-- x.
Church.flip = function(f)
	local flipped = function(y)

		local flipped_part = function(x)

			return f(x)(y)
		end
	end
end
