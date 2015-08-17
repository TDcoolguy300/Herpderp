datum/mind
	var/key
	var/mob/living/current
	var/mob/living/original

	var/memory
	//TODO: store original name --rastaf0

	var/assigned_role
	var/special_role

	var/datum/job/assigned_job

	var/list/datum/objective/objectives = list()
	var/list/datum/objective/special_verbs = list()

	var/has_been_rev = 0//Tracks if this mind has been a rev or not

	proc/transfer_to(mob/new_character)
		if(current)
			current.mind = null

		new_character.mind = src
		current = new_character

		new_character.key = key

	proc/store_memory(new_text)
		memory += "[new_text]<BR>"

	proc/show_memory(mob/recipient)
		var/output = "<B>[current.real_name]'s Memory</B><HR>"
		output += memory

		if(objectives.len>0)
			output += "<HR><B>Objectives:</B>"

			var/obj_count = 1
			for(var/datum/objective/objective in objectives)
				output += "<B>Objective #[obj_count]</B>: [objective.explanation_text]"
				obj_count++

		recipient << browse(output,"window=memory")

	proc/edit_memory()
		var/out = "<B>[current.real_name]</B><br>"
		out += "Assigned role: [assigned_role]. <a href='?src=\ref[src];role_edit=1'>Edit</a><br>"
		out += "Factions and special roles:<br>"

		var/list/sections = list(
			"revolution",
			"cult",
			"wizard",
			"changeling",
			"nuclear",
			"traitor", // "traitorchan",
			"monkey",
			"malfunction",
		)
		var/text = ""

		if (istype(current, /mob/living/carbon/human) || istype(current, /mob/living/carbon/monkey))
			/** CHANGELING ***/
			text = "changeling"
			if (ticker.mode.config_tag=="changeling" || ticker.mode.config_tag=="traitorchan")
				text = uppertext(text)
			text = "<i><b>[text]</b></i>: "
			if (src in ticker.mode.changelings)
				text += "<b>YES</b>|<a href='?src=\ref[src];changeling=clear'>no</a>"
				if (objectives.len==0)
					text += "<br>Objectives are empty! <a href='?src=\ref[src];changeling=autoobjectives'>Randomize!</a>"
				if (current.changeling && (current.changeling.absorbed_dna.len>0 && current.real_name != current.changeling.absorbed_dna[1]))
					text += "<br><a href='?src=\ref[src];changeling=initialdna'>Transform to initial appearance.</a>"
			else
				text += "<a href='?src=\ref[src];changeling=changeling'>yes</a>|<b>NO</b>"
