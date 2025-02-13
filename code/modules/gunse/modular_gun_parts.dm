
/*
BASIC BROAD PART PARADIGMS:
" gun " : the reciever - determines whether it's single or double action, basic capacity (bolt or revolver), and DRM types
Barrels : largely handle how a shot behaves after leaving your gun. Spread, muzzle flash, silencing, damage modifiers.
Stocks  : everything to do with holding and interfacing the gun. Crankhandles, extra capacity, 2-handedness, and (on rare occasions) power cells go here
Mags    : entirely optional component that adds ammo capacity, but also increases jamming frequency. May affect action type by autoloading?
accssry : mall ninja bullshit. optics. gadgets. flashlights. horns. sexy nude men figurines. your pick.
*/





ABSTRACT_TYPE(/obj/item/gun_parts)
/obj/item/gun_parts/
	icon = 'icons/obj/items/cet_guns/accessory.dmi'
	var/name_addition = ""
	var/part_type = null
	var/overlay_x = 0
	var/overlay_y = 0
	var/part_DRM = 0 //which gun models is this part compatible with?
	var/obj/item/gun/modular/my_gun = null

	proc/add_part_to_gun(var/obj/item/gun/modular/gun)
		my_gun = gun
		var/image/I = image(icon, icon_state)
		I.pixel_x = overlay_x
		I.pixel_y = overlay_y
		my_gun.UpdateOverlays(I, part_type)
		return 1

	proc/remove_part_from_gun()
		RETURN_TYPE(/obj/item/gun_parts/)
		my_gun.name = my_gun.real_name
		my_gun = null
		overlay_x = initial(overlay_x)
		overlay_y = initial(overlay_y)
		part_type = initial(part_type)
		return src

	//barrel vars
	var/spread_angle = 0 // modifier, added to stock
	var/silenced = 0
	var/muzzle_flash = "muzzle_flash"
	var/lensing = 0 // Variable used for optical gun barrels. Scalar around 1.0
	var/jam_frequency_fire = 1 //additional % chance to jam on fire. Reload to clear.
	var/scatter = 0
	var/length = 0 // centimetres

	//stock vars
	var/can_dual_wield = 1
	//var/spread_angle = 0 // modifier, added to stock // repeat of barrel
	var/max_ammo_capacity = 0 //modifier
	var/flashbulb_only = 0 // FOSS guns only
	var/max_crank_level = 0 // FOSS guns only
	var/stock_two_handed = 0 // if gun or stock is 2 handed, whole gun is 2 handed
	var/stock_dual_wield = 1 // if gun AND stock can be dual wielded, whole gun can be dual wielded.
	var/jam_frequency_reload = 0 //attitional % chance to jam on reload. Just reload again to clear.

	// mag vars
	// max_ammo_capacity = 0 //modifier
	// jam_frequency_reload = 5 //additional % chance to jam on reload. Just reload again to clear.

	buildTooltipContent()
		. = ..()
		if(part_DRM)
			. += "<div><span>DRM REQUIREMENTS: </span>"
			if(part_DRM & GUN_NANO)
				. += "<img src='[resource("images/tooltips/temp_nano.png")]' alt='' class='icon' />"
			if(part_DRM & GUN_FOSS)
				. += "<img src='[resource("images/tooltips/temp_foss.png")]' alt='' class='icon' />"
			if(part_DRM & GUN_JUICE)
				. += "<img src='[resource("images/tooltips/temp_juice.png")]' alt='' class='icon' />"
			if(part_DRM & GUN_SOVIET)
				. += "<img src='[resource("images/tooltips/temp_soviet.png")]' alt='' class='icon' />"
			if(part_DRM & GUN_ITALIAN)
				. += "<img src='[resource("images/tooltips/temp_italian.png")]' alt='' class='icon' />"
			. += "</div>"
		if(scatter)
			. += "<div><img src='[resource("images/tooltips/temp_scatter.png")]' alt='' class='icon' /></div>"
		if(spread_angle)
			. += "<div><img src='[resource("images/tooltips/temp_spread.png")]' alt='' class='icon' /><span>Spread Modifier: [src.spread_angle] </span></div>"
		if(lensing)
			. += "<div><img src='[resource("images/tooltips/lensing.png")]' alt='' class='icon' /><span>Optical Lens: [src.lensing] </span></div>"
		if(length)
			. += "<div><span>Barrel length: [src.length] </span></div>"
		if(jam_frequency_fire || jam_frequency_reload)
			. += "<div><img src='[resource("images/tooltips/jamjarrd.png")]' alt='' class='icon' /><span>Jam Probability: [src.jam_frequency_reload + src.jam_frequency_fire] </span></div>"
		if(max_ammo_capacity)
			. += "<div> <span>Capacity Modifier: [src.max_ammo_capacity] </span></div>"
		lastTooltipContent = .



