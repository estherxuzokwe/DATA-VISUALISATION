/*
	Visual class
	Manages processing and displaying and interaction with dataset
*/
class Visual {
	// data set
	Data data;

	// bounds of the graph area
	float graphXMin, graphXMax, graphXRng, graphXGap;
	float graphYMin, graphYMax, graphYRng, graphYGap;

	// bounds of the legend area
	float legendXMin, legendXMax, legendXRng, legendXGap, legendXCount;
	float legendYMin, legendYMax, legendYRng, legendYGap, legendYCount;

	// bounds of the info area
	float infoXMin, infoXMax, infoXRng;
	float infoYMin, infoYMax, infoYRng;

	// ranges of dataset
	float yearMin, yearMax, yearRng;
	float saleMin, saleMax, saleRng;

	// fonts being used
	PFont font;
	PFont fontBig;
	PFont fontInfo;

	// zoom variables
	Boolean zoomed;
	float zoomScale;
	float zoomSize;
	PVector target;

	// current highlighted game
	Game gameSelected;

	// visibility variables for dataset
	Boolean showNa, showEu, showJp, showOt;
	ArrayList<Boolean> showGenre;

	Visual() {

	}

	// load the data object and set display size
	void settings(Data dataObj) {
		data = dataObj;

		size(1200, 800);
	}

	// setup different parts of the visual
	void setup() {
		// set title of window
		surface.setTitle("Video Game Visualisation");

		setupLimits();
		setupZoom();
		setupVisibility();
		setupText();
		setupCanvas();

		// select first game by default
		gameSelected = data.games.get(0);
	}

	// setup font variables
	void setupText() {
		font = loadFont("Input-Bold-11.vlw");
		fontBig = loadFont("Input-Bold-48.vlw");
		fontInfo = loadFont("Input-Bold-18.vlw");
		textFont(font);
		textSize(11);
	}

	// setup canvas attributes, such as color mode etc.
	void setupCanvas() {
		colorMode(HSB, 1);
		background(0, 0, 0.2);
	}

	// setup bounds for graph, legend, info and data
	void setupLimits() {
		yearMin = data.yrStats.min;
		// get year limit (e.g. 2016 ends at start of 2017)
		yearMax = data.yrStats.max + 1;
		yearRng = yearMax - yearMin;

		saleMin = floor(data.slStats.min);
		saleMax = ceil(data.slStats.max);
		saleRng = saleMax - saleMin;

		graphXMin = width * 0.03;
		graphXMax = width * 0.99;
		graphXRng = graphXMax - graphXMin;
		graphXGap = graphXRng / yearRng;

		graphYMin = height * 0.97;
		graphYMax = height * 0.1;
		graphYRng = graphYMax - graphYMin;
		graphYGap = graphYRng / yearRng;

		legendXMin = width*0.03;
		legendXMax = width*0.99;
		legendXRng = legendXMax - legendXMin;
		legendXCount = 10;
		legendXGap = legendXRng / legendXCount;

		legendYMin = height*0.09;
		legendYMax = height*0.01;
		legendYRng = legendYMax - legendYMin;
		legendYCount = 4;
		legendYGap = legendYRng / legendYCount;

		infoXMin = width*0.6;
		infoXMax = width*1;
		infoXRng = infoXMax - infoXMin;

		infoYMin = height*0.1;
		infoYMax = height*0.3;
		infoYRng = infoYMax - infoYMin;
	}

	// setup zoom variables, by default is zoomed out
	void setupZoom() {
		zoomed = false;
		zoomSize = height/6;
		zoomScale = 24;

		target = new PVector(0, 0);
	}

	// setup all data to be visible
	void setupVisibility() {
		showNa = true;
		showEu = true;
		showJp = true;
		showOt = true;

		showGenre = new ArrayList<Boolean>();
		for (String genre : data.genres) {
			showGenre.add(true);
		}
	}

	void update() {
		// update zoom target position
		target.lerp(mouseX, mouseY, 0, 0.03);
	}

	// manage key presses
	void keyPressed() {
		// switch zoom if z is pressed
		zoomed = key == 'z' ? !zoomed : zoomed;

		// switch continent visibility if number is pressed
		showNa = key == '1' ? !showNa : showNa;
		showEu = key == '2' ? !showEu : showEu;
		showJp = key == '3' ? !showJp : showJp;
		showOt = key == '4' ? !showOt : showOt;

		// switch genre visibility if letter is pressed
		int index = key - 'a';

		if (index >= 0 && index < showGenre.size()) {
			showGenre.set(index, !showGenre.get(index));
		}
	}

	void draw() {
		background(0.2);

		pushMatrix();

		zoom();

		drawGrid();

		drawAxis();

		drawLabels();

		drawPoints();

		drawLegend();

		popMatrix();

		drawInfo();
		drawLens();
	}

