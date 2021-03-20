/*
	Statistic class
	Keeps track of ranges and averages of data
*/
class Statistic {
	float min;
	float max;
	float sum;
	float avg;
	
	Statistic() {
		min = Float.MAX_VALUE;
		max = Float.MIN_VALUE;
		sum = 0;
		avg = 0;
	}

	void update(float value) {
		min = min(min, value);
		max = max(max, value);
		sum += value;
	}

	void updateAvg(float n) {
		avg = sum/n;
	}
}

