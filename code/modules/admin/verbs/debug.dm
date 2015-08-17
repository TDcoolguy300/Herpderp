/client/proc/Debug2()
	set category = "Debug"
	set name = "Debug-Game"
	if(!authenticated || !holder)
		src << "Only administrators may use this command."
		return
	if(holder.rank == "Game Admin")
		Debug2 = !Debug2

		world << "Debugging [Debug2 ? "On" : "Off"]"
		log_admin("[key_name(src)] toggled debugging to [Debug2]")
	else if(holder.rank == "Game Master")
		Debug2 = !Debug2

		world << "Debugging [Debug2 ? "On" : "Off"]"
		log_admin("[key_name(src)] toggled debugging to [Debug2]")
	else
		alert("Coders only baby")
		return



/* 21st Sept 2010
Updated by Skie -- Still not perfect but better!
Stuff you can't do:
Call proc /mob/proc/make_dizzy() for some player
Because if you select a player mob as owner it tries to do the proc for
/mob/living/carbon/human/ instead. And that gives a run-time error.
But you can call procs that are of type /mob/living/carbon/human/proc/ for that player.
*/

/client/proc/callproc()
	set category = "Debug"
	set name = "Advanced ProcCall"
	if(!authenticated || !holder)
		src << "Only administrators may use this command."
		return
	var/target = null
	var/lst[] // List reference
	lst = new/list() // Make the list
	var/returnval = null
	var/class = null

	switch(alert("Proc owned by something?",,"Yes","No"))
		if("Yes")
			class = input("Proc owned by...","Owner") in list("Obj","Mob","Area or Turf","Client","CANCEL ABORT STOP")
			switch(class)
				if("CANCEL ABORT STOP")
					return
				if("Obj")
					target = input("Enter target:","Target",usr) as obj in world
				if("Mob")
					target = input("Enter target:","Target",usr) as mob in world
				if("Area or Turf")
					target = input("Enter target:","Target",usr.loc) as area|turf in world
				if("Client")
					var/list/keys = list()
					for(var/mob/M in world)
						keys += M.client
					target = input("Please, select a player!", "Selection", null, null) as null|anything in keys
		if("No")
			target = null

	var/procname = input("Proc path, eg: /proc/fake_blood","Path:", null)

	var/argnum = input("Number of arguments","Number:",0) as num

	lst.len = argnum // Expand to right length

	var/i
	for(i=1, i<argnum+1, i++) // Lists indexed from 1 forwards in byond

		// Make a list with each index containing one variable, to be given to the proc
		class = input("What kind of variable?","Variable Type") in list("text","num","type","reference","mob reference","icon","file","client","mob's area","CANCEL")
		switch(class)
			if("CANCEL")
				return

			if("text")
				lst[i] = input("Enter new text:","Text",null) as text

			if("num")
				lst[i] = input("Enter new number:","Num",0) as num

			if("type")
				lst[i] = input("Enter type:","Type") in typesof(/obj,/mob,/area,/turf)

			if("reference")
				lst[i] = input("Select reference:","Reference",src) as mob|obj|turf|area in world

			if("mob reference")
				lst[i] = input("Select reference:","Reference",usr) as mob in world

			if("file")
				lst[i] = input("Pick file:","File") as file

			if("icon")
				lst[i] = input("Pick icon:","Icon") as icon

			if("client")
				var/list/keys = list()
				for(var/mob/M in world)
					keys += M.client
				lst[i] = input("Please, select a player!", "Selection", null, null) as null|anything in keys

			if("mob's area")
				var/mob/temp = input("Select mob", "Selection", usr) as mob in world
				lst[i] = temp.loc


	spawn(0)
		if(target)
			log_admin("[key_name(src)] called [target]'s [procname]() with [lst.len ? "the arguments [list2params(lst)]":"no arguments"].")
			returnval = call(target,procname)(arglist(lst)) // Pass the lst as an argument list to the proc
		else
			log_admin("[key_name(src)] called [procname]() with [lst.len ? "the arguments [list2params(lst)]":"no arguments"].")
			returnval = call(procname)(arglist(lst)) // Pass the lst as an argument list to the proc
	usr << "\blue Proc returned: [returnval ? returnval : "null"]"

