Data data;
Visual visual;

void settings() {
	data = new Data();
	visual = new Visual();

	data.settings("vgsales.csv");
	visual.settings(data);
}

void setup() {
	visual.setup();
}

void draw() {
	visual.update();
	visual.draw();
}

void keyPressed() {
	visual.keyPressed();
}
