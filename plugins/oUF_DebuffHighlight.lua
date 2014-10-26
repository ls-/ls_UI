if not oUF then return end

local playerClass = select(2,UnitClass("player"))
local CanDispel = {
  PRIEST = { Magic = false, Disease = false, },
  SHAMAN = { Magic = false, Curse = false, },
  PALADIN = { Magic = false, Poison = false, Disease = false, },
  MAGE = { Curse = false, },
  DRUID = { Magic = false, Curse = false, Poison = false, },
  MONK = { Magic = false, Poison = false, Disease = false, }
}

local dispellist = CanDispel[playerClass] or {}
local origColors = {}
local origBorderColors = {}
local origPostUpdateAura = {}

local function GetDebuffType(unit, filter)
  if not UnitCanAssist("player", unit) then return nil end
  local i = 1
  while true do
    local _, _, texture, _, debufftype = UnitAura(unit, i, "HARMFUL")
    if not texture then break end
    if debufftype and not filter or (filter and dispellist[debufftype]) then
      return debufftype, texture
    end
    i = i + 1
  end
end


local function CheckSpec(self, event, levels)
  local spec = GetSpecialization()
  local slevel = UnitLevel("player")

  if playerClass == "PALADIN"  and slevel > 19 then -- Cleanse
    dispellist.Poison = true
    dispellist.Disease = true
    if (spec == 1) then               -- Sacred Cleansing
      dispellist.Magic = true
    else
      dispellist.Magic = false
    end
  elseif playerClass == "SHAMAN" and slevel > 17 then -- Cleanse Spirit
    dispellist.Curse = true
    if (spec == 3) then               -- Purify Spirit
      dispellist.Magic = true
    else
      dispellist.Magic = false
    end
  elseif playerClass == "DRUID" and slevel > 21 then  -- Remove Corruption
    dispellist.Poison = true
    dispellist.Curse = true
    if (spec == 4) then               -- Nature's Cure
      dispellist.Magic = true
    else
      dispellist.Magic = false
    end
  elseif playerClass == "PRIEST" and slevel > 21 then
    if not (spec == 3) then             -- Purify
      dispellist.Magic = true
      dispellist.Disease = true
    else
      if slevel > 71 then             -- Mass Dispel
        dispellist.Magic = true
      else
        dispellist.Magic = false
      end
      dispellist.Disease = false
    end
  elseif playerClass == "MONK" and slevel > 19 then -- Detox
    dispellist.Poison = true
    dispellist.Disease = true
    if (spec == 2) then               -- Internal Medicine
      dispellist.Magic = true
    else
      dispellist.Magic = false
    end
  elseif playerClass == "MAGE" and slevel > 28 then -- Remove Curse
    dispellist.Curse = true
  end
end

local function Update(object, event, unit)
  if object.unit ~= unit  then return end
  local debuffType, texture  = GetDebuffType(unit, object.DebuffHighlightFilter)
  if debuffType then
    local color = DebuffTypeColor[debuffType]
    if object.DebuffHighlightBackdrop or object.DebuffHighlightBackdropBorder then
      if object.DebuffHighlightBackdrop then
        object:SetBackdropColor(color.r, color.g, color.b, object.DebuffHighlightAlpha or 1)
      end
      if object.DebuffHighlightBackdropBorder then
        object:SetBackdropBorderColor(color.r, color.g, color.b, object.DebuffHighlightAlpha or 1)
      end
    elseif object.DebuffHighlightUseTexture then
      object.DebuffHighlight:SetTexture(texture)
    else
      object.DebuffHighlight:SetVertexColor(color.r, color.g, color.b, object.DebuffHighlightAlpha or .5)
    end
  else
    if object.DebuffHighlightBackdrop or object.DebuffHighlightBackdropBorder then
      local color
      if object.DebuffHighlightBackdrop then
        color = origColors[object]
        object:SetBackdropColor(color.r, color.g, color.b, color.a)
      end
      if object.DebuffHighlightBackdropBorder then
        color = origBorderColors[object]
        object:SetBackdropBorderColor(color.r, color.g, color.b, color.a)
      end
    elseif object.DebuffHighlightUseTexture then
      object.DebuffHighlight:SetTexture(nil)
    else
      local color = origColors[object]
      object.DebuffHighlight:SetVertexColor(color.r, color.g, color.b, color.a)
    end
  end
end

local function Enable(object)
  -- if we're not highlighting this unit return
  if not object.DebuffHighlightBackdrop and not object.DebuffHighlightBackdropBorder and not object.DebuffHighlight then
    return
  end
  -- if we're filtering highlights and we're not of the dispelling type, return
  if object.DebuffHighlightFilter and not CanDispel[playerClass] then
    return
  end

  -- make sure aura scanning is active for this object
  object:RegisterEvent("UNIT_AURA", Update)
  object:RegisterEvent("PLAYER_TALENT_UPDATE", CheckSpec)
  object:RegisterEvent("CHARACTER_POINTS_CHANGED", CheckSpec)
  CheckSpec()

  if object.DebuffHighlightBackdrop or object.DebuffHighlightBackdropBorder then
    local r, g, b, a = object:GetBackdropColor()
    origColors[object] = { r = r, g = g, b = b, a = a}
    r, g, b, a = object:GetBackdropBorderColor()
    origBorderColors[object] = { r = r, g = g, b = b, a = a}
  elseif not object.DebuffHighlightUseTexture then -- color debuffs
    -- object.DebuffHighlight
    local r, g, b, a = object.DebuffHighlight:GetVertexColor()
    origColors[object] = { r = r, g = g, b = b, a = a}
  end

  return true
end

local function Disable(object)
  if object.DebuffHighlightBackdrop or object.DebuffHighlightBackdropBorder or object.DebuffHighlight then
    object:UnregisterEvent("UNIT_AURA", Update)
    object:UnregisterEvent("PLAYER_TALENT_UPDATE", CheckSpec)
    object:UnregisterEvent("CHARACTER_POINTS_CHANGED", CheckSpec)
  end
end

oUF:AddElement('DebuffHighlight', Update, Enable, Disable)

for i, frame in ipairs(oUF.objects) do Enable(frame) end
