/*
	Game class
	Keeps a record of a single game and its data
*/
class Game {
	// game data fields
	int year;
	String name, platform, genre, publisher;
	float naSales, euSales, jpSales, otSales;
	float totalSales;
	
	Game(TableRow row) {
		year = row.getInt("Year");

		name = row.getString("Name");
		platform = row.getString("Platform");
		genre = row.getString("Genre");
		publisher = row.getString("Publisher");

		naSales = row.getFloat("NA_Sales");
		euSales = row.getFloat("EU_Sales");
		jpSales = row.getFloat("JP_Sales");
		otSales = row.getFloat("Other_Sales");

		// sum of individual continent sales
		totalSales = naSales + euSales + jpSales + otSales;
	}
}
