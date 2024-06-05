// Initializes the Highchart with default settings
function initializeColumnChart() {
  Highcharts.chart('chart-container', {
    chart: {
      type: 'pie'
    },
    title: {
      text: 'Daily Energy Consumption'
    },
    xAxis: {
      categories: []
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
      headerFormat: '<b>{point.key}</b><br/>',
      pointFormat: '<b>{series.name}: {point.y:.2f} kWh</b>'
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
    series: []
  });
}

// Updates the chart with new data
function updateColumnChartData(chartData) {
  var parsedData = JSON.parse(chartData);
  var chart = Highcharts.charts[0];
  chart.xAxis[0].setCategories(parsedData.xAxis.categories);
  parsedData.series.forEach(function(series, index) {
    if (chart.series[index]) {
      chart.series[index].update(series);
    } else {
      chart.addSeries(series);
    }
  });
}
