var chartData = [4, 8, 15, 16, 23, 42, 35, 22, 18, 17];
var pieData = [];

var prevYear = 0;
var pieColors = [
                 "#000924", "#000C2F", "#010F3A", "#021245", "#03195D",
                 "#031C68", "#032074", "#052380", "#06288C", "#082D97",
                 "#0932A3", "#0D39B8", "#1240C3", "#1745CE", "#1B4BD8",
                 "#2254E3", "#275AEA", "#2F62F2", "#3869F9", "#4472FB",
                 "#507CFB", "#5A84FA", "#678DFB", "#7597FB", "#81A0FA",
                 "#90ABFB", "#9EB5FC", "#B2C6FF", "#C2D1FC", "#D4DEFD"
                ];
var europePie;
var africaPie;
var asiaPie;
var nAmericaPie;
var sAmericaPie;
var oceaniaPie;

var loadedEurope = false;
var loadedAfrica = false;
var loadedAsia = false;
var loadedNAmerica = false;
var loadedSAmerica = false;
var loadedOceania = false;



/* Fills for Flat Map */
// var DEFAULTFILL = "#969696";//"#F7FCFD"; // 0 participants
// var FILL1 = "#E0ECF4"; // 1 - 100 participants
// var FILL2 = "#BFD3E6"; // 101 - 200 participants
// var FILL3 = "#9EBCDA"; // 201 - 300 participants
// var FILL4 = "#8C96C6"; // 301 - 400 participants
// var FILL5 = "#8C6BB1"; // 401 - 500 participants
// var FILL6 = "#88419D"; // 501 - 600 participants
// var FILL7 = "#6E016B"; // 601 - 700 participants

var DEFAULTFILL = "#969696";  // 0 participants
var FILL1 = "#40004B"; // 1 - 100 participants
var FILL2 = "#762A83"; // 101 - 200 participants
var FILL3 = "#9970AB"; // 201 - 300 participants
var FILL4 = "#F7F7F7"; // 301 - 400 participants
var FILL5 = "#5AAE61"; // 401 - 500 participants
var FILL6 = "#1B7837"; // 501 - 600 participants
var FILL7 = "#00441B"; // 601 - 700 participants


function initChart() {
    displayView = 1;
	initPieChart();
    // initFlatMap(); // do this inside settime if ("#flatMap svg") hasn't been created yet
	$.getJSON( "data/topten.json")
      .done(function( json ) {
      	countryData = json;
        renderTopTenChart(1896);
      })
      .fail(function( jqxhr, textStatus, error ) {
          var err = textStatus + ", " + error;
          console.log( "Request Failed: " + err );
      });

    $.getJSON( "data/participatingcountries.json")
      .done(function( json ) {
        participatingCountryData = json;
        renderFlatMap(1896);
      })
      .fail(function( jqxhr, textStatus, error ) {
          var err = textStatus + ", " + error;
          console.log( "Request Failed: " + err );
      });
}

/* * * * * * * * * * * * * START OF PODIUM FLAG CODE * * * * * * * * * * * * */
/* Renders the flags that appear on the podiums 
 * NOTE: It is assumed loadTopTenData(year) has already been called for the appropriate year.
 * This is called at end of renderTopTenChart since it already loadsTopTenData(year)
 */
function renderPodiumFlags() {
    var topThree = topTen.slice(0,3);
    var flags = $("#podium image");
    for(i=0; i<topThree.length; i++){
        // replace spaces with -'s so we can get approprate gif for (United States & United Kingdom etc.)
        topThree[i].Country = topThree[i].Country.replace(" ", "-").toLowerCase();
    }
    if(flags.length > 2){
        flags[0].setAttribute("xlink:href","images/"+topTen[1].Country+".gif");  // set silver flag
        flags[1].setAttribute("xlink:href","images/"+topTen[0].Country+".gif");  // set gold flag
        flags[2].setAttribute("xlink:href","images/"+topTen[2].Country+".gif");  // set bronze flag
        flags[2].setAttribute("xlink:title",topTen[2].Country);  // set bronze flag
    }
}

/* * * * * * * * * * * * * END OF PODIUM FLAG CODE * * * * * * * * * * * * */

/* * * * * * * * * * * START OF TOP TEN BARCHART CODE * * * * * * * * * * */