ABSTRACT_TYPE(/obj/item/gun_parts/barrel)
/obj/item/gun_parts/barrel/
// useful vars
	part_type = "barrel"
	spread_angle = 0// remove barrel penalty
	silenced = 0
	muzzle_flash = "muzzle_flash"
	lensing = 0 // Variable used for optical gun barrels. Scalar around 1.0
	jam_frequency_fire = 1 //additional % chance to jam on fire. Reload to clear.
	scatter = 0
	icon = 'icons/obj/items/cet_guns/barrels.dmi'
	icon_state = "it_revolver"
	length = STANDARD_BARREL_LEN
	//overlay_x = 10
	//overlay_y = 4
	// for uniformity, barrels should start on the 2nd pixel of the frame
	// and roughly centered vertically, obviously.
	// use these offsets if your sprite doesnt match that.

	add_part_to_gun(var/obj/item/gun/modular/gun)
		overlay_x += gun.barrel_overlay_x
		overlay_y += gun.barrel_overlay_y
		..()
		if(!my_gun)
			return
		my_gun.barrel = src
		my_gun.spread_angle = max(0, (my_gun.spread_angle + src.spread_angle)) // so we cant dip below 0
		my_gun.silenced = src.silenced
		my_gun.muzzle_flash = src.muzzle_flash
		my_gun.lensing = src.lensing
		my_gun.scatter = src.scatter
		my_gun.jam_frequency_fire += src.jam_frequency_fire
		my_gun.name = my_gun.name + " " + src.name_addition
		//Icon! :)



	remove_part_from_gun()
		if(!my_gun)
			return

		. = ..()

ABSTRACT_TYPE(/obj/item/gun_parts/stock)
/obj/item/gun_parts/stock/
	//add a var for a power cell later
	part_type = "stock"
	can_dual_wield = 1
	spread_angle = 0 // modifier, added to stock
	max_ammo_capacity = 0 //modifier
	flashbulb_only = 0 // FOSS guns only
	max_crank_level = 0 // FOSS guns only
	stock_two_handed = 0 // if gun or stock is 2 handed, whole gun is 2 handed
	stock_dual_wield = 1 // if gun AND stock can be dual wielded, whole gun can be dual wielded.
	jam_frequency_reload = 0 //attitional % chance to jam on reload. Just reload again to clear.
	var/list/ammo_list = list() // ammo that stays in the stock when removed
	icon_state = "nt_wire_alt"
	icon = 'icons/obj/items/cet_guns/stocks.dmi'
	//overlay_x = -10
	// for uniformity, shoulder stocks should end at the 16th pixel.
	// add an overlay_x if your stock is too long to fit.
	// pistol grips are roughly centered also probabl, use stock_overlay_x and y to move them around your gun.



	add_part_to_gun(var/obj/item/gun/modular/gun)
		overlay_x += gun.stock_overlay_x
		overlay_y += gun.stock_overlay_y
		..()
		if(!my_gun)
			return
		if(part_type == "stock")
			my_gun.stock = src
			my_gun.can_dual_wield = src.can_dual_wield
		else //foregrip
			my_gun.stock2 = src
		my_gun.max_ammo_capacity += src.max_ammo_capacity
		my_gun.spread_angle = max(0, (my_gun.spread_angle + src.spread_angle)) // so we cant dip below 0
		my_gun.two_handed |= src.stock_two_handed // if either the stock or the gun design is 2-handed, so is the assy.
		my_gun.can_dual_wield &= src.stock_dual_wield
		my_gun.jam_frequency_reload += src.jam_frequency_reload
		my_gun.ammo_list += src.ammo_list
		my_gun.name = src.name_addition + " " + my_gun.name
		if(flashbulb_only)
			my_gun.flashbulb_only = src.flashbulb_only
			my_gun.max_crank_level = src.max_crank_level
		else
			my_gun.flashbulb_only = 0
			my_gun.max_crank_level = 0

	remove_part_from_gun()
		if(!my_gun)
			return
		if(my_gun.ammo_list.len)
			var/total = ((my_gun.ammo_list.len > src.max_ammo_capacity) ? max_ammo_capacity : 0)
			src.ammo_list = my_gun.ammo_list.Copy(1,(total))
			my_gun.ammo_list.Cut(1,(total))
		. = ..()

