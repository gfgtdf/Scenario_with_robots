-- i think a wml/xml type would be more fitting for these "data with no progrmamming code" files.
-- but i dont know a efficent way to load wml dynamicly from lua.

-- TODO: "segoe print" is a MS font, so i have to look for a better option
-- but since i discard making a campaign i dont need the handwriting font anyway.
-- so this is not really important
local book_manual = {
	name = "diary of aaa",
	pages = {
	{ text = "<span font='segoe print'>Robot Manual:\n" ..
		" \n" ..
		"How to edit the robot 2\n" ..
		"Hot to get components 5\n" ..
		"Advancing and levelups with robots 6\n" ..
		"Description of special parts 7\n" ..
		"\n" ..
		"\n" ..
		"\n" ..
		"\n" ..
		"\n" ..
		"Use this book by clicking on a Page.\n" ..
		"Or use the textbox on the bottom\n" ..
		"to jump to page xx\n" ..
		"</span>"},
	{ text = "<span font='segoe print'>How to edit the robot:\n" ..
		" \n" ..
		"right click the robot and then \"edit robot\"\n" ..
		"that is only posible, if the robot\n" ..
		"stands on a castle, and didn't attack\n" ..
		"in that turn yet.\n" ..
		"click in the downer grid to choose a\n" ..
		"component, and then in the upper grid to\n" ..
		"place the component.\n" ..
		"The number of under the components shows\n" ..
		"how many of them are available.\n" ..
		"click on the first empty field to\n" ..
		"remove components.\n" ..
		"then confirm by clicking \"ok\"\n" ..
		"</span>"},
	{ text = "<span font='segoe print'>\n" ..
		" \n" ..
		"note, that after you cklick \"ok\",\n" ..
		"all unconnected componeents will be\n" ..
		"removed.\n" ..
		"\n" ..
		"\n" ..
		"\n" ..
		"\n" ..
		"\n" ..
		"\n" ..
		"\n" ..
		"\n" ..
		"" ..
		"</span>"
	},
	{ text = "<span font='segoe print'>A Picture of the Edit Robot field:\n" ..
		"\n" ..
		"\n" ..
		"\n" ..
		"\n" ..
		"\n" ..
		"\n" ..
		"\n" ..
		"\n" ..
		"\n" ..
		"\n" ..
		"\n" ..
		"\n" ..
		"" ..
		"</span>",
		grapics = { { name = "misc/edit_sample.png", x = 100, y = 100, h = 320, w = 275 } },
	},
	{ text = "<span font='segoe print'>How to get components:\n" ..
		" \n" ..
		"For every robot you recruit, you get a \n" ..
		"certain amount of components.\n" ..
		"(1 wheel, 1 weapon, 4 pipes, 2 random)\n" ..
		"You also get a random component every \n" ..
		"new turn.\n" ..
		"the third way is to buy them.\n" ..
		"To buy components right-click anywhere\n" ..
		"and then click \"buy components\"\n" ..
		"\n" ..
		"\n" ..
		"\n" ..
		"\n" ..
		"\n" ..
		"</span>"},
	{ text = "<span font='segoe print'>Advancing and levelups with robots:\n" ..
		"\n" ..
		"for every levelup the edit-field of\n" ..
		"the robot grows, the other stats (exept hp)\n" ..
		"remain the same\n" ..
		"the advacements a robot can get \n" ..
		"depend on his components\n" ..
		"\n" ..
		"\n" ..
		"\n" ..
		"\n" ..
		"\n" ..
		"\n" ..
		"\n" ..
		"</span>"},
	{ text = "<span font='segoe print'>Description of special parts:\n" ..
		"\n" ..
		"There is an items called \"core\" that is always\n" ..
		"once available. any robot won't work\n" ..
		"without that every other comonent has to be\n" ..
		"connected to the core with pipes.\n" ..
		"More informations are available in the\n" ..
		"tooltip of the edit window\n" ..
		"\n" ..
		"\n" ..
		"\n" ..
		"\n" ..
		"\n" ..
		"\n" ..
		"</span>"},
	{ text = "<span font='Lindsey'>Day 18:\n" ..
		" \n" ..
		"I just developed a new component for the\n" ..
		"robots. It is a propeller and it is really\n" ..
		"useful: by putting a lot of propellers \n" ..
		"on the robot i was able to make him fly\n" ..
		"here a picture of it:\n" ..
		"\n" ..
		"\n" ..
		"\n" ..
		"\n" ..
		"\n" ..
		"\n" ..
		"\n" ..
		"</span>",
		grapics = { { name = "misc/propeller.png", x = 30, y = 300, h = 250, w = 250 } },
	}}}
return book_manual