	// zooms in if currently zoomed
	void zoom() {
		// if zoomed, then zoom into the current target location
		if (zoomed) {
			translate(width/2, height/2);
			scale(zoomScale);
			translate(-target.x, -target.y);
		}
	}

	// draws the rectangle and focus point for the current zoom location
	void drawLens() {
		float w2 = width/2;
		float h2 = height/2;

		float crossSize = zoomSize/4;

		noFill();
		strokeWeight(1);
		stroke(1, 1);
		if (zoomed) {
			ellipse(w2, h2, 4 * crossSize, 4 * crossSize);
			line(w2 - crossSize, h2, w2 + crossSize, h2);
			line(w2, h2 - crossSize, w2, h2 + crossSize);
		} else {
			crossSize = zoomSize/zoomScale;
			float rectWidth = w2/zoomScale;
			float rectHeight = h2/zoomScale;

			rect(target.x - rectWidth, target.y - rectHeight, 2*rectWidth, 2*rectHeight);
			ellipse(target.x, target.y, 4 * crossSize, 4 * crossSize);
			line(target.x, target.y - crossSize, target.x, target.y + crossSize);
			line(target.x - crossSize, target.y, target.x + crossSize, target.y);
		}
	}

	// draws the grid for the graph area
	void drawGrid() {
		float x, y;

		noStroke();
		for (float yr = yearMin; yr <= yearMax; yr += 1) {
			x = map(yr, yearMin, yearMax, graphXMin, graphXMax);;
			fill(1, yr % 2 == 0 ? 0.02 : 0);
			rect(x, graphYMax, graphXGap, -graphYRng);
		}


		strokeWeight(zoomed ? 0.1 : 1);

		noFill();
		stroke(1, 0.25);
		for (float yr = yearMin; yr <= yearMax; yr += 1) {
			x = map(yr, yearMin, yearMax, graphXMin, graphXMax);;
			line(x, graphYMin, x, graphYMax);
		}

		for (float sl = saleMin; sl <= saleMax; sl += 1) {
			y = map(sl, saleMin, saleMax, graphYMin, graphYMax);
			line(graphXMin, y, graphXMax, y);
		}
	}

	void drawAxis() {

		float thickness = zoomed ? 0.1 : 1;

		noFill();
		stroke(1, 0.5);
		strokeWeight(thickness*2);
		strokeCap(PROJECT);

		// Different axis settings
		line(graphXMin-thickness, graphYMin+thickness, graphXMax+thickness, graphYMin+thickness);
		line(graphXMin-thickness, graphYMax-thickness, graphXMin-thickness, graphYMin+thickness);
		// line(graphXMax+thickness, graphYMin+thickness, graphXMax+thickness, graphYMax-thickness);
		// line(graphXMax+thickness, graphYMax-thickness, graphXMin-thickness, graphYMax-thickness);
		// rect(graphXMin-thickness, graphYMin+thickness, graphXRng+thickness*2, graphYRng-thickness*2);

		// Axis ticks
		float x, y;
		float xOff = width*0.005;
		float yOff = -height*0.005;

		for (float yr = yearMin; yr <= yearMax; yr += 1) {
			x = map(yr, yearMin, yearMax, graphXMin, graphXMax);;
			line(x, graphYMin, x, graphYMin-yOff);
		}

		for (float sl = saleMin; sl <= saleMax; sl += 1) {
			y = map(sl, saleMin, saleMax, graphYMin, graphYMax);
			line(graphXMin, y, graphXMin-xOff, y);
		}
	}

	// draws the text labels for each tick on the axis
	void drawLabels() {
		float x, y;
		float xOff = width*0.01;
		float yOff = -height*0.01;

		fill(1);

		textFont(zoomed ? fontBig : font);
		textSize(11);

		textAlign(CENTER, TOP);
		for (float yr = yearMin; yr < yearMax; yr += 1) {
			x = map(yr, yearMin, yearMax, graphXMin, graphXMax);;
			text(String.format("%.0f", yr), x + graphXGap/2, graphYMin-yOff);
		}

		textAlign(RIGHT, CENTER);
		for (float sl = saleMin; sl <= saleMax; sl += 1) {
			y = map(sl, saleMin, saleMax, graphYMin, graphYMax);
			text(String.format("%.0f", sl), graphXMin-xOff, y);
		}
	}