//			var/datum/game_mode/changeling/changeling = ticker.mode
//			if (istype(changeling) && changeling.changelingdeath)
//				text += "<br>All the changelings are dead! Restart in [round((changeling.TIME_TO_GET_REVIVED-(world.time-changeling.changelingdeathtime))/10)] seconds."
			sections["changeling"] = text

		/** TRAITOR ***/
		text = "traitor"
		if (ticker.mode.config_tag=="traitor" || ticker.mode.config_tag=="traitorchan")
			text = uppertext(text)
		text = "<i><b>[text]</b></i>: "
		if (src in ticker.mode.traitors)
			text += "<b>TRAITOR</b>|<a href='?src=\ref[src];traitor=clear'>loyal</a>"
			if (objectives.len==0)
				text += "<br>Objectives are empty! <a href='?src=\ref[src];traitor=autoobjectives'>Randomize</a>!"
		else
			text += "<a href='?src=\ref[src];traitor=traitor'>traitor</a>|<b>LOYAL</b>"
		sections["traitor"] = text

		/** MONKEY ***/
		if (istype(current, /mob/living/carbon))
			text = "monkey"
			if (ticker.mode.config_tag=="monkey")
				text = uppertext(text)
			text = "<i><b>[text]</b></i>: "
			if (istype(current, /mob/living/carbon/human))
				text += "<a href='?src=\ref[src];monkey=healthy'>healthy</a>|<a href='?src=\ref[src];monkey=infected'>infected</a>|<b>HUMAN</b>|other"
			else if (istype(current, /mob/living/carbon/monkey))
				var/found = 0
				for(var/datum/disease/D in current.viruses)
					if(istype(D, /datum/disease/jungle_fever)) found = 1

				if(found)
					text += "<a href='?src=\ref[src];monkey=healthy'>healthy</a>|<b>INFECTED</b>|<a href='?src=\ref[src];monkey=human'>human</a>|other"
				else
					text += "<b>HEALTHY</b>|<a href='?src=\ref[src];monkey=infected'>infected</a>|<a href='?src=\ref[src];monkey=human'>human</a>|other"

			else
				text += "healthy|infected|human|<b>OTHER</b>"
			sections["monkey"] = text

		if (ticker.mode.config_tag == "traitorchan")
			if (sections["traitor"])
				out += sections["traitor"]+"<br>"
			if (sections["changeling"])
				out += sections["changeling"]+"<br>"
			sections -= "traitor"
			sections -= "changeling"
		else
			if (sections[ticker.mode.config_tag])
				out += sections[ticker.mode.config_tag]+"<br>"
			sections -= ticker.mode.config_tag
		for (var/i in sections)
			if (sections[i])
				out += sections[i]+"<br>"


		if (((src in ticker.mode.traitors) && istype(current,/mob/living/carbon/human)))

			text = "Uplink: <a href='?src=\ref[src];common=uplink'>give</a>"
			var/obj/item/weapon/syndicate_uplink/suplink = find_syndicate_uplink()
			var/obj/item/weapon/integrated_uplink/iuplink = find_integrated_uplink()
			var/crystals
			if (suplink)
				crystals = suplink.uses
			else if (iuplink)
				crystals = iuplink.uses
			if (suplink || iuplink)
				text += "|<a href='?src=\ref[src];common=takeuplink'>take</a>"
				if (usr.client.holder.level >= 3)
					text += ", <a href='?src=\ref[src];common=crystals'>[crystals]</a> crystals"
				else
					text += ", [crystals] crystals"
			text += "." //hiel grammar
			out += text

		out += "<br>"

		out += "<b>Memory:</b><br>"
		out += memory
		out += "<br><a href='?src=\ref[src];memory_edit=1'>Edit memory</a><br>"
		out += "Objectives:<br>"
		if (objectives.len == 0)
			out += "EMPTY<br>"
		else
			var/obj_count = 1
			for(var/datum/objective/objective in objectives)
				out += "<B>[obj_count]</B>: [objective.explanation_text] <a href='?src=\ref[src];obj_edit=\ref[objective]'>Edit</a> <a href='?src=\ref[src];obj_delete=\ref[objective]'>Delete</a><br>"
				obj_count++
		out += "<a href='?src=\ref[src];obj_add=1'>Add objective</a><br><br>"

		out += "<a href='?src=\ref[src];obj_announce=1'>Announce objectives</a><br><br>"

		usr << browse(out, "window=edit_memory[src]")

	Topic(href, href_list)

		if (href_list["role_edit"])
			var/new_role = input("Select new role", "Assigned role", assigned_role) as null|anything in get_all_jobs()
			if (!new_role) return
			assigned_role = new_role

		else if (href_list["memory_edit"])
			var/new_memo = input("Write new memory", "Memory", memory) as null|message
			if (isnull(new_memo)) return
			memory = new_memo

		else if (href_list["obj_edit"] || href_list["obj_add"])
			var/datum/objective/objective
			var/objective_pos
			var/def_value

			if (href_list["obj_edit"])
				objective = locate(href_list["obj_edit"])
				if (!objective) return
				objective_pos = objectives.Find(objective)

				//Text strings are easy to manipulate. Revised for simplicity.
				var/temp_obj_type = "[objective.type]"//Convert path into a text string.
				def_value = copytext(temp_obj_type, 19)//Convert last part of path into an objective keyword.
				if(!def_value)//If it's a custom objective, it will be an empty string.
					def_value = "custom"

			var/new_obj_type = input("Select objective type:", "Objective type", def_value) as null|anything in list("assassinate", "debrain", "protect", "hijack", "escape", "survive", "steal", "download", "nuclear", "capture", "absorb", "custom")
			if (!new_obj_type) return

			var/datum/objective/new_objective = null

			switch (new_obj_type)
				if ("assassinate","protect","debrain")
					//To determine what to name the objective in explanation text.
					var/objective_type_capital = uppertext(copytext(new_obj_type, 1,2))//Capitalize first letter.
					var/objective_type_text = copytext(new_obj_type, 2)//Leave the rest of the text.
					var/objective_type = "[objective_type_capital][objective_type_text]"//Add them together into a text string.

					var/list/possible_targets = list("Free objective")
					for(var/datum/mind/possible_target in ticker.minds)
						if ((possible_target != src) && istype(possible_target.current, /mob/living/carbon/human))
							possible_targets += possible_target.current

					var/mob/def_target = null
					var/objective_list[] = list(/datum/objective/assassinate, /datum/objective/protect, /datum/objective/debrain)
					if (objective&&(objective.type in objective_list) && objective:target)
						def_target = objective:target.current

					var/new_target = input("Select target:", "Objective target", def_target) as null|anything in possible_targets
					if (!new_target) return

					var/objective_path = text2path("/datum/objective/[new_obj_type]")
					if (new_target == "Free objective")
						new_objective = new objective_path
						new_objective.owner = src
						new_objective:target = null
						new_objective.explanation_text = "Free objective"
					else
						new_objective = new objective_path
						new_objective.owner = src
						new_objective:target = new_target:mind
						//Will display as special role if the target is set as MODE. commandos/nuke ops.
						new_objective.explanation_text = "[objective_type] [new_target:real_name], the [new_target:mind:assigned_role=="MODE" ? (new_target:mind:special_role) : (new_target:mind:assigned_role)]."

				if ("hijack")
					new_objective = new /datum/objective/hijack
					new_objective.owner = src

				if ("escape")
					new_objective = new /datum/objective/escape
					new_objective.owner = src

				if ("survive")
					new_objective = new /datum/objective/survive
					new_objective.owner = src

				if ("nuclear")
					new_objective = new /datum/objective/nuclear
					new_objective.owner = src

				if ("steal")
					if (!istype(objective, /datum/objective/steal))
						new_objective = new /datum/objective/steal
						new_objective.owner = src
					else
						new_objective = objective
					var/datum/objective/steal/steal = new_objective
					if (!steal.select_target())
						return

				if("capture","absorb")
					var/def_num
					if(objective&&objective.type==text2path("/datum/objective/[new_obj_type]"))
						def_num = objective.target_amount

					var/target_number = input("Input target number:", "Objective", def_num) as num|null
					if (isnull(target_number))//Ordinarily, you wouldn't need isnull. In this case, the value may already exist.
						return

					switch(new_obj_type)
						if("capture")
							new_objective = new /datum/objective/capture
							new_objective.explanation_text = "Accumulate [target_number] capture points."
						if("absorb")
							new_objective = new /datum/objective/absorb
							new_objective.explanation_text = "Absorb [target_number] compatible genomes."
					new_objective.owner = src
					new_objective.target_amount = target_number

				if ("custom")
					var/expl = input("Custom objective:", "Objective", objective ? objective.explanation_text : "") as text|null
					if (!expl) return
					new_objective = new /datum/objective
					new_objective.owner = src
					new_objective.explanation_text = expl

			if (!new_objective) return

			if (objective)
				objectives -= objective
				objectives.Insert(objective_pos, new_objective)
			else
				objectives += new_objective

		else if (href_list["obj_delete"])
			var/datum/objective/objective = locate(href_list["obj_delete"])
			if (!objective) return
			objectives -= objective

		else if (href_list["changeling"])
			switch(href_list["changeling"])
				if("clear")
					if(src in ticker.mode.changelings)
						ticker.mode.changelings -= src
						special_role = null
						current.remove_changeling_powers()
						if(current.changeling)
							del(current.changeling)
						current << "\red <FONT size = 3><B>You have been brainwashed! You are no longer a changeling!</B></FONT>"
				if("changeling")
					if(!(src in ticker.mode.changelings))
						ticker.mode.changelings += src
						ticker.mode.grant_changeling_powers(current)
						special_role = "Changeling"
						current << "<B>\red You are a changeling!</B>"
				if("autoobjectives")
					ticker.mode.forge_changeling_objectives(src)
					usr << "\blue The objectives for changeling [key] have been generated. You can edit them and anounce manually."

				if("initialdna")
					if (!usr.changeling || !usr.changeling.absorbed_dna[1])
						usr << "\red Resetting DNA failed!"
					else
						usr.dna = usr.changeling.absorbed_dna[usr.changeling.absorbed_dna[1]]
						usr.real_name = usr.changeling.absorbed_dna[1]
						updateappearance(usr, usr.dna.uni_identity)
						domutcheck(usr, null)

		else if (href_list["traitor"])
			switch(href_list["traitor"])
				if("clear")
					if(src in ticker.mode.traitors)
						ticker.mode.traitors -= src
						special_role = null
						current << "\red <FONT size = 3><B>You have been brainwashed! You are no longer a traitor!</B></FONT>"

				if("traitor")
					if(!(src in ticker.mode.traitors))
						ticker.mode.traitors += src
						special_role = "traitor"
						current << "<B>\red You are a traitor!</B>"

				if("autoobjectives")
					ticker.mode.forge_traitor_objectives(src)
					usr << "\blue The objectives for traitor [key] have been generated. You can edit them and anounce manually."

		else if (href_list["monkey"])
			var/mob/living/L = current
			if (L.monkeyizing)
				return
			switch(href_list["monkey"])
				if("healthy")
					if (usr.client.holder.level >= 3)
						var/mob/living/carbon/human/H = current
						var/mob/living/carbon/monkey/M = current
						if (istype(H))
							log_admin("[key_name(usr)] attempting to monkeyize [key_name(current)]")
							message_admins("\blue [key_name_admin(usr)] attempting to monkeyize [key_name_admin(current)]", 1)
							src = null
							M = H.monkeyize()
							src = M.mind
							//world << "DEBUG: \"healthy\": M=[M], M.mind=[M.mind], src=[src]!"
						else if (istype(M) && length(M.viruses))
							for(var/datum/disease/D in M.viruses)
								D.cure(0)
							sleep(0) //because deleting of virus is done through spawn(0)
				if("infected")
					if (usr.client.holder.level >= 3)
						var/mob/living/carbon/human/H = current
						var/mob/living/carbon/monkey/M = current
						if (istype(H))
							log_admin("[key_name(usr)] attempting to monkeyize and infect [key_name(current)]")
							message_admins("\blue [key_name_admin(usr)] attempting to monkeyize and infect [key_name_admin(current)]", 1)
							src = null
							M = H.monkeyize()
							src = M.mind
							current.contract_disease(new /datum/disease/jungle_fever,1,0)
						else if (istype(M))
							current.contract_disease(new /datum/disease/jungle_fever,1,0)
				if("human")
					var/mob/living/carbon/monkey/M = current
					if (istype(M))
						for(var/datum/disease/D in M.viruses)
							if (istype(D,/datum/disease/jungle_fever))
								D.cure(0)
								sleep(0) //because deleting of virus is doing throught spawn(0)
						log_admin("[key_name(usr)] attempting to humanize [key_name(current)]")
						message_admins("\blue [key_name_admin(usr)] attempting to humanize [key_name_admin(current)]", 1)
						var/obj/item/weapon/dnainjector/m2h/m2h = new
						src = null
						m2h.inject(M)
						current.radiation -= 50

		else if (href_list["common"])
			switch(href_list["common"])
				if("undress")
					for(var/obj/item/W in current)
						current.drop_from_slot(W)
				if("takeuplink")
					take_uplink()
					memory = null//Remove any memory they may have had.
				if("crystals")
					if (usr.client.holder.level >= 3)
						var/obj/item/weapon/syndicate_uplink/suplink = find_syndicate_uplink()
						var/obj/item/weapon/integrated_uplink/iuplink = find_integrated_uplink()
						var/crystals
						if (suplink)
							crystals = suplink.uses
						else if (iuplink)
							crystals = iuplink.uses
						crystals = input("Amount of telecrystals for [key]","Sindicate uplink", crystals) as null|num
						if (!isnull(crystals))
							if (suplink)
								suplink.uses = crystals
							else if(iuplink)
								iuplink.uses = crystals
				if("uplink")
					if (!ticker.mode.equip_traitor(current, !(src in ticker.mode.traitors)))
						usr << "\red Equipping a syndicate failed!"

		else if (href_list["obj_announce"])
			var/obj_count = 1
			current << "\blue Your current objectives:"
			for(var/datum/objective/objective in objectives)
				current << "<B>Objective #[obj_count]</B>: [objective.explanation_text]"
				obj_count++

		edit_memory()
