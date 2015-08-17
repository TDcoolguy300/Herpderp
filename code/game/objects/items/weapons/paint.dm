var/global/list/cached_icons = list()

/obj/item/weapon/paint
	name = "Paint Can"
	desc = "Used to recolor floors and walls. Can not be removed by the janitor."
	icon = 'items.dmi'
	icon_state = "paint_neutral"
	item_state = "paintcan"
	w_class = 3.0

/obj/item/weapon/paint/red
	name = "Red paint"
	icon_state = "paint_red"

/obj/item/weapon/paint/green
	name = "Green paint"
	icon_state = "paint_green"

/obj/item/weapon/paint/blue
	name = "Blue paint"
	icon_state = "paint_blue"

/obj/item/weapon/paint/yellow
	name = "Yellow paint"
	icon_state = "paint_yellow"

/obj/item/weapon/paint/violet //no icon
	name = "Violet paint"
	icon_state = "paint_neutral"

/obj/item/weapon/paint/black
	name = "Black paint"
	icon_state = "paint_black"

/obj/item/weapon/paint/white
	name = "White paint"
	icon_state = "paint_white"

/obj/item/weapon/paint/afterattack(turf/target, mob/user as mob)
	if(!istype(target) || istype(target, /turf/space))
		return
	var/ind = "[initial(target.icon)][color]"
	if(!cached_icons[ind])
		var/icon/overlay = new/icon(initial(target.icon))
		overlay.Blend("#[color]",ICON_MULTIPLY)
		overlay.SetIntensity(1.4)
		target.icon = overlay
		cached_icons[ind] = target.icon
	else
		target.icon = cached_icons[ind]
	return

/obj/item/weapon/paint/paint_remover
	name = "Paint remover"
	icon_state = "paint_neutral"

	afterattack(turf/target, mob/user as mob)
		if(istype(target) && target.icon != initial(target.icon))
			target.icon = initial(target.icon)
		return