/* Renders the Top 10 Country Bar Chart */
function renderTopTenChart(year) {
	// only render the topTenChart once we have the data
	loadTopTenData(year);
	if(topTen){
		// topTen should already be sorted by the time it gets here
        var chartWidth = innerWidth * .3;
		var xScale = d3.scale.linear()
			.domain([0, d3.max(topTen, function(d){
					return +d.TOT;})
			]).range([0, chartWidth]);

		var bars = d3.select("#chart").selectAll("div").data(topTen);
		bars.enter().append("div");
		bars.style("width", function(d){
				return xScale(d.TOT) + "px";
				// return d * 10 + "px";
			}).text(function(d){
				return d.TOT;
			});
		bars.attr("title", function(d){return d.Country});
		bars.exit().remove();

        // update the podium flags since we have a new top 3
        renderPodiumFlags();
	}
}

function loadTopTenData(year) {
	if(countryData){
		topTen = countryData[year].slice(0,10);
    	sortResults(topTen, 'TOT', false);
	}
	
}

// Sorts an array on a particular property
// Ex) sortResults(topTen[1896], 'TOT', true); OR sortResults(topTen[1896], 'G', false);
// result (topTen will bee sorted in ascending order based on 'TOT')
function sortResults(arr, prop, asc) {
    arr = arr.sort(function(a, b) {
        if (asc) return (a[prop] > b[prop]);
        else return (b[prop] > a[prop]);
    });
}

/* * * * * * * * * * * * END OF TOP TEN BARCHART CODE * * * * * * * * * * * */


/* * * * * * * * * * * * START OF FLAT MAP CODE * * * * * * * * * * * */

function resetFlatMap(year) {
    if (year) {
        for (i = 0; i < partCountries.length; i++) {
            var countryCode = partCountries[i].Country_Code;
            if ($("."+countryCode).length == 0) {
                // do nothing
            } else {
                var participants = partCountries[i].Participants;
                var temp = $("."+countryCode)[0];
                temp.style.fill = DEFAULTFILL;
            }
        }
    }
}

function renderFlatMap(year) {

    if(!participatingCountryData)
        return;
    resetFlatMap(prevYear);
    partCountries = participatingCountryData[year];

    for (i = 0; i < partCountries.length; i++) {
        var countryCode = partCountries[i].Country_Code;
        if ($("."+countryCode).length == 0) {
            // do nothing
        } else {
            var participants = partCountries[i].Participants;
            var temp = $("."+countryCode)[0];
            if (participants >= 1 && participants <= 100)
                temp.style.fill = FILL1;
            else if (participants >= 101 && participants <= 200)
                temp.style.fill = FILL2;
            else if (participants >= 201 && participants <= 300)
                temp.style.fill = FILL3;
            else if (participants >= 301 && participants <= 400)
                temp.style.fill = FILL4;
            else if (participants >= 401 && participants <= 500)
                temp.style.fill = FILL5;
            else if (participants >= 501 && participants <= 600)
                temp.style.fill = FILL6;
            else if (participants >= 601 && participants <= 700)
                temp.style.fill = FILL7;
            else
                temp.style.fill = DEFAULTFILL;
        }
        
    }

    prevYear = year;

}


function initFlatMap() {
    var map = new Datamap({
        element: document.getElementById('flatMap'),
        fills: {
            /* Added here in order to get the legend */
            defaultFill:  '#969696',
            '0 Participants': "#969696",
            '1 - 100 Participants': "#40004B",
            '101 - 200 Participants': "#762A83",
            '201 - 300 Participants': "#9970AB",
            '301 - 400 Participants': "#F7F7F7",
            '401 - 500 Participants': "#5AAE61",
            '501 - 600 Participants': "#1B7837",
            '601 - 700 Participants': "#00441B"
        },
        geographyConfig: {
            // highlightFillColor: '#0000FF',
            // highlightBorderColor: '#0000FF',
            borderColor: 'lightgray'
        },
        data: {
        }

    });

    map.legend();
}

/* * * * * * * * * * * * END OF FLAT MAP CODE * * * * * * * * * * * */

/* * * * * * * * * * * * START OF PIE CHART CODE * * * * * * * * * * * */

/* Calculates total medals for a country in a particular year */ 
function getYearTotalMedals(countryYearData) {
    var total = 0;
    for(country in countryYearData) {
        total += countryYearData[country].Total;
    }   
    return total;
}

function renderContinentPieData(continentMedals, continentPie, continentName, year) {
    if(!continentMedals || !continentMedals[year]) { 
        return;
    }
    var medalData = continentMedals[year];

    // if continentPie is undefined we need to initialize it
    if(!continentPie){
        return false;
    } else{
        pieData = [];
        for (country in medalData) {
        var colorKey = country;
        if (country > pieColors.length) {
            colorKey = country%pieColors.length;
        }
        pieData.push({
            "label": medalData[country].Country,
            "value": medalData[country].Total,
            "color": pieColors[colorKey]
        });
    }

    return pieData;
    }
    
}


