from sklearn import linear_model
import csv

def main():
	with open("round-2014-small.txt", "rb") as f:
		reader = csv.reader(f, delimiter=";");

		next(reader, None);
		model = linear_model.LinearRegression();
		xFeatures = [];
		yValues = [];
		for line in reader:
			yValues.append(float(line[15]));
			xFeatures.append([float(line[122]), float(line[79])]);

		model.fit(xFeatures, yValues);
		print "Intercept: ", model.intercept_
		print "Coefficients: ", model.coef_

if __name__ == "__main__":
	main();