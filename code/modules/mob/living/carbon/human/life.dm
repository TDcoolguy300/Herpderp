#define HUMAN_MAX_OXYLOSS 12 //Defines how much oxyloss humans can get per tick. No air applies this value.

/mob/living/carbon/human
	var
		oxygen_alert = 0
		toxins_alert = 0
		fire_alert = 0

		temperature_alert = 0


/mob/living/carbon/human/Life()
	set invisibility = 0
	set background = 1

	if (monkeyizing)
		return

	if(!loc)			// Fixing a null error that occurs when the mob isn't found in the world -- TLE
		return

	if (stat != 2) //still breathing
		//Still give containing object the chance to interact
		if(istype(loc, /obj/))
			var/obj/location_as_object = loc
			location_as_object.handle_internal_lifeform(src, 0)

	//Apparently, the person who wrote this code designed it so that
	//blinded get reset each cycle and then get activated later in the
	//code. Very ugly. I dont care. Moving this stuff here so its easy
	//to find it.
	blinded = null

	//Update Mind
	update_mind()

	//Disease Check
	handle_virus_updates()

	//Changeling things
	handle_changeling()

	//Mutations and radiation
	handle_mutations_and_radiation()

	//Chemicals in the body
	handle_chemicals_in_body()

	//stuff in the stomach
	handle_stomach()

	//Disabilities
	handle_disabilities()

	//Random events (vomiting etc)
	handle_random_events()

	//Status updates, death etc.
	UpdateLuminosity()
	handle_regular_status_updates()
	UpdateTemperature()

	// Update clothing
	update_clothing()

	if(client)
		handle_regular_hud_updates()

	//Being buckled to a chair or bed
	check_if_buckled()

	// Yup.
	update_canmove()

	clamp_values()

	// Grabbing
	for(var/obj/item/weapon/grab/G in src)
		G.process()

	if(isturf(loc) && rand(1,1000) == 1) //0.1% chance of playing a scary sound to someone who's in complete darkness
		var/turf/currentTurf = loc
		if(!currentTurf.sd_lumcount)
			playsound_local(src,pick(scarySounds),50, 1, -1)

	..() //for organs

