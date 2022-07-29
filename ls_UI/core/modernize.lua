local _, ns = ...
local E, C, PrC, D, PrD, M, L, P = ns.E, ns.C, ns.PrC, ns.D, ns.PrD, ns.M, ns.L, ns.P

-- Lua
local _G = getfenv(0)
local next = _G.next

-- Mine
local layouts = {"round", "rect"}
local layoutsOld = {"ls", "traditional"}
local unitsLayout = {"player", "pet"}
local unitsNonLayout = {"target", "targettarget", "focus", "focustarget", "boss"}
local bars = {"bar1", "bar2", "bar3", "bar4", "bar5", "bar6", "bar7", "pet_battle", "extra", "zone", "vehicle"}
local auras = {"HELPFUL", "HARMFUL", "TOTEM"}

function P:Modernize(data, name, key)
	if not data.version then return end

	if data.version < 8020003 then
		if key == "profile" then
			E:Print(L["PROFILE_GLOBAL_UPDATE_WARNING"]:format(name, data.version / 100))
		elseif key == "private" then
			E:Print(L["PROFILE_PRIVATE_UPDATE_WARNING"]:format(name, data.version / 100))
		end

		data.version = 8020003
	end

	if key == "global" then
		--> 90002.04
		if data.version < 9000204 then
			if data.fonts then
				if data.fonts.units then
					data.fonts.unit = E:CopyTable(data.fonts.units, data.fonts.unit)
					data.fonts.units = nil
				end

				if data.fonts.bars then
					data.fonts.button = E:CopyTable(data.fonts.bars, data.fonts.button)
					data.fonts.bars = nil
				end
			end

			data.version = 9000204
		end

		--> 90205.02
		if data.version < 9020502 then
			if data.colors then
				data.colors.gain = nil
				data.colors.loss = nil
			end

			-- forgot to remove these with 90205.01
			if data.tags then
				data.tags["ls:name:5"] = nil
				data.tags["ls:name:10"] = nil
				data.tags["ls:name:15"] = nil
				data.tags["ls:name:20"] = nil
			end

			data.version = 9020502
		end
	elseif key == "profile" then
		--> 90001.05
		if data.version < 9000105 then
			if data.units then
				for _, layout in next, layoutsOld do
					if data.units[layout] then
						for _, unit in next, unitsLayout do
							if data.units[layout][unit] then
								if data.units[layout][unit].health then
									if data.units[layout][unit].health.text then
										data.units[layout][unit].health.text.outline = nil
										data.units[layout][unit].health.text.shadow = nil
									end

									if data.units[layout][unit].health.prediction then
										if data.units[layout][unit].health.prediction.absorb_text then
											data.units[layout][unit].health.prediction.absorb_text.outline = nil
											data.units[layout][unit].health.prediction.absorb_text.shadow = nil
										end

										if data.units[layout][unit].health.prediction.heal_absorb_text then
											data.units[layout][unit].health.prediction.heal_absorb_text.outline = nil
											data.units[layout][unit].health.prediction.heal_absorb_text.shadow = nil
										end
									end
								end

								if data.units[layout][unit].power then
									if data.units[layout][unit].power.text then
										data.units[layout][unit].power.text.outline = nil
										data.units[layout][unit].power.text.shadow = nil
									end
								end

								if data.units[layout][unit].castbar then
									if data.units[layout][unit].castbar.text then
										data.units[layout][unit].castbar.text.outline = nil
										data.units[layout][unit].castbar.text.shadow = nil
									end
								end

								if data.units[layout][unit].name then
									data.units[layout][unit].name.outline = nil
									data.units[layout][unit].name.shadow = nil
								end

								if data.units[layout][unit].auras then
									if data.units[layout][unit].auras.cooldown then
										if data.units[layout][unit].auras.cooldown.text then
											data.units[layout][unit].auras.cooldown.text.outline = nil
											data.units[layout][unit].auras.cooldown.text.shadow = nil
										end
									end
								end
							end
						end
					end
				end

				for _, unit in next, unitsNonLayout do
					if data.units[unit] then
						if data.units[unit].health then
							if data.units[unit].health.text then
								data.units[unit].health.text.outline = nil
								data.units[unit].health.text.shadow = nil
							end

							if data.units[unit].health.prediction then
								if data.units[unit].health.prediction.absorb_text then
									data.units[unit].health.prediction.absorb_text.outline = nil
									data.units[unit].health.prediction.absorb_text.shadow = nil
								end

								if data.units[unit].health.prediction.heal_absorb_text then
									data.units[unit].health.prediction.heal_absorb_text.outline = nil
									data.units[unit].health.prediction.heal_absorb_text.shadow = nil
								end
							end
						end

						if data.units[unit].power then
							if data.units[unit].power.text then
								data.units[unit].power.text.outline = nil
								data.units[unit].power.text.shadow = nil
							end
						end

						if data.units[unit].castbar then
							if data.units[unit].castbar.text then
								data.units[unit].castbar.text.outline = nil
								data.units[unit].castbar.text.shadow = nil
							end
						end

						if data.units[unit].name then
							data.units[unit].name.outline = nil
							data.units[unit].name.shadow = nil
						end

						if data.units[unit].auras then
							if data.units[unit].auras.cooldown then
								if data.units[unit].auras.cooldown.text then
									data.units[unit].auras.cooldown.text.outline = nil
									data.units[unit].auras.cooldown.text.shadow = nil
								end
							end
						end
					end
				end
			end

			if data.bars then
				for _, bar in next, bars do
					if data.bars[bar] then
						if data.bars[bar].hotkey then
							data.bars[bar].hotkey.flag = nil
						end

						if data.bars[bar].macro then
							data.bars[bar].macro.flag = nil
						end

						if data.bars[bar].count then
							data.bars[bar].count.flag = nil
						end

						if data.bars[bar].cooldown then
							if data.bars[bar].cooldown.text then
								data.bars[bar].cooldown.text.flag = nil
							end
						end
					end
				end

				if data.bars.xpbar then
					if data.bars.xpbar.text then
						data.bars.xpbar.text.flag = nil
					end
				end
			end

			if data.auras then
				for _, aura in next, auras do
					if data.auras[aura] then
						if data.auras[aura].cooldown then
							if data.auras[aura].cooldown.text then
								data.auras[aura].cooldown.text.flag = nil
							end
						end
					end
				end
			end
		end

		--> 90002.04
		if data.version < 9000204 then
			if data.units then
				for _, layout in next, layoutsOld do
					if data.units[layout] then
						for _, unit in next, unitsLayout do
							if data.units[layout][unit] then
								if data.units[layout][unit].auras then
									if data.units[layout][unit].auras.count then
										data.units[layout][unit].auras.count.outline = nil
										data.units[layout][unit].auras.count.shadow = nil
									end
								end
							end
						end
					end
				end

				for _, unit in next, unitsNonLayout do
					if data.units[unit] then
						if data.units[unit].auras then
							if data.units[unit].auras.count then
								data.units[unit].auras.count.outline = nil
								data.units[unit].auras.count.shadow = nil
							end
						end
					end
				end
			end

			if data.auras then
				for _, aura in next, auras do
					if data.auras[aura] then
						if data.auras[aura].count then
							data.auras[aura].count.flag = nil
						end
					end
				end
			end

			if data.blizzard then
				if data.blizzard.digsite_bar then
					if data.blizzard.digsite_bar.text then
						data.blizzard.digsite_bar.text.flag = nil
					end
				end

				if data.blizzard.timer then
					if data.blizzard.timer.text then
						data.blizzard.timer.text.flag = nil
					end
				end
			end

			data.version = 9000204
		end

		--> 90002.06
		if data.version < 9000206 then
			if data.units then
				if data.units.ls then
					if data.units.ls.player then
						data.units.ls.player.name = nil
					end
				end

				if data.units.boss then
					if data.units.boss.alt_power then
						data.units.boss.alt_power.change_threshold = nil
					end
				end

				if data.units.targettarget then
					data.units.targettarget.custom_texts = nil
				end

				if data.units.focustarget then
					data.units.focustarget.custom_texts = nil
				end

				for _, layout in next, layoutsOld do
					if data.units[layout] then
						for _, unit in next, unitsLayout do
							if data.units[layout][unit] then
								if data.units[layout][unit].health then
									data.units[layout][unit].health.change_threshold = nil
								end

								if data.units[layout][unit].power then
									data.units[layout][unit].power.change_threshold = nil
								end

								if data.units[layout][unit].class_power then
									data.units[layout][unit].class_power.change_threshold = nil
								end


								if data.units[layout][unit].prediction then
									data.units[layout][unit].prediction.absorb_text = nil
									data.units[layout][unit].prediction.heal_absorb_text = nil
								end

								if data.units[layout][unit].pvp then
									data.units[layout][unit].pvp.point1 = nil
								end

								if data.units[layout][unit].insets then
									data.units[layout][unit].insets.t_height = nil
									data.units[layout][unit].insets.b_height = nil
								end

								if data.units[layout][unit].auras then
									if data.units[layout][unit].auras.count then
										data.units[layout][unit].auras.count.outline = nil
										data.units[layout][unit].auras.count.shadow = nil
									end
								end
							end
						end
					end
				end

				for _, unit in next, unitsNonLayout do
					if data.units[unit] then
						if data.units[unit].health then
							data.units[unit].health.change_threshold = nil
						end

						if data.units[unit].power then
							data.units[unit].power.change_threshold = nil
						end

						if data.units[unit].prediction then
							data.units[unit].prediction.absorb_text = nil
							data.units[unit].prediction.heal_absorb_text = nil
						end

						if data.units[unit].pvp then
							data.units[unit].pvp.point1 = nil
						end

						if data.units[unit].insets then
							data.units[unit].insets.t_height = nil
							data.units[unit].insets.b_height = nil
						end

						if data.units[unit].auras then
							if data.units[unit].auras.count then
								data.units[unit].auras.count.outline = nil
								data.units[unit].auras.count.shadow = nil
							end
						end
					end
				end
			end

			data.version = 9000206
		end

		--> 90005.01
		if data.version < 9000501 then
			if data.units then
				for _, layout in next, layoutsOld do
					if data.units[layout] then
						for _, unit in next, unitsLayout do
							if data.units[layout][unit] then
								if data.units[layout][unit].insets then
									data.units[layout][unit].insets.t_size = 0.25
								end
							end
						end
					end
				end

				for _, unit in next, unitsNonLayout do
					if data.units[unit] then
						if data.units[unit].insets then
							if data.units[unit].insets.t_size > 0.25 then
								data.units[unit].insets.t_size = 0.25
							end
						end
					end
				end
			end

			data.version = 9000501
		end

		--> 90005.04
		if data.version < 9000504 then
			if data.bars then
				for _, bar in next, bars do
					if data.bars[bar] then
						if data.bars[bar].fade then
							data.bars[bar].fade.in_delay = nil
						end
					end
				end
			end

			data.version = 9000504
		end

		--> 90105.02
		if data.version < 9010502 then
			if data.minimap then
				data.minimap.size = nil
				data.minimap.scale = nil
			end

			data.version = 9010502
		end

		--> 90105.04
		if data.version < 9010504 then
			if data.units then
				if data.units.ls then
					for _, unit in next, unitsLayout do
						if data.units.ls[unit] then
							if data.units.ls[unit].point then
								data.units.ls[unit].point.ls = nil
								data.units.ls[unit].point.traditional = nil
							end

							if not data.units.round then
								data.units.round = {}
							end

							data.units.round[unit] = E:CopyTable(data.units.ls[unit], data.units.round[unit])
							data.units.ls[unit] = nil
						end
					end

					data.units.ls = nil
				end

				if data.units.traditional then
					for _, unit in next, unitsLayout do
						if data.units.traditional[unit] then
							if data.units.traditional[unit].point then
								data.units.traditional[unit].point.ls = nil
								data.units.traditional[unit].point.traditional = nil
							end

							if not data.units.rect then
								data.units.rect = {}
							end

							data.units.rect[unit] = E:CopyTable(data.units.traditional[unit], data.units.rect[unit])
							data.units.traditional[unit] = nil
						end
					end

					data.units.traditional = nil
				end
			end

			if data.movers then
				if data.movers.ls then
					data.movers.round = E:CopyTable(data.movers.ls, data.movers.round)
					data.movers.ls = nil
				end

				if data.movers.traditional then
					data.movers.rect = E:CopyTable(data.movers.traditional, data.movers.rect)
					data.movers.traditional = nil
				end
			end

			if data.minimap then
				if data.minimap.ls then
					data.minimap.round = E:CopyTable(data.minimap.ls, data.minimap.round)
					data.minimap.ls = nil
				end

				if data.minimap.traditional then
					data.minimap.rect = E:CopyTable(data.minimap.traditional, data.minimap.rect)
					data.minimap.traditional = nil
				end
			end

			data.version = 9010504
		end

		--> 90200.02
		if data.version < 9020002 then
			if data.units then
				for _, layout in next, layouts do
					if data.units[layout] then
						for _, unit in next, unitsLayout do
							if data.units[layout][unit] then
								if data.units[layout][unit].auras then
									data.units[layout][unit].auras.width = data.units[layout][unit].auras.size_override
									data.units[layout][unit].auras.size_override = nil
								end
							end
						end
					end
				end

				for _, unit in next, unitsNonLayout do
					if data.units[unit] then
						if data.units[unit].auras then
							data.units[unit].auras.width = data.units[unit].auras.size_override
							data.units[unit].auras.size_override = nil
						end
					end
				end
			end

			if data.bars then
				for _, bar in next, bars do
					if data.bars[bar] then
						data.bars[bar].width = data.bars[bar].size
						data.bars[bar].size = nil
					end
				end
			end

			if data.auras then
				for _, aura in next, auras do
					if data.auras[aura] then
						data.auras[aura].width = data.auras[aura].size
						data.auras[aura].size = nil
					end
				end
			end

			data.version = 9020002
		end

		--> 90200.05
		if data.version < 9020005 then
			if data.movers then
				if data.movers.ls then
					data.movers.round = E:CopyTable(data.movers.ls, data.movers.round)
					data.movers.ls = nil
				end

				if data.movers.traditional then
					data.movers.rect = E:CopyTable(data.movers.traditional, data.movers.rect)
					data.movers.traditional = nil
				end

				for _, layout in next, layouts do
					if data.movers[layout] then
						for k, v in next, data.movers[layout] do
							if v.point then
								data.movers[layout][k] = {v.point[1], v.point[2], v.point[3], v.point[4], v.point[5]}
							end
						end
					end
				end
			end

			data.version = 9020005
		end

		--> 90205.02
		if data.version < 9020502 then
			if data.units then
				if data.units.change then
					data.units.change.animated = nil
				end
			end

			-- forgot to remove these with 90205.01
			if data.blizzard then
				if data.blizzard.castbar then
					if data.blizzard.castbar.text then
						data.blizzard.castbar.text.font = nil
						data.blizzard.castbar.text.outline = nil
						data.blizzard.castbar.text.shadow = nil
					end
				end
			end

			data.version = 9020502
		end
	elseif key == "private" then
		--> 90001.05
		if data.version < 9000105 then
			if data.auratracker then
				if data.auratracker.cooldown then
					if data.auratracker.cooldown.text then
						data.auratracker.cooldown.text.flag = nil
					end
				end
			end

			data.version = 9000105
		end

		--> 90002.01
		if data.version < 9000201 then
			if data.blizzard then
				data.blizzard.npe = nil
			end

			data.version = 9000201
		end

		--> 90002.04
		if data.version < 9000204 then
			if data.auratracker then
				if data.auratracker.count then
					data.auratracker.count.enabled = nil
					data.auratracker.count.outline = nil
					data.auratracker.count.shadow = nil
					data.auratracker.count.flag = nil
				end
			end

			data.version = 9000204
		end

		--> 90105.04
		if data.version < 9010504 then
			if data.layout == "ls" then
				data.layout = "round"
			elseif data.layout == "traditional" then
				data.layout = "rect"
			end

			if data.minimap then
				if data.minimap.ls then
					data.minimap.round = E:CopyTable(data.minimap.ls, data.minimap.round)
					data.minimap.ls = nil
				end

				if data.minimap.traditional then
					data.minimap.rect = E:CopyTable(data.minimap.traditional, data.minimap.rect)
					data.minimap.traditional = nil
				end
			end

			data.version = 9010504
		end

		--> 90200.02
		if data.version < 9020002 then
			if data.auratracker then
				data.auratracker.width = data.auratracker.size
				data.auratracker.size = nil
			end

			data.version = 9020002
		end
	end
end
