// Data fields are
// 0     1         2     3      4          5         6         7         8
// Name  Platform  Year  Genre  Publisher  NA_Sales  EU_Sales  JP_Sales  Other_Sales

/*
	Data class
	Manages loading and preprocessing of dataset
	Fixes missing records
*/
class Data {
	// number of games
	int count;
	// list of games
	ArrayList<Game> games;

	// list of unique platforms, genres and publishers
	// could use hashset
	ArrayList<String> platforms;
	ArrayList<String> genres;
	ArrayList<String> publishers;

	// statistics for individual fields
	Statistic yrStats;
	Statistic naStats;
	Statistic euStats;
	Statistic jpStats;
	Statistic otStats;
	Statistic slStats;

	Data() {
		count = 0;
		games = new ArrayList<Game>();

		platforms = new ArrayList<String>();
		genres = new ArrayList<String>();
		publishers = new ArrayList<String>();

		yrStats = new Statistic();
		naStats = new Statistic();
		euStats = new Statistic();
		jpStats = new Statistic();
		otStats = new Statistic();
		slStats = new Statistic();

	}

	void settings(String fileName) {
		// load csv file into a table
		Table table = loadTable(fileName, "header");

		// correct the years for games missing a year
		table.setString(179, "Year", "2003");
		table.setString(377, "Year", "2003");
		table.setString(431, "Year", "2008");
		table.setString(470, "Year", "2005");

		// sort table by year
		table.sort("Year");

		// create new game object for each row and add it to list of games
		for (TableRow row : table.rows()) {
			Game game = new Game(row);

			games.add(game);

			updateCategories(game);
			updateStats(game);
		}

		count = games.size();
		updateAvgs(count);

		// stats for sales across all continents, so calculate manually
		slStats.min = min(new float[] {naStats.min, euStats.min, jpStats.min, otStats.min});
		slStats.max = max(new float[] {naStats.max, euStats.max, jpStats.max, otStats.max});
		slStats.sum = naStats.sum + euStats.sum + jpStats.sum + otStats.sum;
		slStats.updateAvg(count);

		display();
	}

	// update categorical data
	void updateCategories(Game game) {
		// add game platform if it is unique
		if (!platforms.contains(game.platform)) {
			platforms.add(game.platform);
		}
		// add game genre if it is unique
		if (!genres.contains(game.genre)) {
			genres.add(game.genre);
		}
		// add game publisher if it is unique
		if (!publishers.contains(game.publisher)) {
			publishers.add(game.publisher);
		}
	}

	void updateStats(Game game) {
		yrStats.update(game.year);
		naStats.update(game.naSales);
		euStats.update(game.euSales);
		jpStats.update(game.jpSales);
		otStats.update(game.otSales);
	}

	void updateAvgs(float n) {
		yrStats.updateAvg(n);
		naStats.updateAvg(n);
		euStats.updateAvg(n);
		jpStats.updateAvg(n);
		otStats.updateAvg(n);
	}

	// display the statistics data
	void display() {
		println("xy		min		max		sum		avg");
		println(String.format(
			"yr		%.2f		%.2f		%.2f	%.2f",
			yrStats.min, yrStats.max, yrStats.sum, yrStats.avg)
		);
		println(String.format(
			"na		%.2f		%.2f		%.2f		%.2f",
			naStats.min, naStats.max, naStats.sum, naStats.avg)
		);
		println(String.format(
			"eu		%.2f		%.2f		%.2f		%.2f",
			euStats.min, euStats.max, euStats.sum, euStats.avg)
		);
		println(String.format(
			"jp		%.2f		%.2f		%.2f		%.2f",
			jpStats.min, jpStats.max, jpStats.sum, jpStats.avg)
		);
		println(String.format(
			"ot		%.2f		%.2f		%.2f		%.2f",
			otStats.min, otStats.max, otStats.sum, otStats.avg)
		);
		println(String.format(
			"sl		%.2f		%.2f		%.2f		%.2f",
			slStats.min, slStats.max, slStats.sum, slStats.avg)
		);
	}
}
