--@name proxy
--@description proxy is a module that allows for proxying HTTP requests in a promise based system.
--@source https://github.com/czctus/proxy

--example:
--[[
require(script.Parent.proxy).post('https://api.perox.dev/')
:ready(function(data)
	print(data.Body)
end)
:catch(function(err)
	warn(err)
end)
:go()
]]
--optionally, you can call the module itself like 
--require(script.Parent.proxy)(METHOD, URL, OPTIONS)

--also, you can add a header with C- at the front to add headers like User-Agent (C-User-Agent)

--if you have any issues you can dm czctus on discord or email vvv@perox.dev

local proxyUrl = "https://api.perox.dev/proxy"
local module = {}
local http = game:GetService('HttpService')

local function createUrl(url, method)
	local proxied = proxyUrl
	url = http:UrlEncode(url)
	proxied = proxied .. "?url=" .. url .. "&method=" .. string.upper(method)
	return proxied
end

local function createProxyType(method, url:string, options:{})
	local stack = {}
	stack.meta = {}
	stack.options = options or {}

	url = createUrl(url, method)

	function stack:ready(callback)
		stack.meta.ready = callback

		return stack
	end

	function stack:catch(callback)
		stack.meta.catch = callback
		return stack
	end

	function stack:go()
		coroutine.wrap(function()
			local s, r = pcall(function()
				return http:RequestAsync({
					Url = url,
					Method = "POST",
					Headers = stack.options.headers or {},
					Body = stack.options.body or nil
				})
			end)

			if (s) and (r and r.Success) then
				if stack.meta.ready ~= nil then
					stack.meta.ready(r)
				else
					error("No ready statement!")
				end
			else
				if stack.meta.catch ~= nil then
					if typeof(r) == "string" then
						stack.meta.catch(r)
					elseif typeof(r) == "table" then
						stack.meta.catch(r.Body)
					end
				else
					error(r)
				end
			end
		end)()
	end

	return stack
end

function module.get(url: string, options: { headers: { [string]: string }?, body: string? }?)
	return createProxyType("GET", url, options)
end

function module.post(url: string, options: { headers: { [string]: string }?, body: string? }?)
	return createProxyType("POST", url, options)
end

function module.delete(url: string, options: { headers: { [string]: string }?, body: string? }?)
	return createProxyType("DELETE", url, options)
end

function module.put(url: string, options: { headers: { [string]: string }?, body: string? }?)
	return createProxyType("PUT", url, options)
end

function module.patch(url: string, options: { headers: { [string]: string }?, body: string? }?)
	return createProxyType("PATCH", url, options)
end

function module.setProxy(url:string)
	proxyUrl = url
end

setmetatable(module, {
	__call = function(base, ...)
		local param = { ... }
		local method = param[1]
		local url = param[2]
		local options = param[3]
		if url and method then
			return createProxyType(method, url, options)
		end
	end,
})

return module
