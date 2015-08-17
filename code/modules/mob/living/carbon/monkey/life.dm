/mob/living/carbon/monkey
	var
		oxygen_alert = 0
		toxins_alert = 0
		fire_alert = 0

		temperature_alert = 0


/mob/living/carbon/monkey/Life()
	set invisibility = 0
	set background = 1

	if (src.monkeyizing)
		return

	if (src.stat != 2) //still breathing
		//Still give containing object the chance to interact
		if(istype(loc, /obj/))
			var/obj/location_as_object = loc
			location_as_object.handle_internal_lifeform(src, 0)

	//Apparently, the person who wrote this code designed it so that
	//blinded get reset each cycle and then get activated later in the
	//code. Very ugly. I dont care. Moving this stuff here so its easy
	//to find it.
	src.blinded = null

	//Disease Check
	handle_virus_updates()

	//Changeling things
	handle_changeling()

	//Mutations and radiation
	handle_mutations_and_radiation()

	//Chemicals in the body
	handle_chemicals_in_body()

	//Disabilities
	handle_disabilities()

	//Status updates, death etc.
	UpdateLuminosity()
	handle_regular_status_updates()

	if(client)
		handle_regular_hud_updates()

	//Being buckled to a chair or bed
	check_if_buckled()

	// Yup.
	update_canmove()

	// Update clothing
	update_clothing()

	clamp_values()

	// Grabbing
	for(var/obj/item/weapon/grab/G in src)
		G.process()

	if(!client && !stat)
		if(prob(33) && canmove && isturf(loc))
			step(src, pick(cardinal))
		if(prob(1))
			emote(pick("scratch","jump","roll","tail"))

