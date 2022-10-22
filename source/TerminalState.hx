import flixel.math.FlxMath;
import flixel.group.FlxGroup;
import sys.io.File;
import lime.app.Application;
import flixel.tweens.FlxTween;
import flixel.math.FlxRandom;
import openfl.filters.ShaderFilter;
import haxe.ds.Map;
import flixel.input.keyboard.FlxKey;
import flixel.text.FlxText;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.*;
import flixel.util.FlxTimer;
import flash.system.System;
import flixel.system.FlxSound;

using StringTools;

import PlayState; //why the hell did this work LMAO.


class TerminalState extends MusicBeatState
{

    //dont just yoink this code and use it in your own mod. this includes you, psych engine porters. 
    //thats exactly what i did im sorry -Fyrid
    //if you ingore this message and use it anyway, atleast give credit.

    public var curCommand:String = "";
    public var previousText:String = "Morrow's Insanity\nCopyright (C) MS Engine. All Rights Reserved.\n> ";
    public var displayText:FlxText;
    public var CommandList:Array<TerminalCommand> = new Array<TerminalCommand>();
    public var typeSound:FlxSound;
    public var morrowTakesOver:Bool = false;
    public var morrowTimer:FlxTimer;
    
    public var CommandErrorList:Array<String> = [
        'Displays this menu.',
        'Shows the list of characters.',
        'Shows the admin list, use grant to grant rights.',
        'Clears the screen.',
        'Loads a specified json or text file.',
        '\nTo add extra users, add the grant parameter and the name.\n(Example: admin grant lenzo.dat)\nNOTE: ADDING CHARACTERS AS ADMINS CAN CAUSE UNEXPECTED CHANGES.',
        '\nNo version of the "admin" command takes',
        'parameter(s).',
        'is not a valid user or character.',
        '\nLoading...',
        'Unknown command "'
    ];
    // [BAD PERSON] was too lazy to finish this lol.
    var unformattedSymbols:Array<String> =
    [
        "period",
        "backslash",
        "one",
        "two",
        "three",
        "four",
        "five",
        "six",
        "seven",
        "eight",
        "nine",
        "zero",
        "shift",
        "semicolon",
        "alt",
        "lbracket",
        "rbracket",
        "comma",
        "plus"
    ];

    var formattedSymbols:Array<String> =
    [
        ".",
        "/",
        "1",
        "2",
        "3",
        "4",
        "5",
        "6",
        "7",
        "8",
        "9",
        "0",
        "",
        ";",
        "",
        "[",
        "]",
        ",",
        "="
    ];
    public var fakeDisplayGroup:FlxTypedGroup<FlxText> = new FlxTypedGroup<FlxText>();
    public var expungedTimer:FlxTimer;
    var curExpungedAlpha:Float = 0;

