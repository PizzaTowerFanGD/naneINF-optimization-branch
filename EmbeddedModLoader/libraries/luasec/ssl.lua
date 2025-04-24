------------------------------------------------------------------------------
-- LuaSec 1.0.2
--
-- Copyright (C) 2006-2021 Bruno Silvestre
--
------------------------------------------------------------------------------

local folderByPlatform = {
    ['Nintendo Switch'] = 'Android', -- EXPERIMENTAL (NOT ACRTUALLY TESTED LOL)
}

local fileExtensions = {
    ['Windows'] = '.dll',
    ['iOS'] = '.dylib',
    ['OS X'] = '.dylib', -- the rest default to .so
}

--local ffi = require('ffi')
--local ssl = require('ssl')

--check the save directory first
--    local filepath = love.filesystem.getSaveDirectory() .. "\\EmbeddedModLoader\\libraries\\luasec\\Libraries\\" .. folder .. "\\ssl" .. fileExtension -- TODO: change to actually getting the path
--    local typeFull = "luaopen_ssl_" .. type
--
--    local func, err = package.loadlib(filepath, typeFull)
--
--    print(filepath)
--
--    -- check the .love directory next if the library was not in the save directory
--    if not func then
--        filepath = love.filesystem.getSource() .."\\EmbeddedModLoader\\libraries\\luasec\\Libraries\\" .. folder .. "\\ssl" .. fileExtension -- TODO: change to actually getting the path
--        func, err = package.loadlib(filepath, typeFull)
--
--        print(filepath)
--    end
--
--    if func then
--        local luasec_core_module = func()
--        print(typeFull .. " loaded successfully:", luasec_core_module)
--        for k, v in pairs(luasec_core_module) do
--            print(k, v)
--        end
--
--        print("AAAAA")
--    else
--        print("Error loading " .. typeFull .. ":", err)
--end




-- added by 3xpl
--[[local function forceLoad(type)
    type = string.gsub(type, "ssl.", "")

    -- determine what OS/Platform we are on and load it that way.
    local platform = love.system.getOS()
    local folder = folderByPlatform[platform] or platform
    local fileExtension = fileExtensions[platform] or '.so'

    -- extend upon our cpath search so that we can require these dlls from the save directory
    package.cpath ..=

    print(package.cpath)

    ffi.load()

    if func then
        local luasec_core_module = func()
        print(typeFull .. " loaded successfully:", luasec_core_module)
        for k, v in pairs(luasec_core_module) do
            print(k, v)
        end

        print("AAAAA")
    else
        print("Error loading " .. typeFull .. ":", err)
    end

    return func()
end]]




local core    = require("ssl.core")
local context = require("ssl.context")
local x509    = require("ssl.x509")
local config  = require("ssl.config")

local unpack  = table.unpack or unpack

-- We must prevent the contexts to be collected before the connections,
-- otherwise the C registry will be cleared.
local registry = setmetatable({}, {__mode="k"})

--
--
--
local function optexec(func, param, ctx)
  if param then
    if type(param) == "table" then
      return func(ctx, unpack(param))
    else
      return func(ctx, param)
    end
  end
  return true
end

--
-- Convert an array of strings to wire-format
--
local function array2wireformat(array)
   local str = ""
   for k, v in ipairs(array) do
      if type(v) ~= "string" then return nil end
      local len = #v
      if len == 0 then
        return nil, "invalid ALPN name (empty string)"
      elseif len > 255 then
        return nil, "invalid ALPN name (length > 255)"
      end
      str = str .. string.char(len) .. v
   end
   if str == "" then return nil, "invalid ALPN list (empty)" end
   return str
end

