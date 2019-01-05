$('#datepicker').datepicker({
    uiLibrary: 'bootstrap4'
});

function storeDateAndAddTeamName() {
    storeDate()
    addTeamName()
}

function storeDate() {
    var date = document.getElementById("datepicker").value;
    document.cookie = "date=" + date + ";path=/";
}

function getCookie(cname) {
    var name = cname + "=";
    var decodedCookie = decodeURIComponent(document.cookie);
    var ca = decodedCookie.split(';');
    for(var i = 0; i <ca.length; i++) {
        var c = ca[i];
        while (c.charAt(0) == ' ') {
            c = c.substring(1);
        }
        if (c.indexOf(name) == 0) {
            return c.substring(name.length, c.length);
        }
    }
    return "";
}

function httpGetAsync(theUrl, callback)
{
    var xmlHttp = new XMLHttpRequest();
    xmlHttp.onreadystatechange = function() { 
        if (xmlHttp.readyState == 4 && xmlHttp.status == 200)
            callback(xmlHttp.responseText);
    }
    xmlHttp.open("GET", theUrl, true); // true for asynchronous 
    xmlHttp.send(null);
}

function parseHTMLAndAddTeamName(responseText) {
    var teamName = []

    parsedText = JSON.parse(responseText)
    for (i = 0; i < parsedText.totalGames; i++) {
        awayTeamName = parsedText.dates[0].games[i].teams.away.team.name
        homeTeamName = parsedText.dates[0].games[i].teams.home.team.name
        teamName.push(awayTeamName)
        teamName.push(homeTeamName)
    }

    var myNode = document.getElementById("team-name-input");
    while (myNode.firstChild) {
        myNode.removeChild(myNode.firstChild);
    }

    var option = document.createElement("option");
    option.selected = true;
    option.innerHTML = "Choose...";
    document.getElementById("team-name-input").appendChild(option);
    var len = teamName.length;
    for (i = 0; i < len; i++) {
        var option = document.createElement("option");
        option.value = i;
        option.innerHTML = teamName[i];
        document.getElementById("team-name-input").appendChild(option);
    }
    console.log(teamName);

    return teamName
}

async function getTeamName() {
    var date = getCookie("date")
    var getUrl = 'https://statsapi.mlb.com/api/v1/schedule?sportId=1&date=' + date
    httpGetAsync(getUrl, parseHTMLAndAddTeamName)
}

var lastGameDate = null
function addTeamName() {
    if (lastGameDate != getCookie("date")) {
        lastGameDate = getCookie("date")
        getTeamName()
    }
}

function storeSelectTeamName() {
    var e = document.getElementById("team-name-input");
    var selectedTeamName = e.options[e.selectedIndex].text;

    document.cookie = "teamName=" + selectedTeamName + ";path=/";
}

// // lively get latest play information (description)
// var receive_index = 0;

// function changeReceiveLiveInfo() {
//     var e = document.getElementById("change_button");
//     e.classList.toggle("btn-danger");
//     e.classList.toggle("btn-success");   
// }

// // default: 30000 (30 sec)
// var myVar = setInterval(myTimer, 10000);

// function myTimer() {
//     var e = document.getElementById("change_button");
//     if (e.classList.contains("btn-success")) {
//         getLiveInfo();
//         receive_index += 1;
//     }
// }

// async function getLiveInfo() {
//     var game_pk = document.getElementById("game_pk").textContent
//     var getUrl = 'https://statsapi.mlb.com/api/v1.1/game/' + game_pk + '/feed/live'
    
//     httpGetAsync(getUrl, parseLiveData)
// }

// function parseLiveData(responseText) {
//     parsedText = JSON.parse(responseText)

//     // for demo
//     pick_index = receive_index;
//     if (pick_index > parsedText.liveData.plays.allPlays.length - 1) {
//         pick_index = parsedText.liveData.plays.allPlays.length - 1;
//     }

//     play_description = parsedText.liveData.plays.allPlays[pick_index].result.description
//     document.getElementById("live_info").textContent = play_description;
//     return play_description
// }