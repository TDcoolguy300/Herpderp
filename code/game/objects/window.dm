/obj/structure/window/bullet_act(var/obj/item/projectile/Proj)
	health -= Proj.damage
	..()
	if(health <=0)
		new /obj/item/weapon/shard( src.loc )
		new /obj/item/stack/rods( src.loc )
		src.density = 0
		del(src)
	return

/obj/structure/window/ex_act(severity)
	switch(severity)
		if(1.0)
			del(src)
			return
		if(2.0)
			new /obj/item/weapon/shard( src.loc )
			if(reinf) new /obj/item/stack/rods( src.loc)
			//SN src = null
			del(src)
			return
		if(3.0)
			if (prob(50))
				new /obj/item/weapon/shard( src.loc )
				if(reinf) new /obj/item/stack/rods( src.loc)

				del(src)
				return
	return

/obj/structure/window/CanExit(atom/movable/O as mob|obj, movementDir)
	return (dir in cardinal) ? !(dir & movementDir) : ..()

/obj/structure/window/CanPass(atom/movable/O, movementDir)
	return (dir in cardinal) ? (!(dir & movementDir) && !density) : ..()

/obj/structure/window/hitby(AM as mob|obj)
	..()
	for(var/mob/O in viewers(src, null))
		O.show_message(text("\red <B>[src] was hit by [AM].</B>"), 1)
	var/tforce = 0
	if(ismob(AM))
		tforce = 40
	else
		tforce = AM:throwforce
	if(reinf) tforce /= 4.0
	playsound(src.loc, 'Glasshit.ogg', 100, 1)
	src.health = max(0, src.health - tforce)
	if (src.health <= 7 && !reinf)
		src.anchored = 0
		step(src, get_dir(AM, src))
	if (src.health <= 0)
		new /obj/item/weapon/shard( src.loc )
		if(reinf) new /obj/item/stack/rods( src.loc)
		src.density = 0
		del(src)
		return
	..()
	return

/obj/structure/window/attack_hand()
	if ((usr.mutations & HULK))
		usr << text("\blue You smash through the window.")
		for(var/mob/O in oviewers())
			if ((O.client && !( O.blinded )))
				O << text("\red [] smashes through the window!", usr)
		src.health = 0
		new /obj/item/weapon/shard( src.loc )
		if(reinf) new /obj/item/stack/rods( src.loc)
		src.density = 0
		del(src)
	return

/obj/structure/window/attack_paw()
	if ((usr.mutations & HULK))
		usr << text("\blue You smash through the window.")
		for(var/mob/O in oviewers())
			if ((O.client && !( O.blinded )))
				O << text("\red [] smashes through the window!", usr)
		src.health = 0
		new /obj/item/weapon/shard( src.loc )
		if(reinf) new /obj/item/stack/rods( src.loc)
		src.density = 0
		del(src)
	return

/obj/structure/window/attack_animal(mob/living/simple_animal/M as mob)
	if (M.melee_damage_upper == 0)
		return
	M << text("\green You smash against the window.")
	for(var/mob/O in viewers(src, null))
		if ((O.client && !( O.blinded )))
			O << text("\red [] smashes against the window.", M)
	playsound(src.loc, 'Glasshit.ogg', 100, 1)
	src.health -= M.melee_damage_upper
	if(src.health <= 0)
		M << text("\green You smash through the window.")
		for(var/mob/O in viewers(src, null))
			if ((O.client && !( O.blinded )))
				O << text("\red [] smashes through the window!", M)
		src.health = 0
		new /obj/item/weapon/shard(src.loc)
		if(reinf)
			new /obj/item/stack/rods(src.loc)
		src.density = 0
		del(src)
		return
	return

/obj/structure/window/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (istype(W, /obj/item/weapon/screwdriver))
		if(reinf && state >= 1)
			state = 3 - state
			playsound(src.loc, 'Screwdriver.ogg', 75, 1)
			usr << ( state==1? "You have unfastened the window from the frame." : "You have fastened the window to the frame." )
		else if(reinf && state == 0)
			anchored = !anchored
			playsound(src.loc, 'Screwdriver.ogg', 75, 1)
			user << (src.anchored ? "You have fastened the frame to the floor." : "You have unfastened the frame from the floor.")
		else if(!reinf)
			src.anchored = !( src.anchored )
			playsound(src.loc, 'Screwdriver.ogg', 75, 1)
			user << (src.anchored ? "You have fastened the window to the floor." : "You have unfastened the window.")
	else if(istype(W, /obj/item/weapon/crowbar) && reinf && state <=1)
		state = 1-state;
		playsound(src.loc, 'Crowbar.ogg', 75, 1)
		user << (state ? "You have pried the window into the frame." : "You have pried the window out of the frame.")
	else
		var/aforce = W.force
		if(reinf) aforce /= 2.0
		src.health = max(0, src.health - aforce)
		playsound(src.loc, 'Glasshit.ogg', 75, 1)
		if (src.health <= 7)
			src.anchored = 0
			step(src, get_dir(user, src))
		if (src.health <= 0)
			if (src.dir == SOUTHWEST)
				var/index = null
				index = 0
				while(index < 2)
					new /obj/item/weapon/shard( src.loc )
					if(reinf) new /obj/item/stack/rods( src.loc)
					index++
			else
				new /obj/item/weapon/shard( src.loc )
				if(reinf) new /obj/item/stack/rods( src.loc)
			src.density = 0
			del(src)
			return
		..()
	return


/obj/structure/window/verb/rotate()
	set name = "Rotate Window Counter-Clockwise"
	set category = "Object"
	set src in oview(1)

	if (src.anchored)
		usr << "It is fastened to the floor; therefore, you can't rotate it!"
		return 0
	src.dir = turn(src.dir, 90)
	src.ini_dir = src.dir
	return

/obj/structure/window/verb/revrotate()
	set name = "Rotate Window Clockwise"
	set category = "Object"
	set src in oview(1)

	if (src.anchored)
		usr << "It is fastened to the floor; therefore, you can't rotate it!"
		return 0
	src.dir = turn(src.dir, 270)
	src.ini_dir = src.dir
	return

/obj/structure/window/New(Loc,re=0)
	..()

	if(re)	reinf = re

	src.ini_dir = src.dir
	if(reinf)
		icon_state = "rwindow"
		desc = "A reinforced window."
		name = "reinforced window"
		state = 2*anchored
		health = 40
		if(opacity)
			icon_state = "twindow"
	else
		icon_state = "window"

	if(dir in cardinal) //hack yo
		density = 0

	var/area/currentArea = get_area(src)
	currentArea.UpdateTemperature()

	return

/obj/structure/window/Del()
	density = 0
	playsound(src, "shatter", 70, 1)

	var/area/currentArea = get_area(src)

	..()

	currentArea.UpdateTemperature()

/obj/structure/window/Move()

	..()

	src.dir = src.ini_dir

	return