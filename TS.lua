-- TouchSprite 工具函数
-- author hiscaler <hiscaler@gmail.com>
require("Util")
TS = {}

-- 等待延迟
function TS.sleep(seconds)
	mSleep(seconds * 1000)
end

-- 初始化
function TS.init(appName, homeKeyPosition)
	if homeKeyPosition == 'left' then
		homeKeyIndex = 1
	elseif homeKeyPosition == 'right' then
		homeKeyIndex = 2
	else
		homeKeyIndex = 0;
	end
	
	init(appName, homeKeyIndex)
end

-- 运行应用
function TS.runApp(appName, replayTimes)
	local flag = appIsRunning(appName)
	if flag == 0 then
		if replayTimes ~= nil and tonumber(replayTimes) then
			while runApp(appName) == 1 do
				TS.sleep(1)
			end
		else
			return runApp(appName) == 1 and false or true
		end
	end
	
	return true
end

-- 关闭应用
function TS.closeApp(appName)
	if appIsRunning(appName) then
		closeApp(appName)
	end
end

-- 根据分辨率获取当前的设备信息
function TS.getDeviceTypes()
	local w, h = getScreenSize();
	if w == 640 and h == 1136 then
		return {'iphone5', 'iphone5s', 'ipad.touch5'}
	elseif w == 640 and h == 960 then
		return {'iphone4', 'iphone4s', 'ipad.touch4'}
	elseif w == 320 and h == 480 then
		return {'iphone'}
	elseif w == 768 and h == 1024 then
		return {'ipad1', 'ipad2', 'ipad.mini1'}
	elseif w == 1536 and h == 2048 then
		return {'ipad3', 'ipad4', 'ipad5', 'ipad.mini2'}
	else
		return nil
	end
end

local function _searchDeviceByName(name)
	if name ~= nil and #name then
		local devices = TS.getDeviceTypes()
		if devices ~= nil then
			local len = #name
			for key, value in pairs(devices) do
				if string.sub(value, 1, len) == name then
					return true
				end
			end
		else
			return false
		end
	else
		return false
	end
end

-- 是否为 iPhone 手机
function TS.isIphone()
	return _searchDeviceByName('iphone')
end

-- 是否为 iPad 设备
function TS.isIpad()
	return _searchDeviceByName('ipad')
end

-- 是否为苹果设备
function TS.isAppleDevice()
	return TS.getDeviceTypes() ~= nil;
end

-- 是否为安卓系统
function TS.isAndroid()
	return not TS.isIphone()
end

-- 防锁屏
function TS.unlock()
	local flag = deviceIsLock()
	if flag ~= 0 then
		sysver = getOSVer()
		sysint = tonumber(string.sub(sysver, 1, 1) .. string.sub(sysver, 2, 2))
		if sysint == 10 then
			pressHomeKey(0)
		end
		unlockDevice()
	end
end

-- 按钮按下并弹起的连续操作
function TS.touchDownUp(index, x, y, milliseconds)
	if x and y then
		index = index or 1
		milliseconds = milliseconds or 50
		touchDown(index, x, y)
		mSleep(milliseconds)
		touchUp(index, x, y)
	end
end

-- 点击文本输入框
function TS.clickTextInput(index, x, y, milliseconds)
	TS.touchDownUp(index, x, y, 50)
	mSleep(milliseconds)
end

-- 清除文本输入框中的内容（先需要获取焦点）
-- len 需要清理的文本长度
function TS.clearTextInput(len)
	len = len or 40
	for i = 1, len do
		inputText("\b")				
	end	
end

function TS.inputText(text, simulation)
	simulation = simulation or true		
	if simulation then
		TS.simulationHumanInputText(text)
	else
		inputText(text)
	end	
end

-- 模拟点击 IOS 输入法键位
function TS.clickIOSIMEKey(key)
	if key ~= nil then
		if key == 'enter' then
			x, y = findMultiColorInRegionFuzzy(11252670, "36|-5|0x000000,59|-1|0x323538,83|-1|0x050606,84|15|0x979ea8,84|16|0x000000,110|4|0xabb3be", 90, 0, 0, 639, 1135)
			TS.touchDownUp(ni, x, y, 50)
		end
	end
end

-- 计算字符长度（一个汉字算一个字符）
function TS.len(str)
	local _, count = string.gsub(str, "[^\128-\193]", "")
	return count
end

-- 对话框输出内容，方便调试
function TS.dialog(...)
	local message = ''
	for i, v in pairs {...} do
		message = message .. i .. ' = ' .. v .. "\r\n"
	end
	
	dialog(message, 0)
end

-- 模拟人工输入
function TS.simulationHumanInputText(text)
	for i = 1, Util.utf8len(text) do
		inputText(Util.utf8sub(text, i, 1));
		mSleep(math.floor(math.random() * 1000))
	end
end

return TS 