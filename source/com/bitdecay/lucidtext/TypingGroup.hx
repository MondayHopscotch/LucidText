package com.bitdecay.lucidtext;

import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.math.FlxRect;

class TypingGroup extends TextGroup {
	var position:Int = 0;
	var typeSpeed:Float = 20;

	var elapsed:Float = 0.0;
	var calcedTimePerChar:Float = 0.0;

	var bounds:FlxRect;
	var margin:Float = 5.0;

	var wordStarts:Array<Int> = [];
	var wordLengths:Map<Int, Int> = [];

	public var letterCallback:() -> Void;
	public var wordCallback:() -> Void;

	public function new(box:FlxRect, text:String, size:Int) {
		super(box.left, box.top, text, size);

		calcedTimePerChar = 1 / typeSpeed;

		var backing = new FlxSprite(0, 0);
		backing.makeGraphic(Std.int(box.width), Std.int(box.height), new FlxColor(0xFFAAAAFF));

		bounds = box;

		for (m in members) {
			m.visible = false;
			m.y += margin;
			m.x += margin;
		}

		organizeTextToRect();

		// We want the preAdd stuff of the FlxSpriteGroup...
		add(backing);
		// ...but we also want the backing to be at index zero
		members.remove(backing);
		members.insert(0, backing);
	}

	private function organizeTextToRect() {
		var wordMatcher:EReg = ~/\b\w+\b/g;
		wordMatcher.map(renderText, (m) -> {
			wordStarts.push(m.matchedPos().pos);
			wordLengths.set(m.matchedPos().pos, m.matchedPos().len);
			return m.matched(0);
		});

		for (start in wordStarts) {
			for (k in start...start + wordLengths[start]) {
				if (members[k].x + members[k].width > bounds.right - margin) {
					shuffleMembersNextRow(start);
					break;
				}
			}
		}
	}

	private function shuffleMembersNextRow(begin:Int) {
		var xCoord = x + margin;
		// this likely isn't a great value to use, we want the "base" line size for the font
		// Namely, if  line break happens on a 'bigger' or 'smaller' character, this value
		// is not correct.
		var yCoordOffset = members[begin].height;
		for (i in begin...members.length) {
			members[i].x = xCoord;
			members[i].y += yCoordOffset;
			xCoord += members[i].width + TextGroup.spacingMod;
		}
	}

	public function setTypeSpeed(charPerSec:Float) {
		typeSpeed = charPerSec;
		calcedTimePerChar = 1 / typeSpeed;
	}

	override public function update(delta:Float) {
		super.update(delta);

		elapsed += delta;
		while (elapsed > calcedTimePerChar && position < members.length) {
			elapsed -= calcedTimePerChar;
			members[position].visible = true;
			position++;
			if (letterCallback != null) {
				letterCallback();
			}
			// our border image is our 0th position, so sub one to get proper string index
			if (wordLengths.exists(position - 1)) {
				if (wordCallback != null) {
					wordCallback();
				}
			}
		}
	}
}