ABSTRACT_TYPE(/obj/item/gun_parts/magazine)
/obj/item/gun_parts/magazine/

	part_type = "magazine"
	max_ammo_capacity = 0 //modifier
	jam_frequency_reload = 5 //additional % chance to jam on reload. Just reload again to clear.
	var/list/ammo_list = list() // ammo that stays in the mag when removed

	icon_state = "generic_magazine"
	contraband = 1

	add_part_to_gun()
		..()
		if(!my_gun)
			return
		my_gun.magazine = src
		my_gun.ammo_list += src.ammo_list
		my_gun.max_ammo_capacity += src.max_ammo_capacity
		my_gun.jam_frequency_reload += src.jam_frequency_reload
		my_gun.name = my_gun.name + " " + src.name_addition

	remove_part_from_gun()
		if(!my_gun)
			return
		my_gun.magazine = null
		if(my_gun.ammo_list.len)
			var/total = ((my_gun.ammo_list.len > src.max_ammo_capacity) ? max_ammo_capacity : 0)
			src.ammo_list = my_gun.ammo_list.Copy(1,(total))
			my_gun.ammo_list.Cut(1,(total))

		. = ..()

ABSTRACT_TYPE(/obj/item/gun_parts/accessory)
/obj/item/gun_parts/accessory/
	var/alt_fire = 0 //does this accessory offer an alt-mode? light perhaps?
	var/call_on_fire = 0 // does the gun call this accessory's on_fire() proc?
	part_type = "accessory"
	icon_state = "generic_magazine"
	overlay_y = 10

	proc/alt_fire()
		return alt_fire

	proc/on_fire()
		return call_on_fire

	add_part_to_gun()
		..()
		if(!my_gun)
			return
		my_gun.accessory = src
		my_gun.accessory_alt = alt_fire
		my_gun.accessory_on_fire = call_on_fire
		my_gun.name = src.name_addition + " " + my_gun.name



	remove_part_from_gun()
		if(!my_gun)
			return

		. = ..()




// NOW WE HAVE THE INSTANCIBLE TYPES

// BASIC BARRELS

/obj/item/gun_parts/barrel/NT
	name = "standard barrel"
	desc = "A cylindrical barrel, unrifled."
	spread_angle = 1 // basic stabilisation
	part_DRM = GUN_NANO | GUN_JUICE | GUN_ITALIAN
	icon_state = "nt_blue_short"
	length = 16
	//overlay_x = 23
	//overlay_y = -1

/obj/item/gun_parts/barrel/NT/long
	name = "standard long barrel"
	desc = "A cylindrical barrel, rifled."
	spread_angle = 0
	name_addition = "longarm"
	icon_state = "nt_blue"
	length = 35

/obj/item/gun_parts/barrel/NT/short
	name = "standard snub barrel"
	spread_angle = 4
	length = 9
	icon_state = "nt_blue_snub"
	name_addition = "shortie"

/obj/item/gun_parts/barrel/NT/long/very
	name = "special long barrel"
	desc = "A cylindrical barrel, rifled."
	spread_angle = -1
	name_addition = "polearm"
	icon_state = "nt_blue_very"
	length = 50
	//overlay_x = 5
	icon = 'icons/obj/items/cet_guns/64.dmi'

/obj/item/gun_parts/barrel/foss
	name = "\improper FOSS lensed barrel"
	desc = "A cylindrical array of lenses to focus laser blasts."
	spread_angle = 2
	lensing = 0.9
	part_DRM = GUN_FOSS | GUN_SOVIET | GUN_JUICE
	name_addition = "lenser"
	icon = 'icons/obj/items/cet_guns/fossgun.dmi'
	icon_state = "barrel_short"
	contraband = 1
	length = 17
	//overlay_x = 18
	//overlay_y = 2

/obj/item/gun_parts/barrel/foss/long
	name = "\improper FOSS lensed long barrel"
	desc = "A cylindrical array of lenses to focus laser blasts."
	spread_angle = 1
	lensing = 1
	name_addition = "focuser"
	icon_state = "barrel_long"
	length = 39