	void drawPoints() {
		float x, y;
		float xBase;
		float s;

		int indexGenre;
		int indexPlatform;
		float hue;

		float genreCount = data.genres.size();
		float platformCount = data.platforms.size();
		float xOff = graphXGap/platformCount/2;

		s = graphXGap/platformCount;

		noFill();
		noStroke();
		strokeWeight(zoomed ? 0.1 : 1);

		for (Game game : data.games) {
			indexGenre = data.genres.indexOf(game.genre);
			indexPlatform = data.platforms.indexOf(game.platform);

			if (showGenre.get(indexGenre)) {
				hue = map(indexGenre, 0, genreCount, 0, 1);

				xBase = map(game.year, yearMin, yearMax, graphXMin, graphXMax);
				x = map(indexPlatform, 0, platformCount, xBase, xBase + graphXGap);

				stroke(hue, 0.5, 1);

				if (showNa) {
					y = map(game.naSales, saleMin, saleMax, graphYMin, graphYMax);
					drawSquare(x, y, s);
					selectGame(game, x, y, s);
				}

				if (showEu) {
					y = map(game.euSales, saleMin, saleMax, graphYMin, graphYMax);
					drawDiamond(x, y, s);
					selectGame(game, x, y, s);
				}

				if (showJp) {
					y = map(game.jpSales, saleMin, saleMax, graphYMin, graphYMax);
					drawTriangle(x, y, s);
					selectGame(game, x, y, s);
				}

				if (showOt) {
					y = map(game.otSales, saleMin, saleMax, graphYMin, graphYMax);
					drawCircle(x, y, s);
					selectGame(game, x, y, s);
				}
			}
		}
	}

	void selectGame(Game game, float x, float y, float s) {
		if (x - s/2 <= target.x && target.x <= x + s/2) {
			if (y - s/2 <= target.y && target.y <= y + s/2) {
				gameSelected = game;
			}
		}
	}

	void drawInfo() {
		float x, y;

		textFont(fontInfo);
		textSize(18);
		textAlign(LEFT, TOP);

		float hue = map(data.genres.indexOf(gameSelected.genre), 0, data.genres.size(), 0, 1);

		strokeWeight(2);
		stroke(hue, 0.5, 1);
		fill(0, 0.4);
		rect(infoXMin, infoYMin, infoXRng, infoYRng);

		fill(1);

		x = map(0.02, 0, 1, infoXMin, infoXMax);
		y = map(0.05, 0, 1, infoYMin, infoYMax);
		text(String.format("Name: %s", gameSelected.name), x, y);

		x = map(0.02, 0, 1, infoXMin, infoXMax);
		y = map(0.2, 0, 1, infoYMin, infoYMax);
		text(String.format("Publisher: %s", gameSelected.publisher), x, y);

		x = map(0.02, 0, 1, infoXMin, infoXMax);
		y = map(0.35, 0, 1, infoYMin, infoYMax);
		text(String.format("Year: %d", gameSelected.year), x, y);

		x = map(0.5, 0, 1, infoXMin, infoXMax);
		y = map(0.35, 0, 1, infoYMin, infoYMax);
		text(String.format("Platform: %s", gameSelected.platform), x, y);

		x = map(0.02, 0, 1, infoXMin, infoXMax);
		y = map(0.5, 0, 1, infoYMin, infoYMax);
		text(String.format("Genre: %s", gameSelected.genre), x, y);

		x = map(0.5, 0, 1, infoXMin, infoXMax);
		y = map(0.5, 0, 1, infoYMin, infoYMax);
		text(String.format("Total sales: %.2f", gameSelected.totalSales), x, y);

		x = map(0.02, 0, 1, infoXMin, infoXMax);
		y = map(0.7, 0, 1, infoYMin, infoYMax);
		text(String.format("NA sales: %.2f", gameSelected.naSales), x, y);

		x = map(0.02, 0, 1, infoXMin, infoXMax);
		y = map(0.85, 0, 1, infoYMin, infoYMax);
		text(String.format("EU sales: %.2f", gameSelected.euSales), x, y);

		x = map(0.5, 0, 1, infoXMin, infoXMax);
		y = map(0.7, 0, 1, infoYMin, infoYMax);
		text(String.format("JP sales: %.2f", gameSelected.jpSales), x, y);

		x = map(0.5, 0, 1, infoXMin, infoXMax);
		y = map(0.85, 0, 1, infoYMin, infoYMax);
		text(String.format("OT sales: %.2f", gameSelected.otSales), x, y);

		x = map(0.02, 0, 1, infoXMin, infoXMax);
		y = map(1.02, 0, 1, infoYMin, infoYMax);
		text(String.format("Current year: %.0f", map(target.x, graphXMin, graphXMax, yearMin, yearMax)), x, y);

		x = map(0.5, 0, 1, infoXMin, infoXMax);
		y = map(1.02, 0, 1, infoYMin, infoYMax);
		text(String.format("Current sales: %.2f", map(target.y, graphYMin, graphYMax, saleMin, saleMax)), x, y);
	}

