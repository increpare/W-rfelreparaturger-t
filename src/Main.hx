import haxe.rtti.XmlParser;
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

	public function tox():Int{
		switch(dir){
			case up:
				return ox;
			case upright:
				return ox+1;
			case right:
				return ox+1;
			case downright:
				return ox+1;
		}
	}

	public function toy():Int{
		switch(dir){
			case up:
				return oy-1;
			case upright:
				return oy-1;
			case right:
				return ox;
			case downright:
				return ox+1;
		}
	}
}

class Ueberzug {
	public var x:Int;
	public var y:Int;
	public var dir:VerbindungDir; //right = point
	public function new(x:Int,y:Int,dir:VerbindungDir){
		this.x=x;
		this.y=y;
		this.dir=dir;
	}
}



class Stuck {
	public var posx:Int;
	public var posy:Int;
	public var mask:Array<String>;

	public var verbindungen:Array<Verbindung>;

	public static function intmax(a:Int,b:Int):Int{
		return a>b?a:b;
	}
	public static function intmin(a:Int,b:Int):Int{
		return a<b?a:b;
	}

	public function overlap(o:Stuck):Array<Ueberzug>{
		var result = new Array<Ueberzug>();

		var x1 = posx;
		var y1 = posy;

		var x2 = o.posx;
		var y2 = o.posy;

		var w1 = mask[0].length;
		var h1 = mask.length;

		var w2 = o.mask[0].length;
		var h2 = o.mask.length;

		var mini =intmax(x1,x2);
		var maxi =intmin(x1+w1,x2+w2);
		var minj=intmax(y1,y2);
		var maxj=intmin(y1+h1,y2+h2);

		if (mini>=maxi || minj>=maxj){
			return result;
		}

		for (i in mini...maxi){
			for (j in minj...maxj){				
				var hasp1 = hasPunkt(i,j);
				if (hasp1==false){
					continue;
				}
				var hasp2 = o.hasPunkt(i,j);
				if (hasp2==false){
					continue;
				}

				var uz = new Ueberzug(i,j,VerbindungDir.right);
				result.push(uz);				
			}
		}

		for (verbindung1 in verbindungen){
			var schraeg1 = verbindung1.dir == VerbindungDir.downright || verbindung1.dir == VerbindungDir.upright;
			if (schraeg1==false){
				continue;
			}

			for (verbindung2 in o.verbindungen){
				var schraeg2 = verbindung2.dir == VerbindungDir.downright || verbindung2.dir == VerbindungDir.upright;
				if (schraeg2==false){
					continue;
				}


				if (verbindung1.dir==VerbindungDir.upright && verbindung2.dir==VerbindungDir.downright){
					var vb1_posx=  verbindung1.ox+this.posx;
					var vb1_posy=  verbindung1.oy+this.posy;

					var vb2_posx=  verbindung2.ox+o.posx;
					var vb2_posy=  verbindung2.oy+o.posy;

					if (vb1_posx==vb2_posx && vb1_posy==vb2_posy+1){						
						var uz = new Ueberzug(vb1_posx,vb1_posy,VerbindungDir.upright);
						result.push(uz);				
					}

				} else if (verbindung1.dir==VerbindungDir.downright && verbindung2.dir==VerbindungDir.upright){
					var vb1_posx=  verbindung1.ox+this.posx;
					var vb1_posy=  verbindung1.oy+this.posy;

					var vb2_posx=  verbindung2.ox+o.posx;
					var vb2_posy=  verbindung2.oy+o.posy;

					if (vb1_posx==vb2_posx && vb1_posy==vb2_posy-1){						
						var uz = new Ueberzug(vb1_posx,vb1_posy,VerbindungDir.downright);
						result.push(uz);				
					}
				} 
			}
		}

		return result;
	}

	public function pixelposx():Int{
		var off_x = Main.feld_x-1;
		var px = off_x+(posx)*Main.tile_s;
		return px;
	}

	public function pixelposy():Int{
		var off_y = Main.feld_y-1;
		var py = off_y+(posy)*Main.tile_s;
		return py;
	}
	
	function has_exit(i:Int,j:Int,dir:VerbindungDir):Bool{
		var w = mask[0].length;
		var h = mask.length;
		for (verbindung in verbindungen){
			if (verbindung.ox==i && verbindung.oy==j && verbindung.dir==dir){
				return true;
			}
		}
		return false;
	}