/*
/client/proc/cmd_admin_monkeyize(var/mob/M in world)
	set category = "Fun"
	set name = "Make Monkey"

	if(!ticker)
		alert("Wait until the game starts")
		return
	if(istype(M, /mob/living/carbon/human))
		var/mob/living/carbon/human/target = M
		log_admin("[key_name(src)] is attempting to monkeyize [M.key].")
		spawn(10)
			target.monkeyize()
	else
		alert("Invalid mob")

/client/proc/cmd_admin_changelinginize(var/mob/M in world)
	set category = "Fun"
	set name = "Make Changeling"

	if(!ticker)
		alert("Wait until the game starts")
		return
	if(istype(M, /mob/living/carbon/human))
		log_admin("[key_name(src)] has made [M.key] a changeling.")
		spawn(10)
			M.absorbed_dna[M.real_name] = M.dna
			M.make_changeling()
			if(M.mind)
				M.mind.special_role = "Changeling"
	else
		alert("Invalid mob")
*/
/*
/client/proc/cmd_admin_abominize(var/mob/M in world)
	set category = null
	set name = "Make Abomination"

	usr << "Ruby Mode disabled. Command aborted."
	return
	if(!ticker)
		alert("Wait until the game starts.")
		return
	if(istype(M, /mob/living/carbon/human))
		log_admin("[key_name(src)] has made [M.key] an abomination.")

	//	spawn(10)
	//		M.make_abomination()

*/
/*
/client/proc/make_cultist(var/mob/M in world) // -- TLE, modified by Urist
	set category = "Fun"
	set name = "Make Cultist"
	set desc = "Makes target a cultist"
	if(!wordtravel)
		runerandom()
	if(M)
		if(M.mind in ticker.mode.cult)
			return
		else
			if(alert("Spawn that person a tome?",,"Yes","No")=="Yes")
				M << "\red You catch a glimpse of the Realm of Nar-Sie, The Geometer of Blood. You now see how flimsy the world is, you see that it should be open to the knowledge of Nar-Sie. A tome, a message from your new master, appears on the ground."
				new /obj/item/weapon/tome(M.loc)
			else
				M << "\red You catch a glimpse of the Realm of Nar-Sie, The Geometer of Blood. You now see how flimsy the world is, you see that it should be open to the knowledge of Nar-Sie."
			var/glimpse=pick("1","2","3","4","5","6","7","8")
			switch(glimpse)
				if("1")
					M << "\red You remembered one thing from the glimpse... [wordtravel] is travel..."
				if("2")
					M << "\red You remembered one thing from the glimpse... [wordblood] is blood..."
				if("3")
					M << "\red You remembered one thing from the glimpse... [wordjoin] is join..."
				if("4")
					M << "\red You remembered one thing from the glimpse... [wordhell] is Hell..."
				if("5")
					M << "\red You remembered one thing from the glimpse... [worddestr] is destroy..."
				if("6")
					M << "\red You remembered one thing from the glimpse... [wordtech] is technology..."
				if("7")
					M << "\red You remembered one thing from the glimpse... [wordself] is self..."
				if("8")
					M << "\red You remembered one thing from the glimpse... [wordsee] is see..."

			if(M.mind)
				M.mind.special_role = "Cultist"
				ticker.mode.cult += M.mind
			src << "Made [M] a cultist."
*/

/client/proc/cmd_debug_del_all()
	set category = "Debug"
	set name = "Del-All"

	// to prevent REALLY stupid deletions
	var/blocked = list(/obj, /mob, /mob/living, /mob/living/carbon, /mob/living/carbon/human)
	var/hsbitem = input(usr, "Choose an object to delete.", "Delete:") as null|anything in typesof(/obj) + typesof(/mob) - blocked
	if(hsbitem)
		for(var/atom/O in world)
			if(istype(O, hsbitem))
				del(O)
		log_admin("[key_name(src)] has deleted all instances of [hsbitem].")
		message_admins("[key_name_admin(src)] has deleted all instances of [hsbitem].", 0)

