-- the function of this file is all LotI related, and used in stats.lua
--local helper = z_require("my_helper")
local constants = {}
constants.all_sorts = Set{"other", "exotic", "gold", "potion", "limited", "armour", "gauntlets", "helm","boots","cloak","amulet","ring","sword","axe","bow","staff","xbow","dagger","knife","mace","polearm","claws","sling","spear"}
constants.geared_sorts = Set{"exotic", "limited", "armour", "gauntlets", "helm","boots","cloak","amulet","ring","sword","axe","bow","staff","xbow","dagger","knife","mace","polearm","claws","sling","spear"}
constants.weapon_sorts = Set{"sword","axe","bow","staff","xbow","dagger","knife","mace","polearm","claws","sling","spear"}
constants.armour_sorts = Set{"armour", "gauntlets", "helm","boots","cloak","amulet","ring"}
constants.melee_weapon_sorts = Set{"sword","axe","staff","dagger","mace","polearm","claws","spear"}
constants.ranged_weapon_sorts = Set{"bow","xbow","knife","sling"}
constants.non_weaon_sorts = Set{"gold", "potion", "limited", "armour", "gauntlets", "helm","boots","cloak","amulet","ring"}

constants.sort_of_weapons = {["sword"] = "sword", ["short sword"] = "sword", ["greatsword"] = "sword", ["saber"] = "sword", ["mberserk"] = "sword", ["whirlwind"] = "sword", ["axe"] = "axe", ["hatchet"] = "axe", ["battle axe"] = "axe", ["axe whirlwind"] = "axe", ["berserker frenzy"] = "axe", ["cleaver"] = "axe", ["bow"] = "bow", ["longbow"] = "bow", ["staff"] = "staff", ["plague staff"] = "staff", ["crossbow"] = "xbow", ["slurbow"] = "xbow", ["dagger"] = "dagger", ["knife"] = "knife", ["throwing knife"] = "knife", ["mace"] = "mace", ["mace-spiked"] = "mace", ["morning star"] = "mace", ["club"] = "mace", ["flail"] = "mace", ["scourge"] = "mace", ["mace_berserk"] = "mace", ["hammer"] = "mace", ["hammer-runic"] = "mace", ["spear"] = "spear", ["javelin"] = "spear", ["lance"] = "spear", ["spike"] = "spear", ["pike"] = "spear", ["trident"] = "spear", ["trident-blade"] = "spear", ["fist"] = "other", ["touch"] = "other", ["faerie touch"] = "other", ["slam"] = "other", ["crush"] = "other", ["ram"] = "other", ["fangs"] = "other", ["tentacle"] = "other", ["bite"] = "other", ["tail"] = "other", ["sting"] = "other", ["jaw"] = "other", ["net"] = "other", ["war talon"] = "exotic", ["war blade"] = "exotic", ["halberd"] = "polearm", ["scythe"] = "polearm", ["whirlwind-scythe"] = "polearm", ["claws"] = "claws", ["battle claws"] = "claws", ["sling"] = "sling", ["bolas"] = "sling", ["thorns"] = "magic", ["gossamer"] = "magic", ["wine"] = "magic", ["wine whip"] = "magic", ["entangle"] = "magic", ["ensnare"] = "magic", ["water spray"] = "magic", ["ink"] = "magic", ["magic blast"] = "magic"}
--this set dooes not contain impassable
constants.all_terrains = Set{"fungus", "swamp_water", "forest", "hills", "mountains", "castle", "cave", "village", "coastal_reef", "shallow_water", "deep_water", "swamp_water", "frozen", "sand", "flat", "cave", "unwalkable", "swamp_water"}
constants.all_damage_types = Set{"arcane", "cold", "fire", "blade" , "pierce", "impact"}
constants.weapon_bonuses = Set{"damage", "suck", "damage_plus", "attacks" ,"icon", "merge", "damage_type", "name"}
constants.weapon_speacial_abilites = Set{"firststrike", "poison", "attacks" ,"slow", "plague" ,"chance_to_hit", "berserk", "damage", "dummy", "drains", "swarm"}
constants.item_list_object = helper.get_variable_array("item_list.object")
constants.item_by_number = {}

for i=1,#constants.item_list_object do
	constants.item_by_number[constants.item_list_object[i].number] = i
end

constants.get_object_by_number = function(number)
	return constants.item_list_object[constants.item_by_number[number]]
end



return constants