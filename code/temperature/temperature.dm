area
	var/temperature = ZERO_K

	proc/UpdateTemperature(masterOnly = 0) //masterOnly = 0 means it'll redirect it to master; masterOnly = 1 means it'll just skip non-masters completely
		if(!master_controller)
			return

		if(src != master)
			if(masterOnly) //just so it doesn't check the area multiple times. that's used when it does for area in world update temp
				return
			else
				master.UpdateTemperature(1)
				return

		var/startTime = world.timeofday //DEBUG

		var/list/turf/turfsToCheck = list()

		for(var/area/relatedArea in related)
			for(var/turf/turfToAdd in relatedArea)
				turfsToCheck += turfToAdd

		var/temp = ZERO_K

		switch(master_controller.GetStateOfDay())
			if("day")
				temp = COLD
			if("night")
				temp = X_COLD

		//temp += weather.GetTemperatureAdjustment() -- Just a mockup for now

		if(CheckIntegrity(turfsToCheck))
			world << "<font size = 1> \green Integrity check for [name] passed. </font>" //DEBUG
			temp = max(GetHeating(turfsToCheck), temp)
		else //DEBUG
			world << "<font size = 1> \red Integrity check for [name] failed.</font>" //DEBUG

		for(var/area/area in related)
			area.temperature = temp

		world << "<font size = 1> \b Updated temperature in [name] in [world.timeofday - startTime] deciseconds. Temperature is [temperature].</font>" //DEBUG

		return

	proc/GetTemp()
		return temperature

proc/CheckIntegrity(list/turf/turfsToCheck)
	for(var/turf/simulated/snow/snow in turfsToCheck) //any snow? fuck that, no integrity
		return 0

	for(var/turf/simulated/floor/tile in turfsToCheck)

		var/integrityPreserved = 0 //I recall seeing an easier way to do this but I can't quite remember it

		for(var/obj/object in tile)
			if(object.preservesIntegrity) //some stuff, like airlocks, keeps the air out too, not just windows
				integrityPreserved = 1

		if(integrityPreserved) continue

		var/totalSnowDir = 0 //first, we check if it's adjacent to any snow tile

		for(var/turf/simulated/snow/snow in range(1,tile))
			var/snowDir = get_dir(tile,snow)
			if(snowDir in cardinal) //to simplify stuff, only snow in cardinal directions counts. No seeping through diagonals for ya.
				totalSnowDir |= snowDir

		if(!totalSnowDir) //if the floor tile is internal, all's ok
			continue

		var/totalWindowDir = 0

		for(var/obj/structure/window/window in tile) //otherwise, however, we'll have to check for windows
			totalWindowDir |= window.dir
			totalWindowDir |= turn(window.dir,180)
			//I realise that that results in some exceptions that should, logically, protect but they don't in-game, but eh,
			//I can improve the algorithm later
			//changed to opposite because it causes less weird shit

		totalSnowDir &= ~totalWindowDir

		tile.overlays = list() //DEBUG

		if(!totalSnowDir) //if it's protected on all sides, all's fine
			continue

		tile.overlays += image('biomass.dmi',tile,"1",100) //DEBUG

		return 0 //otherwise, fuck, integrity's broken

	return 1 //if EVERY tile has its integrity perserved, all's well and integrity of the whole area is preserved

proc/GetHeating(list/turf/turfsToCheck)
	var/heating = ZERO_K

	for(var/turf/simulated/floor/tile in turfsToCheck)
		for(var/mob/living/carbon/monkey/monkey in tile)
			heating = (heating == ZERO_K) ? WARM : HOT
		//y u remove heaters pete they'd be perfect for testing instead we'll have to BURN ANIMALS IS THAT WHAT YOU WANT

	return heating