function renderPieData(year){
    var medalData;

    if(displayView == 3){
        $(".continent").css("display", "block");
    }
    

    var africaPieData = renderContinentPieData(africaMedals, africaPie, "Africa", year);
    if(africaPieData){
        medalData = africaMedals[year];
        africaPie.updateProp("data.content", pieData);
        africaPie.updateProp("header.title.text", getYearTotalMedals(medalData));     
    } else {
        if (loadedAfrica) {
            // means that it's been previously loaded before
            $("#africaPieChart").css("display", "none");
        } else {
            africaPie = loadContinentPieData(africaMedals, africaPie, "Africa", year);
        }
    }
    var asiaPieData = renderContinentPieData(asiaMedals, asiaPie, "Asia", year);
    if(asiaPieData){

        medalData = asiaMedals[year];
        asiaPie.updateProp("data.content", pieData);
        asiaPie.updateProp("header.title.text", getYearTotalMedals(medalData));     
    } else {
        if (loadedAsia) {
            // means that it's been previously loaded before
            $("#asiaPieChart").css("display", "none");
        } else {
            asiaPie = loadContinentPieData(asiaMedals, asiaPie, "Asia", year);
        }
    }
    var europePieData = renderContinentPieData(europeMedals, europePie, "Europe", year);
    if(europePieData){
        medalData = europeMedals[year];
        europePie.updateProp("data.content", pieData);
        europePie.updateProp("header.title.text", getYearTotalMedals(medalData));     
    } else {
        if (loadedEurope) {
            // means that it's been previously loaded before
            $("#europePieChart").css("display", "none");
        }  else {
            europePie = loadContinentPieData(europeMedals, europePie, "Europe", year);   
        }
    }
    var oceaniaPieData = renderContinentPieData(oceaniaMedals, oceaniaPie, "Oceania", year);
    if(oceaniaPieData){
        medalData = oceaniaMedals[year];
        oceaniaPie.updateProp("data.content", pieData);
        oceaniaPie.updateProp("header.title.text", getYearTotalMedals(medalData));     
    } else {
        if (loadedOceania) {
            // means that it's been previously loaded before
            $("#oceaniaPieChart").css("display", "none");
        } else {
            oceaniaPie = loadContinentPieData(oceaniaMedals, oceaniaPie, "Oceania", year);
        }
    }
    var nAmericaPieData = renderContinentPieData(nAmericaMedals, nAmericaPie, "North America", year);
    if(nAmericaPieData){
        medalData = nAmericaMedals[year];
        nAmericaPie.updateProp("data.content", pieData);
        nAmericaPie.updateProp("header.title.text", getYearTotalMedals(medalData));     
    } else {
        if (loadedNAmerica) {
            // means that it's been previously loaded before
            $("#northamericaPieChart").css("display", "none");
        } else {
            nAmericaPie = loadContinentPieData(nAmericaMedals, nAmericaPie, "North America", year);
        }
    }
    var sAmericaPieData = renderContinentPieData(sAmericaMedals, sAmericaPie, "South America", year);
    if(sAmericaPieData){
        medalData = sAmericaMedals[year];
        sAmericaPie.updateProp("data.content", pieData);
        sAmericaPie.updateProp("header.title.text", getYearTotalMedals(medalData));      
    } else {
        if (loadedSAmerica) {
            // means that it's been previously loaded before
            $("#southamericaPieChart").css("display", "none");
        } else {
            sAmericaPie = loadContinentPieData(sAmericaMedals, sAmericaPie, "South America", year);
        }
    }
}

