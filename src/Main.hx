import js.html.svg.AnimatedBoolean;
import haxegon.*;
import utils.*;
import StringTools;

class Punkt{
	public var x:Int;
	public var y:Int;
	public function new(x:Int,y:Int){
		this.x=x;
		this.y=y;
	}
}

enum VerbindungDir {
	up;
	upright;
	right;
	downright;
}

class Verbindung{
	public var ox:Int;//o=offset
	public var oy:Int;
	public var dir:VerbindungDir;
	public function new(ox:Int,oy:Int,dir:VerbindungDir){
		this.ox=ox;
		this.oy=oy;
		this.dir=dir;
	}
}

class Stuck {
	public var posx:Int;
	public var posy:Int;
	public var mask:Array<String>;

	public var verbindungen:Array<Verbindung>;

	public function new(){
		
	}

	public function hasPunkt(x:Int,y:Int):Bool{
		if (inbounds(x,y)==false){
			return false;			
		}
		
		var rx = x-posx;
		var ry = y-posy;
		return mask[ry].charAt(rx)=="O";
	}

	public function addPunkt(x:Int,y:Int){
		if (!inbounds(x,y)){
			resizetoinclude(x,y);
		}
		
		var rx = x-posx;
		var ry = y-posy;

		var row = mask[ry];
		mask[ry]=row.substr(0,rx)+"O"+row.substr(rx+1);
	}
	
	public function resizetoinclude(x:Int,y:Int){

		var rx = x-posx;
		var ry = y-posy;
		var w = mask[0].length;
		var h = mask.length;

		while (rx<0){
			for (j in 0...h){
				mask[j]=" "+mask[j];
			}
			rx++;
			posx--;
		} 
		
		while (rx>=w){
			for (j in 0...h){
				mask[j]=mask[j]+" ";
			}
			w++;
		}
		
		if (ry==h){
			return;
		}
		
		var candrow = " ";
		while(candrow.length<w){
			candrow+=" ";
		}
		
		while (ry<0){
			posy--;
			ry++;			
			mask.unshift(candrow);		
		} 
		
		while (ry>=h){
			mask.push(candrow);
			h++;
		} 
	}

	public function inbounds(x:Int,y:Int):Bool{
		var rx = x-posx;
		var ry = y-posy;
		var w = mask[0].length;
		var h = mask.length;

		return rx>=0&&ry>=0&&rx<w&&ry<h;
	}

	public function removePunkt(x:Int,y:Int){
		if (!inbounds(x,y)){
			return;
		}

		var rx = x-posx;
		var ry = y-posy;

	}

	public function stellbar(brett:Brett,tx:Int,ty:Int):Bool{
		return true;
	}

	public function recalc(){
		verbindungen=[];
		for (i in 0...mask[0].length){

		}
	}
}

class Brett {
	public var stuecke:Array<Stuck>;
}

class Main {	
	
	var darkmodeenter=false;

	function setup(){
		}

	function reset(){
		setup();
	}
	
	function init(){
		// Sound.play("t2");
		//Music.play("music",0,true);
		Gfx.resizescreen(176, 249,true);
		SpriteManager.enable();
		Particle.enable();
		Text.font="nokia";
		setup();
	}	
	
	public var solved:Bool;

	function update() {	
		Gfx.drawimage(0,0,"bg");

		var t_x=20;
		var t_y=37;


		var title_s = solved 
			? Globals.S("Die Würfel sind richtig.","The dice are right!") 
			: Globals.S("Die Würfel sind falsch!","The dice are wrong.")
			;
			
		Text.display(t_x,t_y,title_s,0x47656c);	

		var feld_x=17;
		var feld_y=60;
		for (i in 0...3){
			for (j in 0...3){
				Gfx.drawimage(feld_x+48*i,feld_y+48*j,"diceface");
			}
		}

		//144,13
		var newbuttonstate = IMGUI.togglebutton(
			"audio",
			"button",
			"button_pressed",
			"button_audio_on",
			"button_audio_stumm",
			144,
			11,
			Globals.state.audio==0 ?false:true
		);
		Globals.state.audio = newbuttonstate?1:0;
	
		newbuttonstate = IMGUI.togglebutton(
			"sprache",
			"button",
			"button_pressed",
			"button_flagge_de",
			"button_flagge_en",
			144,
			32,
			Globals.state.sprache==0 ?false:true
		);
		Globals.state.sprache = newbuttonstate?1:0;
	
	//13,219
		var linkspressed = IMGUI.pressbutton(
			"links",
			"button",
			"button_pressed",
			"button_pfeil_links",
			13,
			214
		);


	//144,219

		var rechtspressed = IMGUI.pressbutton(
			"rechts",
			"button",
			"button_pressed",
			"button_pfeil_rechts",
			144,
			214
		);
		if (linkspressed){
			if (Globals.state.level>0){
				Globals.state.level--;
			}
		}
		if (rechtspressed){
			if (Globals.state.level<5){
				Globals.state.level++;
			}
		}
//38,218, 54
		for (stern_index in 0...6){
			var x = 38+16*stern_index;
			var y = 213;
			Gfx.drawimage(
				x,
				y,
				Globals.state.solved[stern_index]==1? "stern_default":"stern_leer"
				);

			if (stern_index==Globals.state.level){
				Gfx.drawimage(x,y,"stern_outline");
			}
		}
	}
}
