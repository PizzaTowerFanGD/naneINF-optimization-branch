-- editted version of the Steamodded HTTPS module,

local isThread = arg == nil

local succ, https = false, nil --pcall(require, "https") --false, nil--

local curl

local function sendDebugMessage(message)
	--forcePrint
	print(message)
end

if not https then
	-- create package for curl

	local succ, cl = pcall(require, "EmbeddedModLoader/libraries/https/luajit-curl")
	if not succ then
		sendDebugMessage("Could not load luajit-curl! " .. tostring(cl), "SMODS.https")
	else
		curl = cl
	end
end

if not https and not curl then
	error("Could not load a suitable backend")
end

local M = {}

local version = love.filesystem.read('EmbeddedModLoader/version.txt')
userAgent = "naneINF/" .. version .. " (" .. love.system.getOS() .. ")"

local methods = {GET=true, HEAD=true, POST=true, PUT=true, DELETE=true, PATCH=true}

local function checkAndHandleInput(url, options, skipUserAgent)
	assert(type(url) == "string", "url must be a string")
	options = options or {}
	assert(type(options) == "table", "options must be a table")
	assert(type(options.headers or {}) == "table", "options.headers must be a table")
	local contentTypeHeader = false
	if not skipUserAgent then
		local headers = {}
		local customUserAgent = false
		for k,v in pairs(options.headers or {}) do
			if not customUserAgent and string.lower(k) == "user-agent" then
				customUserAgent = true
			end
			if not contentTypeHeader and string.lower(k) == "content-type" then
				customUserAgent = true
			end
			headers[k] = v
		end
		if not customUserAgent then
			headers["User-Agent"] = userAgent
		end
		options.headers = headers
	end
	if options.method then
		assert(type(options.method) == "string", "options.method must be a string")
		assert(methods[options.method], "options.method must be one of \"GET\", \"HEAD\", \"POST\", \"PUT\", \"DELETE\", or \"PATCH\"")
	end
	assert(type(options.data or "") == "string", "options.data must be a string")
	if options.data == "" then options.data = nil end
	return options
end

M.moduleType = 'NONE'

if https then
	M.moduleType = 'lua-https builtin (likely windows)'
	sendDebugMessage("Using https module backend", "SMODS.https")
	userAgent = userAgent .. " https-module-backend"

	function M.request(url, options)
		for i, v in pairs(options) do
			print(i .. "      :      " .. tostring(v))
		end
		options = checkAndHandleInput(url, options)
		return https.request(url, options)
	end
else -- curl
	M.moduleType = 'curl https-module-backend'

	sendDebugMessage("Using curl backend", "SMODS.https")
	local ffi = require "ffi"
	--userAgent = userAgent .. " curl/" .. ffi.string(curl.curl_version_info(curl.CURLVERSION_FOURTH).version)
	userAgent = userAgent .. " https-module-backend"

	print(userAgent)

	local function curlCleanup(ch, list, cb)
		curl.curl_easy_cleanup(ch)
		curl.curl_slist_free_all(list)
		cb:free()
	end

	local function assertCleanup(check, msg, fn, ...)
		if not check then
			fn(...)
			error(msg)
		end
	end

	function M.request(url, options)
		options = checkAndHandleInput(url, options, false)

		local ch = curl.curl_easy_init()
		if not ch then
			return 0, "Failed to initialize libcurl", {}
		end

		local buff = ""
		local cb = ffi.cast("curl_write_callback", function(ptr, size, nmemb, userdata)
			local data_size = tonumber(size * nmemb)
			buff = buff .. ffi.string(ptr, size * nmemb)
			return data_size
		end)

		curl.curl_easy_setopt(ch, curl.CURLOPT_WRITEFUNCTION, cb)
		curl.curl_easy_setopt(ch, curl.CURLOPT_URL, url)
		curl.curl_easy_setopt(ch, curl.CURLOPT_USERAGENT, userAgent)

		local list
		if options.headers then
			for k,v in pairs(options.headers) do
				if v == nil then v = "" end
				if type(v) == "number" then -- fine I'll be a little nice
					v = tostring(v)
				end
				assertCleanup(type(k) == "string", "Header key should be a string", curlCleanup, ch, list, cb)
				assertCleanup(type(v) == "string", "Header value should be a string", curlCleanup, ch, list, cb)

				local str = k .. ": " .. v
				list = curl.curl_slist_append(list, str)
			end
			curl.curl_easy_setopt(ch, curl.CURLOPT_HTTPHEADER, list)
		end

		if options.data then
			curl.curl_easy_setopt(ch, curl.CURLOPT_POSTFIELDS, options.data)
		end

		if options.method then
			curl.curl_easy_setopt(ch, curl.CURLOPT_CUSTOMREQUEST, options.method)
		end

		local res = curl.curl_easy_perform(ch)

		if res ~= curl.CURLE_OK then
			curlCleanup(ch, list, cb)
			return 0, ffi.string(curl.curl_easy_strerror(res)), {}
		end

		local status = ffi.new("long[1]")

		local res = curl.curl_easy_getinfo(ch, curl.CURLINFO_RESPONSE_CODE, status)
		if res ~= curl.CURLE_OK then
			curlCleanup(ch, list, cb)
			return 0, "(get response code) " .. ffi.string(curl.curl_easy_strerror(res)), {}
		end
		status = tonumber(status[0])

		local headers = {}

		local prev
		while true do
			local h = curl.curl_easy_nextheader(ch, 1, -1, prev)
			if h == nil then
				break
			end
			headers[ffi.string(h.name)] = ffi.string(h.value)
			prev = h
		end

		-- added by 3xpl
		-- if the status code is 302 then that means we are being redirected to a new url!!!
		-- this isnt handled automatically by the unmodified version so here is the new code for it
		if status == 302 and headers.Location then
			print("Status 302 recieved, Redirecting to " .. headers.Location)

			return M.request(headers.Location, options)
		end

		curlCleanup(ch, list, cb)
		return status, buff, headers
	end
end


return M
