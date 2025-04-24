NOTE FROM 3XPL ON APRIL 23 2025
this regex module has issues with detecting the range of the matches it actually finds (which is kinda funny)
this is a VERY heavily editted version of https://github.com/Roblox/luau-regexp/tree/main to move it from luau to luajit
and to fix those really weird issues (which i partially succeeded at)? i also changed the syntax quite a bit

the biggest issue with this module was that matchall() absolutely did not work in the slightest which is a huge reason why
injection is so slow,

another issue is that sometimes the spans for injections are still 1-2 characters off causing bleeding issues (which is weirdly somewhat 'fixed') by adding
a debugging comment after every regex injection, somewhat because some patches have an extra space or whatever idk
for example: this patch right here!

[patches.regex]
target = 'functions/common_events.lua'
pattern = '_c.config'
position = 'at'
payload = 'cfg'

i believe ive found a newer version of the roblox regex module with these issues fixed, but I have not tested it yet
https://devforum.roblox.com/t/100a2-pcre2-based-regex-implemention-for-luau-a-better-string-pattern-library/872807
