/turf
	icon = 'floors.dmi'
	var/intact = 1 //for floors, use is_plating(), is_plasteel_floor() and is_light_floor()

	level = 1.0

	var
		//Properties for open tiles (/floor)
		oxygen = 0
		carbon_dioxide = 0
		nitrogen = 0
		toxins = 0

		//Properties for airtight tiles (/wall)
		thermal_conductivity = 0.05
		heat_capacity = 1

		//Properties for both
		temperature = T20C

		blocks_air = 0
		icon_old = null
		pathweight = 1

	proc/is_plating()
		return 0
	proc/is_asteroid_floor()
		return 0
	proc/is_plasteel_floor()
		return 0
	proc/is_light_floor()
		return 0
	proc/is_grass_floor()
		return 0
	proc/return_siding_icon_state()
		return 0

/turf/space
	icon = 'snow.dmi'
	name = "\proper space"
	icon_state = "snow0"

	temperature = TCMB
	thermal_conductivity = OPEN_HEAT_TRANSFER_COEFFICIENT
	heat_capacity = 700000

/turf/space/New()
//	icon = 'space.dmi'
//	icon_state = "[pick(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25)]"
	icon_state = "snow[rand(0,3)]"

/turf/simulated
	name = "station"
	var/wet = 0
	var/image/wet_overlay = null

	var/thermite = 0
	oxygen = MOLES_O2STANDARD
	nitrogen = MOLES_N2STANDARD
	var/to_be_destroyed = 0 //Used for fire, if a melting temperature was reached, it will be destroyed
	var/max_fire_temperature_sustained = 0 //The max temperature of the fire which it was subjected to

/turf/simulated/snow
	icon = 'snow.dmi'
	name = "\proper snow"
	icon_state = "snow0"

/turf/simulated/snow/New()
	icon_state = "snow[rand(0,3)]"


/turf/simulated/snow/attackby(obj/item/weapon/W as obj, mob/user as mob)

	if (istype(W, /obj/item/weapon/shovel))
		if(!user.IsAdvancedToolUser())
			user << "\red you don't know how to use this [W.name]"
			return
		var/footprints = 0
		usr << "\blue you start shoveling"
		if(do_after(user,20))
			for(var/obj/effect/footprint/footprint in src)
				del(footprint)
				footprints = 1
			if(isturf(user.loc))
				for(var/obj/effect/footprint/footprint in user.loc)
					del(footprint)
					footprints = 1
			if(footprints)
				usr << "\blue You cover up the footprints"
			else //There were no footprints to clear. Means the person is trying to collect snow
				new/obj/item/stack/sheet/snow(src)
				usr << "\blue You dig up some snow"