/client/proc/cmd_debug_make_powernets()
	set category = "Debug"
	set name = "Make Powernets"
	makepowernets()
	log_admin("[key_name(src)] has remade the powernet. makepowernets() called.")
	message_admins("[key_name_admin(src)] has remade the powernets. makepowernets() called.", 0)

/client/proc/cmd_debug_tog_aliens()
	set category = "Server"
	set name = "Toggle Aliens"

	aliens_allowed = !aliens_allowed
	log_admin("[key_name(src)] has turned aliens [aliens_allowed ? "on" : "off"].")
	message_admins("[key_name_admin(src)] has turned aliens [aliens_allowed ? "on" : "off"].", 0)

/client/proc/cmd_admin_grantfullaccess(var/mob/M in world)
	set category = "Admin"
	set name = "Grant Full Access"

	if (!ticker)
		alert("Wait until the game starts")
		return
	if (istype(M, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		if (H.wear_id)
			var/obj/item/weapon/card/id/id = H.wear_id
			if(istype(H.wear_id, /obj/item/device/pda))
				var/obj/item/device/pda/pda = H.wear_id
				id = pda.id
			log_admin("[key_name(src)] has granted [M.key] full access.")
			id.icon_state = "gold"
			id:access = get_all_accesses()+get_all_centcom_access()+get_all_syndicate_access()
		else
			var/obj/item/weapon/card/id/id = new/obj/item/weapon/card/id(M);
			log_admin("[key_name(src)] has granted [M.key] full access.")
			id.icon_state = "gold"
			id:access = get_all_accesses()+get_all_centcom_access()+get_all_syndicate_access()
			id.registered = H.real_name
			id.assignment = "Captain"
			id.name = "[id.registered]'s ID Card ([id.assignment])"
			H.equip_if_possible(id, H.slot_wear_id)
			H.update_clothing()
	else
		alert("Invalid mob")

/client/proc/cmd_switch_radio()
	set category = "Debug"
	set name = "Switch Radio Mode"
	set desc = "Toggle between normal radios and experimental radios. Have a coder present if you do this."

	GLOBAL_RADIO_TYPE = !GLOBAL_RADIO_TYPE // toggle
	log_admin("[key_name(src)] has turned the experimental radio system [GLOBAL_RADIO_TYPE ? "on" : "off"].")
	message_admins("[key_name_admin(src)] has turned the experimental radio system [GLOBAL_RADIO_TYPE ? "on" : "off"].", 0)





/client/proc/cmd_admin_dress(var/mob/living/carbon/human/M in world)
	set category = "Fun"
	set name = "Select equipment"
	if(!ishuman(M))
		alert("Invalid mob")
		return
	//log_admin("[key_name(src)] has alienized [M.key].")
	var/list/dresspacks = list(
		"strip",
		"make snowy",
		"masked killer"
		)
	var/dresscode = input("Select dress for [M]", "Robust quick dress shop") as null|anything in dresspacks
	if (isnull(dresscode))
		return
	if(dresscode != "make snowy")
		for (var/obj/item/I in M)
			del(I)
	switch(dresscode)
		if ("strip")
			//do nothing
		if("masked killer")
			M.equip_if_possible(new /obj/item/clothing/under/overalls(M), M.slot_w_uniform)
			M.equip_if_possible(new /obj/item/clothing/shoes/black(M), M.slot_shoes)
			M.equip_if_possible(new /obj/item/clothing/gloves/latex(M), M.slot_gloves)
			M.equip_if_possible(new /obj/item/clothing/mask/surgical(M), M.slot_wear_mask)
			M.equip_if_possible(new /obj/item/clothing/head/helmet/welding(M), M.slot_head)
			M.equip_if_possible(new /obj/item/clothing/suit/apron(M), M.slot_wear_suit)

			var/obj/item/weapon/fireaxe/fire_axe = new(M)
			fire_axe.name = "Fire Axe (Unwielded)"
			M.equip_if_possible(fire_axe, M.slot_r_hand)

	M.update_clothing()
	return
