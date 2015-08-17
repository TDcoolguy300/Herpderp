/mob/living/carbon/human/proc/monkeyize()
	if (monkeyizing)
		return
	for(var/obj/item/W in src)
		if (W==w_uniform) // will be teared
			continue
		drop_from_slot(W)
	update_clothing()
	monkeyizing = 1
	canmove = 0
	icon = null
	invisibility = 101
	for(var/t in organs)
		del(t)
	var/atom/movable/overlay/animation = new /atom/movable/overlay( loc )
	animation.icon_state = "blank"
	animation.icon = 'mob.dmi'
	animation.master = src
	flick("h2monkey", animation)
	sleep(48)
	//animation = null
	var/mob/living/carbon/monkey/O = new /mob/living/carbon/monkey( loc )
	del(animation)

	O.name = "monkey"
	O.dna = dna
	dna = null
	O.dna.uni_identity = "00600200A00E0110148FC01300B009"
	//O.dna.struc_enzymes = "0983E840344C39F4B059D5145FC5785DC6406A4BB8"
	O.dna.struc_enzymes = "[copytext(O.dna.struc_enzymes,1,1+3*13)]BB8"
	O.loc = loc
	O.viruses = viruses
	viruses = list()
	for(var/datum/disease/D in O.viruses)
		D.affected_mob = O

	if (client)
		client.mob = O
	if(mind)
		mind.transfer_to(O)
	O.a_intent = "hurt"
	O << "<B>You are now a monkey.</B>"
	spawn(0)//To prevent the proc from returning null.
		del(src)
	return O

/mob/living/carbon/human/proc/corgize()
	if (monkeyizing)
		return
	for(var/obj/item/W in src)
		drop_from_slot(W)
	update_clothing()
	monkeyizing = 1
	canmove = 0
	icon = null
	invisibility = 101
	for(var/t in organs)
		del(t)

	var/mob/living/simple_animal/corgi/new_corgi = new /mob/living/simple_animal/corgi (loc)

	new_corgi.mind_initialize(src)
	new_corgi.key = key

	new_corgi.a_intent = "hurt"
	new_corgi << "<B>You are now a Corgi!.</B>"
	spawn(0)//To prevent the proc from returning null.
		del(src)
	return