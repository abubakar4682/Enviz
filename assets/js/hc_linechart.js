function jsHeatmapFunc(chartData, startDate, endDate) {
  try {
    console.log('jsHeatmapFunc called with data:', chartData);
    console.log('Start Date:', startDate, 'End Date:', endDate);

    // Function to generate array of dates between two dates
    function getDatesBetween(startDate, endDate) {
      const start = new Date(startDate);
      const end = new Date(endDate);
      const dates = [];

      while (start <= end) {
        dates.push(new Date(start).toISOString().split('T')[0]);
        start.setDate(start.getDate() + 1);
      }

      // Format dates for display, e.g., 'Mon 01', 'Tue 02', ...
      return dates.map(date => {
        const d = new Date(date);
        return d.toLocaleDateString('en-US', { weekday: 'short', day: '2-digit' });
      });
    }

    const dateCategories = getDatesBetween(startDate, endDate);

    Highcharts.chart('highChartsDiv', {
      chart: {
        type: 'heatmap',
        marginTop: 100,
        marginBottom: 100,
        plotBorderWidth: 10
      },
      title: {
        text: 'Energy Consumption Pattern'
      },
      xAxis: {
        categories: dateCategories,
      },
      yAxis: {
        categories: ['12 AM', '1 AM', '2 AM', '3 AM', '4 AM', '5 AM', '6 AM', '7 AM', '8 AM', '9 AM', '10 AM', '11 AM', '12 PM', '1 PM', '2 PM', '3 PM', '4 PM', '5 PM', '6 PM', '7 PM', '8 PM', '9 PM', '10 PM', '11 PM'],
        title: null,
        reversed: true
      },
      colorAxis: {
        min: 0,
        minColor: '#FFFFFF', // white color for the minimum value
        maxColor: '#960C0C', // the darkest shade of #960C0C
        stops: [
          [0, '#FFFFFF'],       // white at 0%
          [0.1, '#F9C1C1'],     // slightly darker shade at 10%
          [0.2, '#F49A9A'],     // and so on...
          [0.3, '#EF7474'],
          [0.4, '#EA4E4E'],
          [0.5, '#E52828'],     // a medium shade around the 50% mark
          [0.6, '#CC2323'],
          [0.7, '#B31E1E'],
          [0.8, '#991919'],
          [0.9, '#801414'],     // a darker shade before the darkest at 90%
          [1, '#960C0C']        // the darkest shade at 100%
        ]
      },

      tooltip: {
        formatter: function () {
          var energyValue = (this.point.value / 1000).toFixed(2);
          return '<b>' + this.series.xAxis.categories[this.point.x] + '</b><br><b>' +
            this.series.yAxis.categories[this.point.y] + '</b><br><b>' +
            'Energy: ' + energyValue + ' kWh</b>';
        }
      },
      legend: {
        align: 'right',
        layout: 'vertical',
        margin: 0,
        verticalAlign: 'top',
        y: 25,
        symbolHeight: 280
      },
      series: [{
        name: 'Hourly Energy Consumption',
        borderWidth: 1,
        data: chartData,
        dataLabels: {
          enabled: false
        }
      }]
    });
  } catch (error) {
    console.error('Error in jsHeatmapFunc:', error);
  }
}

// Add event listener to ensure the content is fully loaded before running the script
document.addEventListener('DOMContentLoaded', (event) => {
  if (window.flutter_inappwebview) {
    window.flutter_inappwebview.callHandler('pageLoaded');
  }
});






//function jsHeatmapFunc(chartData) {
//  Highcharts.chart('highChartsDiv', {
//    chart: {
//      type: 'heatmap',
//      marginTop: 100,
//      marginBottom: 100,
//      plotBorderWidth: 10
//    },
//    title: {
//      text: 'Weekly Pattern'
//    },
//    xAxis: {
//      categories: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'],
//    },
//    yAxis: {
//      categories: ['12 AM', '1 AM', '2 AM', '3 AM', '4 AM', '5 AM', '6 AM', '7 AM', '8 AM', '9 AM', '10 AM', '11 AM', '12 PM', '1 PM', '2 PM', '3 PM', '4 PM', '5 PM', '6 PM', '7 PM', '8 PM', '9 PM', '10 PM', '11 PM'],
//      title: null,
//      reversed: true
//    },
//    colorAxis: {
//      min: 0,
//      minColor: '#8B4513',
//      maxColor: '#F4A460',
//      stops: [
//        [0, '#8B4513'],  // Dark brown color
//        [0.5, '#CD853F'], // Medium brown color
//        [1, '#F4A460']    // Light brown color
//      ]
//    },
//tooltip: {
//  formatter: function () {
//    // Convert the value to kilowatts and fix to 2 decimal places
//    var energyValue = (this.point.value / 1000).toFixed(2);
//    return '<b>' + this.series.xAxis.categories[this.point.x] + '</b><br><b>' +
//      this.series.yAxis.categories[this.point.y] + '</b><br><b>' +
//      'Energy: ' + energyValue + ' kWh</b>';
//  }
//},
//
//
//    legend: {
//      align: 'right',
//      layout: 'vertical',
//      margin: 0,
//      verticalAlign: 'top',
//      y: 25,
//      symbolHeight: 280
//    },
//    series: [{
//      name: 'Hourly Heatmap',
//      borderWidth: 1,
//      data: chartData,
//      dataLabels: {
//        enabled: false
//      }
//    }]
//  });
//}



