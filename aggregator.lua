--[[
An example of performing server-side processing of
Redis Streams with Lua scripting. Here we'll maintain
a simple moving average of the temps in a stream.
]]--

local rawkey, aggkey = KEYS[1], KEYS[2]

-- Add the entry to the raw stream
local rid = redis.call('XADD', rawkey, 'MAXLEN', '~', 10000, '*', unpack(ARGV))

-- Read the last n entries in the stream
local n = 7
local entries = redis.call('XREVRANGE', rawkey, '+', '-', 'COUNT', n+1)
table.remove(entries, 1)

-- Compute the average for each field
local t = {}            -- A temporary table
local agg = {}          -- The aggregate record
while #entries > 0  do  -- Iterate entries
  local e = table.remove(entries)  -- An entry
  local r = e[2]                   -- The record
  while #r > 0  do       -- Iterate each record's fields
    local f, v = table.remove(r, 1), tonumber(table.remove(r, 1))
    if v then              -- Number value
      if t[f] == nil then  -- Create a new table entry for the field
        t[f] = {
          count = 1,
          sum = v
        }
      else                 -- Update an existing entry
        t[f]['count'] = t[f]['count'] + 1
        t[f]['sum'] = t[f]['sum'] + tonumber(v)
      end
    end
  end
end

for f, v in pairs(t) do
  table.insert(agg, f)
  table.insert(agg, v['sum']/v['count'])
end

-- Add the aggregates record to the aggregate stream
local aid = redis.call('XADD', aggkey, 'MAXLEN', '~', 10000, '*', ARGV[1], ARGV[2], unpack(agg))

-- Return the entry id
return { rid }
