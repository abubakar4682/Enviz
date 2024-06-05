function updateColumnChart(data) {
    Highcharts.chart('container', JSON.parse(data));
}

function updatePieChart(data) {
    Highcharts.chart('piecontainer', JSON.parse(data));
}
