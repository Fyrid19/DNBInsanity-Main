package;

import flixel.addons.display.FlxBackdrop;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.math.FlxRandom;
import flixel.util.FlxTimer;

class PackSelectState extends MusicBeatState 
{
    public static var catagories:Array<String> = ['Story', 'Extra', 'Joke', 'Covers'];
    public static var currentPack:Int = 0;
    // public var NameAlpha:Alphabet;
    var grpCats:FlxTypedGroup<Alphabet>;
    var curSelected:Int = 0;
    var BG:FlxBackdrop;
    var CurrentSongIcon:FlxSprite;
    var icons:Array<FlxSprite> = [];
    
    var packColors:Array<FlxColor> = [
		0xff929292,
        0xfffffb00,
        0xffff0000,
        0xff00bfff
    ];

    private var camFollow:FlxObject;
	private static var prevCamFollow:FlxObject;

    override function create()
    {
        BG = new FlxBackdrop(MainMenuState.randomizeBG(), 0.2, 0, true, true);
        BG.velocity.set(50);
        BG.updateHitbox();
        // BG.screenCenter();
        // BG.color = 0x55D650;
        add(BG);

        for (i in 0...catagories.length)
		{
            Highscore.load();

			var CurrentSongIcon:FlxSprite = new FlxSprite(0,0).loadGraphic(Paths.image('packs/' + (catagories[i].toLowerCase()), "preload"));
			CurrentSongIcon.centerOffsets(false);
			CurrentSongIcon.x = (1000 * i + 1) + (512 - CurrentSongIcon.width);
			CurrentSongIcon.y = (FlxG.height / 2) - 256;
			CurrentSongIcon.antialiasing = true;

			add(CurrentSongIcon);
			icons.push(CurrentSongIcon);
		}
        
        camFollow = new FlxObject(0, 0, 1, 1);
		camFollow.setPosition(icons[curSelected].x + 256, icons[curSelected].y + 256);

		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}

		add(camFollow);
		
		FlxG.camera.follow(camFollow, LOCKON, 0.04);
		FlxG.camera.focusOn(camFollow.getPosition());

        changeSelection();

        super.create();
    }

    override public function update(elapsed:Float){
        if (controls.UI_LEFT_P)
            changeSelection(-1);
        if (controls.UI_RIGHT_P)
            changeSelection(1);

        if (controls.BACK) {
            FlxG.sound.play(Paths.sound('cancelMenu'));
            MusicBeatState.switchState(new MainMenuState());
        }

        if (controls.ACCEPT){

            FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);

            new FlxTimer().start(0.2, function(Dumbshit:FlxTimer)
            {
                for (item in icons) { FlxTween.tween(item, {alpha: 0, y: item.y - 200}, 0.2, {ease: FlxEase.quadIn}); }                
                new FlxTimer().start(0.2, function(Dumbshit:FlxTimer)
                {
                    for (item in icons) { item.visible = false; }
                    MusicBeatState.switchState(new FreeplayState());
                });
            });
        }

        currentPack = curSelected;

        super.update(elapsed);
    }

    function changeSelection(change:Int = 0) {
        curSelected += change;

        if (curSelected < 0)
            curSelected = catagories.length - 1;
        if (curSelected >= catagories.length)
            curSelected = 0;

        camFollow.x = icons[curSelected].x + 256;

        FlxG.sound.play(Paths.sound('scrollMenu'));

        FlxTween.color(BG, 0.25, BG.color, packColors[curSelected]);
    }
}