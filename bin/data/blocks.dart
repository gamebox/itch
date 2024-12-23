const blocks = """
[
  {
    "opcode": "control_forever",
    "args": [
      {
        "type": "input_statement",
        "name": "SUBSTACK"
      },
      {
        "type": "field_image",
        "src": "repeat.svg",
        "width": 24,
        "height": 24,
        "alt": "*",
        "flip_rtl": true
      }
    ],
    "category": "control",
    "blockLabel": "forever {}"
  },
  {
    "opcode": "control_repeat",
    "args": [
      {
        "type": "input_value",
        "name": "TIMES"
      },
      {
        "type": "input_statement",
        "name": "SUBSTACK"
      },
      {
        "type": "field_image",
        "src": "repeat.svg",
        "width": 24,
        "height": 24,
        "alt": "*",
        "flip_rtl": true
      }
    ],
    "category": "control",
    "blockLabel": "repeat () {}"
  },
  {
    "opcode": "control_if",
    "args": [
      {
        "type": "input_value",
        "name": "CONDITION",
        "check": "Boolean"
      },
      {
        "type": "input_statement",
        "name": "SUBSTACK"
      }
    ],
    "category": "control",
    "blockLabel": "if () then {}"
  },
  {
    "opcode": "control_if_else",
    "args": [
      {
        "type": "input_value",
        "name": "CONDITION",
        "check": "Boolean"
      },
      {
        "type": "input_statement",
        "name": "SUBSTACK"
      },
      {
        "type": "input_statement",
        "name": "SUBSTACK2"
      }
    ],
    "category": "control",
    "blockLabel": "if () then {} else {}"
  },
  {
    "opcode": "control_stop",
    "args": [
      {
        "type": "field_dropdown",
        "name": "STOP_OPTION",
        "options": [
          [
            "all",
            "all"
          ],
          [
            "this script",
            "this script"
          ],
          [
            "other scripts in sprite",
            "other scripts in sprite"
          ]
        ]
      }
    ],
    "category": "control",
    "blockLabel": "stop ()"
  },
  {
    "opcode": "control_wait",
    "args": [
      {
        "type": "input_value",
        "name": "DURATION"
      }
    ],
    "category": "control",
    "blockLabel": "wait () seconds"
  },
  {
    "opcode": "control_wait_until",
    "args": [
      {
        "type": "input_value",
        "name": "CONDITION",
        "check": "Boolean"
      }
    ],
    "category": "control",
    "blockLabel": "wait until ()"
  },
  {
    "opcode": "control_repeat_until",
    "args": [
      {
        "type": "input_value",
        "name": "CONDITION",
        "check": "Boolean"
      },
      {
        "type": "input_statement",
        "name": "SUBSTACK"
      },
      {
        "type": "field_image",
        "src": "repeat.svg",
        "width": 24,
        "height": 24,
        "alt": "*",
        "flip_rtl": true
      }
    ],
    "category": "control",
    "blockLabel": "repeat until () {}"
  },
  {
    "opcode": "control_while",
    "args": [
      {
        "type": "input_value",
        "name": "CONDITION",
        "check": "Boolean"
      },
      {
        "type": "input_statement",
        "name": "SUBSTACK"
      },
      {
        "type": "field_image",
        "src": "repeat.svg",
        "width": 24,
        "height": 24,
        "alt": "*",
        "flip_rtl": true
      }
    ],
    "category": "control",
    "blockLabel": "while () {}"
  },
  {
    "opcode": "control_for_each",
    "args": [
      {
        "type": "field_variable",
        "name": "VARIABLE"
      },
      {
        "type": "input_value",
        "name": "VALUE"
      },
      {
        "type": "input_statement",
        "name": "SUBSTACK"
      }
    ],
    "category": "control",
    "blockLabel": "for each () in () {}"
  },
  {
    "opcode": "control_start_as_clone",
    "args": [],
    "category": "control",
    "blockLabel": "when I start as a clone"
  },
  {
    "opcode": "control_create_clone_of_menu",
    "args": [
      {
        "type": "field_dropdown",
        "name": "CLONE_OPTION",
        "options": [
          [
            "myself",
            "_myself_"
          ]
        ],
        "hasMenu": true
      }
    ],
    "blockLabel": "()"
  },
  {
    "opcode": "control_create_clone_of",
    "args": [
      {
        "type": "input_value",
        "name": "CLONE_OPTION",
        "hasMenu": true
      }
    ],
    "category": "control",
    "blockLabel": "create clone of ()"
  },
  {
    "opcode": "control_delete_this_clone",
    "args": [],
    "category": "control",
    "blockLabel": "delete this clone"
  },
  {
    "opcode": "control_get_counter",
    "args": [],
    "category": "control",
    "blockLabel": "counter"
  },
  {
    "opcode": "control_incr_counter",
    "args": [],
    "category": "control",
    "blockLabel": "increment counter"
  },
  {
    "opcode": "control_clear_counter",
    "args": [],
    "category": "control",
    "blockLabel": "clear counter"
  },
  {
    "opcode": "control_all_at_once",
    "args": [
      {
        "type": "input_statement",
        "name": "SUBSTACK"
      }
    ],
    "category": "control",
    "blockLabel": "all at once {}"
  },
  {
    "opcode": "data_variable",
    "args": [
      {
        "type": "field_variable_getter",
        "text": "",
        "name": "VARIABLE",
        "variableType": ""
      }
    ],
    "category": "data",
    "blockLabel": "()"
  },
  {
    "opcode": "data_setvariableto",
    "args": [
      {
        "type": "field_variable",
        "name": "VARIABLE"
      },
      {
        "type": "input_value",
        "name": "VALUE"
      }
    ],
    "category": "data",
    "blockLabel": "set () to ()"
  },
  {
    "opcode": "data_changevariableby",
    "args": [
      {
        "type": "field_variable",
        "name": "VARIABLE"
      },
      {
        "type": "input_value",
        "name": "VALUE"
      }
    ],
    "category": "data",
    "blockLabel": "change () by ()"
  },
  {
    "opcode": "data_showvariable",
    "args": [
      {
        "type": "field_variable",
        "name": "VARIABLE"
      }
    ],
    "category": "data",
    "blockLabel": "show variable ()"
  },
  {
    "opcode": "data_hidevariable",
    "args": [
      {
        "type": "field_variable",
        "name": "VARIABLE"
      }
    ],
    "category": "data",
    "blockLabel": "hide variable ()"
  },
  {
    "opcode": "data_listcontents",
    "args": [
      {
        "type": "field_variable_getter",
        "text": "",
        "name": "LIST"
      }
    ],
    "blockLabel": "()"
  },
  {
    "opcode": "data_listindexall",
    "args": [
      {
        "type": "field_numberdropdown",
        "name": "INDEX",
        "value": "1",
        "min": 1,
        "precision": 1,
        "options": [
          [
            "1",
            "1"
          ],
          [
            "last",
            "last"
          ],
          [
            "all",
            "all"
          ]
        ]
      }
    ],
    "category": "data",
    "blockLabel": "()"
  },
  {
    "opcode": "data_listindexrandom",
    "args": [
      {
        "type": "field_numberdropdown",
        "name": "INDEX",
        "value": "1",
        "min": 1,
        "precision": 1,
        "options": [
          [
            "1",
            "1"
          ],
          [
            "last",
            "last"
          ],
          [
            "random",
            "random"
          ]
        ]
      }
    ],
    "category": "data",
    "blockLabel": "()"
  },
  {
    "opcode": "data_addtolist",
    "args": [
      {
        "type": "input_value",
        "name": "ITEM"
      },
      {
        "type": "field_variable",
        "name": "LIST",
        "variableTypes": [
          null
        ]
      }
    ],
    "blockLabel": "add () to ()"
  },
  {
    "opcode": "data_deleteoflist",
    "args": [
      {
        "type": "input_value",
        "name": "INDEX"
      },
      {
        "type": "field_variable",
        "name": "LIST",
        "variableTypes": [
          null
        ]
      }
    ],
    "blockLabel": "delete () of ()"
  },
  {
    "opcode": "data_deletealloflist",
    "args": [
      {
        "type": "field_variable",
        "name": "LIST",
        "variableTypes": [
          null
        ]
      }
    ],
    "blockLabel": "delete all of ()"
  },
  {
    "opcode": "data_insertatlist",
    "args": [
      {
        "type": "input_value",
        "name": "ITEM"
      },
      {
        "type": "input_value",
        "name": "INDEX"
      },
      {
        "type": "field_variable",
        "name": "LIST",
        "variableTypes": [
          null
        ]
      }
    ],
    "blockLabel": "insert () at () of ()"
  },
  {
    "opcode": "data_replaceitemoflist",
    "args": [
      {
        "type": "input_value",
        "name": "INDEX"
      },
      {
        "type": "field_variable",
        "name": "LIST",
        "variableTypes": [
          null
        ]
      },
      {
        "type": "input_value",
        "name": "ITEM"
      }
    ],
    "blockLabel": "replace item () of () with ()"
  },
  {
    "opcode": "data_itemoflist",
    "args": [
      {
        "type": "input_value",
        "name": "INDEX"
      },
      {
        "type": "field_variable",
        "name": "LIST",
        "variableTypes": [
          null
        ]
      }
    ],
    "blockLabel": "item () of ()"
  },
  {
    "opcode": "data_itemnumoflist",
    "args": [
      {
        "type": "input_value",
        "name": "ITEM"
      },
      {
        "type": "field_variable",
        "name": "LIST",
        "variableTypes": [
          null
        ]
      }
    ],
    "blockLabel": "item # of () in ()"
  },
  {
    "opcode": "data_lengthoflist",
    "args": [
      {
        "type": "field_variable",
        "name": "LIST",
        "variableTypes": [
          null
        ]
      }
    ],
    "blockLabel": "length of list ()"
  },
  {
    "opcode": "data_listcontainsitem",
    "args": [
      {
        "type": "field_variable",
        "name": "LIST",
        "variableTypes": [
          null
        ]
      },
      {
        "type": "input_value",
        "name": "ITEM"
      }
    ],
    "blockLabel": "list () contains ()?"
  },
  {
    "opcode": "data_showlist",
    "args": [
      {
        "type": "field_variable",
        "name": "LIST",
        "variableTypes": [
          null
        ]
      }
    ],
    "blockLabel": "show list ()"
  },
  {
    "opcode": "data_hidelist",
    "args": [
      {
        "type": "field_variable",
        "name": "LIST",
        "variableTypes": [
          null
        ]
      }
    ],
    "blockLabel": "hide list ()"
  },
  {
    "opcode": "event_whentouchingobject",
    "args": [
      {
        "type": "input_value",
        "name": "TOUCHINGOBJECTMENU",
        "hasMenu": true
      }
    ],
    "category": "event",
    "blockLabel": "when this sprite touches ()"
  },
  {
    "opcode": "event_touchingobjectmenu",
    "args": [
      {
        "type": "field_dropdown",
        "name": "TOUCHINGOBJECTMENU",
        "options": [
          [
            "mouse-pointer",
            "_mouse_"
          ],
          [
            "edge",
            "_edge_"
          ]
        ],
        "hasMenu": true
      }
    ],
    "blockLabel": "()"
  },
  {
    "opcode": "event_whenflagclicked",
    "args": [
      {
        "type": "field_image",
        "src": "green-flag.svg",
        "width": 24,
        "height": 24,
        "alt": "flag"
      }
    ],
    "category": "event",
    "blockLabel": "when flag clicked"
  },
  {
    "opcode": "event_whenthisspriteclicked",
    "args": [],
    "category": "event",
    "blockLabel": "when this sprite clicked"
  },
  {
    "opcode": "event_whenstageclicked",
    "args": [],
    "category": "event",
    "blockLabel": "when stage clicked"
  },
  {
    "opcode": "event_whenbroadcastreceived",
    "args": [
      {
        "type": "field_variable",
        "name": "BROADCAST_OPTION",
        "variableTypes": [
          null
        ],
        "variable": "message1"
      }
    ],
    "category": "event",
    "blockLabel": "when I receive ()"
  },
  {
    "opcode": "event_whenbackdropswitchesto",
    "args": [
      {
        "type": "field_dropdown",
        "name": "BACKDROP",
        "options": [
          [
            "backdrop1",
            "BACKDROP1"
          ]
        ],
        "hasMenu": true
      }
    ],
    "category": "event",
    "blockLabel": "when backdrop switches to ()"
  },
  {
    "opcode": "event_whengreaterthan",
    "args": [
      {
        "type": "field_dropdown",
        "name": "WHENGREATERTHANMENU",
        "options": [
          [
            "loudness",
            "LOUDNESS"
          ],
          [
            "timer",
            "TIMER"
          ]
        ]
      },
      {
        "type": "input_value",
        "name": "VALUE"
      }
    ],
    "category": "event",
    "blockLabel": "when () > ()"
  },
  {
    "opcode": "event_broadcast_menu",
    "args": [
      {
        "type": "field_variable",
        "name": "BROADCAST_OPTION",
        "variableTypes": [
          null
        ],
        "variable": "message1"
      }
    ],
    "blockLabel": "()"
  },
  {
    "opcode": "event_broadcast",
    "args": [
      {
        "type": "input_value",
        "name": "BROADCAST_INPUT"
      }
    ],
    "category": "event",
    "blockLabel": "broadcast ()"
  },
  {
    "opcode": "event_broadcastandwait",
    "args": [
      {
        "type": "input_value",
        "name": "BROADCAST_INPUT"
      }
    ],
    "category": "event",
    "blockLabel": "broadcast () and wait"
  },
  {
    "opcode": "event_whenkeypressed",
    "args": [
      {
        "type": "field_dropdown",
        "name": "KEY_OPTION",
        "options": [
          [
            "space",
            "space"
          ],
          [
            "up arrow",
            "up arrow"
          ],
          [
            "down arrow",
            "down arrow"
          ],
          [
            "right arrow",
            "right arrow"
          ],
          [
            "left arrow",
            "left arrow"
          ],
          [
            "any",
            "any"
          ],
          [
            "a",
            "a"
          ],
          [
            "b",
            "b"
          ],
          [
            "c",
            "c"
          ],
          [
            "d",
            "d"
          ],
          [
            "e",
            "e"
          ],
          [
            "f",
            "f"
          ],
          [
            "g",
            "g"
          ],
          [
            "h",
            "h"
          ],
          [
            "i",
            "i"
          ],
          [
            "j",
            "j"
          ],
          [
            "k",
            "k"
          ],
          [
            "l",
            "l"
          ],
          [
            "m",
            "m"
          ],
          [
            "n",
            "n"
          ],
          [
            "o",
            "o"
          ],
          [
            "p",
            "p"
          ],
          [
            "q",
            "q"
          ],
          [
            "r",
            "r"
          ],
          [
            "s",
            "s"
          ],
          [
            "t",
            "t"
          ],
          [
            "u",
            "u"
          ],
          [
            "v",
            "v"
          ],
          [
            "w",
            "w"
          ],
          [
            "x",
            "x"
          ],
          [
            "y",
            "y"
          ],
          [
            "z",
            "z"
          ],
          [
            "0",
            "0"
          ],
          [
            "1",
            "1"
          ],
          [
            "2",
            "2"
          ],
          [
            "3",
            "3"
          ],
          [
            "4",
            "4"
          ],
          [
            "5",
            "5"
          ],
          [
            "6",
            "6"
          ],
          [
            "7",
            "7"
          ],
          [
            "8",
            "8"
          ],
          [
            "9",
            "9"
          ]
        ],
        "hasMenu": true
      }
    ],
    "category": "event",
    "blockLabel": "when () key pressed"
  },
  {
    "opcode": "looks_sayforsecs",
    "args": [
      {
        "type": "input_value",
        "name": "MESSAGE"
      },
      {
        "type": "input_value",
        "name": "SECS"
      }
    ],
    "category": "looks",
    "blockLabel": "say () for () seconds"
  },
  {
    "opcode": "looks_say",
    "args": [
      {
        "type": "input_value",
        "name": "MESSAGE"
      }
    ],
    "category": "looks",
    "blockLabel": "say ()"
  },
  {
    "opcode": "looks_thinkforsecs",
    "args": [
      {
        "type": "input_value",
        "name": "MESSAGE"
      },
      {
        "type": "input_value",
        "name": "SECS"
      }
    ],
    "category": "looks",
    "blockLabel": "think () for () seconds"
  },
  {
    "opcode": "looks_think",
    "args": [
      {
        "type": "input_value",
        "name": "MESSAGE"
      }
    ],
    "category": "looks",
    "blockLabel": "think ()"
  },
  {
    "opcode": "looks_show",
    "args": [],
    "category": "looks",
    "blockLabel": "show"
  },
  {
    "opcode": "looks_hide",
    "args": [],
    "category": "looks",
    "blockLabel": "hide"
  },
  {
    "opcode": "looks_hideallsprites",
    "args": [],
    "category": "looks",
    "blockLabel": "hide all sprites"
  },
  {
    "opcode": "looks_changeeffectby",
    "args": [
      {
        "type": "field_dropdown",
        "name": "EFFECT",
        "options": [
          [
            "color",
            "COLOR"
          ],
          [
            "fisheye",
            "FISHEYE"
          ],
          [
            "whirl",
            "WHIRL"
          ],
          [
            "pixelate",
            "PIXELATE"
          ],
          [
            "mosaic",
            "MOSAIC"
          ],
          [
            "brightness",
            "BRIGHTNESS"
          ],
          [
            "ghost",
            "GHOST"
          ]
        ]
      },
      {
        "type": "input_value",
        "name": "CHANGE"
      }
    ],
    "category": "looks",
    "blockLabel": "change () effect by ()"
  },
  {
    "opcode": "looks_seteffectto",
    "args": [
      {
        "type": "field_dropdown",
        "name": "EFFECT",
        "options": [
          [
            "color",
            "COLOR"
          ],
          [
            "fisheye",
            "FISHEYE"
          ],
          [
            "whirl",
            "WHIRL"
          ],
          [
            "pixelate",
            "PIXELATE"
          ],
          [
            "mosaic",
            "MOSAIC"
          ],
          [
            "brightness",
            "BRIGHTNESS"
          ],
          [
            "ghost",
            "GHOST"
          ]
        ]
      },
      {
        "type": "input_value",
        "name": "VALUE"
      }
    ],
    "category": "looks",
    "blockLabel": "set () effect to ()"
  },
  {
    "opcode": "looks_cleargraphiceffects",
    "args": [],
    "category": "looks",
    "blockLabel": "clear graphic effects"
  },
  {
    "opcode": "looks_changesizeby",
    "args": [
      {
        "type": "input_value",
        "name": "CHANGE"
      }
    ],
    "category": "looks",
    "blockLabel": "change size by ()"
  },
  {
    "opcode": "looks_setsizeto",
    "args": [
      {
        "type": "input_value",
        "name": "SIZE"
      }
    ],
    "category": "looks",
    "blockLabel": "set size to () %"
  },
  {
    "opcode": "looks_size",
    "args": [],
    "category": "looks",
    "blockLabel": "size"
  },
  {
    "opcode": "looks_changestretchby",
    "args": [
      {
        "type": "input_value",
        "name": "CHANGE"
      }
    ],
    "category": "looks",
    "blockLabel": "change stretch by ()"
  },
  {
    "opcode": "looks_setstretchto",
    "args": [
      {
        "type": "input_value",
        "name": "STRETCH"
      }
    ],
    "category": "looks",
    "blockLabel": "set stretch to () %"
  },
  {
    "opcode": "looks_costume",
    "args": [
      {
        "type": "field_dropdown",
        "name": "COSTUME",
        "options": [
          [
            "costume1",
            "COSTUME1"
          ],
          [
            "costume2",
            "COSTUME2"
          ]
        ],
        "hasMenu": true
      }
    ],
    "blockLabel": "()"
  },
  {
    "opcode": "looks_switchcostumeto",
    "args": [
      {
        "type": "input_value",
        "name": "COSTUME",
        "hasMenu": true
      }
    ],
    "category": "looks",
    "blockLabel": "switch costume to ()"
  },
  {
    "opcode": "looks_nextcostume",
    "args": [],
    "category": "looks",
    "blockLabel": "next costume"
  },
  {
    "opcode": "looks_switchbackdropto",
    "args": [
      {
        "type": "input_value",
        "name": "BACKDROP",
        "hasMenu": true
      }
    ],
    "category": "looks",
    "blockLabel": "switch backdrop to ()"
  },
  {
    "opcode": "looks_backdrops",
    "args": [
      {
        "type": "field_dropdown",
        "name": "BACKDROP",
        "options": [
          [
            "backdrop1",
            "BACKDROP1"
          ]
        ],
        "hasMenu": true
      }
    ],
    "blockLabel": "()"
  },
  {
    "opcode": "looks_gotofrontback",
    "args": [
      {
        "type": "field_dropdown",
        "name": "FRONT_BACK",
        "options": [
          [
            "front",
            "front"
          ],
          [
            "back",
            "back"
          ]
        ]
      }
    ],
    "category": "looks",
    "blockLabel": "go to () layer"
  },
  {
    "opcode": "looks_goforwardbackwardlayers",
    "args": [
      {
        "type": "field_dropdown",
        "name": "FORWARD_BACKWARD",
        "options": [
          [
            "forward",
            "forward"
          ],
          [
            "backward",
            "backward"
          ]
        ]
      },
      {
        "type": "input_value",
        "name": "NUM"
      }
    ],
    "category": "looks",
    "blockLabel": "go () () layers"
  },
  {
    "opcode": "looks_backdropnumbername",
    "args": [
      {
        "type": "field_dropdown",
        "name": "NUMBER_NAME",
        "options": [
          [
            "number",
            "number"
          ],
          [
            "name",
            "name"
          ]
        ]
      }
    ],
    "category": "looks",
    "blockLabel": "backdrop ()"
  },
  {
    "opcode": "looks_costumenumbername",
    "args": [
      {
        "type": "field_dropdown",
        "name": "NUMBER_NAME",
        "options": [
          [
            "number",
            "number"
          ],
          [
            "name",
            "name"
          ]
        ]
      }
    ],
    "category": "looks",
    "blockLabel": "costume ()"
  },
  {
    "opcode": "looks_switchbackdroptoandwait",
    "args": [
      {
        "type": "input_value",
        "name": "BACKDROP",
        "hasMenu": true
      }
    ],
    "category": "looks",
    "blockLabel": "switch backdrop to () and wait"
  },
  {
    "opcode": "looks_nextbackdrop",
    "args": [],
    "category": "looks",
    "blockLabel": "next backdrop"
  },
  {
    "opcode": "motion_movesteps",
    "args": [
      {
        "type": "input_value",
        "name": "STEPS"
      }
    ],
    "category": "motion",
    "blockLabel": "move () steps"
  },
  {
    "opcode": "motion_turnright",
    "args": [
      {
        "type": "input_value",
        "name": "DEGREES"
      }
    ],
    "category": "motion",
    "blockLabel": "turn right () degrees"
  },
  {
    "opcode": "motion_turnleft",
    "args": [
      {
        "type": "input_value",
        "name": "DEGREES"
      }
    ],
    "category": "motion",
    "blockLabel": "turn left () degrees"
  },
  {
    "opcode": "motion_pointindirection",
    "args": [
      {
        "type": "input_value",
        "name": "DIRECTION"
      }
    ],
    "category": "motion",
    "blockLabel": "point in direction ()"
  },
  {
    "opcode": "motion_pointtowards_menu",
    "args": [
      {
        "type": "field_dropdown",
        "name": "TOWARDS",
        "options": [
          [
            "mouse-pointer",
            "_mouse_"
          ],
          [
            "random direction",
            "_random_"
          ]
        ],
        "hasMenu": true
      }
    ],
    "blockLabel": "()"
  },
  {
    "opcode": "motion_pointtowards",
    "args": [
      {
        "type": "input_value",
        "name": "TOWARDS",
        "hasMenu": true
      }
    ],
    "category": "motion",
    "blockLabel": "point towards ()"
  },
  {
    "opcode": "motion_goto_menu",
    "args": [
      {
        "type": "field_dropdown",
        "name": "TO",
        "options": [
          [
            "mouse-pointer",
            "_mouse_"
          ],
          [
            "random position",
            "_random_"
          ]
        ],
        "hasMenu": true
      }
    ],
    "blockLabel": "()"
  },
  {
    "opcode": "motion_gotoxy",
    "args": [
      {
        "type": "input_value",
        "name": "X"
      },
      {
        "type": "input_value",
        "name": "Y"
      }
    ],
    "category": "motion",
    "blockLabel": "go to x: () y: ()"
  },
  {
    "opcode": "motion_goto",
    "args": [
      {
        "type": "input_value",
        "name": "TO",
        "hasMenu": true
      }
    ],
    "category": "motion",
    "blockLabel": "go to ()"
  },
  {
    "opcode": "motion_glidesecstoxy",
    "args": [
      {
        "type": "input_value",
        "name": "SECS"
      },
      {
        "type": "input_value",
        "name": "X"
      },
      {
        "type": "input_value",
        "name": "Y"
      }
    ],
    "category": "motion",
    "blockLabel": "glide () secs to x: () y: ()"
  },
  {
    "opcode": "motion_glideto_menu",
    "args": [
      {
        "type": "field_dropdown",
        "name": "TO",
        "options": [
          [
            "mouse-pointer",
            "_mouse_"
          ],
          [
            "random position",
            "_random_"
          ]
        ],
        "hasMenu": true
      }
    ],
    "blockLabel": "()"
  },
  {
    "opcode": "motion_glideto",
    "args": [
      {
        "type": "input_value",
        "name": "SECS"
      },
      {
        "type": "input_value",
        "name": "TO",
        "hasMenu": true
      }
    ],
    "category": "motion",
    "blockLabel": "glide () secs to ()"
  },
  {
    "opcode": "motion_changexby",
    "args": [
      {
        "type": "input_value",
        "name": "DX"
      }
    ],
    "category": "motion",
    "blockLabel": "change x by ()"
  },
  {
    "opcode": "motion_setx",
    "args": [
      {
        "type": "input_value",
        "name": "X"
      }
    ],
    "category": "motion",
    "blockLabel": "set x to ()"
  },
  {
    "opcode": "motion_changeyby",
    "args": [
      {
        "type": "input_value",
        "name": "DY"
      }
    ],
    "category": "motion",
    "blockLabel": "change y by ()"
  },
  {
    "opcode": "motion_sety",
    "args": [
      {
        "type": "input_value",
        "name": "Y"
      }
    ],
    "category": "motion",
    "blockLabel": "set y to ()"
  },
  {
    "opcode": "motion_ifonedgebounce",
    "args": [],
    "category": "motion",
    "blockLabel": "if on edge, bounce"
  },
  {
    "opcode": "motion_setrotationstyle",
    "args": [
      {
        "type": "field_dropdown",
        "name": "STYLE",
        "options": [
          [
            "left-right",
            "left-right"
          ],
          [
            "don't rotate",
            "don't rotate"
          ],
          [
            "all around",
            "all around"
          ]
        ]
      }
    ],
    "category": "motion",
    "blockLabel": "set rotation style ()"
  },
  {
    "opcode": "motion_xposition",
    "args": [],
    "category": "motion",
    "blockLabel": "x position"
  },
  {
    "opcode": "motion_yposition",
    "args": [],
    "category": "motion",
    "blockLabel": "y position"
  },
  {
    "opcode": "motion_direction",
    "args": [],
    "category": "motion",
    "blockLabel": "direction"
  },
  {
    "opcode": "motion_scroll_right",
    "args": [
      {
        "type": "input_value",
        "name": "DISTANCE"
      }
    ],
    "category": "motion",
    "blockLabel": "scroll right ()"
  },
  {
    "opcode": "motion_scroll_up",
    "args": [
      {
        "type": "input_value",
        "name": "DISTANCE"
      }
    ],
    "category": "motion",
    "blockLabel": "scroll up ()"
  },
  {
    "opcode": "motion_align_scene",
    "args": [
      {
        "type": "field_dropdown",
        "name": "ALIGNMENT",
        "options": [
          [
            "bottom-left",
            "bottom-left"
          ],
          [
            "bottom-right",
            "bottom-right"
          ],
          [
            "middle",
            "middle"
          ],
          [
            "top-left",
            "top-left"
          ],
          [
            "top-right",
            "top-right"
          ]
        ]
      }
    ],
    "category": "motion",
    "blockLabel": "align scene ()"
  },
  {
    "opcode": "motion_xscroll",
    "args": [],
    "category": "motion",
    "blockLabel": "x scroll"
  },
  {
    "opcode": "motion_yscroll",
    "args": [],
    "category": "motion",
    "blockLabel": "y scroll"
  },
  {
    "opcode": "operator_add",
    "args": [
      {
        "type": "input_value",
        "name": "NUM1"
      },
      {
        "type": "input_value",
        "name": "NUM2"
      }
    ],
    "blockLabel": "() + ()"
  },
  {
    "opcode": "operator_subtract",
    "args": [
      {
        "type": "input_value",
        "name": "NUM1"
      },
      {
        "type": "input_value",
        "name": "NUM2"
      }
    ],
    "blockLabel": "() - ()"
  },
  {
    "opcode": "operator_multiply",
    "args": [
      {
        "type": "input_value",
        "name": "NUM1"
      },
      {
        "type": "input_value",
        "name": "NUM2"
      }
    ],
    "blockLabel": "() * ()"
  },
  {
    "opcode": "operator_divide",
    "args": [
      {
        "type": "input_value",
        "name": "NUM1"
      },
      {
        "type": "input_value",
        "name": "NUM2"
      }
    ],
    "blockLabel": "() / ()"
  },
  {
    "opcode": "operator_random",
    "args": [
      {
        "type": "input_value",
        "name": "FROM"
      },
      {
        "type": "input_value",
        "name": "TO"
      }
    ],
    "blockLabel": "pick random () to ()"
  },
  {
    "opcode": "operator_lt",
    "args": [
      {
        "type": "input_value",
        "name": "OPERAND1"
      },
      {
        "type": "input_value",
        "name": "OPERAND2"
      }
    ],
    "blockLabel": "() < ()"
  },
  {
    "opcode": "operator_equals",
    "args": [
      {
        "type": "input_value",
        "name": "OPERAND1"
      },
      {
        "type": "input_value",
        "name": "OPERAND2"
      }
    ],
    "blockLabel": "() = ()"
  },
  {
    "opcode": "operator_gt",
    "args": [
      {
        "type": "input_value",
        "name": "OPERAND1"
      },
      {
        "type": "input_value",
        "name": "OPERAND2"
      }
    ],
    "blockLabel": "() > ()"
  },
  {
    "opcode": "operator_and",
    "args": [
      {
        "type": "input_value",
        "name": "OPERAND1",
        "check": "Boolean"
      },
      {
        "type": "input_value",
        "name": "OPERAND2",
        "check": "Boolean"
      }
    ],
    "blockLabel": "() and ()"
  },
  {
    "opcode": "operator_or",
    "args": [
      {
        "type": "input_value",
        "name": "OPERAND1",
        "check": "Boolean"
      },
      {
        "type": "input_value",
        "name": "OPERAND2",
        "check": "Boolean"
      }
    ],
    "blockLabel": "() or ()"
  },
  {
    "opcode": "operator_not",
    "args": [
      {
        "type": "input_value",
        "name": "OPERAND",
        "check": "Boolean"
      }
    ],
    "blockLabel": "not ()"
  },
  {
    "opcode": "operator_join",
    "args": [
      {
        "type": "input_value",
        "name": "STRING1"
      },
      {
        "type": "input_value",
        "name": "STRING2"
      }
    ],
    "blockLabel": "join () ()"
  },
  {
    "opcode": "operator_letter_of",
    "args": [
      {
        "type": "input_value",
        "name": "LETTER"
      },
      {
        "type": "input_value",
        "name": "STRING"
      }
    ],
    "blockLabel": "letter () of ()"
  },
  {
    "opcode": "operator_length",
    "args": [
      {
        "type": "input_value",
        "name": "STRING"
      }
    ],
    "blockLabel": "length of ()"
  },
  {
    "opcode": "operator_contains",
    "args": [
      {
        "type": "input_value",
        "name": "STRING1"
      },
      {
        "type": "input_value",
        "name": "STRING2"
      }
    ],
    "blockLabel": "() contains ()?"
  },
  {
    "opcode": "operator_mod",
    "args": [
      {
        "type": "input_value",
        "name": "NUM1"
      },
      {
        "type": "input_value",
        "name": "NUM2"
      }
    ],
    "blockLabel": "() mod ()"
  },
  {
    "opcode": "operator_round",
    "args": [
      {
        "type": "input_value",
        "name": "NUM"
      }
    ],
    "blockLabel": "round ()"
  },
  {
    "opcode": "operator_mathop",
    "args": [
      {
        "type": "field_dropdown",
        "name": "OPERATOR",
        "options": [
          [
            "abs",
            "abs"
          ],
          [
            "floor",
            "floor"
          ],
          [
            "ceiling",
            "ceiling"
          ],
          [
            "sqrt",
            "sqrt"
          ],
          [
            "sin",
            "sin"
          ],
          [
            "cos",
            "cos"
          ],
          [
            "tan",
            "tan"
          ],
          [
            "asin",
            "asin"
          ],
          [
            "acos",
            "acos"
          ],
          [
            "atan",
            "atan"
          ],
          [
            "ln",
            "ln"
          ],
          [
            "log",
            "log"
          ],
          [
            "e ^",
            "e ^"
          ],
          [
            "10 ^",
            "10 ^"
          ]
        ]
      },
      {
        "type": "input_value",
        "name": "NUM"
      }
    ],
    "blockLabel": "() of ()"
  },
  {
    "opcode": "sensing_touchingobject",
    "args": [
      {
        "type": "input_value",
        "name": "TOUCHINGOBJECTMENU",
        "hasMenu": true
      }
    ],
    "category": "sensing",
    "blockLabel": "touching ()?"
  },
  {
    "opcode": "sensing_touchingobjectmenu",
    "args": [
      {
        "type": "field_dropdown",
        "name": "TOUCHINGOBJECTMENU",
        "options": [
          [
            "mouse-pointer",
            "_mouse_"
          ],
          [
            "edge",
            "_edge_"
          ]
        ],
        "hasMenu": true
      }
    ],
    "blockLabel": "()"
  },
  {
    "opcode": "sensing_touchingcolor",
    "args": [
      {
        "type": "input_value",
        "name": "COLOR"
      }
    ],
    "category": "sensing",
    "blockLabel": "touching color ()?"
  },
  {
    "opcode": "sensing_coloristouchingcolor",
    "args": [
      {
        "type": "input_value",
        "name": "COLOR"
      },
      {
        "type": "input_value",
        "name": "COLOR2"
      }
    ],
    "category": "sensing",
    "blockLabel": "color () is touching ()?"
  },
  {
    "opcode": "sensing_distanceto",
    "args": [
      {
        "type": "input_value",
        "name": "DISTANCETOMENU",
        "hasMenu": true
      }
    ],
    "category": "sensing",
    "blockLabel": "distance to ()"
  },
  {
    "opcode": "sensing_distancetomenu",
    "args": [
      {
        "type": "field_dropdown",
        "name": "DISTANCETOMENU",
        "options": [
          [
            "mouse-pointer",
            "_mouse_"
          ]
        ],
        "hasMenu": true
      }
    ],
    "blockLabel": "()"
  },
  {
    "opcode": "sensing_askandwait",
    "args": [
      {
        "type": "input_value",
        "name": "QUESTION"
      }
    ],
    "category": "sensing",
    "blockLabel": "ask () and wait"
  },
  {
    "opcode": "sensing_answer",
    "args": [],
    "category": "sensing",
    "blockLabel": "answer"
  },
  {
    "opcode": "sensing_keypressed",
    "args": [
      {
        "type": "input_value",
        "name": "KEY_OPTION",
        "hasMenu": true
      }
    ],
    "category": "sensing",
    "blockLabel": "key () pressed?"
  },
  {
    "opcode": "sensing_keyoptions",
    "args": [
      {
        "type": "field_dropdown",
        "name": "KEY_OPTION",
        "options": [
          [
            "space",
            "space"
          ],
          [
            "up arrow",
            "up arrow"
          ],
          [
            "down arrow",
            "down arrow"
          ],
          [
            "right arrow",
            "right arrow"
          ],
          [
            "left arrow",
            "left arrow"
          ],
          [
            "any",
            "any"
          ],
          [
            "a",
            "a"
          ],
          [
            "b",
            "b"
          ],
          [
            "c",
            "c"
          ],
          [
            "d",
            "d"
          ],
          [
            "e",
            "e"
          ],
          [
            "f",
            "f"
          ],
          [
            "g",
            "g"
          ],
          [
            "h",
            "h"
          ],
          [
            "i",
            "i"
          ],
          [
            "j",
            "j"
          ],
          [
            "k",
            "k"
          ],
          [
            "l",
            "l"
          ],
          [
            "m",
            "m"
          ],
          [
            "n",
            "n"
          ],
          [
            "o",
            "o"
          ],
          [
            "p",
            "p"
          ],
          [
            "q",
            "q"
          ],
          [
            "r",
            "r"
          ],
          [
            "s",
            "s"
          ],
          [
            "t",
            "t"
          ],
          [
            "u",
            "u"
          ],
          [
            "v",
            "v"
          ],
          [
            "w",
            "w"
          ],
          [
            "x",
            "x"
          ],
          [
            "y",
            "y"
          ],
          [
            "z",
            "z"
          ],
          [
            "0",
            "0"
          ],
          [
            "1",
            "1"
          ],
          [
            "2",
            "2"
          ],
          [
            "3",
            "3"
          ],
          [
            "4",
            "4"
          ],
          [
            "5",
            "5"
          ],
          [
            "6",
            "6"
          ],
          [
            "7",
            "7"
          ],
          [
            "8",
            "8"
          ],
          [
            "9",
            "9"
          ]
        ],
        "hasMenu": true
      }
    ],
    "blockLabel": "()"
  },
  {
    "opcode": "sensing_mousedown",
    "args": [],
    "category": "sensing",
    "blockLabel": "mouse down?"
  },
  {
    "opcode": "sensing_mousex",
    "args": [],
    "category": "sensing",
    "blockLabel": "mouse x"
  },
  {
    "opcode": "sensing_mousey",
    "args": [],
    "category": "sensing",
    "blockLabel": "mouse y"
  },
  {
    "opcode": "sensing_setdragmode",
    "args": [
      {
        "type": "field_dropdown",
        "name": "DRAG_MODE",
        "options": [
          [
            "draggable",
            "draggable"
          ],
          [
            "not draggable",
            "not draggable"
          ]
        ]
      }
    ],
    "category": "sensing",
    "blockLabel": "set drag mode ()"
  },
  {
    "opcode": "sensing_loudness",
    "args": [],
    "category": "sensing",
    "blockLabel": "loudness"
  },
  {
    "opcode": "sensing_loud",
    "args": [],
    "category": "sensing",
    "blockLabel": "loud?"
  },
  {
    "opcode": "sensing_timer",
    "args": [],
    "category": "sensing",
    "blockLabel": "timer"
  },
  {
    "opcode": "sensing_resettimer",
    "args": [],
    "category": "sensing",
    "blockLabel": "reset timer"
  },
  {
    "opcode": "sensing_of_object_menu",
    "args": [
      {
        "type": "field_dropdown",
        "name": "OBJECT",
        "options": [
          [
            "Sprite1",
            "Sprite1"
          ],
          [
            "Stage",
            "_stage_"
          ]
        ],
        "hasMenu": true
      }
    ],
    "category": "sensing",
    "blockLabel": "()"
  },
  {
    "opcode": "sensing_of",
    "args": [
      {
        "type": "field_dropdown",
        "name": "PROPERTY",
        "options": [
          [
            "x position",
            "x position"
          ],
          [
            "y position",
            "y position"
          ],
          [
            "direction",
            "direction"
          ],
          [
            "costume #",
            "costume #"
          ],
          [
            "costume name",
            "costume name"
          ],
          [
            "size",
            "size"
          ],
          [
            "volume",
            "volume"
          ],
          [
            "backdrop #",
            "backdrop #"
          ],
          [
            "backdrop name",
            "backdrop name"
          ]
        ]
      },
      {
        "type": "input_value",
        "name": "OBJECT",
        "hasMenu": true
      }
    ],
    "category": "sensing",
    "blockLabel": "the () of ()"
  },
  {
    "opcode": "sensing_current",
    "args": [
      {
        "type": "field_dropdown",
        "name": "CURRENTMENU",
        "options": [
          [
            "year",
            "YEAR"
          ],
          [
            "month",
            "MONTH"
          ],
          [
            "date",
            "DATE"
          ],
          [
            "day of week",
            "DAYOFWEEK"
          ],
          [
            "hour",
            "HOUR"
          ],
          [
            "minute",
            "MINUTE"
          ],
          [
            "second",
            "SECOND"
          ]
        ]
      }
    ],
    "category": "sensing",
    "blockLabel": "current ()"
  },
  {
    "opcode": "sensing_dayssince2000",
    "args": [],
    "category": "sensing",
    "blockLabel": "days since 2000"
  },
  {
    "opcode": "sensing_username",
    "args": [],
    "category": "sensing",
    "blockLabel": "username"
  },
  {
    "opcode": "sensing_userid",
    "args": [],
    "category": "sensing",
    "blockLabel": "user id"
  },
  {
    "opcode": "sound_sounds_menu",
    "args": [
      {
        "type": "field_dropdown",
        "name": "SOUND_MENU",
        "options": [
          [
            "1",
            "0"
          ],
          [
            "2",
            "1"
          ],
          [
            "3",
            "2"
          ],
          [
            "4",
            "3"
          ],
          [
            "5",
            "4"
          ],
          [
            "6",
            "5"
          ],
          [
            "7",
            "6"
          ],
          [
            "8",
            "7"
          ],
          [
            "9",
            "8"
          ],
          [
            "10",
            "9"
          ],
          [
            "call a function",
            null
          ]
        ],
        "hasMenu": true
      }
    ],
    "blockLabel": "()"
  },
  {
    "opcode": "sound_play",
    "args": [
      {
        "type": "input_value",
        "name": "SOUND_MENU",
        "hasMenu": true
      }
    ],
    "category": "sound",
    "blockLabel": "start sound ()"
  },
  {
    "opcode": "sound_playuntildone",
    "args": [
      {
        "type": "input_value",
        "name": "SOUND_MENU",
        "hasMenu": true
      }
    ],
    "category": "sound",
    "blockLabel": "play sound () until done"
  },
  {
    "opcode": "sound_stopallsounds",
    "args": [],
    "category": "sound",
    "blockLabel": "stop all sounds"
  },
  {
    "opcode": "sound_seteffectto",
    "args": [
      {
        "type": "field_dropdown",
        "name": "EFFECT",
        "options": [
          [
            "pitch",
            "PITCH"
          ],
          [
            "pan left/right",
            "PAN"
          ]
        ]
      },
      {
        "type": "input_value",
        "name": "VALUE"
      }
    ],
    "category": "sound",
    "blockLabel": "set sound () effect to ()"
  },
  {
    "opcode": "sound_changeeffectby",
    "args": [
      {
        "type": "field_dropdown",
        "name": "EFFECT",
        "options": [
          [
            "pitch",
            "PITCH"
          ],
          [
            "pan left/right",
            "PAN"
          ]
        ]
      },
      {
        "type": "input_value",
        "name": "VALUE"
      }
    ],
    "category": "sound",
    "blockLabel": "change () sound effect by ()"
  },
  {
    "opcode": "sound_cleareffects",
    "args": [],
    "category": "sound",
    "blockLabel": "clear sound effects"
  },
  {
    "opcode": "sound_changevolumeby",
    "args": [
      {
        "type": "input_value",
        "name": "VOLUME"
      }
    ],
    "category": "sound",
    "blockLabel": "change volume by ()"
  },
  {
    "opcode": "sound_setvolumeto",
    "args": [
      {
        "type": "input_value",
        "name": "VOLUME"
      }
    ],
    "category": "sound",
    "blockLabel": "set volume to ()%"
  },
  {
    "opcode": "sound_volume",
    "args": [],
    "category": "sound",
    "blockLabel": "volume"
  }
]
""";
