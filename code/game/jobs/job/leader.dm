/datum/job/leader
	title = "Expedition Leader"
	flag = LEADER
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "Trasen-North Corporation"
	selection_color = "#ffeeba"


	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		H.equip_if_possible(new /obj/item/clothing/under/det(H), H.slot_w_uniform)
		H.equip_if_possible(new /obj/item/clothing/shoes/brown(H), H.slot_shoes)
		H.equip_if_possible(new /obj/item/weapon/gun/projectile/mateba(H), H.slot_belt)
		return 1