	void drawLegend() {
		fill(1, 0.1);
		noStroke();
		rect(legendXMin, legendYMin, legendXRng, legendYRng);

		float x, y;
		float i, j;
		float s = -legendYGap - 2;


		strokeWeight(1);
		stroke(0, 0.1);
		fill(1, 0.2);
		for (i = 0; i < legendXCount; i += 1) {
			for (j = 0; j < legendYCount; j += 1) {
				x = map(i, 0, legendXCount, legendXMin, legendXMax);
				y = map(j+0.5, 0, legendYCount, legendYMax, legendYMin);

				rect(x, y+legendYGap/2, legendXGap, -legendYGap);
			}
		}


		textFont(zoomed ? fontBig : font);
		textSize(11);
		textAlign(RIGHT, CENTER);


		i = 0;
		j = 0;
		x = map(i+0.8, 0, legendXCount, legendXMin, legendXMax);
		y = map(j+0.5, 0, legendYCount, legendYMax, legendYMin);
		fill(1);
		text("1. NA Sale", x, y);
		x = map(i+0.9, 0, legendXCount, legendXMin, legendXMax);
		noFill();
		stroke(1, showNa ? 1 : 0.5);
		drawSquare(x, y, s);

		i = 0;
		j = 1;
		x = map(i+0.8, 0, legendXCount, legendXMin, legendXMax);
		y = map(j+0.5, 0, legendYCount, legendYMax, legendYMin);
		fill(1);
		text("2. EU Sale", x, y);
		x = map(i+0.9, 0, legendXCount, legendXMin, legendXMax);
		noFill();
		stroke(1, showEu ? 1 : 0.5);
		drawDiamond(x, y, s);

		i = 0;
		j = 2;
		x = map(i+0.8, 0, legendXCount, legendXMin, legendXMax);
		y = map(j+0.5, 0, legendYCount, legendYMax, legendYMin);
		fill(1);
		text("3. JP Sale", x, y);
		x = map(i+0.9, 0, legendXCount, legendXMin, legendXMax);
		noFill();
		stroke(1, showJp ? 1 : 0.5);
		drawTriangle(x, y, s);

		i = 0;
		j = 3;
		x = map(i+0.8, 0, legendXCount, legendXMin, legendXMax);
		y = map(j+0.5, 0, legendYCount, legendYMax, legendYMin);
		fill(1);
		text("4. OT Sale", x, y);
		x = map(i+0.9, 0, legendXCount, legendXMin, legendXMax);
		noFill();
		stroke(1, showOt ? 1 : 0.5);
		drawCircle(x, y, s);


		float hue;
		float genreCount = data.genres.size();

		noStroke();
		for (int indexGenre = 0; indexGenre < genreCount; indexGenre+=1) {
			String genre = data.genres.get(indexGenre);

			i = indexGenre / 4 + 1;
			j = indexGenre % 4;
			x = map(i+0.8, 0, legendXCount, legendXMin, legendXMax);
			y = map(j+0.5, 0, legendYCount, legendYMax, legendYMin);
			fill(1);
			text(String.format("%c. %s", 97+indexGenre, genre), x, y);
			x = map(i+0.9, 0, legendXCount, legendXMin, legendXMax);

			hue = map(indexGenre, 0, genreCount, 0, 1);
			if (showGenre.get(indexGenre)) {
				noStroke();
				fill(hue, 0.5, 1);
			} else {
				noFill();
				stroke(hue, 0.5, 1);
			}
			ellipse(x, y, s, s);
		}


		float platformCount = data.platforms.size();

		textAlign(LEFT, CENTER);
		noStroke();
		for (int indexPlatform = 0; indexPlatform < platformCount; indexPlatform+=1) {
			String genre = data.platforms.get(indexPlatform);

			i = indexPlatform / 4;
			j = indexPlatform % 4;
			x = map(i*0.8 + 4 + 1, 0, legendXCount, legendXMin, legendXMax);
			y = map(j+0.5, 0, legendYCount, legendYMax, legendYMin);
			fill(1);
			text(String.format("%d. %s", indexPlatform+1, genre), x, y);
		}

	}

	void drawCircle(float x, float y, float s) {
		s *= 1;
		ellipse(x, y, s, s);
		point(x, y);
	}

	void drawSquare(float x, float y, float s) {
		s *= 0.9;
		rect(x-s/2, y-s/2, s, s);
		point(x, y);
	}

	void drawTriangle(float x, float y, float s) {
		s *= 1;
		triangle(x-s/2, y+s/2, x, y-s/2, x+s/2, y+s/2);
		point(x, y);
	}

	void drawDiamond(float x, float y, float s) {
		s *= 1.2;
		quad(x, y-s/2, x+s/2, y, x, y+s/2, x-s/2, y);
		point(x, y);
	}
}

