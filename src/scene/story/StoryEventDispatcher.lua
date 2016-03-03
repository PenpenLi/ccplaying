--
-- Author: keyring
-- Date: 2014-10-17 09:44:07
--

module(...,package.seeall)

local function preinvoke( eventname, callback, object, userdata, ... )
	if object then
		callback(eventname, object, ...)
	else
		callback(eventname, ...)
	end
end

function newDispatcher( self )
	-- 1.
	-- local newobj = {}
	-- setmetatable(newobj,{__index = scene.test.StoryEventDispatcher})

	-- 2.
	-- local newobj = setmetatable({}, { __index = package.loaded["scene.test.StoryEventDispatcher"] })
	
	-- 3.
	local newobj = {}
	setmetatable(newobj, self)
	self.__index = self

	newobj.preinvoke = preinvoke
	newobj.eventtable = {}
	return newobj
end

function listenEvent( self, eventname, callback, object, userdata )
	assert(callback)
	self.eventtable[eventname] = self.eventtable[eventname] or {}
	local event = self.eventtable[eventname]
	if not object then
		object = "_static_callback"
	end

	event[object] = event[object] or {}
	local object_event = event[object]
	object_event[callback] = userdata or true
end

function dispatch( self, eventname, ... )
	assert(eventname)
	local event = self.eventtable[eventname]
	for object,objectfunc in pairs(event) do
		if object == "_static_callback" then
			for callback,userdata in pairs(objectfunc) do
				self.preinvoke(eventname, callback, nil, userdata, ...)
			end
		else
			for callback,userdata in pairs(objectfunc) do
				self.preinvoke(eventname, callback, object, userdata, ...)
			end
		end
	end
end

-- 删除某对象的某个回调
function delEvent( self, eventname, callback, object )
	assert(callback)
	local event = self.eventtable[eventname]
	if not event then
		return
	end
	if not object then
		object = "_static_callback"
	end
	local object_event = event[object]
	if not object_event then
		return
	end

	object_event[callback] = nil
end

-- 删除某对象的全部回调
function removeAllEvent( self, eventname, object )
	assert(object)
	local event = self.eventtable[eventname]
	if not event then
		return
	end
	event[object] = nil
end