function loadContinentPieData(json, piechart, continentName, year) {
    if (!json || !json[year]) {
        return;
    }

    var medalData = json[year];

    pieData = [];

    for(key in medalData){
        var colorKey = key;
        if(key > pieColors.length){
            colorKey = key%pieColors.length;
        }
        pieData.push({
            "label": medalData[key].Country,
            "value": medalData[key].Total,
            "color": pieColors[colorKey]
        });
    }
    var divcontinentName = continentName.replace(" ", "").toLowerCase();

    var piechart1 = new d3pie(divcontinentName + "PieChart", {
        "header": {
            "title": {
                "color" : "#FFFFFF",
                "text": getYearTotalMedals(medalData),
                "fontSize": 30,
                "font": "courier"
            },
            "subtitle": {
                "text": continentName,
                "color": "#FFFFFF",
                "fontSize": 13,
                "font": "courier"
            },
            "location": "pie-center",
            "titleSubtitlePadding": 10
        },
        "footer": {
            "color": "#999999",
            "fontSize": 10,
            "font": "open sans",
            "location": "bottom-left"
        },
        "size": {
            "canvasHeight": 250,
            "canvasWidth": 250,
            "pieInnerRadius": "60%",
            "pieOuterRadius": "95%"
        },
        "data": {
            "sortOrder": "label-desc",
            "content": pieData 
        },
        "labels": {
            "outer": {
                "format": "none",
                "hideWhenLessThanPercentage": 1,
                "pieDistance": 32
            },
            "inner": {
                "format": "none"
            },
            "mainLabel": {
                "fontSize": 11,
                "color": "#FFFFFF"
            },
            "percentage": {
                "color": "#FFFFFF",
                "fontSize": 11,
                "decimalPlaces": 0
            },
            "value": {
                "color": "#cccc43",
                "fontSize": 11
            },
            "lines": {
                "enabled": true,
                "color": "#777777"
            },
            "truncation": {
                "enabled": true
            }
        },
        "tooltips": {
            "enabled": true,
            "type": "placeholder",
            "string": "{label}: {value}, {percentage}%"
        },
        "effects": {
            "pullOutSegmentOnClick": {
                "effect": "linear",
                "speed": 400,
                "size": 8
            }
        },
        "misc": {
            "colors": {
                "segmentStroke": "#FFFFFF"
            }
        }
    });
    
    switch (continentName) {
        case "Africa":
            loadedAfrica = true;
            break;
        case "Asia":
            loadedAsia = true;
            break;
        case "Europe":
            loadedEurope = true;
            break;
        case "Oceania":
            loadedOceania = true;
            break;
        case "North America":
            loadedNAmerica = true;
            break;
        case "South America":
            loadedSAmerica = true;
            break;
        default:
            console.log("Continent name " + continentName + " is not valid.");
    }
    return piechart1;
}

function loadPieData(year) {
    africaPie = loadContinentPieData(africaMedals, africaPie, "Africa", year);
    asiaPie = loadContinentPieData(asiaMedals, asiaPie, "Asia", year);
    europePie = loadContinentPieData(europeMedals, europePie, "Europe", year);
    oceaniaPie = loadContinentPieData(oceaniaMedals, oceaniaPie, "Oceania", year);
    nAmericaPie = loadContinentPieData(nAmericaMedals, nAmericaPie, "North America", year);
    sAmericaPie = loadContinentPieData(sAmericaMedals, sAmericaPie, "South America", year);
}

function initPieChart() {
    $.when(
        $.getJSON("data/EuropeMedals.json").done(function(json) {
            europeMedals = json;
        }),
        $.getJSON("data/AfricaMedals.json").done(function(json) {
            africaMedals = json;
        }),
        $.getJSON("data/AsiaMedals.json").done(function(json) {
            asiaMedals = json;
        }),
        $.getJSON("data/NorthAmericaMedals.json").done(function(json) {
            nAmericaMedals = json;
        }),
        $.getJSON("data/SouthAmericaMedals.json").done(function(json) {
            sAmericaMedals = json;
        }),
        $.getJSON("data/OceaniaMedals.json").done(function(json) {
            oceaniaMedals = json;
        })
    ).then(function() {
        if (!europeMedals) { console.log("europeMedals not loaded"); }
        if (!africaMedals) { console.log("africaMedals not loaded"); }
        if (!asiaMedals) { console.log("asiaMedals not loaded"); }
        if (!oceaniaMedals) { console.log("oceaniaMedals not loaded"); }
        if (!nAmericaMedals) { console.log("nAmericaMedals not loaded"); }
        if (!sAmericaMedals) { console.log("sAmericaMedals not loaded"); }

        loadPieData(1896);
        // $(".continent").css("display", "block");
    })
}
/* * * * * * * * * * * * START OF PIE CHART CODE * * * * * * * * * * * */


function show_view1() {
    displayView = 1;
    renderTopTenChart(currentYear);
    $("#container").show();
    $("#chart").show();
    $("#podium").show();
    $("#chartTitle").show();
    $("#flatMap").hide();
    // $("#flatMap svg").hide();
    // $("#flatMap .datamaps-legend").hide();
    $(".continent").hide();
}

function show_view2() {
    displayView = 2;
    $("#flatMap").show();
    var map = $("#flatMap svg");
    if(map && map.length == 0){
        initFlatMap();
    }
    renderFlatMap(currentYear);
    // map.show();
    // $("#flatMap .datamaps-legend").show();
    $("#container").hide();
    $("#chart").hide();
    $("#chartTitle").hide();
    $("#podium").hide();
    $(".continent").hide();
}

function show_view3() {
    displayView = 3;
    $(".continent").show();
    renderPieData(currentYear);
    $("#flatMap").hide();
    // $("#flatMap svg").hide();
    // $("#flatMap .datamaps-legend").hide();
    $("#container").hide();
    $("#chart").hide();
    $("#chartTitle").hide();
    $("#podium").hide();
}