	public function width():Int{
		return mask[0].length;
	}
	public function height():Int{
		return mask.length;
	}
	
	public function drawhighlight(){
		var w = mask[0].length;
		var h = mask.length;
		var off_x = Main.feld_x-1;
		var off_y = Main.feld_y-1;
		var tile_s = Main.tile_s;
		for (i in 0...w){
			for (j in 0...h){
				if (mask[j].charAt(i)==" "){
					continue;
				}

				var upconnection= has_exit(i,j,VerbindungDir.up);
				var downconnection= has_exit(i,j+1,VerbindungDir.up);
				var leftconnection= has_exit(i-1,j,VerbindungDir.right);
				var rightconnection= has_exit(i,j,VerbindungDir.right);
				
				var uprightconnection= has_exit(i,j,VerbindungDir.upright);
				var downleftconnection= has_exit(i-1,j+1,VerbindungDir.upright);
				var downrightconnection= has_exit(i,j,VerbindungDir.downright);
				var upleftconnection= has_exit(i-1,j-1,VerbindungDir.downright);

				//tl quadrant
				{
					var px = off_x+(posx+i)*tile_s;
					var py = off_y+(posy+j)*tile_s;

					if (upconnection && leftconnection){
						Gfx.drawimage(px,py,"highlight_bi_tl");
					} else if (upconnection){
						Gfx.drawimage(px,py,"highlight_n_tl");
					} else if (leftconnection){
						Gfx.drawimage(px,py,"highlight_w_tl");
					} else if (upleftconnection){
						//Gfx.drawimage(px,py,"");
					} else {
						Gfx.drawimage(px,py,"highlight_tl");
					}

				}
				//tr quadrant
				{
					var px = off_x+(posx+i)*tile_s+8;
					var py = off_y+(posy+j)*tile_s;

					if (upconnection && rightconnection){
						Gfx.drawimage(px,py,"highlight_bi_tr");
					} else if (upconnection){
						Gfx.drawimage(px,py,"highlight_n_tr");
					} else if (rightconnection){
						Gfx.drawimage(px,py,"highlight_e_tr");
					} else if (uprightconnection){
						py-=8;
						Gfx.drawimage(px,py,"highlight_ur");
					} else {
						Gfx.drawimage(px,py,"highlight_tr");
					}
				}

				//br quadrant
				{
					var px = off_x+(posx+i)*tile_s+8;
					var py = off_y+(posy+j)*tile_s+8;

					if (downconnection && rightconnection){
						Gfx.drawimage(px,py,"highlight_bi_br");
					} else if (downconnection){
						Gfx.drawimage(px,py,"highlight_s_br");
					} else if (rightconnection){
						Gfx.drawimage(px,py,"highlight_e_br");
					} else if (downrightconnection){
						Gfx.drawimage(px,py,"highlight_dr");
					} else {
						Gfx.drawimage(px,py,"highlight_br");
					}
				}

				//bl quadrant
				{
					var px = off_x+(posx+i)*tile_s;
					var py = off_y+(posy+j)*tile_s+8;

					if (downconnection && leftconnection){
						Gfx.drawimage(px,py,"highlight_bi_bl");
					} else if (downconnection){
						Gfx.drawimage(px,py,"highlight_s_bl");
					} else if (leftconnection){
						Gfx.drawimage(px,py,"highlight_w_bl");
					} else if (downleftconnection){
						// Gfx.drawimage(px,py,"highlight_dr");
					} else {
						Gfx.drawimage(px,py,"highlight_bl");
					}
				}
			}
		}

	}

	public function draw_skeleton(){
		var w = mask[0].length;
		var h = mask.length;
		var off_x = Main.feld_x-1;
		var off_y = Main.feld_y-1;
		var tile_s = Main.tile_s;

		
		for (verbindung in verbindungen){
			var px = off_x+(posx+verbindung.ox)*tile_s;
			var py = off_y+(posy+verbindung.oy)*tile_s;
			switch (verbindung.dir){
				case up:
					py=py-8;
					Gfx.drawimage(px,py,"skeleton_connector_ud");
				case upright:
					px+=8;
					py=py-8;					
					Gfx.drawimage(px,py,"skeleton_connector_ur");
				case right:
					px+=8;
					Gfx.drawimage(px,py,"skeleton_connector_lr");
				case downright:
					px+=8;
					py+=8;
					Gfx.drawimage(px,py,"skeleton_connector_dr");
			}
		}

		for (i in 0...w){
			for (j in 0...h){
				var c = mask[j].charAt(i);
				if (c=="O"){
					var px = off_x+(posx+i)*tile_s;
					var py = off_y+(posy+j)*tile_s;
					Gfx.drawimage(px,py,"skeleton_pip");
				}
			}
		}
	}

