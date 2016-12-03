(function() {
    // Constants
    var margin = { top: 30, left: 50, right: 30, bottom: 50},
    height = 420 - margin.top - margin.bottom,
    width = 780 - margin.left - margin.right,
    radius = 7;

    // Setup svg and translated g element
    var svg = d3.select("#chart")
        .append("svg")
        .attr("height", height + margin.top + margin.bottom)
        .attr("width", width + margin.left + margin.right)
        .append("g")
        .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

    // Accessor functions for scales
    var xValue = function(d) { return d.X };
    var yValue = function(d) { return d.Y };

    // Position Scales
    var xPositionScale = d3.scaleLinear().range([0, width]);
    var yPositionScale = d3.scaleLinear().range([height, 0]);

    var personToString = function(d) {
        return "Name: " + d.Person +"<br><br>X: " + d.X + "<br>Y: " + d.Y + "<br>Z: " + d.Z; 
    }

    // Load people dataset
    d3.queue()
        .defer(d3.csv, "part1/people.csv", function(d) {
            d.X = +d.X;
            d.Y = +d.Y;
            d.Z = +d.Z;
            return d;
        })
        .await(ready);

    // Draws scatterplot, called when data is loaded
    function ready(error, people) {

        // Sets domain for x and y to be 0 to max value
        xPositionScale.domain([0, d3.max(people, xValue)]);
        yPositionScale.domain([0, d3.max(people, yValue)]);

        // Axis Functions
        var xAxis = d3.axisBottom().scale(xPositionScale);
        var yAxis = d3.axisLeft().scale(yPositionScale);

        // Append axes to g element
        svg.append("g")
            .attr("class", "axis")
            .attr("transform", "translate(0," + height + ")")
            .call(xAxis);

        svg.append("g")
            .attr("class", "axis")
            .call(yAxis);

        svg.append("text")
            .attr("x", width / 2)
            .attr("y", height + margin.bottom)
            .text("X Value");

        svg.append("text")
            .attr("x", -height / 2)
            .attr("y", -margin.left + 15)
            .attr("transform", "rotate(-90)")
            .text("Y Value");

        // Creates tooltip div
        var tooltip = d3.select("body")
            .append("div")
            .attr("id", "tooltip")
            .style("display", "none");

        // Plot datapoints
        svg.selectAll(".person")
            .data(people)
            .enter().append("circle")
            .attr("class", "person")
            .attr("r", radius)
            .attr("cx", function(d) { return xPositionScale(xValue(d)); })
            .attr("cy", function(d) { return yPositionScale(yValue(d)); })
            .on("mouseover", function(d) {
                tooltip
                    .style("display", "inline")
                    .html(personToString(d));
            })
            .on("mousemove", function() {
                tooltip
                    .style("left", (d3.event.pageX + 10) + "px")     
                    .style("top", (d3.event.pageY) + "px")
            })
            .on("mouseout", function() {
                tooltip.style("display", "none")
            })
        }

})();