/turf/simulated/snow/Entered(atom/movable/A as mob|obj)
	..()
	if ((!(A) || src != A.loc || istype(null, /obj/effect/beam)))	return

	if(ticker && ticker.mode)

		// Okay, so let's make it so that people can travel z levels but not nuke disks!
		// if(ticker.mode.name == "nuclear emergency")	return

		if(istype(A, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = A
			if(!H.lying)
				spawn(2)
					var/obj/effect/footprint/human/newprints = new /obj/effect/footprint/human (src)
					newprints.dir = H.dir
		if (src.x <= TRANSITIONEDGE || src.x >= (world.maxx - TRANSITIONEDGE) || src.y <= TRANSITIONEDGE || src.y >= (world.maxy - TRANSITIONEDGE))

			var/edge = ""
			if( src.x <= TRANSITIONEDGE )
				edge = "west"
			if( src.x >= (world.maxx - TRANSITIONEDGE) )
				edge = "east"
			if( src.y <= TRANSITIONEDGE )
				edge = "south"
			if( src.y >= (world.maxy - TRANSITIONEDGE) )
				edge = "north"

			var/deathedge = 0

			switch(src.z)
				if(ZLEVEL_OBSERVATORY)
					switch(edge)
						if("north") A.z = ZLEVEL_IGLOO
						if("south") A.z = ZLEVEL_POWER
						if("east") A.z = ZLEVEL_TROLL
						if("west") A.z = ZLEVEL_LEFT
				if(ZLEVEL_MINE)
					switch(edge)
						if("north") deathedge = 1
						if("south") A.z = ZLEVEL_LEFT
						if("east") A.z = ZLEVEL_IGLOO
						if("west") deathedge = 1
				if(ZLEVEL_IGLOO)
					switch(edge)
						if("north") deathedge = 1
						if("south") A.z = ZLEVEL_OBSERVATORY
						if("east") A.z = ZLEVEL_LAKE
						if("west") A.z = ZLEVEL_MINE
				if(ZLEVEL_LAKE)
					switch(edge)
						if("north") deathedge = 1
						if("south") A.z = ZLEVEL_TROLL
						if("east") deathedge = 1
						if("west") A.z = ZLEVEL_IGLOO
				if(ZLEVEL_LEFT)
					switch(edge)
						if("north") A.z = ZLEVEL_MINE
						if("south") A.z = ZLEVEL_LEFTBOTTOM
						if("east") A.z = ZLEVEL_OBSERVATORY
						if("west") deathedge = 1
				if(ZLEVEL_TROLL)
					switch(edge)
						if("north") A.z = ZLEVEL_LAKE
						if("south") A.z = ZLEVEL_RIGHTBOTTOM
						if("east") deathedge = 1
						if("west") A.z = ZLEVEL_OBSERVATORY
				if(ZLEVEL_LEFTBOTTOM)
					switch(edge)
						if("north") A.z = ZLEVEL_LEFT
						if("south") deathedge = 1
						if("east") A.z = ZLEVEL_POWER
						if("west") deathedge = 1
				if(ZLEVEL_POWER)
					switch(edge)
						if("north") A.z = ZLEVEL_OBSERVATORY
						if("south") deathedge = 1
						if("east") A.z = ZLEVEL_RIGHTBOTTOM
						if("west") A.z = ZLEVEL_LEFTBOTTOM
				if(ZLEVEL_POWER)
					switch(edge)
						if("north") A.z = ZLEVEL_TROLL
						if("south") deathedge = 1
						if("east") deathedge = 1
						if("west") A.z = ZLEVEL_POWER

			if(deathedge)
				if(isliving(A))
					var/mob/living/L = A
					if(L.deathedge_process) return //Animation already started. Prevents additioanl movement from calling it again.
					if(L.client)
						L << "\red <b>You got lost in the snow</b>"
						var/mob/dead/observer/O = new(L.loc)
						O.client = L.client
					L.deathedge_process = 1 //The animation is within the edge so additional Entered() calls would double the animation. This prevents this.
					var/walkdir = 0
					switch(edge)
						if("north") walkdir = NORTH
						if("south") walkdir = SOUTH
						if("east") walkdir = EAST
						if("west") walkdir = WEST
					for(var/i = 1; i < TRANSITIONEDGE+1; i++)
						if(!L) return
						step(L,walkdir)
						sleep(10)
					if(L)
						L.death()
				else
					del(A)
				return

			switch(edge)
				if("north") A.y = TRANSITIONEDGE + 1
				if("south") A.y = world.maxy - TRANSITIONEDGE -1
				if("east") A.x = TRANSITIONEDGE +1
				if("west") A.x = world.maxx - TRANSITIONEDGE -1

			spawn (0)
				if ((A && A.loc))
					A.loc.Entered(A)



/turf/simulated/wall/r_wall
	name = "r wall"
	desc = "A huge chunk of reinforced metal used to seperate rooms."
	icon_state = "r_wall"
	opacity = 1
	density = 1

	walltype = "rwall"

	var/d_state = 0

/turf/simulated/wall
	name = "wall"
	desc = "A huge chunk of metal used to seperate rooms."
	icon = 'walls.dmi'
	opacity = 1
	density = 1
	blocks_air = 1

	thermal_conductivity = WALL_HEAT_TRANSFER_COEFFICIENT
	heat_capacity = 312500 //a little over 5 cm thick , 312500 for 1 m by 2.5 m by 0.25 m plasteel wall

	var/walltype = "wall"

/turf/simulated/shuttle
	name = "shuttle"
	icon = 'shuttle.dmi'
	thermal_conductivity = 0.05
	heat_capacity = 0

/turf/simulated/shuttle/wall
	name = "wall"
	icon_state = "wall1"
	opacity = 1
	density = 1
	blocks_air = 1

/turf/simulated/shuttle/floor
	name = "floor"
	icon_state = "floor"

/turf/simulated/shuttle/floor4 // Added this floor tile so that I have a seperate turf to check in the shuttle -- Polymorph
	name = "Brig floor"        // Also added it into the 2x3 brig area of the shuttle.
	icon_state = "floor4"

/turf/unsimulated
	intact = 1
	name = "command"
	oxygen = MOLES_O2STANDARD
	nitrogen = MOLES_N2STANDARD

/turf/unsimulated/floor
	name = "floor"
	icon = 'floors.dmi'
	icon_state = "Floor3"

/turf/unsimulated/wall
	name = "wall"
	icon = 'walls.dmi'
	icon_state = "riveted"
	opacity = 1
	density = 1

/turf/unsimulated/wall/other
	icon_state = "r_wall"

/turf/proc
	AdjacentTurfs()
		var/L[] = new()
		for(var/turf/simulated/t in oview(src,1))
			if(!t.density)
				if(!LinkBlocked(src, t) && !TurfBlockedNonWindow(t))
					L.Add(t)
		return L
	Distance(turf/t)
		if(get_dist(src,t) == 1)
			var/cost = (src.x - t.x) * (src.x - t.x) + (src.y - t.y) * (src.y - t.y)
			cost *= (pathweight+t.pathweight)/2
			return cost
		else
			return get_dist(src,t)
	AdjacentTurfsSpace()
		var/L[] = new()
		for(var/turf/t in oview(src,1))
			if(!t.density)
				if(!LinkBlocked(src, t) && !TurfBlockedNonWindow(t))
					L.Add(t)
		return L