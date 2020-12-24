package;

import flixel.util.FlxColor;
import flixel.FlxG;
import misc.FlxTextFactory;
import flixel.FlxState;
import com.bitdecay.lucidtext.TextGroup;

class SpacingCompareState extends FlxState {
	override public function create():Void {
		super.create();
		bgColor = FlxColor.WHITE;

		// FlxTextFactory.defaultFont = AssetPaths.Brain_Slab_8__ttf;
		FlxTextFactory.defaultColor = FlxColor.BLACK;
		TextGroup.textMakerFunc = FlxTextFactory.makeSimple;

		FlxG.autoPause = false;

		var y = 100.0;
		for (i in 1...7) {
			y = makeSpacingTest(i * 6, y);
		}
	}

	private function makeSpacingTest(size:Int, yCoord:Float) {
		var textRef = FlxTextFactory.make('Welcome to LucidText! size ${size} (FlxText)', 30, yCoord, size);
		add(textRef);
		yCoord += textRef.height;
		var lucid = new TextGroup(30, yCoord, 'Welcome to <wave>LucidText!</wave> size ${size} (Lucid)', size);
		add(lucid);
		return yCoord + lucid.height;
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);
	}
}
