function jsPieChartFunc(chartSeriesData) {
    try {
        console.log('Received data for chart:', chartSeriesData);
        const parsedData = JSON.parse(chartSeriesData);
        console.log('Parsed data:', parsedData);
        Highcharts.chart('highChartsDiv', {
            chart: {
                type: 'pie'
            },
            title: {
                text: 'Energy Usage Distribution',
                align: 'left'
            },
            subtitle: {
                text: 'Click the slices to view details',
                align: 'left'
            },
            accessibility: {
                announceNewData: {
                    enabled: true
                },
                point: {
                    valueSuffix: '%'
                }
            },
            plotOptions: {
                series: {
                    borderRadius: 5,
                    dataLabels: [{
                        enabled: true,
                        distance: 15,
                        format: '{point.name}'
                    }, {
                        enabled: true,
                        distance: '-30%',
                        filter: {
                            property: 'percentage',
                            operator: '>',
                            value: 5
                        },
                        format: '{point.y:.1f}%',
                        style: {
                            fontSize: '0.9em',
                            textOutline: 'none'
                        }
                    }]
                }
            },
            tooltip: {
                headerFormat: '<span style="font-size:11px">{series.name}</span><br>',
                pointFormat: '<span style="color:{point.color}">{point.name}</span>: <b>{point.y:.2f}%</b> of total<br/>'
            },
            series: parsedData.series,
        });
    } catch (error) {
        console.error('Error parsing chart data:', error);
    }
}
