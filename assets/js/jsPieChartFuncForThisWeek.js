function jsPieChartFunc(chartData) {
            try {
                console.log('Received data for pie chart:', chartData);
                const parsedData = JSON.parse(chartData);
                console.log('Parsed pie chart data:', parsedData);

                Highcharts.chart('highChartsDiv', {
                    chart: {
                        type: 'pie'
                    },
                    title: {
                        text: 'Appliance Share',
                        align: 'center'
                    },
                    tooltip: {
                        pointFormat: '<b>{point.y:.1f} kWh</b>'
                    },
                    plotOptions: {
                        pie: {
                            allowPointSelect: true,
                            cursor: 'pointer',
                            dataLabels: {
                                enabled: true,
                                format: '{point.percentage:.1f}%',
                                style: {
                                    color: 'black'
                                }
                            },
                            showInLegend: true
                        }
                    },
                    series: [{
                        name: 'Energy',
                        colorByPoint: true,
                        data: parsedData
                    }]
                });
            } catch (error) {
                console.error('Error parsing pie chart data:', error);
            }
        }