//
//function jsLineChartFunc(chartSeriesData) {
//    Highcharts.chart('highChartsDiv', {
//
//        title: {
//            text: 'U.S Solar Employment Growth',
//            align: 'left'
//        },
//
//        subtitle: {
//            text: 'By Job Category. Source: <a href="https://irecusa.org/programs/solar-jobs-census/" target="_blank">IREC</a>.',
//            align: 'left'
//        },
//
//        yAxis: {
//            title: {
//                text: 'Number of Employees'
//            }
//        },
//
//        xAxis: {
//            accessibility: {
//                rangeDescription: 'Range: 2010 to 2020'
//            }
//        },
//
//        legend: {
//            layout: 'vertical',
//            align: 'right',
//            verticalAlign: 'middle'
//        },
//
//        plotOptions: {
//            series: {
//                label: {
//                    connectorAllowed: false
//                },
//                pointStart: 2010
//            }
//        },
//
//        series: chartSeriesData,
//
//        responsive: {
//            rules: [{
//                condition: {
//                    maxWidth: 500
//                },
//                chartOptions: {
//                    legend: {
//                        layout: 'horizontal',
//                        align: 'center',
//                        verticalAlign: 'bottom'
//                    }
//                }
//            }]
//        }
//
//    });
//}

//function jsHeatmapFunc(chartData, categories) {
//    Highcharts.chart('highChartsDiv', {
//        chart: {
//            type: 'heatmap',
//            marginTop: 40,
//            marginBottom: 80,
//            plotBorderWidth: 1
//        },
//        title: {
//            text: 'Daily Heatmap Example'
//        },
//        xAxis: {
//            categories: categories, // Use the passed categories here
//        },
//        yAxis: {
//            categories: ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13', '14', '15', '16', '17', '18', '19', '20', '21', '22', '23'],
//            title: null,
//            reversed: true
//        },
//        colorAxis: {
//            min: 0,
//            minColor: '#FFFFFF',
//            maxColor: Highcharts.getOptions().colors[0]
//        },
//        legend: {
//            align: 'right',
//            layout: 'vertical',
//            margin: 0,
//            verticalAlign: 'top',
//            y: 25,
//            symbolHeight: 280
//        },
//        series: [{
//            name: 'Hourly Heatmap',
//            borderWidth: 1,
//            data: chartData,
//            dataLabels: {
//                enabled: false,
//                color: '#000000'
//            }
//        }],
//        tooltip: {
//            enabled: false,
//            formatter: function () {
//                return '<b>Date: ' + this.series.xAxis.categories[this.point.x] + '</b><br/>' +
//
//                       '<b>Value: ' + this.point.value + ' kW</b>';
//            }
//        },
//    });
//}
//
//
//
////
//function jsLineChartFunc(chartSeriesData) {
//    Highcharts.chart('highChartsDiv', {
//
//        title: {
//            text: 'U.S Solar Employment Growth',
//            align: 'left'
//        },
//
//        subtitle: {
//            text: 'By Job Category. Source: <a href="https://irecusa.org/programs/solar-jobs-census/" target="_blank">IREC</a>.',
//            align: 'left'
//        },
//
//        yAxis: {
//            title: {
//                text: 'Number of Employees'
//            }
//        },
//
//        xAxis: {
//            accessibility: {
//                rangeDescription: 'Range: 2010 to 2020'
//            }
//        },
//
//        legend: {
//            layout: 'vertical',
//            align: 'right',
//            verticalAlign: 'middle'
//        },
//
//        plotOptions: {
//            series: {
//                label: {
//                    connectorAllowed: false
//                },
//                pointStart: 2010
//            }
//        },
//
//        series: chartSeriesData,
//
//        responsive: {
//            rules: [{
//                condition: {
//                    maxWidth: 500
//                },
//                chartOptions: {
//                    legend: {
//                        layout: 'horizontal',
//                        align: 'center',
//                        verticalAlign: 'bottom'
//                    }
//                }
//            }]
//        }
//
//    });
//}
////function fetchAndPlotHeatmap() {
////    // Assume URL is constructed dynamically with date parameters in your Flutter app
////    const apiUrl = 'http://203.135.63.22:8000/data?username=ppjiq&mode=hour&start=2023-12-07&end=2023-12-07';
////
////    fetch(apiUrl)
////        .then(response => response.json())
////        .then(data => {
////            const chartData = data.data['Date & Time'].map((dateTime, index) => {
////                const date = new Date(dateTime);
////                const hour = date.getHours();
////                // Assuming there's a direct correlation between Date & Time and Main_[kW] by their indices
////                const value = parseFloat(data.data['Main_[kW]'][index]);
////                return [date.getDay(), hour, value];
////            });
////
////            Highcharts.chart('highChartsDiv', {
////                chart: {
////                    type: 'heatmap',
////                    marginTop: 40,
////                    marginBottom: 80,
////                    plotBorderWidth: 1
////                },
////                title: {
////                    text: 'Daily Power Consumption Heatmap'
////                },
////                xAxis: {
////                    categories: ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'],
////                },
////                yAxis: {
////                    categories: ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13', '14', '15', '16', '17', '18', '19', '20', '21', '22', '23'],
////                    title: null,
////                    reversed: true
////                },
////                colorAxis: {
////                    min: 0,
////                    minColor: '#FFFFFF',
////                    maxColor: Highcharts.getOptions().colors[0]
////                },
////                legend: {
////                    align: 'right',
////                    layout: 'vertical',
////                    margin: 0,
////                    verticalAlign: 'top',
////                    y: 25,
////                    symbolHeight: 280
////                },
////                series: [{
////                    name: 'Power Consumption [kW]',
////                    borderWidth: 1,
////                    data: chartData,
////                    dataLabels: {
////                        enabled: true,
////                        color: '#000000'
////                    }
////                }]
////            });
////        })
////        .catch(error => console.error('Error fetching data:', error));
////}