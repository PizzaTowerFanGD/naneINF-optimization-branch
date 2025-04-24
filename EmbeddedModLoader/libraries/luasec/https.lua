----------------------------------------------------------------------------
-- LuaSec 1.0.2
-- Copyright (C) 2009-2021 PUC-Rio
--
-- Author: Pablo Musa
-- Author: Tomas Guisasola
---------------------------------------------------------------------------

-- MODIFIED LUASEC VERSION!!!


local filepath = "./ssl.dll" -- Adjust the path if needed
local func, err = package.loadlib(filepath, "luaopen_ssl")

if func then
    local ssl = func() -- Call the initialization function
    if ssl then
        -- Now you can use the 'ssl' module
        print("SSL module loaded successfully:", ssl)
        -- Example (depending on what 'ssl' provides):
        -- local socket = ssl.new_socket()
    else
        print("Error initializing SSL module:", err)
    end
else
    print("Error loading SSL library:", err)
end

-- user agent
local version = love.filesystem.read('EmbeddedModLoader/version.txt')
userAgent = "naneINF/" .. version .. " (" .. love.system.getOS() .. ")"


local socket = require("socket")
local ssl    = require("EmbeddedModLoader/libraries/luasec/ssl")
local ltn12  = require("ltn12")
local http   = require("socket.http")
local url    = require("socket.url")

local try    = socket.try

--
-- Module
--
local _M = {
  _VERSION   = "1.0.2",
  _COPYRIGHT = "LuaSec 1.0.2 - Copyright (C) 2009-2021 PUC-Rio",
  PORT       = 443,
  TIMEOUT    = 60
}

-- TLS configuration
local cfg = {
  protocol = "any",
  options  = {"all", "no_sslv2", "no_sslv3", "no_tlsv1"},
  verify   = "none",
}

--------------------------------------------------------------------
-- Auxiliar Functions
--------------------------------------------------------------------

-- Insert default HTTPS port.
local function default_https_port(u)
   return url.build(url.parse(u, {port = _M.PORT}))
end

-- Convert an URL to a table according to Luasocket needs.
local function urlstring_totable(url, body, result_table)
   url = {
      url = default_https_port(url),
      method = body and "POST" or "GET",
      sink = ltn12.sink.table(result_table)
   }
   if body then
      url.source = ltn12.source.string(body)
      url.headers = {
         ["content-length"] = #body,
         ["content-type"] = "application/x-www-form-urlencoded",
      }
   end
   return url
end

-- Forward calls to the real connection object.
local function reg(conn)
   local mt = getmetatable(conn.sock).__index
   for name, method in pairs(mt) do
      if type(method) == "function" then
         conn[name] = function (self, ...)
                         return method(self.sock, ...)
                      end
      end
   end
end

-- Return a function which performs the SSL/TLS connection.
local function tcp(params)
   params = params or {}
   -- Default settings
   for k, v in pairs(cfg) do 
      params[k] = params[k] or v
   end
   -- Force client mode
   params.mode = "client"
   -- 'create' function for LuaSocket
   return function ()
      local conn = {}
      conn.sock = try(socket.tcp())
      local st = getmetatable(conn.sock).__index.settimeout
      function conn:settimeout(...)
         return st(self.sock, _M.TIMEOUT)
      end
      -- Replace TCP's connection function
      function conn:connect(host, port)
         try(self.sock:connect(host, port))
         self.sock = try(ssl.wrap(self.sock, params))
         self.sock:sni(host)
         self.sock:settimeout(_M.TIMEOUT)
         try(self.sock:dohandshake())
         reg(self, getmetatable(self.sock))
         return 1
      end
      return conn
  end
end

--------------------------------------------------------------------
-- Main Function
--------------------------------------------------------------------

-- Make a HTTP request over secure connection.  This function receives
--  the same parameters of LuaSocket's HTTP module (except 'proxy' and
--  'redirect') plus LuaSec parameters.
--
-- @param url mandatory (string or table)
-- @param body optional (string)
-- @return (string if url == string or 1), code, headers, status
--
local function request(url, body)
  local result_table = {}
  local stringrequest = type(url) == "string"
  if stringrequest then
    url = urlstring_totable(url, body, result_table)
  else
    url.url = default_https_port(url.url)
  end
  if http.PROXY or url.proxy then
    return nil, "proxy not supported"
  elseif url.redirect then
    return nil, "redirect not supported"
  elseif url.create then
    return nil, "create function not permitted"
  end
  -- New 'create' function to establish a secure connection
  url.create = tcp(url)

    --[[for i, v in pairs(body) do
        url[i] = v
    end]]

    for i, v in pairs(url) do
        print(tostring(i) .. " : " .. tostring(v))
    end

    url.method = 'GET'

  local res, status, headers, code = http.request(url)
    print(res, code, headers, status)
  if res and stringrequest then
    return table.concat(result_table), code, headers, status
  end
  return res, code, headers, status
end

--------------------------------------------------------------------------------
-- Export module
--

_M.request = request
_M.tcp = tcp

return _M