/obj/item/gun_parts/barrel/foss/long/very
	name = "\improper FOSS ultra lensed barrel"
	desc = "A hyperbolic array of lenses to focus laser blasts."
	spread_angle = -1
	lensing = 0.85
	name_addition = "catalyst"
	icon = 'icons/obj/items/cet_guns/64.dmi'
	icon_state = "foss_very_long"
	length = 50

/obj/item/gun_parts/barrel/juicer
	name = "\improper BLUNDA Barrel"
	desc = "A cheaply-built shotgun barrel. Not great."
	spread_angle =  13 // jesus christ it's a spread machine
	scatter = 1
	jam_frequency_fire = 5 //but very poorly built
	part_DRM = GUN_JUICE | GUN_NANO | GUN_FOSS
	name_addition = "BLUNDER"
	icon_state = "juicer_blunderbuss"
	length = 12
	//overlay_y = -1

/obj/item/gun_parts/barrel/juicer/chub
	name = "\improper BUSTIN Barrel"
	spread_angle = 6
	length = 25
	icon_state = "juicer_chub"
	name_addition = "BUSTER"

/obj/item/gun_parts/barrel/juicer/longer
	name = "\improper SNIPA Barrel"
	desc = "A cheaply-built extended rifled shotgun barrel. Not good."
	spread_angle =  4 // accurate?? ish?
	jam_frequency_fire = 15 //but very!!!!!!! poorly built
	name_addition = "BLITZER"
	icon_state = "juicer_long"
	length = 40

/obj/item/gun_parts/barrel/soviet
	name = "soviet lenses"
	desc = "стопка линз для фокусировки вашего пистолета"
	spread_angle =  5
	lensing = 1.2
	part_DRM = GUN_FOSS | GUN_SOVIET | GUN_ITALIAN
	name_addition = "comrade"
	icon_state = "soviet_lens"
	length = 16
	//overlay_x = 8

/obj/item/gun_parts/barrel/soviet/long
	name = "long soviet lenses"
	desc = "стопка линз для фокусировки вашего пистолета"
	spread_angle = 3
	lensing = 1.4
	name_addition = "tovarisch"
	icon_state = "soviet_lens_long"
	length = 22

/obj/item/gun_parts/barrel/italian
	name = "canna di fucile"
	desc = "una canna di fucile di base e di alta qualità"
	spread_angle = 9 // "alta qualità"
	part_DRM = GUN_NANO | GUN_ITALIAN | GUN_SOVIET
	name_addition = "paisan"
	icon_state = "it_revolver_short"
	length = 13

// BASIC STOCKS
// Stocks should always have a negative spread angle unless they're particularly cumbersome.
// those ones probably add functionality that offsets the +ve spread?

/obj/item/gun_parts/stock/NT
	name = "standard grip"
	desc = "A comfortable NT pistol grip"
	spread_angle = -3 // basic stabilisation
	part_DRM = GUN_NANO | GUN_JUICE | GUN_ITALIAN
	name_addition = "trusty"
	icon = 'icons/obj/items/cet_guns/grips.dmi'
	icon_state = "nt_blue"
	overlay_y = -1

	guardless
		name = "guardless standard grip"
		icon_state = "nt_blue_guardless"
		name_addition = "rusty"

	ceremonial
		name = "ceremonial standard grip"
		icon_state = "nt_ceremonial"
		name_addition = "shmancy"

	fancy
		name = "fancy standard grip"
		icon_state = "nt_fancy"
		name_addition = "fancy"

	stub
		name = "stub grip"
		icon_state = "nt_stub"
		spread_angle = -1
		name_addition = "stubby"

/obj/item/gun_parts/stock/NT/shoulder
	name = "standard stock"
	desc = "A comfortable NT shoulder stock"
	spread_angle = -4 // better stabilisation
	stock_two_handed = 1
	can_dual_wield = 0
	max_ammo_capacity = 1 // additional shot in the butt
	jam_frequency_reload = 2 // a little more jammy
	icon = 'icons/obj/items/cet_guns/stocks.dmi'
	name_addition = "sturdy"
	icon_state = "nt_blue"
	overlay_x = -2
	overlay_y = 1

/obj/item/gun_parts/stock/NT/arm_brace
	name = "standard brace"
	desc = "A comfortable NT forearm brace"
	spread_angle = -6 // quite better stabilisation
	stock_two_handed = 0
	can_dual_wield = 0
	max_ammo_capacity = 1 // additional shot in the butt
	jam_frequency_reload = 3 // a little more jammy
	icon = 'icons/obj/items/cet_guns/stocks.dmi'
	name_addition = "capable"
	icon_state = "nt_wire"
	//overlay_x = -19

