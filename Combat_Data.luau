local Combat_Animation_Functions = require(script.Parent.Combat_Animation_Functions)
--- NOTE: if a Attack Damages multiple times split the damage up in to pieces

return table.freeze({
	SukunaV1 = {
		Name = "SukunaV1",
		M1s = {
			[1] = {
				Animation = "Animation", --> will be an id
				Damage = 5,
				HitBoxSize = Vector3.new(8, 8, 8), -- idk if i want to keep m1s this simple
				Offset = Vector3.new(4, 0, 0),
			},
			[2] = {
				Animation = "Animation",
				Damage = 5,
				HitBoxSize = Vector3.new(8, 8, 8),
				Offset = Vector3.new(4, 0, 0),
			},
			[3] = {
				Animation = "Animation",
				Damage = 5,
				HitBoxSize = Vector3.new(8, 8, 8),
				Offset = Vector3.new(4, 0, 0),
			},
			[4] = {
				Animation = "Animation",
				Damage = 5,
				HitBoxSize = Vector3.new(8, 8, 8),
				Offset = Vector3.new(4, 0, 0),
			},
		},

		Abilitys = {
			Ability2 = {
				Base_Couldown = 15,
				Aktiv_Time = 9,
				Animation = "rbxassetid://118590644732874",
				Clinet_Init = function(self, character: Model)
					print(self, character)
					Combat_Animation_Functions:Sukuna_SlashAura(character, self.Animation)
				end,
				Attack_Function = function(Owner: Player, ...) end,
			},
			Ability3 = { --> Testingwise
				Base_Couldown = 15,
				Aktiv_Time = 9,
				Animation = "rbxassetid://118590644732874",
				Clinet_Init = function(self, character: Model)
					print(self, character)
					Combat_Animation_Functions:Sukuna_SlashAura(character, self.Animation)
				end,
				Attack_Function = function(Owner: Player, ...) end,
			},
		},
	},
})
