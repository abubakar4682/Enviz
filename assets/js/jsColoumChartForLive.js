 function jsColumnChartFuncForLive(chartSeriesData) {
      Highcharts.chart('highChartsDiv', {
        chart: {
          type: 'column'
        },
        title: {
          text: '',
          align: 'left'
        },
        xAxis: {
          type: 'category'
        },
        yAxis: {
          title: {
            text: 'Power (kW)'
          },
          labels: {
            enabled: false
          },
          min: 0,
          startOnTick: false,
          endOnTick: false,
          gridLineWidth: 0,
          minorGridLineWidth: 0,
          lineColor: 'transparent',
          minorTickLength: 0,
          tickLength: 0
        },
        tooltip: {
          formatter: function() {
            return '<b>' + this.point.name + '</b><br/>' +
                   'Power: ' + this.point.formattedValue;
          }
        },
        plotOptions: {
          column: {
            colorByPoint: true,
            pointPadding: 0.1,
            groupPadding: 0.1,
            borderWidth: 0,
            minPointLength: 3
          }
        },
        series: [{
          name: 'kW',
          data: chartSeriesData
        }]
      });
    }