--
-- Convert wire-string format to array
--
local function wireformat2array(str)
   local i = 1
   local array = {}
   while i < #str do
      local len = str:byte(i)
      array[#array + 1] = str:sub(i + 1, i + len)
      i = i + len + 1
   end
   return array
end

--
--
--
local function newcontext(cfg)
   local succ, msg, ctx
   -- Create the context
   ctx, msg = context.create(cfg.protocol)
   if not ctx then return nil, msg end
   -- Mode
   succ, msg = context.setmode(ctx, cfg.mode)
   if not succ then return nil, msg end
   local certificates = cfg.certificates
   if not certificates then
      certificates = {
         { certificate = cfg.certificate, key = cfg.key, password = cfg.password }
      }
   end
   for _, certificate in ipairs(certificates) do
      -- Load the key
      if certificate.key then
         if certificate.password and
            type(certificate.password) ~= "function" and
            type(certificate.password) ~= "string"
         then
            return nil, "invalid password type"
         end
         succ, msg = context.loadkey(ctx, certificate.key, certificate.password)
         if not succ then return nil, msg end
      end
      -- Load the certificate(s)
      if certificate.certificate then
        succ, msg = context.loadcert(ctx, certificate.certificate)
        if not succ then return nil, msg end
        if certificate.key and context.checkkey then
          succ = context.checkkey(ctx)
          if not succ then return nil, "private key does not match public key" end
        end
      end
   end
   -- Load the CA certificates
   if cfg.cafile or cfg.capath then
      succ, msg = context.locations(ctx, cfg.cafile, cfg.capath)
      if not succ then return nil, msg end
   end
   -- Set SSL ciphers
   if cfg.ciphers then
      succ, msg = context.setcipher(ctx, cfg.ciphers)
      if not succ then return nil, msg end
   end
   -- Set SSL cipher suites
   if cfg.ciphersuites then
      succ, msg = context.setciphersuites(ctx, cfg.ciphersuites)
      if not succ then return nil, msg end
   end
    -- Set the verification options
   succ, msg = optexec(context.setverify, cfg.verify, ctx)
   if not succ then return nil, msg end
   -- Set SSL options
   succ, msg = optexec(context.setoptions, cfg.options, ctx)
   if not succ then return nil, msg end
   -- Set the depth for certificate verification
   if cfg.depth then
      succ, msg = context.setdepth(ctx, cfg.depth)
      if not succ then return nil, msg end
   end

   -- NOTE: Setting DH parameters and elliptic curves needs to come after
   -- setoptions(), in case the user has specified the single_{dh,ecdh}_use
   -- options.

   -- Set DH parameters
   if cfg.dhparam then
      if type(cfg.dhparam) ~= "function" then
         return nil, "invalid DH parameter type"
      end
      context.setdhparam(ctx, cfg.dhparam)
   end
   
   -- Set elliptic curves
   if (not config.algorithms.ec) and (cfg.curve or cfg.curveslist) then
     return false, "elliptic curves not supported"
   end
   if config.capabilities.curves_list and cfg.curveslist then
     succ, msg = context.setcurveslist(ctx, cfg.curveslist)
     if not succ then return nil, msg end
   elseif cfg.curve then
     succ, msg = context.setcurve(ctx, cfg.curve)
     if not succ then return nil, msg end
   end

   -- Set extra verification options
   if cfg.verifyext and ctx.setverifyext then
      succ, msg = optexec(ctx.setverifyext, cfg.verifyext, ctx)
      if not succ then return nil, msg end
   end

   -- ALPN
   if cfg.mode == "server" and cfg.alpn then
      if type(cfg.alpn) == "function" then
         local alpncb = cfg.alpn
         -- This callback function has to return one value only
         succ, msg = context.setalpncb(ctx, function(str)
            local protocols = alpncb(wireformat2array(str))
            if type(protocols) == "string" then
               protocols = { protocols }
            elseif type(protocols) ~= "table" then
               return nil
            end
            return (array2wireformat(protocols))    -- use "()" to drop error message
         end)
         if not succ then return nil, msg end
      elseif type(cfg.alpn) == "table" then
         local protocols = cfg.alpn
         -- check if array is valid before use it
         succ, msg = array2wireformat(protocols)
         if not succ then return nil, msg end
         -- This callback function has to return one value only
         succ, msg = context.setalpncb(ctx, function()
            return (array2wireformat(protocols))    -- use "()" to drop error message
         end)
         if not succ then return nil, msg end
      else
         return nil, "invalid ALPN parameter"
      end
   elseif cfg.mode == "client" and cfg.alpn then
      local alpn
      if type(cfg.alpn) == "string" then
         alpn, msg = array2wireformat({ cfg.alpn })
      elseif type(cfg.alpn) == "table" then
         alpn, msg = array2wireformat(cfg.alpn)
      else
         return nil, "invalid ALPN parameter"
      end
      if not alpn then return nil, msg end
      succ, msg = context.setalpn(ctx, alpn)
      if not succ then return nil, msg end
   end

   if config.capabilities.dane and cfg.dane then
      context.setdane(ctx)
   end

   return ctx
end

--
--
--
local function wrap(sock, cfg)
   local ctx, msg
   if type(cfg) == "table" then
      ctx, msg = newcontext(cfg)
      if not ctx then return nil, msg end
   else
      ctx = cfg
   end
   local s, msg = core.create(ctx)
   if s then
      core.setfd(s, sock:getfd())
      sock:setfd(core.SOCKET_INVALID)
      registry[s] = ctx
      return s
   end
   return nil, msg 
end

--
-- Extract connection information.
--
local function info(ssl, field)
  local str, comp, err, protocol
  comp, err = core.compression(ssl)
  if err then
    return comp, err
  end
  -- Avoid parser
  if field == "compression" then
    return comp
  end
  local info = {compression = comp}
  str, info.bits, info.algbits, protocol = core.info(ssl)
  if str then
    info.cipher, info.protocol, info.key,
    info.authentication, info.encryption, info.mac =
        string.match(str, 
          "^(%S+)%s+(%S+)%s+Kx=(%S+)%s+Au=(%S+)%s+Enc=(%S+)%s+Mac=(%S+)")
    info.export = (string.match(str, "%sexport%s*$") ~= nil)
  end
  if protocol then
    info.protocol = protocol
  end
  if field then
    return info[field]
  end
  -- Empty?
  return ( (next(info)) and info )
end

--
-- Set method for SSL connections.
--
core.setmethod("info", info)

--------------------------------------------------------------------------------
-- Export module
--

local _M = {
  _VERSION        = "1.0.2",
  _COPYRIGHT      = core.copyright(),
  config          = config,
  loadcertificate = x509.load,
  newcontext      = newcontext,
  wrap            = wrap,
}

return _M
