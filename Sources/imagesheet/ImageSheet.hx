package imagesheet;

import haxe.Json;
import kha.Image;
import kha.Assets;

class SubImage{
	/**
	rectangle in which the image reside in the sheet is defined by x,y,width, height
	*/
	public var x(default,null) : Int;
	public var y(default,null) : Int;
	public var width(default,null) : Int;
	public var height(default,null) : Int;
	
	/**
	if the image is trimmed
	offsetX will represent the ammount of pixels trimmed on the left
	offsetY will represent the ammount of pixels trimmed on the top
	originalWidth will be be bigger than width
	originalHeight will be be bigger than height
	*/
	public var offsetX(default,null) : Int;
	public var offsetY(default,null) : Int;
	public var originalWidth(default,null) : Int;
	public var originalHeight(default,null) : Int;
	
	/* 
	represent the pivot information provided by texturePacker, default to 0,0
	**/
	public var pivotX(default,null) : Float;
	public var pivotY(default,null) : Float;
	
	/*
	if true the image has been rotated to fit better in the sheet/
	All the other values still represent the image as if not rotated
	**/
	public var rotated(default,null) : Bool;

	public var image(default,null) : Image;
	
	//TODO fix :
	// public function draw(g : kha.graphics2.Graphics, tx : Float, ty : Float):Void{
		
	// 	if(rotated){
	// 		var oldTrans = g.transformation;
	// 		g.transformation = kha.math.FastMatrix3.rotation(-Math.PI/2).multmat(kha.math.FastMatrix3.translation(-x, -y));
	// 		g.drawScaledSubImage(image, x, y, height, width, tx, ty, height, width);
	// 		g.transformation = oldTrans;
	// 	}else{
	// 		g.drawScaledSubImage(image, x, y, width, height, tx, ty, width, height);
	// 	}
		
	// }

	private function new(image : Image, x : Int, y : Int, width : Int, height : Int, offsetX : Int, offsetY : Int, originalWidth : Int, originalHeight : Int, rotated : Bool, pivotX : Float, pivotY : Float){
		this.image = image;
		this.x = x;
		this.y = y;
		this.width = width;
		this.height = height;
		this.offsetX = offsetX;
		this.offsetY = offsetY;
		this.originalWidth = originalWidth;
		this.originalHeight = originalHeight;
		this.rotated = rotated;
		this.pivotX = pivotX;
		this.pivotY = pivotY;
	}
}

@:access(imagesheet)
class ImageSheet{
	public static function fromTexturePackerJsonArray(jsonString : String) : ImageSheet{
		var json = Json.parse(jsonString);
		var meta = json.meta;
		//TODO better kha handling of dynamic asset path:
		var image = Reflect.field(Assets.images, meta.image.substr(0,meta.image.indexOf(".")));
		var frames : Array<Dynamic> = json.frames;
		var subImages : Map<String, SubImage> = new Map();
		for(frame in frames){
			var pivotX = 0.0;
			var pivotY = 0.0;
			if(Reflect.hasField(frame, "pivot")){
				pivotX = frame.pivotX;
				pivotY = frame.pivotY;
			}
			var subImage = new SubImage(image,frame.frame.x, frame.frame.y, frame.frame.w, frame.frame.h, frame.spriteSourceSize.x, frame.spriteSourceSize.y, frame.sourceSize.w, frame.sourceSize.h,  frame.rotated, pivotX, pivotY);
			subImages.set(frame.filename, subImage);
		}
		return new ImageSheet(subImages, image);
	}

	public static function fromSubImages(subImages : Map<String, SubImage>, image : Image) : ImageSheet{
		return new ImageSheet(subImages,image); 
	}

	public static function fromFixedSizeTiles(image : kha.Image, w : Int, h : Int, numTiles : Int) : ImageSheet{ //TODO make numTiles optional ?
		var subImages : Map<String, SubImage> = new Map();
		var x : Int = 0;
		var y : Int = 0;
		var imgWidth = image.width;
		var imgHeight = image.height;
		for(i in 0...numTiles){
			var subImage = new SubImage(image, x, y, w, h, 0, 0, w, h, false, 0, 0);
			subImages.set(""+i, subImage);
			x+=w;
			if(x + w > imgWidth){
				y+= h;
				x = 0;
			}
		}
		return new ImageSheet(subImages, image);
	}
	
	public var image(default, null) : Image;
	
	inline public function getSubImage(path : String) : SubImage{
		return subImages.get(path);
	}

	private var subImages : Map<String, SubImage>;
	private function new(subImages : Map<String, SubImage>, image : Image){
		this.subImages = subImages;
		this.image = image;
	}
	
	
}