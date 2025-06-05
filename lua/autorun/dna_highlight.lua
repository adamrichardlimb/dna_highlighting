local function has_dna(ent)
  if not IsValid(ent) or ent:IsPlayer() then return false end
  if ent:GetClass() == "prop_ragdoll" and ent.killer_sample and ent.killer_sample.t > CurTime() then
    return true
  end
  return istable(ent.fingerprints) and #ent.fingerprints > 0
end

if CLIENT then
  highlighted_entities = {}

  hook.Add("TTTBeginRound", "ClearDNAHighlights", function()
    highlighted_entities = {}
  end)
else
  hook.Add("OnEntityCreated", "SendDNAEntities", function(ent)
    timer.Simple(0, function()
      if has_dna(ent) then
        print("We have DNA!")
        print(ent)
      end
    end)
  end)
end

