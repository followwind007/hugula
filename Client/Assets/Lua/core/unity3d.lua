------------------------------------------------
--  Copyright © 2013-2014   Hugula: Arpg game Engine
--   
--  author pu
------------------------------------------------
-- luanet.load_assembly("UnityEngine.UI")
-- import "UnityEngine"
-- delay = PLua.Delay
-- stop_delay = PLua.StopDelay
Vector3 = UnityEngine.Vector3
local Resources = UnityEngine.Resources
local LuaHelper = LuaHelper
local LuaTimer = LuaTimer
if unpack==nil then unpack=table.unpack end

--用timer实现delay 函数
function delay(fun,delay_time,...)
    local arg = {...}
    local function temp_delay(id)
      fun(unpack(arg))
    end
    local id = LuaTimer.Add(delay_time*1000,temp_delay)
    return id
end

function stop_delay(id)
  if type(id) == "number" then LuaTimer.Delete(id) end
end
--
--PrefabPool资源自动回收
--当内存达到阈值的时候触发回收，回收按照PrefabCacheType从0开始每段回收
--PrefabPool.gcDeltaTimeConfig = 10 两次GC检测间隔时间

--资源放入缓存使用的类型,与回收密切相关
PrefabCacheType =
{
  segment0 = 0, --最先被回收
  segment1 = 1, --第一个内存阈值时候回收 (PrefabPool.threshold1 = 150)
  segment2 = 2, 
  segment3 = 3, --第二个内存阈值的时候回收(PrefabPool.threshold1 = 180)
  segment4 = 4,
  segment5 = 5,
  segment6 = 6, --第三个阈值的时候回收 (PrefabPool.threshold1 = 200)
  segment7 = 7, --手动调用回收PrefabPool.GCCollect(PrefabCacheType.segment7)
  segment8 = 8  --永远不回收 TODO:自动收缩 
}

function get_angle(posFrom,posTo)  
    local tmpx=posTo.x - posFrom.x
    local tmpy=posTo.y - posFrom.y
    local angle= math.atan2(tmpy,tmpx)*(180/math.pi)
    return angle
end

function print_table(tbl)	print(tojson(tbl)) end

function string.split(s, delimiter)
    result = {};
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match)
    end
    return result
end

function class(base, _ctor)
    local c = {}    -- a new class instance
    if not _ctor and type(base) == 'function' then
        _ctor = base
        base = nil
    elseif type(base) == 'table' then
    -- our new class is a shallow copy of the base class!
        for i,v in pairs(base) do
            c[i] = v
        end
        c._base = base
    end
    
    -- the class will be the metatable for all its objects,
    -- and they will look up their methods in it.
    c.__index = c

    -- expose a constructor which can be called by <classname>(<args>)
    local mt = {}
    
    mt.__call = function(class_tbl, ...)
        local obj = {}
        setmetatable(obj,c)
  
        if _ctor then
            _ctor(obj,...)
        end
        return obj
    end    
        
    c._ctor = _ctor
    c.is_a = function(self, klass)
        local m = getmetatable(self)
        while m do 
            if m == klass then return true end
            m = m._base
        end
        return false
    end
    setmetatable(c, mt)
    return c
end

function lua_gc()
  collectgarbage("collect")
  c=collectgarbage("count")
  print(" gc end ="..tostring(c).." ")
end

function math.randomseed1(i)
    math.randomseed(tostring(os.time()+tonumber(i)):reverse():sub(1, 6)) 
end

--释放没有使用的资源 (mesh,texture)
function unload_unused_assets()
  lua_gc()
  Resources.UnloadUnusedAssets()
  LuaHelper.GCCollect()
end



