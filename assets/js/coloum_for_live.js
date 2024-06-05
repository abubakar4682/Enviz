function jsColumnChartFuncForLive(chartData) {
    try {
        const parsedData = JSON.parse(chartData);
        Highcharts.chart('highChartsDiv', parsedData);
    } catch (error) {
        console.error('Error parsing column chart data:', error);
    }
}
