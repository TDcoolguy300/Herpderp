/obj/machinery/door
	name = "Door"
	desc = "It opens and closes."
	icon = 'doorint.dmi'
	icon_state = "door1"
	anchored = 1
	opacity = 1
	density = 1
	layer = 2.7

	var
		secondsElectrified = 0
		visible = 1
		p_open = 0
		operating = 0
		autoclose = 0
		glass = 0

	proc/bumpopen(mob/user as mob)
	proc/update_nearby_tiles(need_rebuild)
	proc/requiresID()	return 1
//	proc/animate(animation)
	proc/open()
	proc/close()


	New()
		..()
		if(density)
			layer = 3.1 //Above most items if closed
		else
			layer = 2.7 //Under all objects if opened. 2.7 due to tables being at 2.6
		update_nearby_tiles(need_rebuild=1)
		return


	Del()
		update_nearby_tiles()
		..()
		return


	Bumped(atom/AM)
		if(p_open || operating) return
		if(ismob(AM))
			var/mob/M = AM
			if(world.time - M.last_bumped <= 60) return
			if(M.client && !M.handcuffed)
				bumpopen(M)
			return

		if(istype(AM, /obj/effect/critter))
			var/obj/effect/critter/critter = AM
			if(critter.opensdoors)	return
			if(src.check_access_list(critter.access_list))
				if(density)
					open()
			return
		return

	bumpopen(mob/user as mob)
		if(operating)	return
		src.add_fingerprint(user)
		if(!src.requiresID())
			user = null

		if(allowed(user) && density)
			open()
		else if(density)
			flick("door_deny", src)
		return

	attack_paw(mob/user as mob)
		return src.attack_hand(user)


	attack_hand(mob/user as mob)
		return src.attackby(user, user)


	attackby(obj/item/I as obj, mob/user as mob)
		if(src.operating)	return
		src.add_fingerprint(user)
		if(!src.requiresID())
			user = null
		if(src.density && (istype(I, /obj/item/weapon/card/emag)||istype(I, /obj/item/weapon/melee/energy/blade)))
			flick("door_spark", src)
			sleep(6)
			open()
			operating = -1
			return 1
		if(src.allowed(user))
			if(src.density)
				open()
			else
				close()
			return
		if(src.density)
			flick("door_deny", src)
		return


	blob_act()
		if(prob(40))
			del(src)
		return


	emp_act(severity)
		if(prob(20/severity) && (istype(src,/obj/machinery/door/airlock) || istype(src,/obj/machinery/door/window)) )
			open()
		if(prob(40/severity))
			if(secondsElectrified == 0)
				secondsElectrified = -1
				spawn(300)
					secondsElectrified = 0
		..()


	ex_act(severity)
		switch(severity)
			if(1.0)
				del(src)
			if(2.0)
				if(prob(25))
					del(src)
			if(3.0)
				if(prob(80))
					var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
					s.set_up(2, 1, src)
					s.start()
		return


	update_icon()
		if(density)
			icon_state = "door1"
		else
			icon_state = "door0"
		return

/*
	animate(animation)
		switch(animation)
			if("opening")
				if(p_open)
					flick("o_doorc0", src)
				else
					flick("doorc0", src)
			if("closing")
				if(p_open)
					flick("o_doorc1", src)
				else
					flick("doorc1", src)
			if("deny")
				flick("door_deny", src)
		return
*/

	open()
		if(!density)	return 1
		if(operating > 0)	return
		if(!ticker)	return 0
		if(!operating)	operating = 1

		animate("opening")
		src.sd_SetOpacity(0)
		sleep(10)
		src.layer = 2.7
		src.density = 0
		update_icon()
		src.sd_SetOpacity(0)
		update_nearby_tiles()

		if(operating)	operating = 0

		if(autoclose)
			spawn(150)
				autoclose()
		return 1


	close()
		if(density)	return 1
		if(operating)	return
		operating = 1

		animate("closing")
		src.density = 1
		src.layer = 3.1
		sleep(10)
		update_icon()

		if(visible && !glass)
			src.sd_SetOpacity(1)
		operating = 0
		update_nearby_tiles()
		return

/obj/machinery/door/proc/autoclose()
	var/obj/machinery/door/airlock/A = src
	if(!A.density && !A.operating && !A.locked && !A.welded)
		close()
	return



/obj/machinery/door/airlock/proc/ion_act()
	if(src.density)
		if(prob(4))
			world << "\red Airlock emagged in [src.loc.loc]"
			src.operating = -1
			flick("door_spark", src)
			sleep(6)
			open()
		else
			if(prob(8))
				world << "\red non vital Airlock emagged in [src.loc.loc]"
				src.operating = -1
				flick("door_spark", src)
				sleep(6)
				open()
	return

/obj/machinery/door/firedoor/proc/ion_act()
	if(src.z == 1)
		if(prob(15))
			if(density)
				open()
			else
				close()
	return
