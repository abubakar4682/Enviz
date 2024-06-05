function jsColumnChartFunc(chartData) {
    try {
        console.log('Received data for column chart:', chartData);
        const parsedData = JSON.parse(chartData);
        console.log('Parsed column chart data:', parsedData);

        Highcharts.chart('highChartsDiv', {
            chart: {
                type: 'column'
            },
            title: {
                text: 'Daily Breakdown',
                align: 'center'
            },
            xAxis: {
                categories: parsedData.categories
            },
            yAxis: {
                min: 0,
                title: {
                    text: 'Energy (kWh)'
                },
                stackLabels: {
                    enabled: false
                }
            },
            tooltip: {
                headerFormat: '<span style="font-size:10px">{point.key}</span><br/>',
                pointFormat: '<b>{series.name}: {point.y:.2f} kWh</b><br/>'
            },
            plotOptions: {
                column: {
                    stacking: 'normal',
                    dataLabels: {
                        enabled: false
                    },
                    pointWidth: 25,
                    borderRadius: 5
                }
            },
            series: parsedData.series
        });
    } catch (error) {
        console.error('Error parsing column chart data:', error);
    }
}