	public function draw(){
		var w = mask[0].length;
		var h = mask.length;
		var off_x = Main.feld_x-1;
		var off_y = Main.feld_y-1;
		var tile_s = Main.tile_s;

		
		for (verbindung in verbindungen){
			var px = off_x+(posx+verbindung.ox)*tile_s;
			var py = off_y+(posy+verbindung.oy)*tile_s;
			switch (verbindung.dir){
				case up:
					py=py-8;
					Gfx.drawimage(px,py,"connector_ud");
				case upright:
					px+=8;
					py=py-8;					
					Gfx.drawimage(px,py,"connector_ur");
				case right:
					px+=8;
					Gfx.drawimage(px,py,"connector_lr");
				case downright:
					px+=8;
					py+=8;
					Gfx.drawimage(px,py,"connector_dr");
			}
		}

		for (i in 0...w){
			for (j in 0...h){
				var c = mask[j].charAt(i);
				if (c=="O"){
					var px = off_x+(posx+i)*tile_s;
					var py = off_y+(posy+j)*tile_s;
					Gfx.drawimage(px,py,"pip");
				}
			}
		}
	}
	
	public function new(){
		mask = new Array<String>();
		verbindungen = new Array<Verbindung>();
	}

	public function hasPunkt(x:Int,y:Int):Bool{
		if (inbounds(x,y)==false){
			return false;			
		}
		
		var rx = x-posx;
		var ry = y-posy;
		return mask[ry].charAt(rx)=="O";
	}

	public function removePunkt(x:Int,y:Int):Bool{
		if (inbounds(x,y)==false){
			return false;
		}

		var rx = x-posx;
		var ry = y-posy;
		
		var c = mask[ry].charAt(rx);
		if (c==" "){
			return false;
		}

		

		var row = mask[ry];
		mask[ry]=row.substr(0,rx)+" "+row.substr(rx+1);

		removeEmptyRowsCols();
		return true;
	}

	public function emptyRowString(s:String):Bool{
		return s.indexOf("O")==-1;
	}
	public function emptyCol(i:Int):Bool{
		for (r in mask){
			if (r.charAt(i)=="O"){
				return false;
			}
		}
		return true;
	}

	public function removeCol(i:Int){
		for (r in 0...mask.length){
			var row = mask[r];
			mask[r]=row.substr(0,i)+row.substr(i+1);			
		}
	}

	public function removeEmptyRowsCols(){
		//remove initial empty cols - incrementing posy if so
		
		while(mask[0].length>0 && emptyCol(0)){			
			removeCol(0);
			posx++;
		}

		while(mask[0].length>0 && emptyCol(mask[0].length-1)){
			removeCol(mask[0].length-1);
		}

		while(mask.length>0 && emptyRowString(mask[0])){
			mask.shift();
			posy++;
		}

		while(mask.length>0 && emptyRowString(mask[mask.length-1])){
			mask.pop();
		}
	}

	public function addPunkt(x:Int,y:Int){
		if (!inbounds(x,y)){
			resizetoinclude(x,y);
		}
		
		var rx = x-posx;
		var ry = y-posy;

		var row = mask[ry];
		mask[ry]=row.substr(0,rx)+"O"+row.substr(rx+1);
		recalc();
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
		
		if (ry+1==h){
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
				var tx = verbindung.tox();				
				var ty = verbindung.toy();

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
				if (mask[j].charAt(i)=="O" && mask[j].charAt(i+1)=="O"){
					verbindungen.push( new Verbindung(i,j,VerbindungDir.right) );
				}
			}
		}

		
		
		//dann, obenwarts
		for (j in 1...h){
			for (i in 0...w){				
				var tx = i;
				var ty = j-1;
				if (mask[j].charAt(i)=="O" && mask[ty].charAt(tx)=="O"
				&& !connected(i,j,tx,ty)){
					verbindungen.push( new Verbindung(i,j,VerbindungDir.up) );
				}
			}
		}

