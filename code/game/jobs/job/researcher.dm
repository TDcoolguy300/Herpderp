/datum/job/researcher
	title = "Researcher"
	flag = RESEARCHER
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 2
	spawn_positions = 2
	supervisors = "Expedition Leader"
	selection_color = "#ffeeff"


	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		H.equip_if_possible(new /obj/item/clothing/under/lawyer/bluesuit(H), H.slot_w_uniform)
		H.equip_if_possible(new /obj/item/clothing/suit/labcoat(H), H.slot_wear_suit)
		H.equip_if_possible(new /obj/item/clothing/shoes/black(H), H.slot_shoes)
		return 1