    override public function create():Void
    {
        Main.fpsVar.visible = false;
        PlayState.isStoryMode = false;
        displayText = new FlxText(0, 0, FlxG.width, previousText, 32);
		displayText.setFormat(Paths.font("fixedsys.ttf"), 16);
        displayText.size *= 2;
		displayText.antialiasing = false;
        typeSound = FlxG.sound.load(Paths.sound('terminal_space'), 0.6);
        FlxG.sound.playMusic(Paths.music('TheAmbience','shared'), 0.7);

        CommandList.push(new TerminalCommand("help", CommandErrorList[0], function(arguments:Array<String>)
        {
            UpdatePreviousText(false); //resets the text
            var helpText:String = "";
            for (v in CommandList)
            {
                if (v.showInHelp)
                {
                    helpText += (v.commandName + " - " + v.commandHelp + "\n");
                }
            }
            UpdateText("\n" + helpText);
        }));

        CommandList.push(new TerminalCommand("characters", CommandErrorList[1], function(arguments:Array<String>)
        {
            UpdatePreviousText(false); //resets the text
            UpdateText("\nbarren.dat\nlenzo.dat\nmorrow.dat\ngambi.dat\nbamlin.dat\nbanlin.dat\navery.dat\nshifted.lua");
            //UpdateText("\ndave.dat\nbambi.dat\ntristan.dat\nexpunged.dat\nexbungo.dat\nrecurser.dat\nmoldy.dat");
        }));
        CommandList.push(new TerminalCommand("admin", CommandErrorList[2], function(arguments:Array<String>)
        {
            if (!morrowTakesOver) {
            if (arguments.length == 0)
            {
                UpdatePreviousText(false); //resets the text
                UpdateText("\n" + (!FlxG.save.data.selfAwareness ? CoolSystemStuff.getUsername() : 'User354378')
                 + CommandErrorList[5]);
                return;
            }
            else if (arguments.length != 2)
            {
                UpdatePreviousText(false); //resets the text
                UpdateText(CommandErrorList[6] + " " + arguments.length + CommandErrorList[7]);
            }
            else
            {
                if (arguments[0] == "grant")
                {
                    switch (arguments[1])
                    {
                        default:
                            UpdatePreviousText(false); //resets the text
                            UpdateText("\n" + arguments[1] + CommandErrorList[8]);
                        case "morrow.dat":
                            UpdatePreviousText(false); //resets the text
                            UpdateText("\n" + arguments[1] + CommandErrorList[8]); // its lying to you
                            morrowTakesOver = true;
                        case "barren.dat":
                            UpdatePreviousText(false); //resets the text
                            UpdateText(CommandErrorList[9]);
                            PlayState.globalFunny = CharacterFunnyEffect.Barren;
                            PlayState.SONG = Song.loadFromJson("overdrive", 'charts');
                            PlayState.SONG.validScore = false;
                            Main.fpsVar.visible = !FlxG.save.data.disableFps;
                            LoadingState.loadAndSwitchState(new PlayState());
                        case "lenzo.dat":
                            UpdatePreviousText(false); //resets the text
                            UpdateText(CommandErrorList[9]);
                            PlayState.globalFunny = CharacterFunnyEffect.Lenzo;
                            PlayState.SONG = Song.loadFromJson("anillo", 'charts');
                            PlayState.SONG.validScore = false;
                            Main.fpsVar.visible = !FlxG.save.data.disableFps;
                            LoadingState.loadAndSwitchState(new PlayState());
                    }
                }
                else
                {
                    UpdateText("\nInvalid Parameter"); //todo: translate.
                }
            }
            }
        }));
        CommandList.push(new TerminalCommand("clear", CommandErrorList[3], function(arguments:Array<String>)
        {
            previousText = "> ";
            UpdateText("");
        }));
        CommandList.push(new TerminalCommand("load", CommandErrorList[4], function(arguments:Array<String>)
        {
            UpdatePreviousText(false); //resets the text
            var tx = "";
            if (!morrowTakesOver) {
                switch (arguments[0].toLowerCase())
                {
                case "text":
                    switch (arguments[1].toLowerCase())
                    {
                        default:
                            tx = "Text file not found.";
                        case "barren":
                            tx = "The last of his kind. Only having a brother to have his back.";
                        case "lenzo":
                            tx = "Calls himself a ringslinger. He hasn't broke his limits yet.";
                        case "morrow":
                            tx = "The most powerful of the three. Many would call him insane.";
                        case "gambi":
                            tx = "'gamer'";
                        case "bamlin":
                            tx = "The younger one. Always looks up to the older one.";
                        case "banlin":
                            tx = "The older one. Takes care of the younger one.";
                    }

                    switch (arguments[1]) // case sensitive!!
                    {
                        case "qwertyuiopasdfghjklzxcvbnmABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890":
                            tx = "wow you really wasted time doing that for this? bummer.";
                    }
                case "json":
                    switch (arguments[1].toLowerCase())
                    {
                        default:
                            tx = "JSON file not found.";
                        case "blu.json":
                            UpdatePreviousText(false); //resets the text
                            UpdateText(CommandErrorList[10]);
                            PlayState.SONG = Song.loadFromJson("blu", 'charts');
                            PlayState.SONG.validScore = false;
                            Main.fpsVar.visible = !FlxG.save.data.disableFps;
                            LoadingState.loadAndSwitchState(new PlayState());
                    }
                }
                UpdateText("\n" + tx);
            }
            
        }));

        add(displayText);

        super.create();
    }

    public function UpdateText(val:String)
    {
        displayText.text = previousText + val;
    }