		//diagonal obenrechts
		for (j in 1...h ){
			for (i in 0...(w-1)){				
				var tx = i+1;
				var ty = j-1;
				if (mask[j].charAt(i)=="O" && mask[ty].charAt(tx)=="O"
				&& !connected(i,j,tx,ty)){
					verbindungen.push( new Verbindung(i,j,VerbindungDir.upright) );
				}
			}
		}



		//diagonal untenrechts
		for (j in 0...(h-1) ){
			for (i in 0...(w-1)){				
				var tx = i+1;
				var ty = j+1;
				if (mask[j].charAt(i)=="O" && mask[ty].charAt(tx)=="O"
				&& !connected(i,j,tx,ty)){
					verbindungen.push( new Verbindung(i,j,VerbindungDir.downright) );
				}
			}
		}

	}

}

class Brett {
	public var stuecke:Array<Stuck>;
	public function new(){
		stuecke = new Array<Stuck>();
	}
}

class Main {	
	private var editmode=false;
	private var lastselected=-1;

	private var selectedIndex=-1;
	private var selected_x_offset=0;
	private var selected_y_offset=0;

	public static var levels:Array<Array<String>> = [
		[	
			"4     77 ",
			"4  33 777",
			"   1   77",
			" 21  5   ",
			"  2 555  ",
			"     5   ",
			"6 6    88",
			" 6    888",
			"6 6   88 ",
		],
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


	];

	
	var darkmodeenter=false;

	public var brett:Brett;
	function LoadLevel(l:Int){
		var leveldat = levels[l];

		brett = new Brett();
	
		var found="";

		var w=9;
		var h = 9;
		for (i in 0...w){
			for (j in 0...h){
				var c = leveldat[j].charAt(i);
				if (c==" "){
					continue;
				}
				var ci = found.indexOf(c);
				if (ci>=0){

					var stueck = brett.stuecke[ci];
					stueck.addPunkt(i,j);
				} else {
					var stueck:Stuck = new Stuck();

					stueck.posx=i;
					stueck.posy=j;
					stueck.mask=["O"];					
					brett.stuecke.push(stueck);
					lastselected=brett.stuecke.length-1;
					found = found+c;
				}
			}
		}

		for (stuck in brett.stuecke){
			stuck.recalc();
		}

		trace(brett);
	}

	function setup(){
		Globals.state.level=Save.loadvalue("level",0);
		Globals.state.audio=Save.loadvalue("audio",1);

		for(i in 0...6){
			Globals.state.solved[i]=Save.loadvalue("solved"+i,0);
		}

		LoadLevel(Globals.state.level);	
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
		Gfx.loadtiles("dice_highlighted",16,16);
		setup();
	}	
	
	public var solved:Bool;
	
	public static var feld_x=17;
	public static var feld_y=60;
	public static var tile_s=16;

