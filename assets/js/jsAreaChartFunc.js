function jsAreaChartFunc(seriesData) {
    const container = document.getElementById('highChartsDiv');
    if (container) {
        container.innerHTML = ''; // Clear the existing chart
    }
    Highcharts.chart('highChartsDiv', {
        chart: {
            type: 'area'
        },
        title: {
            text: 'Weekly Data Display'
        },
        xAxis: {
            type: 'datetime',
            dateTimeLabelFormats: {
                day: '%e %b',
            },
        },
        yAxis: {
            title: {
                text: 'Energy (kW)',
            },
        },
        legend: {
            enabled: true,
        },
        tooltip: {
            pointFormat: '<span style="color:{point.color}">\u25CF</span> {series.name}: <b>{point.y:.2f} kW</b><br/>'
        },
        series: seriesData,
    });
}
