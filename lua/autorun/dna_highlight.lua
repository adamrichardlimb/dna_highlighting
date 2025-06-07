local function has_dna(ent)
  if not IsValid(ent) or ent:IsPlayer() then return false end
  if ent:GetClass() == "prop_ragdoll" and ent.killer_sample and ent.killer_sample.t > CurTime() then
    return true
  end
  return istable(ent.fingerprints) and #ent.fingerprints > 0 and (ent.AllowDrop or ent:GetClass() == "ent_blood_dna")
end

if CLIENT then
  highlighted_entities = {}

  hook.Add("TTTBeginRound", "ClearDNAHighlights", function()
    highlighted_entities = {}
  end)

  hook.Add("PreDrawHalos", "highlight_dna", function()
    local ply = LocalPlayer()
    if not IsValid(ply) then return end

    local halo_ents = {}
    local fade_start, fade_end = 0, 300

    for _, ent in ipairs(highlighted_entities) do
      if IsValid(ent) then
        local dist = ply:GetPos():Distance(ent:GetPos())
        if dist < fade_end then
          local t = math.Remap(dist, fade_start, fade_end, 0.1, 1)
          local smooth = 1 - math.ease.InOutQuad(t)
          local alpha = 255 * smooth

          if alpha > 5 then -- prevent black halos
            table.insert(halo_ents, {ent, alpha})
          end
        end
      end
    end

    for _, data in ipairs(halo_ents) do
      halo.Add({data[1]}, Color(0, 255, 0, data[2]), 3, 1, 1, true, false)
    end
  end)


  net.Receive("dna_highlights", function (len)
    entities_to_highlight = net.ReadEntity()
    table.insert(highlighted_entities, entities_to_highlight)
  end)
else
	-- Declare that we will be sending a table to the players
	util.AddNetworkString("dna_highlights")

  hook.Add("OnEntityCreated", "SendDNAEntities", function(ent)
    timer.Simple(0, function()
      if has_dna(ent) then
        local detectives = {}
        net.Start("dna_highlights")
        net.WriteEntity(ent)
        for index, player in ipairs(player.GetAll()) do
		      if player:IsActiveDetective() then table.insert(detectives, player) end
	      end
        -- Broadcast to all for now
        net.Send(detectives)
      end
    end)
  end)
end
