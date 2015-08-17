mob/living/carbon/human/proc/dream()
	dreaming = 1
	var/list/dreams = list(
		"pride", "the lab", "a long hallway", "the garage", "sick bay", "a glint of steel", "cracking ice", "endless snow",
		"a beautiful sunset", "a woman's laughter", "a distant light", "howling wind", "a treasured possession", "footprints in the snow",
		"a promotion", "broken glass", "crunching footsteps", "hushed whispers", "success", "isolation", "loneliness", "anxiety",
		"an old friend", "pain", "loss", "shadowy figures", "agitated voices", "disappointment", "numbness", "bleak walls", "smoke",
		"sweat", "ebbing warmth", "a flickering flame", "an empty cave", "whiteness", "noise", "snow-capped hills", "anticipation",
		"falling backwards", "sudden vertigo", "a piercing scream", "emptiness", "a stopped clock", "ancient ice-caps", "warm soil",
		"a painted fence", "a huge tree", "a dark skyline", "the taste of metal", "copper wires", "rusted steel", "chipped paint",
		"blue ice", "drifting", "exhilaration", "a loved one", "a slow piano", "a grave", "running", "daylight", "a bad joke", "despair"
		)
	spawn(0)
		for(var/i = rand(2,4),i > 0, i--)
			var/dream_image = pick(dreams)
			dreams -= dream_image
			src << "\blue <i>...[dream_image]...</i>"
			sleep(rand(50,80))
			if(paralysis <= 0)
				dreaming = 0
				return 0
		dreaming = 0
		return 1

mob/living/carbon/human/proc/handle_dreams()
	if(!dreaming) dream()