	function update() {	
		Gfx.drawimage(0,0,"bg");

		if (Input.justpressed(Key.E)){
			editmode=!editmode;			
			if (editmode==false){
				lastselected=-1;
			}
		}

		if (editmode){
			Text.display(1,1,"E",0xffffff);
		}

		var t_x=20;
		var t_y=37;


		var title_s = solved 
			? Globals.S("Die Würfel sind richtig.","The dice are right!") 
			: Globals.S("Die Würfel sind falsch!","The dice are wrong.")
			;
			

		Text.display(t_x,t_y,title_s,0x47656c);	


		for (i in 0...3){
			for (j in 0...3){
				Gfx.drawimage(feld_x+48*i,feld_y+48*j,"diceface");
			}
		}

		var off_x = Main.feld_x-1;
		var off_y = Main.feld_y-1;

		if (editmode){
			if (lastselected>=0){
				var stueck = brett.stuecke[lastselected];
				var w = stueck.width();
				var h = stueck.height();
				for (i in 0...w){
					for (j in 0...h){
						if (stueck.mask[j].charAt(i)=="O"){

							var px = off_x+16*(stueck.posx+i);
							var py = off_y+16*(stueck.posy+j);
							
							var xm3 = (stueck.posx+i)%3;
							var ym3 = (stueck.posy+j)%3;


							var ci = 3*ym3+xm3;
							Gfx.drawtile(px,py,"dice_highlighted",ci);

						}
					}
				}
			}
		}


		var alreadyselected:Bool=selectedIndex>=0;

		var mx = Math.floor((Mouse.x-off_x)/tile_s);
		var my = Math.floor((Mouse.y-off_y)/tile_s);
		var clicked = Mouse.leftclick();
		// var released = Mouse.leftreleased();
		
		
		var highlighted:Bool=false;
		for (i in 0...brett.stuecke.length){
			var stueck = brett.stuecke[i];


			if ( selectedIndex==-1 &&  stueck.hasPunkt(mx,my)){
				if (clicked){
					if (selectedIndex==-1 && editmode==false){
						selectedIndex = i;
						lastselected = i;
						selected_x_offset = stueck.posx-mx;
						selected_y_offset = stueck.posy-my;
					}
				}
				stueck.drawhighlight();
				highlighted=true;								
			}
	
			if (selectedIndex==i){
				continue;
			}

			stueck.draw();
		}

		if (selectedIndex>=0){
			var stueck = brett.stuecke[selectedIndex];

			var mx = Math.floor((Mouse.x-off_x)/tile_s);
			var my = Math.floor((Mouse.y-off_y)/tile_s);
			
			var sx = mx+selected_x_offset;
			var sy = my+selected_y_offset;

			if (sx<0){
				sx=0;
			}
			if (sx+stueck.width()>9){
				sx = 9-stueck.width();
			}
			if (sy<0){
				sy=0;
			}
			if (sy+stueck.height()>9){
				sy = 9-stueck.height();
			}

			stueck.posx=sx;
			stueck.posy=sy;
			stueck.draw_skeleton();
			
			var anyoverlaps=false;
			//überzüge
			for (i in 0...brett.stuecke.length){
				if (i==selectedIndex){
					continue;
				}
				var stueck_i = brett.stuecke[i];
				var overlaps = stueck.overlap(stueck_i);
				for (ol in overlaps){
					var px = off_x+(ol.x)*tile_s;
					var py = off_y+(ol.y)*tile_s;

					switch (ol.dir){
						case VerbindungDir.right:					
							Gfx.drawimage(px,py,"highlight_no");
						case VerbindungDir.upright:
							Gfx.drawimage(px,py-16,"highlight_no_ur");
						case VerbindungDir.downright:
							Gfx.drawimage(px,py,"highlight_no_dr");
						default:
						trace("shouldn't get here "+ol);
					}
				}
				if (overlaps.length>0){
					anyoverlaps=true;
				}
			}
			if (anyoverlaps==false && alreadyselected==true){
				if (clicked){
					selectedIndex=-1;
				}
			}
		}
	
		if (mx>=0 && my>=0 && mx<9 && my<9 && selectedIndex==-1){
			var px = off_x+16*mx;
			var py = off_y+16*my;
			var cx = mx%3;
			var cy = my%3;
			var ci = 3*cy+cx;
			// Gfx.drawtile(px,py,"dice_highlighted",ci);
			Gfx.drawimage(px,py,"cursor");

			if (editmode && clicked){
				var anyfound=false;
				//if it's part of an existing piece, delete it

				var i:Int=0;
				while (i<brett.stuecke.length){
					var stueck = brett.stuecke[i];
					if (stueck.hasPunkt(mx,my)){
						anyfound=true;
						stueck.removePunkt(mx,my);
						if (stueck.mask.length==0){
							brett.stuecke.splice(i,1);
							if (lastselected==i){
								lastselected=-1;
							}
							i--;
							continue;
						}
						stueck.recalc();
					}
					i++;
				}

				if (anyfound==false) {
					if (lastselected==-1){
						var s:Stuck = new Stuck();
						s.posx=mx;
						s.posy=my;
						s.mask=["O"];
						s.recalc();
						brett.stuecke.push(s);
					} else {
						var stueck = brett.stuecke[lastselected];
						stueck.addPunkt(mx,my);
					}
				}
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
		if ((Globals.state.audio==1)!=newbuttonstate){
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
		if ( (Globals.state.sprache==1)!=newbuttonstate){
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
				LoadLevel(Globals.state.level);	
			}
		}
		if (rechtspressed){
			if (Globals.state.level<5){
				Globals.state.level++;
				Save.savevalue("level",Globals.state.level);
				LoadLevel(Globals.state.level);	
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
