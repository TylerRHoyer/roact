local cache = setmetatable({}, {__mode = "v"})
local function U2(xScl, xOff, yScl, yOff)
	local key = (("UDim2 %.6f %.6f %.6f %.6f"):format(xScl, xOff, yScl, yOff))
	local value = cache[key]
	if not value then
		value = UDim2.new(xScl, xOff, yScl, yOff)
		cache[key] = value
	end
	return value
end

local function C3(x, y, z)
	local key = (("Color3 %.6f %.6f %.6f"):format(x, y, z))
	local value = cache[key]
	if not value then
		value = Color3.new(x, y, z)
		cache[key] = value
	end
	return value
end

local function V2(x, y)
	local key = (("Vector2 %.6f %.6f"):format(x, y))
	local value = cache[key]
	if not value then
		value = Vector2.new(x, y)
		cache[key] = value
	end
	return value
end

return function()
	local RunService = game:GetService("RunService")
	local PlayerGui = game:GetService("Players").LocalPlayer.PlayerGui

	local Roact = require(game.ReplicatedStorage.Roact)

	local NODE_SIZE = 10
	local GRID_SIZE = 50

	--[[
		A frame that changes its background color according to time and position props
	]]
	local function Node(props)
		local x = props.x
		local y = props.y
		local time = props.time

		local n = time + x / NODE_SIZE + y / NODE_SIZE

		return Roact.createElement("Frame", {
			Size = U2(0, NODE_SIZE, 0, NODE_SIZE),
			Position = U2(0, NODE_SIZE * x, 0, NODE_SIZE * y),
			BackgroundColor3 = C3(0.5 + 0.5 * math.sin(n), 0.5, 0.5),
		})
	end

	--[[
		Displays a large number of nodes and updates each of them every RunService step
	]]
	local App = Roact.Component:extend("App")

	function App:init()
		self.state = {
			time = tick(),
		}
	end

	function App:render()
		local time = self.state.time
		local nodes = {}

		local n = 0
		for x = 0, GRID_SIZE - 1 do
			for y = 0, GRID_SIZE - 1 do
				n = n + 1
				nodes[n] = Roact.createElement(Node, {
					x = x,
					y = y,
					time = time,
				})
			end
		end

		return Roact.createElement("Frame", {
			Size = U2(0, GRID_SIZE * NODE_SIZE, 0, GRID_SIZE * NODE_SIZE),
			Position = U2(0.5, 0, 0.5, 0),
			AnchorPoint = V2(0.5, 0.5),
		}, nodes)
	end

	function App:didMount()
		self.connection = RunService.Stepped:Connect(function()
			self:setState({
				time = tick(),
			})
		end)
	end

	function App:willUnmount()
		self.connection:Disconnect()
	end

	local app = Roact.createElement("ScreenGui", nil, {
		Main = Roact.createElement(App),
	})

	local handle = Roact.mount(app, PlayerGui)

	local function stop()
		Roact.unmount(handle)
	end

	return stop
end