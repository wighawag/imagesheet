package imagesheet;

import haxe.Json;

class SubImage{
	public var x1(default,null) : Int;
	public var y1(default,null) : Int;
	public var x2(default,null) : Int;
	public var y2(default,null) : Int;
	public var refX(default,null) : Int;
	public var refY(default,null) : Int;
	private function new(){
		
	}
}

@:access(imagesheet)
class ImageSheet{
	public static function fromTexturePackerJsonArray(jsonString : String) : ImageSheet{
		var json = Json.parse(jsonString);
		var meta = json.meta;
		var frames = json.frames;
		var subImages : Map<String, SubImage> = new Map();
		for(frame in frames){
			var subImage = new SubImage();
			subImages.set(frame.filename, subImage);
		}
		return new ImageSheet(subImages);
	}
	
	public var image(default, null) : Image;
	
	inline public function getSubImage(path : String) : SubImage{
		return subImages.get(path);
	}
	
	private var subImages : Map<String, SubImage>;
	private function new(subImages : Map<String, SubImage>){
		this.subImages = subImages;
	}
	
	
}