/mob/living/carbon/human
	proc
		clamp_values()

			SetStunned(min(stunned, 20))
			SetParalysis(min(paralysis, 20))
			SetWeakened(min(weakened, 20))
			sleeping = max(min(sleeping, 20), 0)
			adjustBruteLoss(0)
			adjustToxLoss(0)
			adjustOxyLoss(0)
			adjustFireLoss(0)


		update_mind()
			if(!mind && client)
				mind = new
				mind.current = src
				mind.assigned_role = job
				if(!mind.assigned_role)
					mind.assigned_role = "Assistant"
				mind.key = key


		handle_disabilities()
			if (disabilities & 2)
				if ((prob(1) && paralysis < 1 && r_epil < 1))
					src << "\red You have a seizure!"
					for(var/mob/O in viewers(src, null))
						if(O == src)
							continue
						O.show_message(text("\red <B>[src] starts having a seizure!"), 1)
					Paralyse(10)
					make_jittery(1000)
			if (disabilities & 4)
				if ((prob(5) && paralysis <= 1 && r_ch_cou < 1))
					drop_item()
					spawn( 0 )
						emote("cough")
						return
			if (disabilities & 8)
				if ((prob(10) && paralysis <= 1 && r_Tourette < 1))
					Stun(10)
					spawn( 0 )
						switch(rand(1, 3))
							if(1)
								emote("twitch")
							if(2 to 3)
								say("[prob(50) ? ";" : ""][pick("SHIT", "PISS", "FUCK", "CUNT", "COCKSUCKER", "MOTHERFUCKER", "TITS")]")
						var/old_x = pixel_x
						var/old_y = pixel_y
						pixel_x += rand(-2,2)
						pixel_y += rand(-1,1)
						sleep(2)
						pixel_x = old_x
						pixel_y = old_y
						return
			if (disabilities & 16)
				if (prob(10))
					stuttering = max(10, stuttering)
			if (getBrainLoss() >= 60 && stat != 2)
				if (prob(7))
					switch(pick(1,2,3))
						if(1)
							say(pick("IM A PONY NEEEEEEIIIIIIIIIGH", "without oxigen blob don't evoluate?", "CAPTAINS A COMDOM", "[pick("", "that faggot traitor")] [pick("joerge", "george", "gorge", "gdoruge")] [pick("mellens", "melons", "mwrlins")] is grifing me HAL;P!!!", "can u give me [pick("telikesis","halk","eppilapse")]?", "THe saiyans screwed", "Bi is THE BEST OF BOTH WORLDS>", "I WANNA PET TEH monkeyS", "stop grifing me!!!!", "SOTP IT#"))
						if(2)
							say(pick("FUS RO DAH","fucking 4rries!", "stat me", ">my face", "roll it easy!", "waaaaaagh!!!", "red wonz go fasta", "FOR TEH EMPRAH", "lol2cat", "dem dwarfs man, dem dwarfs", "SPESS MAHREENS", "hwee did eet fhor khayosss", "lifelike texture ;_;", "luv can bloooom"))
						if(3)
							emote("drool")


		handle_mutations_and_radiation()
			if(getFireLoss())
				if(mutations & COLD_RESISTANCE || (prob(1) && prob(75)))
					heal_organ_damage(0,1)

			if (mutations & HULK && health <= 25)
				mutations &= ~HULK
				src << "\red You suddenly feel very weak."
				Weaken(3)
				emote("collapse")

			if (radiation)
				if (radiation > 100)
					radiation = 100
					Weaken(10)
					src << "\red You feel weak."
					emote("collapse")

				if (radiation < 0)
					radiation = 0

				switch(radiation)
					if(1 to 49)
						radiation--
						if(prob(25))
							adjustToxLoss(1)
							updatehealth()

					if(50 to 74)
						radiation -= 2
						adjustToxLoss(1)
						if(prob(5))
							radiation -= 5
							Weaken(3)
							src << "\red You feel weak."
							emote("collapse")
						updatehealth()

					if(75 to 100)
						radiation -= 3
						adjustToxLoss(3)
						if(prob(1))
							src << "\red You mutate!"
							randmutb(src)
							domutcheck(src,null)
							emote("gasp")
						updatehealth()

		update_canmove()
			if(paralysis || stunned || weakened || buckled || (changeling && changeling.changeling_fakedeath)) canmove = 0
			else canmove = 1

		handle_chemicals_in_body()
			if(reagents) reagents.metabolize(src)

			if(mutantrace == "plant") //couldn't think of a better place to place it, since it handles nutrition -- Urist
				var/light_amount = 0 //how much light there is in the place, affects receiving nutrition and healing
				if(istype(loc,/turf)) //else, there's considered to be no light
					light_amount = min(10,loc:sd_lumcount) - 5 //hardcapped so it's not abused by having a ton of flashlights
				if(nutrition < 500) //so they can't store nutrition to survive without light forever
					nutrition += light_amount
				if(light_amount > 0) //if there's enough light, heal
					heal_overall_damage(1,1)
					adjustToxLoss(-1)
					adjustOxyLoss(-1)

			if(overeatduration > 500 && !(mutations & FAT))
				src << "\red You suddenly feel blubbery!"
				mutations |= FAT
				update_body()
			if (overeatduration < 100 && mutations & FAT)
				src << "\blue You feel fit again!"
				mutations &= ~FAT
				update_body()

			// nutrition decrease
			if (nutrition > 0 && stat != 2)
				nutrition = max (0, nutrition - HUNGER_FACTOR)

			if (nutrition > 450)
				if(overeatduration < 600) //capped so people don't take forever to unfat
					overeatduration++
			else
				if(overeatduration > 1)
					overeatduration -= 2 //doubled the unfat rate

			if(mutantrace == "plant")
				if(nutrition < 200)
					take_overall_damage(2,0)

			if (drowsyness)
				drowsyness--
				eye_blurry = max(2, eye_blurry)
				if (prob(5))
					sleeping = 1
					Paralyse(5)

			confused = max(0, confused - 1)
			// decrement dizziness counter, clamped to 0
			if(resting)
				dizziness = max(0, dizziness - 15)
				jitteriness = max(0, jitteriness - 15)
			else
				dizziness = max(0, dizziness - 3)
				jitteriness = max(0, jitteriness - 3)

			updatehealth()

			return //TODO: DEFERRED

		handle_regular_status_updates()

		//	health = 100 - (getOxyLoss() + getToxLoss() + getFireLoss() + getBruteLoss() + getCloneLoss())

			if(getOxyLoss() > 50) Paralyse(3)

			if(sleeping)
				Paralyse(3)
				if (prob(10) && health) spawn(0) emote("snore")
				sleeping--

			if(resting)
				Weaken(3)

			if(health < config.health_threshold_dead || brain_op_stage == 4.0)
				death()
			else if(health < config.health_threshold_crit)
				if(health <= 20 && prob(1)) spawn(0) emote("gasp")

				//if(!rejuv) oxyloss++
				if(!reagents.has_reagent("inaprovaline")) adjustOxyLoss(1)

				if(stat != 2)	stat = 1
				Paralyse(5)

			if (stat != DEAD) //Alive.
				if (silent)
					silent--

				if (paralysis || stunned || weakened || (changeling && changeling.changeling_fakedeath)) //Stunned etc.
					if (stunned > 0)
						AdjustStunned(-1)
						stat = 0
					if (weakened > 0)
						AdjustWeakened(-1)
						lying = 1
						stat = 0
					if (paralysis > 0)
						AdjustParalysis(-1)
						blinded = 1
						lying = 1
						stat = 1
					var/h = hand
					hand = 0
					drop_item()
					hand = 1
					drop_item()
					hand = h

				else	//Not stunned.
					lying = 0
					stat = 0

			else //Dead.
				lying = 1
				blinded = 1
				stat = 2
				silent = 0

			if (stuttering) stuttering--

			if (eye_blind)
				eye_blind--
				blinded = 1

			if (ear_deaf > 0) ear_deaf--
			if (ear_damage < 25)
				ear_damage -= 0.05
				ear_damage = max(ear_damage, 0)

			density = !( lying )

			if ((sdisabilities & 1 || istype(glasses, /obj/item/clothing/glasses/blindfold)))
				blinded = 1
			if ((sdisabilities & 4 || istype(ears, /obj/item/clothing/ears/earmuffs)))
				ear_deaf = 1

			if (eye_blurry > 0)
				eye_blurry--
				eye_blurry = max(0, eye_blurry)

			if (druggy > 0)
				druggy--
				druggy = max(0, druggy)

			return 1

		handle_regular_hud_updates()

			if(!client)	return 0

			for(var/image/hud in client.images)
				if(copytext(hud.icon_state,1,4) == "hud") //ugly, but icon comparison is worse, I believe
					del(hud)

			if (stat == 2 || mutations & XRAY)
				sight |= SEE_TURFS
				sight |= SEE_MOBS
				sight |= SEE_OBJS
				see_in_dark = 8
				if(!druggy)
					see_invisible = 2
			else if(istype(glasses, /obj/item/clothing/glasses/meson))
				sight |= SEE_TURFS
				if(!druggy)
					see_invisible = 0
			else if(istype(glasses, /obj/item/clothing/glasses/night))
				see_in_dark = 5
				if(!druggy)
					see_invisible = 0
			else if(istype(glasses, /obj/item/clothing/glasses/thermal))
				sight |= SEE_MOBS
				if(!druggy)
					see_invisible = 2
			else if(istype(glasses, /obj/item/clothing/glasses/material))
				sight |= SEE_OBJS
				if (!druggy)
					see_invisible = 0

			else if(stat != 2)
				sight &= ~SEE_TURFS
				sight &= ~SEE_MOBS
				sight &= ~SEE_OBJS
				if (mutantrace == "lizard" || mutantrace == "metroid")
					see_in_dark = 3
					see_invisible = 1
				else if (druggy) // If drugged~
					see_in_dark = 2
					//see_invisible regulated by drugs themselves.
				else
					see_in_dark = 2
					var/seer = 0
					if(!seer)
						see_invisible = 0

			else if(istype(head, /obj/item/clothing/head/helmet/welding))
				if(!head:up && tinted_weldhelh)
					see_in_dark = 1

		/* HUD shit goes here, as long as it doesn't modify src.sight flags */
		// The purpose of this is to stop xray and w/e from preventing you from using huds -- Love, Doohl
			if(istype(glasses, /obj/item/clothing/glasses/hud/health))
				if(client)
					glasses:process_hud(src)
				if (!druggy)
					see_invisible = 0

			if(istype(glasses, /obj/item/clothing/glasses/hud/security))
				if(client)
					glasses:process_hud(src)
				if (!druggy)
					see_invisible = 0

			if(istype(glasses, /obj/item/clothing/glasses/sunglasses))
				see_in_dark = 1
				if(istype(glasses, /obj/item/clothing/glasses/sunglasses/sechud))
					if(client)
						if(glasses:hud)
							glasses:hud:process_hud(src)
				if (!druggy)
					see_invisible = 0

