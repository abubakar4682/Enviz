function jsLineChartFunc(chartData) {
  try {
    console.log('jsLineChartFunc called with data:', chartData);

    Highcharts.chart('highChartsDiv', {
      title: { text: '' },
      yAxis: { title: { text: 'Power' } },
      tooltip: {
        pointFormatter: function() {
          var value = this.y / 1000;
          value = Highcharts.numberFormat(value, 1) + ' kWh';
          return 'Power: ' + value;
        }
      },
      xAxis: {
        categories: ['12 AM', '1 AM', '2 AM', '3 AM', '4 AM', '5 AM', '6 AM', '7 AM', '8 AM', '9 AM', '10 AM', '11 AM', '12 PM', '1 PM', '2 PM', '3 PM', '4 PM', '5 PM', '6 PM', '7 PM', '8 PM', '9 PM', '10 PM', '11 PM'],
      },
      series: [{
        name: 'Your Daily Usage',
        data: chartData
      }]
    });
  } catch (error) {
    console.error('Error in jsLineChartFunc:', error);
  }
}

// Add event listener to ensure the content is fully loaded before running the script
document.addEventListener('DOMContentLoaded', (event) => {
  if (window.flutter_inappwebview) {
    window.flutter_inappwebview.callHandler('pageLoaded');
  }
});