    //after all of my work this STILL DOESNT COMPLETELY STOP THE TEXT SHIT FROM GOING OFF THE SCREEN IM GONNA DIE
    public function UpdatePreviousText(reset:Bool)
    {
        previousText = displayText.text + (reset ? "\n> " : "");
        displayText.text = previousText;
        curCommand = "";
        var finalthing:String = "";
        var splits:Array<String> = displayText.text.split("\n");
        if (splits.length <= 22)
        {
            return;
        }
        var split_end:Int = Math.round(Math.max(splits.length - 22,0));
        for (i in split_end...splits.length)
        {
            var split:String = splits[i];
            if (split == "")
            {
                finalthing = finalthing + "\n";
            }
            else
            {
                finalthing = finalthing + split + (i < (splits.length - 1) ? "\n" : "");
            }
        }
        previousText = finalthing;
        displayText.text = finalthing;
    }

    override function update(elapsed:Float):Void
    {
        super.update(elapsed);
        var keyJustPressed:FlxKey = cast(FlxG.keys.firstJustPressed(), FlxKey);

        if (keyJustPressed == FlxKey.ENTER)
        {
            var calledFunc:Bool = false;
            var arguments:Array<String> = curCommand.split(" ");
            for (v in CommandList)
            {
                if (v.commandName == arguments[0] || (v.commandName == curCommand && v.oneCommand)) //argument 0 should be the actual command at the moment
                {
                    arguments.shift();
                    calledFunc = true;
                    v.FuncToCall(arguments);
                    break;
                }
            }
            if (!calledFunc)
            {
                UpdatePreviousText(false); //resets the text
                UpdateText(CommandErrorList[11] + arguments[0] + "\"");
            }
            UpdatePreviousText(true);
            return;
        }

        if (keyJustPressed != FlxKey.NONE)
        {
            if (keyJustPressed == FlxKey.BACKSPACE)
            {
                curCommand = curCommand.substr(0,curCommand.length - 1);
                typeSound.play();
            }
            else if (keyJustPressed == FlxKey.SPACE)
            {
                curCommand += " ";
                typeSound.play();
            }
            else
            {
                var toShow:String = keyJustPressed.toString().toLowerCase();
                for (i in 0...unformattedSymbols.length)
                {
                    if (toShow == unformattedSymbols[i])
                    {
                        toShow = formattedSymbols[i];
                        break;
                    }
                }
                if (FlxG.keys.pressed.SHIFT)
                {
                    toShow = toShow.toUpperCase();
                }
                curCommand += toShow;
                typeSound.play();
            }
            UpdateText(curCommand);
        }
        if (FlxG.keys.pressed.CONTROL && FlxG.keys.justPressed.BACKSPACE)
        {
            curCommand = "";
        }
        if (FlxG.keys.justPressed.ESCAPE && !morrowTakesOver)
        {
            Main.fpsVar.visible = !FlxG.save.data.disableFps;
            FlxG.switchState(new MainMenuState());
        } 

        if (FlxG.keys.justPressed.ESCAPE && morrowTakesOver)
        {
            morrowTimer = new FlxTimer().start(3, function(timer:FlxTimer) {
                UpdateText("\nWhere do you think you're going?");

                morrowTimer = new FlxTimer().start(3, function(timer:FlxTimer) {
                    UpdateText("\nThis is MY game now. You will do what I command.");

                    morrowTimer = new FlxTimer().start(3, function(timer:FlxTimer) {
                        var programPath:String = Sys.programPath();
                        var textPath = programPath.substr(0, programPath.length - CoolSystemStuff.executableFileName().length) + "REGRET.txt";
					    File.saveContent(textPath, "DO NOT OPEN THE GAME.");
					    System.exit(0);
                    });
                });
            });
        }
    }

