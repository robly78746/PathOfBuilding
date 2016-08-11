-- Path of Building
--
-- Class: Slider Control
-- Basic slider control
--

local m_min = math.min
local m_max = math.max

local SliderClass = common.NewClass("SliderControl", function(self, x, y, width, height, changeFunc, enableFunc)
	self.x = x
	self.y = y
	self.width = width
	self.height = height
	self.knobSize = height - 2
	self.knobTravel = width - self.knobSize - 2
	self.val = 0
	self.changeFunc = changeFunc
	self.enableFunc = enableFunc
end)

function SliderClass:GetPos()
	return type(self.x) == "function" and self:x() or self.x,
		   type(self.y) == "function" and self:y() or self.y
end

function SliderClass:IsMouseOver()
	if self.hidden then
		return false
	end
	local x, y = self:GetPos()
	local cursorX, cursorY = GetCursorPos()
	local mOver = cursorX >= x and cursorY >= y and cursorX < x + self.width and cursorY < y + self.height
	local mOverComp
	if mOver then
		local relX = cursorX - x - 2
		local knobX = self:GetKnobXForVal()
		if relX >= knobX and relX < knobX + self.knobSize then
			mOverComp = "KNOB"
		else
			mOverComp = "SLIDE"
		end
	end
	return mOver, mOverComp
end

function SliderClass:SetValFromKnobX(knobX)
	self.val = m_max(0, m_min(1, knobX / self.knobTravel))
	if self.changeFunc then
		self.changeFunc(self.val)
	end
end

function SliderClass:GetKnobXForVal()
	return self.knobTravel * self.val
end

function SliderClass:Draw()
	if self.hidden then
		return
	end
	local x, y = self:GetPos()
	local width, height = self.width, self.height
	local enabled = not self.enableFunc or self.enableFunc()
	if self.dragging then
		local cursorX, cursorY = GetCursorPos()
		self:SetValFromKnobX((cursorX - self.dragCX) + self.dragKnobX)
	end
	local mOver, mOverComp = self:IsMouseOver()
	if not enabled then
		SetDrawColor(0.33, 0.33, 0.33)
	elseif self.dragging or mOver then
		SetDrawColor(1, 1, 1)
	else
		SetDrawColor(0.5, 0.5, 0.5)
	end
	DrawImage(nil, x, y, width, height)
	SetDrawColor(0, 0, 0)
	DrawImage(nil, x + 1, y + 1, width - 2, height - 2)
	if enabled then
		if self.dragging or mOverComp == "KNOB" then
			SetDrawColor(1, 1, 1)
		else
			SetDrawColor(0.5, 0.5, 0.5)
		end
		local knobX = self:GetKnobXForVal()
		DrawImage(nil, x + 2 + knobX, y + 2, self.knobSize - 2, self.knobSize - 2)
	end
end

function SliderClass:OnKeyDown(key)
	if self.hidden or (self.enableFunc and not self.enableFunc()) then
		return
	end
	if key == "LEFTBUTTON" then
		local mOver, mOverComp = self:IsMouseOver()
		if not mOver then
			return
		end
		if not self.dragging then
			self.dragging = true
			local cursorX, cursorY = GetCursorPos()
			self.dragCX = cursorX
			if mOverComp == "SLIDE" then
				local x, y = self:GetPos()
				self:SetValFromKnobX(cursorX - x - 1 - self.knobSize / 2)
			end	
			self.dragKnobX = self:GetKnobXForVal()
		end
	end
	return self
end

function SliderClass:OnKeyUp(key)
	if self.hidden or (self.enableFunc and not self.enableFunc()) then
		return
	end
	if key == "LEFTBUTTON" then
		if self.dragging then
			self.dragging = false
			local cursorX, cursorY = GetCursorPos()
			self:SetValFromKnobX((cursorX - self.dragCX) + self.dragKnobX)
		end
	end
end
