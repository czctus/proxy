# proxy
An module for Roblox that allows for proxying HTTP requests in a promise based system.

## Module Setup
1. Get the most recent release [Here](https://github.com/czctus/proxy/releases)
2. Move the module anywhere
3. Create a script and require the module at the top like so:
```lua
  local proxy = require(path.to.proxy)
```
4. Your done! Feel free to check out some examples at the bottom.

## Examples
These are some examples you can use to get started

### Set User Agent
```lua
require(path.to.proxy).get('https://api.perox.dev/self-headers', {headers={["C-User-Agent"]="CustomUserAgent"}})
  :ready(function(data)
  	print(data.Body)
  end)
  :catch(function(err)
  	warn("Failed to get headers: "..err)
  end)
  :go()
```
### Set Body Text
```lua
require(script.Parent.proxy).post('https://api.perox.dev/', {body="Some body text here"})
	:ready(function(data)
		print(data.Body)
	end)
	:catch(function(err)
		warn(err)
	end)
	:go()
```
