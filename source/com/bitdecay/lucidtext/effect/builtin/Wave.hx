package com.bitdecay.lucidtext.effect.builtin;

import com.bitdecay.lucidtext.effect.Effect.EffectUpdater;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import com.bitdecay.lucidtext.properties.Setters;

/**
 * A sine wave motion for the affected characters
**/
class Wave implements Effect {
	public var height:Float = 10.0;
	public var speed:Float = 2.0;
	public var offset:Float = 0.1;
	public var reverse:Bool = false;

	public function new() {}

	public function getUserProperties():Map<String, PropSetterFunc> {
		var fields:Map<String, (Dynamic, String, String) -> Void> = [
			"height" => Setters.setFloat,
			"speed" => Setters.setFloat,
			"offset" => Setters.setFloat,
			"reverse" => Setters.setBool
		];

		return fields;
	}

	public function apply(o:FlxText, i:Int):EffectUpdater {
		var posOffset = FlxPoint.get();
		var tempPosition = FlxPoint.get();

		var timer = i * offset;

		return (delta) -> {
			if (reverse) {
				timer += delta;
			} else {
				// Personal preference: This direction looks better to be the 'default'
				timer -= delta;
			}

			o.getPosition(tempPosition);

			// undo our previous offset;
			tempPosition.subtractPoint(posOffset);

			// then calculate our new offset and add it to the working temp position
			posOffset.y = Math.sin(timer * speed) * height;
			tempPosition.addPoint(posOffset);

			// set our position
			o.setPosition(tempPosition.x, tempPosition.y);

			return true;
		};
	}

	public function begin(ops:TypeOptions) {}

	public function end(ops:TypeOptions) {}
}
