




    function jsPieChartFuncForLive(chartSeriesData) {
          Highcharts.chart('highChartsDiv', {
            chart: {
              type: 'pie'
            },
            title: {
                     text: 'Appliance Energy Distribution',
                     align: 'center', // Align title to the center
                     style: {
                       fontSize: '16px' // Adjust font size if needed
                     }
                   },
            tooltip: {
              formatter: function() {
                return '<b>' + this.point.name + '</b><br/>' +
                       'Energy Share: ' + this.point.y.toFixed(1) + '%<br/>' +
                       'Power: ' + this.point.formattedValue;
              }
            },
            plotOptions: {
              pie: {
                allowPointSelect: true,
                cursor: 'pointer',
                dataLabels: {
                  enabled: true,
                  format: '<b>{point.name}</b>: {point.y:.1f}%'
                }
              }
            },
            series: chartSeriesData,
          });
        }