/*
			if (istype(glasses, /obj/item/clothing/glasses))
				sight = glasses.vision_flags
				see_in_dark = 2 + glasses.darkness_view
				see_invisible = invisa_view

					if(istype(glasses, /obj/item/clothing/glasses/hud))
						if(client)
							glasses:process_hud(src)
*/
//Should finish this up later



			if (sleep) sleep.icon_state = text("sleep[]", sleeping)
			if (rest) rest.icon_state = text("rest[]", resting)

			if (healths)
				if (stat != 2)
					switch(health)
						if(100 to INFINITY)
							healths.icon_state = "health0"
						if(80 to 100)
							healths.icon_state = "health1"
						if(60 to 80)
							healths.icon_state = "health2"
						if(40 to 60)
							healths.icon_state = "health3"
						if(20 to 40)
							healths.icon_state = "health4"
						if(0 to 20)
							healths.icon_state = "health5"
						else
							healths.icon_state = "health6"
				else
					healths.icon_state = "health7"

			if (nutrition_icon)
				switch(nutrition)
					if(450 to INFINITY)
						nutrition_icon.icon_state = "nutrition0"
					if(350 to 450)
						nutrition_icon.icon_state = "nutrition1"
					if(250 to 350)
						nutrition_icon.icon_state = "nutrition2"
					if(150 to 250)
						nutrition_icon.icon_state = "nutrition3"
					else
						nutrition_icon.icon_state = "nutrition4"

			if(pullin)	pullin.icon_state = "pull[pulling ? 1 : 0]"

			if(resting || lying || sleeping)	rest.icon_state = "rest[(resting || lying || sleeping) ? 1 : 0]"


			if (toxin)	toxin.icon_state = "tox[toxins_alert ? 1 : 0]"
			if (oxygen) oxygen.icon_state = "oxy[oxygen_alert ? 1 : 0]"
			if (fire) fire.icon_state = "fire[fire_alert ? 1 : 0]"
			//NOTE: the alerts dont reset when youre out of danger. dont blame me,
			//blame the person who coded them. Temporary fix added.

			bodytemp.icon_state = "temp[bodytemperature]"

			if(!client)	return 0 //Wish we did not need these
			client.screen -= hud_used.blurry
			client.screen -= hud_used.druggy
			client.screen -= hud_used.vimpaired
			client.screen -= hud_used.darkMask

			if ((blind && stat != 2))
				if ((blinded))
					blind.layer = 18
				else
					blind.layer = 0

					if (disabilities & 1 && !istype(glasses, /obj/item/clothing/glasses/regular) )
						client.screen += hud_used.vimpaired

					if (eye_blurry)
						client.screen += hud_used.blurry

					if (druggy)
						client.screen += hud_used.druggy

					if ((istype(head, /obj/item/clothing/head/helmet/welding)) )
						if(!head:up && tinted_weldhelh)
							client.screen += hud_used.darkMask

					if(eye_stat > 20)
						if((eye_stat > 30))
							client.screen += hud_used.darkMask
						else
							client.screen += hud_used.vimpaired



			if (stat != 2)
				if (machine)
					if (!( machine.check_eye(src) ))
						reset_view(null)
				else
					if(!client.adminobs)
						reset_view(null)

			return 1

		handle_random_events()
			/* // probably stupid -- Doohl
			if (prob(1) && prob(2))
				spawn(0)
					emote("sneeze")
					return
			*/

			// Puke if toxloss is too high
			if(!stat)
				if (getToxLoss() >= 45 && nutrition > 20)
					lastpuke ++
					if(lastpuke >= 25) // about 25 second delay I guess
						Stun(5)

						for(var/mob/O in viewers(world.view, src))
							O.show_message(text("<b>\red [] throws up!</b>", src), 1)
						playsound(src.loc, 'splat.ogg', 50, 1)

						var/turf/location = loc
						if (istype(location, /turf/simulated))
							location.add_vomit_floor(src, 1)

						nutrition -= 20
						adjustToxLoss(-3)

						// make it so you can only puke so fast
						lastpuke = 0

		handle_virus_updates()
		//WHY? -Pete
		//	if(bodytemperature > 406)
		//		for(var/datum/disease/D in viruses)
		//			D.cure()
			return

		handle_stomach()
			spawn(0)
				for(var/mob/M in stomach_contents)
					if(M.loc != src)
						stomach_contents.Remove(M)
						continue
					if(istype(M, /mob/living/carbon) && stat != 2)
						if(M.stat == 2)
							M.death(1)
							stomach_contents.Remove(M)
							del(M)
							continue
							if(!M.nodamage)
								M.adjustBruteLoss(5)
							nutrition += 10

		handle_changeling()
			if (mind)
				if (mind.special_role == "Changeling" && changeling)
					changeling.chem_charges = between(0, (max((0.9 - (changeling.chem_charges / 50)), 0.1) + changeling.chem_charges), 50)
					if ((changeling.geneticdamage > 0))
						changeling.geneticdamage = changeling.geneticdamage-1

