local Keys = {
	['ESC'] = 322, ['F1'] = 288, ['F2'] = 289, ['F3'] = 170, ['F5'] = 166, ['F6'] = 167, ['F7'] = 168, ['F8'] = 169, ['F9'] = 56, ['F10'] = 57, 
	['~'] = 243, ['1'] = 157, ['2'] = 158, ['3'] = 160, ['4'] = 164, ['5'] = 165, ['6'] = 159, ['7'] = 161, ['8'] = 162, ['9'] = 163, ['-'] = 84, ['='] = 83, ['BACKSPACE'] = 177, 
	['TAB'] = 37, ['Q'] = 44, ['W'] = 32, ['E'] = 38, ['R'] = 45, ['T'] = 245, ['Y'] = 246, ['U'] = 303, ['P'] = 199, ['['] = 39, [']'] = 40, ['ENTER'] = 18,
	['CAPS'] = 137, ['A'] = 34, ['S'] = 8, ['D'] = 9, ['F'] = 23, ['G'] = 47, ['H'] = 74, ['K'] = 311, ['L'] = 182,
	['LEFTSHIFT'] = 21, ['Z'] = 20, ['X'] = 73, ['C'] = 26, ['V'] = 0, ['B'] = 29, ['N'] = 249, ['M'] = 244, [','] = 82, ['.'] = 81,
	['LEFTCTRL'] = 36, ['LEFTALT'] = 19, ['SPACE'] = 22, ['RIGHTCTRL'] = 70, 
	['HOME'] = 213, ['PAGEUP'] = 10, ['PAGEDOWN'] = 11, ['DELETE'] = 178,
	['LEFT'] = 174, ['RIGHT'] = 175, ['TOP'] = 27, ['DOWN'] = 173,
	['NENTER'] = 201, ['N4'] = 108, ['N5'] = 60, ['N6'] = 107, ['N+'] = 96, ['N-'] = 97, ['N7'] = 117, ['N8'] = 61, ['N9'] = 118
}

Config = {}
Config.Locale = 'de'

Config.UseItemPerso = false

Config.servername = 'XXXX RolePlay' -- change it to you're server name
Config.doublejob = false -- enable if you're using esx double job
Config.noclip_speed = 4.0 -- change it to change the speed in noclip --Standart für den server ist 2.0

Config.EnableJsfourIDCard = true-- enable if you're using jsfour-idcard

-- GENERAL
Config.Menu = {
	clavier = Keys['F5']
}

Config.handsUP = {
    clavier = Keys['M']
}

Config.pointing = {
	clavier = Keys['B']
}

Config.stopAnim = {
	clavier = Keys['X']
}

Config.crouch = {
	clavier = Keys['LEFTCTRL']
}

Config.TPMarker = {
	clavier1 = Keys['LEFTALT'],
	clavier2 = Keys['E']
}
Config.mTitle = "Auto Menu"
Config.mBG = {'shopui_title_ie_modgarage','shopui_title_ie_modgarage'} -- interaction_bgd = Blue, gradient_bgd = Black.

Config.menuKey = 344

--- Don't touch :)
--- You can touch if you want to change the language?
Config.doors = {
    [1] = "Front Left",
    [2] = "Front Right" ,
    [3] = "Back Left",
    [4] = "Back Right",
    [5] = "Hood" ,
    [6] = "Trunk",  
    [7] = "Back" , 
    [8] = "Back 2"  
}

Config.windows = {
    [1] = "Front Left",
    [2] = "Front Right" ,
    [3] = "Back Left",
    [4] = "Back Right",
}