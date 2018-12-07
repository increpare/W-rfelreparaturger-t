import haxe.ds.Vector;
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

	public function tx():Int{
		switch(dir){
			case up:
				return tx;
			case upright:
				return tx+1;
			case right:
				return tx+1;
			case downright:
				return tx+1;
		}
	}

	public function ty():Int{
		switch(dir){
			case up:
				return ty-1;
			case upright:
				return ty-1;
			case right:
				return tx;
			case downright:
				return tx+1;
		}
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

	private static function min(a:Int,b:Int){
		return a<b?a:b;
	}

	public function connected(rx1:Int,ry1:Int, rx2:Int, ry2:Int):Bool{
		//flood fill?

		var w = mask[0].length;
		var h = mask.length;

		var colors = new haxe.ds.Vector<Int>(w*h);
		for (i in 0...w*h){
			colors[i]=i;
		}

		var changed=true;
		while(changed){			
			changed=false;
			for (verbindung in verbindungen){
				var sx = verbindung.ox;
				var sy = verbindung.oy;
				var tx = verbindung.tx();				
				var ty = verbindung.ty();

				var c1 = colors[sx+w*sy];
				var c2 = colors[tx+w*ty];
				if (c1!=c2){
					var m = min(c1,c2);
					colors[sx+w*sy]=m;
					colors[tx+w*ty]=m;
					changed=true;
				}
			}	
		}
		return colors[rx1+w*ry1]==colors[rx2+w*ry2];
	}

	public function recalc(){
		verbindungen=[];


		var w = mask[0].length;
		var h = mask.length;

		//erst, recht
		for (j in 0...h){
			for (i in 0...(w-1)){
				if if (mask[j].charAt[i]=="O" && mask[j].charAt[i+1]=="O"){
					verbindungen.push( new Verbindung(i,j,VerbindungDir.right) );
				}
			}
		}

		
		
		//dann, obenwarts
		for (j in 1...h) ){
			for (i in 0...w){				
				var tx = i;
				var ty = j-1;
				if if (mask[ty].charAt[tx]=="O" && mask[ty].charAt[tx]=="O"
				&& connected(i,j,tx,ty)){
					verbindungen.push( new Verbindung(i,j,VerbindungDir.up) );
				}
			}
		}

		//diagonal obenrechts
		for (j in 1...h) ){
			for (i in 0...(w-1)){				
				var tx = i+1;
				var ty = j-1;
				if if (mask[ty].charAt[tx]=="O" && mask[ty].charAt[tx]=="O"
				&& connected(i,j,tx,ty)){
					verbindungen.push( new Verbindung(i,j,VerbindungDir.upright) );
				}
			}
		}

		//diagonal untenrechts
		for (j in 0...(h-1)) ){
			for (i in 0...(w-1)){				
				var tx = i+1;
				var ty = j+1;
				if if (mask[ty].charAt[tx]=="O" && mask[ty].charAt[tx]=="O"
				&& connected(i,j,tx,ty)){
					verbindungen.push( new Verbindung(i,j,VerbindungDir.downright) );
				}
			}
		}

		trace(verbindungen);
	}

}

class Brett {
	public var stuecke:Array<Stuck>;
}

class Main {	
	public static var levels:Array<Array<String>> = [
		[	
			"  11   9 ",
			"   1   9 ",
			"  88  3  ",
			"  88     ",
			"     22  ",
			" 4  0    ",
			"   00 7  ",
			"   5  67 ",
			"         ",
		],
		[	
			"         ",
			"         ",
			"         ",
			"         ",
			"         ",
			"         ",
			"         ",
			"         ",
			"         ",
		],
		[	
			"         ",
			"         ",
			"         ",
			"         ",
			"         ",
			"         ",
			"         ",
			"         ",
			"         ",
		],
		[	
			"         ",
			"         ",
			"         ",
			"         ",
			"         ",
			"         ",
			"         ",
			"         ",
			"         ",
		],
		[	
			"         ",
			"         ",
			"    1    ",
			"         ",
			"         ",
			"         ",
			"         ",
			"         ",
			"         ",
		],
		[	
			"         ",
			"  1      ",
			"         ",
			"         ",
			"      1  ",
			"         ",
			"  1      ",
			"         ",
			"         ",
		],


	]
	
	var darkmodeenter=false;

	function setup(){
		Globals.state.level=Save.loadvalue("level",0);
		Globals.state.audio=Save.loadvalue("audio",1);

		for(i in 0...6){
			Globals.state.solved[i]=Save.loadvalue("solved"+i,0);
		}

		LoadLevel(level);	
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
			"button_audio_stumm",
			"button_audio_on",
			144,
			11,
			Globals.state.audio==0 ?false:true
		);
		if (Globals.state.audio!=newbuttonstate?1:0){
			Globals.state.audio = newbuttonstate?1:0;
			Save.savevalue("audio",Globals.state.audio);
		}
	
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
		if (Globals.state.sprache!=newbuttonstate?1:0){
			Globals.state.sprache = newbuttonstate?1:0;
			Save.savevalue("sprache",Globals.state.sprache);
		}
	
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
				Save.savevalue("level",Globals.state.level);
			}
		}
		if (rechtspressed){
			if (Globals.state.level<5){
				Globals.state.level++;
				Save.savevalue("level",Globals.state.level);
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
