package com.bitdecay.dialog;

import com.bitdecay.lucidtext.TypeOptions;
import flixel.math.FlxRect;
import com.bitdecay.lucidtext.TypingGroup;
import flixel.FlxBasic;
import haxe.Timer;
import flixel.FlxG;
import flixel.FlxCamera;
import flixel.input.keyboard.FlxKey;
import flixel.FlxState;

class DialogManager extends FlxBasic {
	static inline final FontSize = 10;

	var currentDialogIndex:Int = -1;
	var currentDialogId:String = "";

	// TODO: Pull these out into an Options class that we can pass around
	//       Will need to also put font size in there if it makes sense
	static inline final CharactersPerTextBox = 100;
	static inline final NextPageDelayMs = 4000;
	static inline final NextPageInputDelayMs = 500;

	var dialogMap:Map<String, Array<String>>;
	var progressionKey:FlxKey;

	public var typeText:TypingGroup;
	public var opts:TypeOptions;

	var pages:Array<String>;
	var currentPage:Int = 0;
	var typing:Bool;
	var fastTyping:Bool = false;
	var canManuallyTriggerNextPage:Bool;

	// Optional callbacks to enable custom sound solutions
	var onTypingBegin:() -> Void;
	var onTypingEnd:() -> Void;
	var onTypingSpeedUp:() -> Void;

	// Keep references to the timers to reset them whenever a new page of text starts
	// Initialize them to real timers to avoid the need to check for null
	var autoProgressTimer:Timer = new Timer(1000);
	var manuallyProgressTimer:Timer = new Timer(1000);

	public function new(_dialogMap:Map<String, Array<String>>, _parentState:FlxState, _camera:FlxCamera, ?_progressionKey:FlxKey = FlxKey.NONE,
			?_onTypingBegin:() -> Void = null, ?_onTypingEnd:() -> Void = null, ?_onTypingSpeedUp:() -> Void = null) {
		super();

		dialogMap = _dialogMap;
		progressionKey = _progressionKey;
		onTypingBegin = _onTypingBegin;
		onTypingEnd = _onTypingEnd;
		onTypingSpeedUp = _onTypingSpeedUp;

		// Position the text to be roughly centered toward the top of the screen

		opts = new TypeOptions(AssetPaths.slice__png, [4, 4, 12, 12]);
		typeText = new TypingGroup(new FlxRect(20, 30, FlxG.width - 40, 200), "", opts, 24);
		typeText.scrollFactor.set(0, 0);
		typeText.cameras = [_camera];
		_parentState.add(typeText);
	}

	public function loadDialog(id:String) {
		if (dialogMap[id] == null) {
			trace("id (" + id + ") not found in dialog map");
			return;
		}
		pages = parseTextIntoPages(dialogMap[id].copy());
		startTyping(pages[0]);
		currentDialogId = id;
	}

	private function parseTextIntoPages(_textList:Array<String>):Array<String> {
		// TODO: This needs to take tags into account to avoid page breaks in weird places
		// var pageArray = new Array<String>();
		// var currentPageBuffer:StringBuf;

		// for(text in _textList){
		// 	currentPageBuffer = new StringBuf();
		// 	for (i in 0...text.length) {
		// 		if (i % CharactersPerTextBox == 0 && i != 0){
		// 			pageArray.push(currentPageBuffer.toString());
		// 			currentPageBuffer = new StringBuf();
		// 		}
		// 		currentPageBuffer.add(text.charAt(i));

		// 		if (i == text.length-1){
		// 			pageArray.push(currentPageBuffer.toString());
		// 		}
		// 	}
		// }

		// return pageArray;
		return _textList;
	}

	public function startTyping(text:String):Void {
		typeText.revive();
		typing = true;
		fastTyping = false;

		typeText.loadText(text);
		canManuallyTriggerNextPage = false;
		autoProgressTimer.stop();
		manuallyProgressTimer.stop();

		// Set onComplete function in-line
		typeText.finishCallback = () -> {
			typing = false;

			if (onTypingEnd != null) {
				onTypingEnd();
			}

			// After NextPageDelayMs, the next page of text will be loaded
			autoProgressTimer = Timer.delay(() -> {
				continueToNextPage();
			}, NextPageDelayMs);

			// After NextPageInputDelayMs, the user can press a button to continue to the next page instead of waiting
			manuallyProgressTimer = Timer.delay(() -> {
				canManuallyTriggerNextPage = true;
			}, NextPageInputDelayMs);
		};

		if (onTypingBegin != null) {
			onTypingBegin();
		}
	}

	public function continueToNextPage():Void {
		currentPage++;
		// When there is no more text to display, transition to completed state
		if (currentPage >= pages.length) {
			completeDialog();
		} else {
			startTyping(pages[currentPage]);
		}
	}

	public function completeDialog() {
		typeText.kill();

		fastTyping = false;
		canManuallyTriggerNextPage = false;
		autoProgressTimer.stop();
		manuallyProgressTimer.stop();
	}

	override public function update(delta:Float):Void {
		super.update(delta);

		// Update loop exclusively handles user input
		if (progressionKey != FlxKey.NONE) {
			if (typing && !fastTyping && FlxG.keys.anyJustPressed([progressionKey])) {
				fastTyping = true;
				opts.charsPerSecond *= 2;
				if (onTypingSpeedUp != null) {
					onTypingSpeedUp();
				}
			}

			if (canManuallyTriggerNextPage && FlxG.keys.anyJustPressed([progressionKey])) {
				continueToNextPage();
			}
		}
	}

	public function getCurrentDialogIndex():Int {
		return currentDialogIndex;
	}

	public function getCurrentDialogId():String {
		return currentDialogId;
	}

	public function isTyping():Bool {
		return typing;
	}

	public function isDone():Bool {
		return !typing;
	}
}