/obj/item/gun_parts/stock/foss
	name = "\improper FOSS laser stock"
	desc = "An open-sourced laser dynamo, with a multiple-position winding spring."
	spread_angle = -3 // basic stabilisation
	part_DRM = GUN_FOSS | GUN_SOVIET // | GUN_JUICE
	flashbulb_only = 1
	max_crank_level = 2

	name_addition = "agile"
	icon = 'icons/obj/items/cet_guns/fossgun.dmi'
	icon_state = "stock_single"
	//overlay_x = -20

/obj/item/gun_parts/stock/foss/long
	name = "\improper FOSS laser rifle stock"
	spread_angle = -4 // better stabilisation
	stock_two_handed = 1
	can_dual_wield = 0
	max_crank_level = 3 // for syndicate ops
	name_addition = "lean"

/obj/item/gun_parts/stock/foss/loader
	name = "\improper FOSS laser loader stock"
	desc = "An open-sourced laser dynamo, with a multiple-position winding spring. This one's kind of hard to hold."
	spread_angle = 7 //  O NO
	max_ammo_capacity = 1 // more bulbs in the pocket
	jam_frequency_reload = 10
	name_addition = "robust"
	icon_state = "stock_double"

/obj/item/gun_parts/stock/foss/longer
	name = "\improper FOSS laser punt gun stock"
	spread_angle = 3 // poor stabilisation
	stock_two_handed = 1
	can_dual_wield = 0
	max_crank_level = 4 // for syndicate ops
	jam_frequency_reload = 5 // a little more jammy
	name_addition = "six-sigma"
	icon_state = "stock_double_alt"

/obj/item/gun_parts/stock/italian
	name = "impugnatura a pistola"
	desc = "un'impugnatura rivestita in cuoio toscano per un revolver di alta qualità"
	spread_angle = 0
	max_ammo_capacity = 1 // to make that revolver revolve!
	jam_frequency_reload = 5 // a lot  more jammy!!
	part_DRM = GUN_NANO | GUN_ITALIAN | GUN_SOVIET
	icon = 'icons/obj/items/cet_guns/grips.dmi'
	icon_state = "it_plain"
	name_addition = "quality"

/obj/item/gun_parts/stock/italian/bigger
	name = "impugnatura a pistola piu larga"
	desc = "un'impugnatura rivestita in cuoio toscano per un revolver di alta qualità"
	spread_angle = -1
	max_ammo_capacity = 3 // to make that revolver revolve!
	jam_frequency_reload = 9 // a lot  more jammy!!
	icon_state = "it_fancy"
	name_addition = "jovial"


/obj/item/gun_parts/stock/juicer
	name = "da grip"
	desc = "some kind of knockoff tacticool pistol grip"
	spread_angle = -3
	icon = 'icons/obj/items/cet_guns/grips.dmi'
	icon_state = "white"
	name_addition = "strapped"

	stub
		name = "da stub"
		desc = "some kind of stubbed tacticool pistol grip"
		spread_angle = -1
		icon_state = "short_white"
		name_addition = "Fukt UP"

	red
		name = "redgrip"
		icon_state = "red"

	black
		icon_state = "black"

	trans
		name = "da brick"
		icon_state = "trans"
		throwforce = 10 // hehe
		name_addition = "queer"

// BASIC ACCESSORIES
	// flashlight!!
	// grenade launcher!!
	// a horn!!
/obj/item/gun_parts/accessory/horn
	name = "Tactical Alerter"
	desc = "Efficiently alerts your squadron within miliseconds of target engagement, using cutting edge over-the-airwaves technology"
	call_on_fire = 1
	name_addition = "tactical"
	icon = 'icons/obj/instruments.dmi'
	icon_state = "bike_horn"

	on_fire()
		playsound(src.my_gun.loc, pick('sound/musical_instruments/Bikehorn_bonk1.ogg', 'sound/musical_instruments/Bikehorn_bonk2.ogg', 'sound/musical_instruments/Bikehorn_bonk3.ogg'), 50, 1, -1)



// No such thing as a basic magazine! they're all bullshit!!
/obj/item/gun_parts/magazine/juicer
	name = "HOTT SHOTTS MAG"
	desc = "Holds 3 rounds, and 30,000 followers."
	max_ammo_capacity = 3
	jam_frequency_reload = 8
	name_addition = "LARGE"
	icon_state = "juicer_drum"
	overlay_y = 8