/*
	proc/clear_memory(var/silent = 1)
		var/datum/game_mode/current_mode = ticker.mode

		// remove traitor uplinks
		var/list/L = current.get_contents()
		for (var/t in L)
			if (istype(t, /obj/item/device/pda))
				if (t:uplink) del(t:uplink)
				t:uplink = null
			else if (istype(t, /obj/item/device/radio))
				if (t:traitorradio) del(t:traitorradio)
				t:traitorradio = null
				t:traitor_frequency = 0.0
			else if (istype(t, /obj/item/weapon/SWF_uplink) || istype(t, /obj/item/weapon/syndicate_uplink))
				if (t:origradio)
					var/obj/item/device/radio/R = t:origradio
					R.loc = current.loc
					R.traitorradio = null
					R.traitor_frequency = 0.0
				del(t)

		// remove wizards spells
		//If there are more special powers that need removal, they can be procced into here./N
		current.spellremove(current)

		// clear memory
		memory = ""
		special_role = null

*/

	proc/find_syndicate_uplink()
		var/obj/item/weapon/syndicate_uplink/uplink = null
		var/list/L = current.get_contents()
		for (var/obj/item/device/radio/radio in L)
			uplink = radio.traitorradio
			if (uplink)
				return uplink
		uplink =  locate() in L
		return uplink

	proc/find_integrated_uplink()
		//world << "DEBUG: find_integrated_uplink()"
		var/obj/item/weapon/integrated_uplink/uplink = null
		var/list/L = current.get_contents()
		for (var/obj/item/device/pda/pda in L)
			uplink = pda.uplink
			if (uplink)
				return uplink
		return uplink

	proc/take_uplink() //assuming only one uplink because I am tired of all this uplink shit --rastaf0
		var/list/L = current.get_contents()
		var/obj/item/weapon/syndicate_uplink/suplink = null
		var/obj/item/weapon/integrated_uplink/iuplink = null
		for (var/obj/item/device/radio/radio in L)
			suplink = radio.traitorradio
			if (suplink)
				break
		if (!suplink)
			suplink = locate() in L

		for (var/obj/item/device/pda/pda in L)
			iuplink = pda.uplink
			if (iuplink)
				break
		if (!iuplink)
			iuplink = locate() in L

		if (iuplink)
			iuplink.shutdown_uplink()
			del(iuplink)
		else if (suplink)
			suplink.shutdown_uplink()
			del(suplink)
		return


