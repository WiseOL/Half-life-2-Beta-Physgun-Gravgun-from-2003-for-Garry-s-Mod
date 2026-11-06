local lifetime = 0.4
local inv = 1 / lifetime

function EFFECT:Init(data)
	local ent = data:GetEntity() 
	self.Scale = 1

	if(ent:IsWeapon() && ent:IsCarriedByLocalPlayer()) then
		local ply = ent:GetOwner()

		if(!ply:ShouldDrawLocalPlayer()) then
			local vm = ply:GetViewModel()
			
			if(IsValid(vm)) then
				ent = vm
			end
		end
	end

	self.EndPos = data:GetOrigin()
	self.Att = data:GetAttachment()
	self.Ent = ent

	self.DieTime = CurTime() + lifetime

	self.StartAlpha = math.random(10, 50)
end

local MAT = Material("sprites/bluelaser1")

function EFFECT:Render()
	local x = math.sin((self.DieTime - CurTime()) * inv)
	render.SetMaterial(MAT)
	render.DrawBeam(self.Ent:GetAttachment(self.Att).Pos, self.EndPos, x * 16, 0, 1, Color(255,0,0))
end

function EFFECT:Think()
	if(!IsValid(self.Ent)) then return false end

	self:SetRenderBoundsWS(self.Ent:GetAttachment(self.Att).Pos, self.EndPos)
	return self.DieTime > CurTime()
end