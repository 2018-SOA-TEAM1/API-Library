// lively get latest play information (description)
var receive_index = 0;

function changeReceiveLiveInfo() {
    var change_button = document.getElementById("change_button");
    var live_info = document.getElementById("live_info")
    change_button.classList.toggle("btn-danger");
    change_button.classList.toggle("btn-success");   

    if (change_button.classList.contains("btn-success")) {
        change_button.textContent = "Notify On"
    } else {
        change_button.textContent = "Notify Off"
    }
}

// default: 5000 (5 sec)
var myVar = setInterval(myTimer, 5000);

function myTimer() {
    var e = document.getElementById("change_button");
    if (e.classList.contains("btn-success")) {
        getLiveInfo();
        receive_index += 1;
    }
}

async function getLiveInfo() {
    var game_pk = document.getElementById("game_pk").textContent
    var getUrl = 'https://statsapi.mlb.com/api/v1.1/game/' + game_pk + '/feed/live'
    
    httpGetAsync(getUrl, parseLiveData)
}

function parseLiveData(responseText) {
    parsedText = JSON.parse(responseText)

    // for demo
    pick_index = receive_index;
    if (pick_index > parsedText.liveData.plays.allPlays.length - 1) {
        pick_index = parsedText.liveData.plays.allPlays.length - 1;
    }

    play_description = parsedText.liveData.plays.allPlays[pick_index].result.description

    $("#live_info").animate({'opacity': 0}, 400, function(){
        document.getElementById("live_info").textContent = play_description;
        $(this).html(play_description).animate({'opacity': 1}, 400);    
    });
    
    return play_description
}