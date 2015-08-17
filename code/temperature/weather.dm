var/datum/weather/globalweather

datum/weather
	var/lifespan = -1 //unless it's -1, every time it is processed it decreases by 1. at 0, it decreases its intensity (varies with weather type)
	var/list/area/areas = list()

	proc/DecrementIntensity()
		return

	proc/Process()
		if(lifespan > 0)
			lifespan--
			if(!lifespan)
				DecrementIntensity()
		return

	calm //aka default

	snow
		DecrementIntensity()
			SetWeather(areas, "calm")

	hail
		lifespan = 300

		DecrementIntensity()
			SetWeather(areas, "snow")

	blizzard
		lifespan = 120

		DecrementIntensity()
			SetWeather(areas, "snow")

area
	var/datum/weather/weather

proc/SetWeather(var/list/area/areas, weatherType)
	if(!weatherType)
		world << "No weather type set for SetWeather()." //DEBUG
		return
	if(!(weatherType in list("calm","snow","hail","blizzard")))
		world << "Weather type in SetWeather() invalid." //DEBUG
		return

	var/path = text2path("/datum/weather/[weatherType]")
	var/datum/weather/newWeather = new path()

	for(var/area/area in areas)
		area.weather = newWeather
		area.UpdateTemperature()

	world << "Weather in areas [areas] changed to [weatherType]." //DEBUG

	return