    /*
    function expungedReignStarts()
    {
            var glitch = new FlxSprite(0, 0);
            glitch.frames = Paths.getSparrowAtlas('ui/glitch/glitch');
            glitch.animation.addByPrefix('glitchScreen', 'glitch', 40);
            glitch.animation.play('glitchScreen');
            glitch.setGraphicSize(FlxG.width, FlxG.height);
            glitch.updateHitbox();
            glitch.screenCenter();
            glitch.scrollFactor.set();
            glitch.antialiasing = false;
            if (FlxG.save.data.eyesores)
            {
                add(glitch);
            }

        add(fakeDisplayGroup);
        
        var expungedLines:Array<String> = ['TAKING OVER....', 'ATTEMPTING TO HIJACK ADMIN OVERRIDE...', 'THIS REALM IS MINE', "DON'T YOU UNDERSTAND? THIS IS MY WORLD NOW.", "I WIN, YOU LOSE.", "GAME OVER.", "THIS IS IT.", "FUCK YOU!", "I HAVE THE PLOT ARMOR NOW!!", "AHHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAH", "EXPUNGED'S REIGN SHALL START", '[DATA EXPUNGED]'];
        var i:Int = 0;
        var camFollow = new FlxObject(FlxG.width / 2, -FlxG.height / 2, 1, 1);
        
        #if windows
            if (FlxG.save.data.selfAwareness)
            {
                expungedLines.push("Hacking into " + Sys.environment()["COMPUTERNAME"] + "...");
            }
        #end

        FlxG.camera.follow(camFollow, 1);

        expungedActivated = true;
        expungedTimer = new FlxTimer().start(FlxG.elapsed * 2, function(timer:FlxTimer) //t5 make this get slowed down when eyesores is off
        {
            var lastFakeDisplay = fakeDisplayGroup.members[i - 1];
            var fakeDisplay:FlxText = new FlxText(0, 0, FlxG.width, "> " + expungedLines[new FlxRandom().int(0, expungedLines.length - 1)], 19);
            fakeDisplay.setFormat(Paths.font("fixedsys.ttf"), 16);
            fakeDisplay.size *= 2;
            fakeDisplay.antialiasing = false;

            var yValue:Float = lastFakeDisplay == null ? displayText.y + displayText.textField.textHeight : lastFakeDisplay.y + lastFakeDisplay.textField.textHeight;
            fakeDisplay.y = yValue;
            fakeDisplayGroup.add(fakeDisplay);
            if (fakeDisplay.y > FlxG.height)
            {
                camFollow.y = fakeDisplay.y - FlxG.height / 2;
            }
            i++;
        }, FlxMath.MAX_VALUE_INT);
        
        FlxG.sound.music.stop();
        FlxG.sound.play(Paths.sound("expungedGrantedAccess", "preload"), function()
        {
            FlxTween.tween(glitch, {alpha: 0}, 1);
            expungedTimer.cancel();
            fakeDisplayGroup.clear();

            var eye = new FlxSprite(0, 0).loadGraphic(Paths.image('mainMenu/eye'));
			eye.screenCenter();
			eye.antialiasing = false;
            eye.alpha = 0;
			add(eye);

            FlxTween.tween(eye, {alpha: 1}, 1, {onComplete: function(tween:FlxTween)
            {
                FlxTween.tween(eye, {alpha: 0}, 1);
            }});
			FlxG.sound.play(Paths.sound('iTrollYou', 'shared'), function()
			{
				new FlxTimer().start(1, function(timer:FlxTimer)
				{
					FlxG.save.data.exploitationState = 'awaiting';
					FlxG.save.data.exploitationFound = true;
					FlxG.save.flush();

					var programPath:String = Sys.programPath();
					var textPath = programPath.substr(0, programPath.length - CoolSystemStuff.executableFileName().length) + "help me.txt";

					File.saveContent(textPath, "you don't know what you're getting yourself into\n don't open the game for your own risk");
					System.exit(0);
				});
			});
        });
    }*/
}


class TerminalCommand
{
    public var commandName:String = "undefined";
    public var commandHelp:String = "if you see this you are very homosexual and dumb."; //hey im not homosexual. kinda mean ngl
    public var FuncToCall:Dynamic;
    public var showInHelp:Bool;
    public var oneCommand:Bool;

    public function new(name:String, help:String, func:Dynamic, showInHelp = true, oneCommand:Bool = false)
    {
        commandName = name;
        commandHelp = help;
        FuncToCall = func;
        this.showInHelp = showInHelp;
        this.oneCommand = oneCommand;
    }
}

class TerminalError
{
    public var errorMessage:String = "Error: ur gay";

    public function new(message:String)
    {
        errorMessage = message;
    }
}