/*
			// Commented out so hunger system won't be such shock
			// Damage and effect from not eating
			if(nutrition <= 50)
				if (prob (0.1))
					src << "\red Your stomach rumbles."
				if (prob (10))
					bruteloss++
				if (prob (5))
					src << "You feel very weak."
					weakened += rand(2, 3)
*/
/*
snippets

	if (mach)
		if (machine)
			mach.icon_state = "mach1"
		else
			mach.icon_state = null

	if (!m_flag)
		moved_recently = 0
	m_flag = null



		if ((istype(loc, /turf/space) && !( locate(/obj/movable, loc) )))
			var/layers = 20
			// ******* Check
			if (((istype(head, /obj/item/clothing/head) && head.flags & 4) || (istype(wear_mask, /obj/item/clothing/mask) && (!( wear_mask.flags & 4 ) && wear_mask.flags & 8))))
				layers -= 5
			if (istype(w_uniform, /obj/item/clothing/under))
				layers -= 5
			if ((istype(wear_suit, /obj/item/clothing/suit) && wear_suit.flags & 8))
				layers -= 10
			if (layers > oxcheck)
				oxcheck = layers


				if(bodytemperature < 282.591 && (!firemut))
					if(bodytemperature < 250)
						adjustFireLoss(4)
						updatehealth()
						if(paralysis <= 2)	paralysis += 2
					else if(prob(1) && !paralysis)
						if(paralysis <= 5)	paralysis += 5
						emote("collapse")
						src << "\red You collapse from the cold!"
				if(bodytemperature > 327.444  && (!firemut))
					if(bodytemperature > 345.444)
						if(!eye_blurry)	src << "\red The heat blurs your vision!"
						eye_blurry = max(4, eye_blurry)
						if(prob(3))	adjustFireLoss(rand(1,2))
					else if(prob(3) && !paralysis)
						paralysis += 2
						emote("collapse")
						src << "\red You collapse from heat exaustion!"
				plcheck = t_plasma
				oxcheck = t_oxygen
				G.turf_add(T, G.total_moles())
*/