local Pool = {}
Pool.__index = Pool

function Pool.new()
	local counts = {}
	return setmetatable({
		sets = {},
		keys = {},
		counts = counts,
		values = {},
	}, Pool)
end

function Pool:add(keys, value)
	local node = {}
	local sets = self.sets
	local count = 1
	for key, req in next, keys do
		local set = sets[key]
		if set then
			local records = set[req]
			if records then
				local i = #records + 1
				records[i] = node
				node[records] = i
			else
				records = {node}
				node[records] = 1
				set[req] = records
			end
		else
			local records = {node}
			node[records] = 1
			sets[key] = {
				[req] = records
			}
		end

		-- Keep track of the number of requirements
		count = count - 1
	end
	self.keys[node] = keys
	self.counts[node] = count
	self.values[node] = value
end

function Pool:nearest(keys)
	local sets = self.sets
	local counts = self.counts

	-- Find # of matching requirements minus not matching
	local matchCount = {}
	for key, req in next, keys do
		local set = sets[key]
		if set then
			local records = set[req]
			if records and #records < 10 then
				for i, value in next, records do
					local c = matchCount[value]
					if c then
						matchCount[value] = c + 1
					else
						matchCount[value] = counts[value]
					end
				end
			end
		end
	end

	-- Compare the counts
	local maxValue, maxCount = next(matchCount)
	for value, count in next, matchCount, maxValue do
		if count > maxCount then
			maxValue = value
			maxCount = count
		end
	end

	-- If no requirements matched at all
	if not maxValue then
		return
	end

	local value = self.values[maxValue]
	local key = self.keys[maxValue]

	-- Pop the value
	self.keys[maxValue] = nil
	self.values[maxValue] = nil
	self.counts[maxValue] = nil
	for records, i in next, maxValue do
		local n = #records
		local rep = records[n]
		if rep then
			rep[records] = i
			records[i] = rep
		end
		records[n] = nil
	end

	return value, key
end

return Pool