/mob/living/carbon/monkey
	proc

		clamp_values()

			AdjustStunned(0)
			AdjustParalysis(0)
			AdjustWeakened(0)

		handle_disabilities()

			if (src.disabilities & 2)
				if ((prob(1) && src.paralysis < 10 && src.r_epil < 1))
					src << "\red You have a seizure!"
					Paralyse(10)
			if (src.disabilities & 4)
				if ((prob(5) && src.paralysis <= 1 && src.r_ch_cou < 1))
					src.drop_item()
					spawn( 0 )
						emote("cough")
						return
			if (src.disabilities & 8)
				if ((prob(10) && src.paralysis <= 1 && src.r_Tourette < 1))
					Stun(10)
					spawn( 0 )
						emote("twitch")
						return
			if (src.disabilities & 16)
				if (prob(10))
					src.stuttering = max(10, src.stuttering)

		update_mind()
			if(!mind && client)
				mind = new
				mind.current = src
				mind.key = key

		handle_mutations_and_radiation()

			if(src.getFireLoss())
				if(src.mutations & COLD_RESISTANCE || prob(50))
					switch(src.getFireLoss())
						if(1 to 50)
							src.adjustFireLoss(-1)
						if(51 to 100)
							src.adjustFireLoss(-5)

			if (src.mutations & HULK && src.health <= 25)
				src.mutations &= ~HULK
				src << "\red You suddenly feel very weak."
				Weaken(3)
				emote("collapse")

			if (src.radiation)
				if (src.radiation > 100)
					src.radiation = 100
					Weaken(10)
					src << "\red You feel weak."
					emote("collapse")

				switch(src.radiation)
					if(1 to 49)
						src.radiation--
						if(prob(25))
							src.adjustToxLoss(1)
							src.updatehealth()

					if(50 to 74)
						src.radiation -= 2
						src.adjustToxLoss(1)
						if(prob(5))
							src.radiation -= 5
							Weaken(3)
							src << "\red You feel weak."
							emote("collapse")
						src.updatehealth()

					if(75 to 100)
						src.radiation -= 3
						src.adjustToxLoss(3)
						if(prob(1))
							src << "\red You mutate!"
							randmutb(src)
							domutcheck(src,null)
							emote("gasp")
						src.updatehealth()

		update_canmove()
			if(paralysis || stunned || weakened || buckled || (changeling && changeling.changeling_fakedeath)) canmove = 0
			else canmove = 1

		handle_chemicals_in_body()

			if(reagents) reagents.metabolize(src)

			if (src.drowsyness)
				src.drowsyness--
				src.eye_blurry = max(2, src.eye_blurry)
				if (prob(5))
					src.sleeping = 1
					Paralyse(5)

			confused = max(0, confused - 1)
			// decrement dizziness counter, clamped to 0
			if(resting)
				dizziness = max(0, dizziness - 5)
			else
				dizziness = max(0, dizziness - 1)

			src.updatehealth()

			return //TODO: DEFERRED

		handle_regular_status_updates()

			health = 100 - (getOxyLoss() + getToxLoss() + getFireLoss() + getBruteLoss() + getCloneLoss())

			if(getOxyLoss() > 25) Paralyse(3)

			if(src.sleeping)
				Paralyse(5)
				if (prob(1) && health) spawn(0) emote("snore")

			if(src.resting)
				Weaken(5)

			if(health < config.health_threshold_dead && stat != 2)
				death()
			else if(src.health < config.health_threshold_crit)
				if(src.health <= 20 && prob(1)) spawn(0) emote("gasp")

				//if(!src.rejuv) src.oxyloss++	//-Nodrak (I can't believe I thought this should be commented back in)
				if(!src.reagents.has_reagent("inaprovaline") && src.stat != 2) src.adjustOxyLoss(2)

				if(src.stat != 2)	src.stat = 1
				Paralyse(5)

			if (src.stat != 2) //Alive.

				if (src.paralysis || src.stunned || src.weakened || (changeling && changeling.changeling_fakedeath)) //Stunned etc.
					if (src.stunned > 0)
						AdjustStunned(-1)
						src.stat = 0
					if (src.weakened > 0)
						AdjustWeakened(-1)
						src.lying = 1
						src.stat = 0
					if (src.paralysis > 0)
						AdjustParalysis(-1)
						src.blinded = 1
						src.lying = 1
						src.stat = 1
					var/h = src.hand
					src.hand = 0
					drop_item()
					src.hand = 1
					drop_item()
					src.hand = h

				else	//Not stunned.
					src.lying = 0
					src.stat = 0

			else //Dead.
				src.lying = 1
				src.blinded = 1
				src.stat = 2

			if (src.stuttering) src.stuttering--

			if (src.eye_blind)
				src.eye_blind--
				src.blinded = 1

			if (src.ear_deaf > 0) src.ear_deaf--
			if (src.ear_damage < 25)
				src.ear_damage -= 0.05
				src.ear_damage = max(src.ear_damage, 0)

			src.density = !( src.lying )

			if (src.sdisabilities & 1)
				src.blinded = 1
			if (src.sdisabilities & 4)
				src.ear_deaf = 1

			if (src.eye_blurry > 0)
				src.eye_blurry--
				src.eye_blurry = max(0, src.eye_blurry)

			if (src.druggy > 0)
				src.druggy--
				src.druggy = max(0, src.druggy)

			return 1

		handle_regular_hud_updates()

			if (src.stat == 2 || src.mutations & XRAY)
				src.sight |= SEE_TURFS
				src.sight |= SEE_MOBS
				src.sight |= SEE_OBJS
				src.see_in_dark = 8
				src.see_invisible = 2
			else if (src.stat != 2)
				src.sight &= ~SEE_TURFS
				src.sight &= ~SEE_MOBS
				src.sight &= ~SEE_OBJS
				src.see_in_dark = 2
				src.see_invisible = 0

			if (src.sleep) src.sleep.icon_state = text("sleep[]", src.sleeping)
			if (src.rest) src.rest.icon_state = text("rest[]", src.resting)

			if (src.healths)
				if (src.stat != 2)
					switch(health)
						if(100 to INFINITY)
							src.healths.icon_state = "health0"
						if(80 to 100)
							src.healths.icon_state = "health1"
						if(60 to 80)
							src.healths.icon_state = "health2"
						if(40 to 60)
							src.healths.icon_state = "health3"
						if(20 to 40)
							src.healths.icon_state = "health4"
						if(0 to 20)
							src.healths.icon_state = "health5"
						else
							src.healths.icon_state = "health6"
				else
					src.healths.icon_state = "health7"

			if(src.pullin)	src.pullin.icon_state = "pull[src.pulling ? 1 : 0]"


			if (src.toxin)	src.toxin.icon_state = "tox[src.toxins_alert ? 1 : 0]"
			if (src.oxygen) src.oxygen.icon_state = "oxy[src.oxygen_alert ? 1 : 0]"
			if (src.fire) src.fire.icon_state = "fire[src.fire_alert ? 1 : 0]"
			//NOTE: the alerts dont reset when youre out of danger. dont blame me,
			//blame the person who coded them. Temporary fix added.

			bodytemp.icon_state = "temp[bodytemperature]"

			src.client.screen -= src.hud_used.blurry
			src.client.screen -= src.hud_used.druggy
			src.client.screen -= src.hud_used.vimpaired

			if ((src.blind && src.stat != 2))
				if ((src.blinded))
					src.blind.layer = 18
				else
					src.blind.layer = 0

					if (src.disabilities & 1)
						src.client.screen += src.hud_used.vimpaired

					if (src.eye_blurry)
						src.client.screen += src.hud_used.blurry

					if (src.druggy)
						src.client.screen += src.hud_used.druggy

			if (src.stat != 2)
				if (src.machine)
					if (!( src.machine.check_eye(src) ))
						src.reset_view(null)
				else
					if(!client.adminobs)
						reset_view(null)

			return 1

		handle_random_events()
			if (prob(1) && prob(2))
				spawn(0)
					emote("scratch")
					return

		handle_virus_updates()
		//WHY -Pete again
		//	if(bodytemperature > 406)
		//		for(var/datum/disease/D in viruses)
		//			D.cure()
			return

		handle_changeling()
			if (mind)
				if (mind.special_role == "Changeling" && changeling)
					changeling.chem_charges = between(0, (max((0.9 - (changeling.chem_charges / 50)), 0.1) + changeling.chem_charges), 50)
					if ((changeling.geneticdamage > 0))
						changeling.geneticdamage = changeling.geneticdamage-1